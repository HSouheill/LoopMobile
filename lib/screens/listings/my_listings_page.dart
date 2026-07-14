import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/listing_service.dart';
import '../../widgets/boost_days_sheet.dart';
import '../../widgets/refresh_listing_sheet.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/listing_image_widget.dart';
import '../../widgets/listing_details_modal.dart';

// Sort options for the "See all my listings" screen. Values map 1:1 to the
// backend `sort` query param on GET /listings/my-listings.
enum ListingSort { newest, oldest, priceLow, priceHigh }

extension _ListingSortApi on ListingSort {
  String get apiValue {
    switch (this) {
      case ListingSort.newest:
        return 'date_desc';
      case ListingSort.oldest:
        return 'date_asc';
      case ListingSort.priceLow:
        return 'price_asc';
      case ListingSort.priceHigh:
        return 'price_desc';
    }
  }

  String label(AppLocalizations? l10n) {
    switch (this) {
      case ListingSort.newest:
        return l10n?.newestFirst ?? 'Newest First';
      case ListingSort.oldest:
        return l10n?.oldestFirst ?? 'Oldest First';
      case ListingSort.priceLow:
        return l10n?.priceLowToHigh ?? 'Price: Low to High';
      case ListingSort.priceHigh:
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

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
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
  ListingSort _sort = ListingSort.newest;
  String? _typeFilter; // null == all types
  String? _listingForFilter; // null == both, else 'sale' | 'rent'

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
      _sort != ListingSort.newest;

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
        status: 'active',
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
    ListingSort tmpSort = _sort;
    String? tmpType = _typeFilter;
    String? tmpListingFor = _listingForFilter;

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
                    sectionTitle(l10n?.sortBy ?? 'Sort by'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ListingSort.values.map((s) {
                        final selected = tmpSort == s;
                        return ChoiceChip(
                          label: Text(s.label(l10n)),
                          selected: selected,
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
                          final selected = tmpType == e.key;
                          return ChoiceChip(
                            label: Text(e.value),
                            selected: selected,
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
                                tmpSort = ListingSort.newest;
                                tmpType = null;
                                tmpListingFor = null;
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
      });
      await _loadListings(refresh: true);
    }
  }

  void _showListingDetails(PropertyListing listing) {
    showListingDetailsModal(context, listing);
  }

  Future<void> _deleteListing(PropertyListing listing) async {
    final l10n = AppLocalizations.of(context);
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteListing ?? 'Delete Listing'),
        content: Text(l10n?.deleteListingConfirm(listing.title) ?? 'Are you sure you want to delete "${listing.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final success = await ListingService.deleteListing(listing.id);
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog

        final l10n = AppLocalizations.of(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.listingDeletedSuccessfully ?? 'Listing deleted successfully')),
          );
          // Refresh the listings
          await _refresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.failedToDeleteListing ?? 'Failed to delete listing')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.errorDeletingListing(e.toString()) ?? 'Error deleting listing: $e')),
        );
      }
    }
  }

  Future<void> _archiveListing(PropertyListing listing) async {
    final result = await ListingService.archiveListing(listing.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    if (result.success) await _refresh();
  }

  Future<void> _boostListing(PropertyListing listing) async {
    final result = await BoostDaysSheet.show(
      context,
      targetType: 'listing',
      targetId: listing.id,
      targetLabel: listing.title.isNotEmpty ? '“${listing.title}”' : 'this listing',
      currentFeaturedUntil: listing.featuredUntil,
    );
    // On a successful boost, refresh so the featured state is reflected.
    if (result != null && mounted) {
      await _refresh();
    }
  }

  Future<void> _refreshListing(PropertyListing listing) async {
    final result = await RefreshListingSheet.show(
      context,
      listingId: listing.id,
      listingLabel:
          listing.title.isNotEmpty ? '“${listing.title}”' : 'this listing',
    );
    // The listing's date changed, so reload to show it in its new queue position.
    if (result != null && mounted) {
      await _refresh();
    }
  }

  Future<void> _editListing(PropertyListing listing) async {
    // Warn that editing sends the listing back to admin for re-approval.
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit listing?'),
        content: const Text(
          'Editing this listing will send it back for admin approval, so it will be temporarily hidden until re-approved. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (proceed != true) return;

    Navigator.pushNamed(
      context,
      '/add-listing-form',
      arguments: {
        'editMode': true,
        'listing': listing,
      },
    );
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
        title: Text(l10n?.myListings ?? 'My Listings'),
        backgroundColor: const Color(0xFF0048FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(l10n),
          // Result count / active-filter hint.
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
                          _sort = ListingSort.newest;
                          _typeFilter = null;
                          _listingForFilter = null;
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
                              child: MyListingCard(
                                listing: listing,
                                onSold: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n?.soldFunctionalityNotImplemented ?? 'Sold functionality not implemented yet')),
                                  );
                                },
                                onDelete: () => _deleteListing(listing),
                                onArchive: () => _archiveListing(listing),
                                onBoost: () => _boostListing(listing),
                                onRefresh: () => _refreshListing(listing),
                                onEdit: () => _editListing(listing),
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
                        : (l10n?.noActiveListings ?? 'No active listings found'),
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
}

class MyListingCard extends StatefulWidget {
  final PropertyListing listing;
  final VoidCallback onSold;
  final VoidCallback onDelete;
  final VoidCallback onBoost;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const MyListingCard({
    super.key,
    required this.listing,
    required this.onSold,
    required this.onDelete,
    required this.onBoost,
    required this.onRefresh,
    required this.onEdit,
    required this.onArchive,
  });

  @override
  State<MyListingCard> createState() => _MyListingCardState();
}

class _MyListingCardState extends State<MyListingCard> {
  bool boostPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
      child: Column(
        children: [
          // First row: title only (removed views/saves)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.listing.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: image + buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              ListingImageWidget(
                imageUrl: widget.listing.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                placeholderIcon: Icons.home,
                placeholderIconSize: 30,
              ),
              const SizedBox(width: 12),

              // Buttons. Sold is intentionally hidden (handler kept for easy
              // re-enable). Active-listing actions are Boost + Delete (left) and
              // Edit/Archive (right).
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: DynamicGradientButton(
                              buttonText: 'Boost',
                              onTap: widget.onBoost,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: DynamicGradientButton(
                              buttonText: AppLocalizations.of(context)?.delete ?? 'Delete',
                              onTap: widget.onDelete,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              useGradient: false,
                              backgroundColor: const Color(0xFFF9FBFF),
                              borderColor: const Color(0xFFEA4435),
                              borderWidth: 1.0,
                              textColor: const Color(0xFFEA4435),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: DynamicGradientButton(
                              buttonText: AppLocalizations.of(context)?.editButton ?? 'Edit',
                              onTap: widget.onEdit,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: DynamicGradientButton(
                              buttonText: 'Archive',
                              onTap: widget.onArchive,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              useGradient: false,
                              backgroundColor: const Color(0xFFF9FBFF),
                              borderColor: const Color(0xFF6B7280),
                              borderWidth: 1.0,
                              textColor: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Refresh: spends 1 refresh to bump this listing back to the top of
          // the queue. Reusable on the same listing as often as the user likes.
          SizedBox(
            width: double.infinity,
            child: DynamicGradientButton(
              buttonText: 'Refresh',
              onTap: widget.onRefresh,
              padding: const EdgeInsets.symmetric(vertical: 8),
              useGradient: false,
              backgroundColor: const Color(0xFFF9FBFF),
              borderColor: const Color(0xFF0048FF),
              borderWidth: 1.0,
              textColor: const Color(0xFF0048FF),
            ),
          ),
        ],
      ),
    );
  }
}
