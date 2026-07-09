import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/listing_service.dart';
import '../dashboards/widgets/inactive_listing_card_list.dart';
import '../../widgets/listing_details_modal.dart';

// Sort options for the "See all inactive listings" screen. Values map 1:1 to
// the backend `sort` query param on GET /listings/my-listings.
enum InactiveListingSort { newest, oldest, priceLow, priceHigh }

extension _InactiveListingSortApi on InactiveListingSort {
  String get apiValue {
    switch (this) {
      case InactiveListingSort.newest:
        return 'date_desc';
      case InactiveListingSort.oldest:
        return 'date_asc';
      case InactiveListingSort.priceLow:
        return 'price_asc';
      case InactiveListingSort.priceHigh:
        return 'price_desc';
    }
  }

  String label(AppLocalizations? l10n) {
    switch (this) {
      case InactiveListingSort.newest:
        return l10n?.newestFirst ?? 'Newest First';
      case InactiveListingSort.oldest:
        return l10n?.oldestFirst ?? 'Oldest First';
      case InactiveListingSort.priceLow:
        return l10n?.priceLowToHigh ?? 'Price: Low to High';
      case InactiveListingSort.priceHigh:
        return l10n?.priceHighToLow ?? 'Price: High to Low';
    }
  }
}

// Property types offered in the filter. Keys match the backend Listing.type enum.
const List<MapEntry<String, String>> _kTypeOptions = [
  MapEntry('apartment', 'Apartment'),
  MapEntry('villa', 'Villa'),
  MapEntry('chalet', 'Chalet'),
  MapEntry('studio', 'Studio'),
  MapEntry('land', 'Land'),
  MapEntry('commercial', 'Commercial'),
  MapEntry('building', 'Building'),
  MapEntry('room', 'Room'),
  MapEntry('industrial', 'Industrial'),
  MapEntry('international', 'International'),
];

// Status sub-filter, since inactive listings mix archived + pending (+ draft).
enum InactiveStatusFilter { all, archived, pending, draft }

extension _InactiveStatusApi on InactiveStatusFilter {
  // null == the page default ('not-active'); otherwise a concrete status the
  // backend understands.
  String? get apiValue {
    switch (this) {
      case InactiveStatusFilter.all:
        return null;
      case InactiveStatusFilter.archived:
        return 'archived';
      case InactiveStatusFilter.pending:
        return 'pending';
      case InactiveStatusFilter.draft:
        return 'draft';
    }
  }

  String get label {
    switch (this) {
      case InactiveStatusFilter.all:
        return 'All';
      case InactiveStatusFilter.archived:
        return 'Archived';
      case InactiveStatusFilter.pending:
        return 'Pending';
      case InactiveStatusFilter.draft:
        return 'Draft';
    }
  }
}

class InactiveListingsPage extends StatefulWidget {
  const InactiveListingsPage({super.key});

  @override
  State<InactiveListingsPage> createState() => _InactiveListingsPageState();
}

class _InactiveListingsPageState extends State<InactiveListingsPage> {
  List<PropertyListing> listings = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 10;
  int total = 0;
  final ScrollController _scrollController = ScrollController();

  // Search + filter/sort state.
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  InactiveListingSort _sort = InactiveListingSort.newest;
  String? _typeFilter; // null == all types
  String? _listingForFilter; // null == both, else 'sale' | 'rent'
  InactiveStatusFilter _statusFilter = InactiveStatusFilter.all;

  // Monotonic token so a slow in-flight request can't overwrite newer results
  // when the user types/filters quickly.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadListings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _typeFilter != null ||
      _listingForFilter != null ||
      _statusFilter != InactiveStatusFilter.all ||
      _sort != InactiveListingSort.newest;

  // Effective status sent to the backend: the sub-filter if chosen, else the
  // page-wide 'not-active' bucket.
  String get _effectiveStatus => _statusFilter.apiValue ?? 'not-active';

  // Load the next page when nearing the bottom.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        hasMore &&
        !isLoadingMore &&
        !isLoading) {
      _loadListings();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim() == _query) return;
      _query = value.trim();
      _loadListings(refresh: true);
    });
  }

  Future<void> _loadListings({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        listings.clear();
        hasMore = true;
        isLoading = true;
      });
    }

    if ((!hasMore && !refresh) || isLoadingMore) return;
    if (!refresh) setState(() => isLoadingMore = true);

    final int myRequest = ++_requestId;
    final int pageToFetch = currentPage;

    try {
      final response = await ListingService.getMyListings(
        status: _effectiveStatus,
        page: pageToFetch,
        limit: limit,
        search: _query.isEmpty ? null : _query,
        sort: _sort.apiValue,
        type: _typeFilter,
        listingFor: _listingForFilter,
      );

      // Drop stale responses (a newer search/filter has started).
      if (!mounted || myRequest != _requestId) return;

      setState(() {
        if (refresh) {
          listings = response.listings;
        } else {
          listings.addAll(response.listings);
        }
        total = response.meta.total;
        hasMore = pageToFetch < response.meta.pages;
        currentPage = pageToFetch + 1;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted || myRequest != _requestId) return;
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.errorLoadingListings(e.toString()) ?? 'Error loading listings: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    await _loadListings(refresh: true);
  }

  Future<void> _openFilterSheet() async {
    final l10n = AppLocalizations.of(context);
    // Local copies so nothing applies until the user taps Apply.
    InactiveListingSort tmpSort = _sort;
    String? tmpType = _typeFilter;
    String? tmpListingFor = _listingForFilter;
    InactiveStatusFilter tmpStatus = _statusFilter;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Widget sectionTitle(String text) => Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                );

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle('Status'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: InactiveStatusFilter.values.map((s) {
                        return ChoiceChip(
                          label: Text(s.label),
                          selected: tmpStatus == s,
                          onSelected: (_) => setSheet(() => tmpStatus = s),
                        );
                      }).toList(),
                    ),
                    sectionTitle(l10n?.sortBy ?? 'Sort by'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: InactiveListingSort.values.map((s) {
                        return ChoiceChip(
                          label: Text(s.label(l10n)),
                          selected: tmpSort == s,
                          onSelected: (_) => setSheet(() => tmpSort = s),
                        );
                      }).toList(),
                    ),
                    sectionTitle('For'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: tmpListingFor == null,
                          onSelected: (_) =>
                              setSheet(() => tmpListingFor = null),
                        ),
                        ChoiceChip(
                          label: Text(l10n?.forSale ?? 'For Sale'),
                          selected: tmpListingFor == 'sale',
                          onSelected: (_) =>
                              setSheet(() => tmpListingFor = 'sale'),
                        ),
                        ChoiceChip(
                          label: Text(l10n?.forRent ?? 'For Rent'),
                          selected: tmpListingFor == 'rent',
                          onSelected: (_) =>
                              setSheet(() => tmpListingFor = 'rent'),
                        ),
                      ],
                    ),
                    sectionTitle('Property type'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: tmpType == null,
                          onSelected: (_) => setSheet(() => tmpType = null),
                        ),
                        ..._kTypeOptions.map((e) {
                          return ChoiceChip(
                            label: Text(e.value),
                            selected: tmpType == e.key,
                            onSelected: (_) =>
                                setSheet(() => tmpType = e.key),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheet(() {
                                tmpSort = InactiveListingSort.newest;
                                tmpType = null;
                                tmpListingFor = null;
                                tmpStatus = InactiveStatusFilter.all;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0048FF),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (applied == true) {
      setState(() {
        _sort = tmpSort;
        _typeFilter = tmpType;
        _listingForFilter = tmpListingFor;
        _statusFilter = tmpStatus;
      });
      await _loadListings(refresh: true);
    }
  }

  void _showListingDetails(PropertyListing listing) {
    showListingDetailsModal(context, listing);
  }

  // Unarchive (re-activate) an archived listing. Backend returns 403 if it would
  // exceed the plan limit — we surface that message.
  Future<void> _unarchive(PropertyListing listing) async {
    final result = await ListingService.unarchiveListing(listing.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.success) {
      await _refresh();
    }
  }

  Widget _buildSearchAndFilterBar(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                _debounce?.cancel();
                _query = v.trim();
                _loadListings(refresh: true);
              },
              decoration: InputDecoration(
                hintText: l10n?.searchPropertiesHint ?? 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          _query = '';
                          _loadListings(refresh: true);
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF3F5FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button with a dot when any filter/sort is active.
          Stack(
            children: [
              Material(
                color: const Color(0xFF0048FF),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openFilterSheet,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA4435),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool searchingOrFiltering = _query.isNotEmpty || _hasActiveFilters;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.inactiveListings ?? 'Inactive Listings'),
        backgroundColor: const Color(0xFF0048FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(l10n),
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
              child: Row(
                children: [
                  Text(
                    '$total ${total == 1 ? 'listing' : 'listings'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (searchingOrFiltering)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _debounce?.cancel();
                        setState(() {
                          _query = '';
                          _sort = InactiveListingSort.newest;
                          _typeFilter = null;
                          _listingForFilter = null;
                          _statusFilter = InactiveStatusFilter.all;
                        });
                        _loadListings(refresh: true);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: isLoading && listings.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : listings.isEmpty
                      ? _buildEmptyState(l10n, searchingOrFiltering)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          itemCount: listings.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == listings.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

                            final listing = listings[index];
                            return GestureDetector(
                              onTap: () => _showListingDetails(listing),
                              child: InactiveListingCard(
                                daysLeft:
                                    _calculateDaysLeft(listing.createdAt),
                                backgroundImage: listing.imageUrl,
                                description: listing.title,
                                price: _extractPrice(listing.price),
                                layoutType: 'B',
                                location: listing.location,
                                owner: listing.agentName,
                                status: listing.status,
                                onActivate: () => _unarchive(listing),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? l10n, bool searchingOrFiltering) {
    // Empty state must be scrollable so pull-to-refresh works.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchingOrFiltering ? Icons.search_off : Icons.inbox,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchingOrFiltering
                        ? 'No listings match your search'
                        : (l10n?.noInactiveListings ??
                            'No inactive listings found'),
                    style:
                        const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _calculateDaysLeft(DateTime? createdAt) {
    if (createdAt == null) return '0';
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference.toString();
  }

  String _extractPrice(String price) {
    // Extract numeric value from price string like "$1,200/Month"
    final regex = RegExp(r'[\d,]+');
    final match = regex.firstMatch(price);
    return match?.group(0)?.replaceAll(',', '') ?? '0';
  }
}
