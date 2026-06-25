import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/agent_info_service.dart';
import '../../services/review_service.dart';
import '../../services/listing_service.dart';
import '../../models/review.dart';
import '../../environment.dart';
import './widgets/statistics_card.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/verification_banner.dart';
import '../../screens/dashboards/widgets/dynamic_service_card.dart';
import './widgets/add_social_account_card.dart';
import './widgets/inactive_listing_card_list.dart';
import './widgets/social_links_display_widget.dart';
import '../../widgets/listing_details_modal.dart';
import '../../widgets/active_plan_widget.dart';
import '../../widgets/all_plans_section.dart';

class AgentIndividualDashboardPage extends StatefulWidget {
  const AgentIndividualDashboardPage({super.key});

  @override
  State<AgentIndividualDashboardPage> createState() => _AgentIndividualDashboardPageState();
}

class _AgentIndividualDashboardPageState extends State<AgentIndividualDashboardPage> {
  User? user;
  Map<String, dynamic>? agentInfo;
  bool isLoading = true;
  List<Review> reviews = [];
  bool reviewsLoading = true;
  List<PropertyListing> inactiveListings = [];
  List<PropertyListing> activeListings = [];
  bool inactiveListingsLoading = true;
  bool activeListingsLoading = true;
  Key _activePlanKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAgentInfo();
    _loadReviews();
    _loadInactiveListings();
    _loadActiveListings();
  }

  Future<void> _loadUser() async {
    await AuthService.checkAuthStatus();
    setState(() {
      user = AuthService.currentUser;
    });
  }

  Future<void> _loadAgentInfo() async {
    try {
      final info = await AgentInfoService.getAgentInfo();
      setState(() {
        agentInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final response = await ReviewService.getMyReviews(page: 1, limit: 3);
      setState(() {
        reviews = response.reviews;
        reviewsLoading = false;
      });
    } catch (e) {
      setState(() {
        reviewsLoading = false;
      });
    }
  }

  Future<void> _loadInactiveListings() async {
    try {
      final response = await ListingService.getMyListings(
        status: 'not-active',
        page: 1,
        limit: 3,
      );
      setState(() {
        inactiveListings = response.listings;
        inactiveListingsLoading = false;
      });
    } catch (e) {
      setState(() {
        inactiveListingsLoading = false;
      });
    }
  }

  Future<void> _loadActiveListings() async {
    try {
      final response = await ListingService.getMyListings(
        status: 'active',
        page: 1,
        limit: 3,
      );
      setState(() {
        activeListings = response.listings;
        activeListingsLoading = false;
      });
    } catch (e) {
      setState(() {
        activeListingsLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      reviewsLoading = true;
      inactiveListingsLoading = true;
      activeListingsLoading = true;
    });
    await _loadAgentInfo();
    await _loadReviews();
    await _loadInactiveListings();
    await _loadActiveListings();
  }

  String _calculateDaysLeftFromCreated(DateTime? createdAt) {
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

  void _showListingDetails(PropertyListing listing) {
    showListingDetailsModal(context, listing);
  }

  // Method to refresh data when returning from edit/delete operations
  void _onListingOperationComplete() {
    _refreshData();
  }

  // Archive an active listing (from the dashboard preview).
  Future<void> _archiveByTitle(String title) async {
    final listing = activeListings.firstWhere(
      (l) => l.title == title,
      orElse: () => activeListings.first,
    );
    final result = await ListingService.archiveListing(listing.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.success) await _refreshData();
  }

  // Unarchive (re-activate) an archived listing. Blocked by the backend (403)
  // if it would exceed the plan limit — we surface that message.
  Future<void> _unarchiveByTitle(String title) async {
    final listing = inactiveListings.firstWhere(
      (l) => l.title == title,
      orElse: () => inactiveListings.first,
    );
    final result = await ListingService.unarchiveListing(listing.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.success) {
      await _refreshData();
    }
  }

  Future<void> _deleteListingFromDashboard(String listingTitle) async {
    // Find the listing by title
    final listing = activeListings.firstWhere(
      (l) => l.title == listingTitle,
      orElse: () => activeListings.first,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
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
        );
      },
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
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.listingDeletedSuccessfully ?? 'Listing deleted successfully')),
            );
            // Refresh the data
            await _refreshData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.failedToDeleteListing ?? 'Failed to delete listing')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.errorDeletingListing(e.toString()) ?? 'Error deleting listing: $e')),
          );
        }
      }
    }
  }

  Future<void> _editListingFromDashboard(String listingTitle) async {
    // Find the listing by title
    final listing = activeListings.firstWhere(
      (l) => l.title == listingTitle,
      orElse: () => activeListings.first,
    );

    // Warn that editing sends the listing back for admin re-approval.
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
    if (proceed != true || !mounted) return;

    Navigator.pushNamed(
      context,
      '/add-listing-form',
      arguments: {
        'editMode': true,
        'listing': listing,
      },
    );
  }




  Widget _buildReviewsSection() {
    if (reviewsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 103, 155, 218),
                      Color.fromARGB(255, 69, 100, 201),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Icon(
                  Icons.reviews_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  return Text(
                    AppLocalizations.of(context)?.noReviewsYet ?? 'No reviews yet',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
        return _buildReviewCard(review);
      }).toList(),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 69, 100, 201),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: review.userProfileImage.isNotEmpty
                  ? Image.network(
                      '${Environment.apiUrl}assets/${review.userProfileImage}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 69, 100, 201),
                        size: 24,
                      );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 69, 100, 201),
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: name and rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        review.userName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    _buildStars(review.rating.toDouble()),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E1E1E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Date
                Text(
                  review.formattedDate,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Split location into district and governance if it has a comma
    String district = '';
    String governance = '';
    if (user!.location != null && user!.location!.contains(',')) {
      final parts = user!.location!.split(',');
      district = parts[0].trim();
      governance = parts[1].trim();
    } else if (user!.location != null) {
      district = user!.location!;
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
            Column(
              children: [
                // AppBar background
                SizedBox(
                  height: 130,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage("assets/dashboard_background.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50), // space for avatar

                // User info + button
                userInfoAndEditButton(district, governance, context),

                // Verification status banner
                VerificationBanner(agentInfo: agentInfo),

                const SizedBox(height: 20),

                // Active Plan Widget (uses subscription API)
                ActivePlanWidget(key: _activePlanKey),

                const SizedBox(height: 20),

                // All Plans Section with pagination
                AllPlansSection(
                  onSubscriptionChanged: () {
                    setState(() {
                      _activePlanKey = UniqueKey();
                    });
                  },
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              Text(
                AppLocalizations.of(context)?.stats ?? "Stats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatCardList(
                    items: [
                      {"title": AppLocalizations.of(context)?.totalListings ?? "Total Listings:", "value": "${agentInfo?['totalListings'] ?? 0}"},
                      {"title": AppLocalizations.of(context)?.profileViews ?? "Profile Views:", "value": "${agentInfo?['user']?['profileViews'] ?? 0}"},
                      {"title": AppLocalizations.of(context)?.activeListings ?? "Active Listings:", "value": "${agentInfo?['activeListings'] ?? 0}"},
                      {"title": AppLocalizations.of(context)?.totalChats ?? "Total Chats:", "value": "${agentInfo?['totalChats'] ?? 0}"},
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: DynamicGradientButton(
                  buttonText: AppLocalizations.of(context)?.addNewListing ?? "+  Add New Listing",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/property-type-selection',
                      arguments: {'listingType': 'owner'},
                    );
                  },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textSize: 16,
                ),
              ),

              const SizedBox(height: 28),

              // NEW ROW: Inactive Listings title + See all button
              SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)?.inactiveListings ?? "Inactive Listings",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: TextButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/inactive-listings-page');
                            _onListingOperationComplete();
                          },
                          child: Text(
                            AppLocalizations.of(context)?.seeAll ?? "See all",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 69, 100, 201),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal scrollable cards
              if (inactiveListingsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (inactiveListings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.noInactiveListings ?? 'No inactive listings',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      InactiveListingCardList(
                        onItemTap: (title) {
                          // Find the listing by title and show details
                          final listing = inactiveListings.firstWhere(
                            (l) => l.title == title,
                            orElse: () => inactiveListings.first,
                          );
                          _showListingDetails(listing);
                        },
                        onActivate: (title) => _unarchiveByTitle(title),
                        items: inactiveListings.map((listing) {
                          return {
                            "daysLeft": _calculateDaysLeftFromCreated(listing.createdAt),
                            "backgroundImage": listing.imageUrl,
                            "description": listing.title,
                            "price": _extractPrice(listing.price),
                            "location": listing.location,
                            "type": listing.type ?? '',
                            "bedrooms": listing.bedrooms?.toString() ?? '',
                            "bathrooms": listing.bathrooms?.toString() ?? '',
                            "size": listing.size?.toString() ?? '',
                            "condition": listing.condition ?? '',
                            "buildingAge": listing.buildingAge?.toString() ?? '',
                            "papers": listing.papers ?? '',
                            "listingFor": listing.listingFor ?? '',
                            "currency": listing.currency ?? 'USD',
                            "status": listing.status ?? '',
                            "viewsCount": "0", // Default since not in current model
                            "favoritesCount": "0", // Default since not in current model
                            "amenities": (listing.amenityList ?? []).join(', '),
                          };
                        }).toList(),
                      )
                    ],
                  ),
                ),


              // My Listings section with "See all" button
              SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)?.myListings ?? "My Listings",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: TextButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/my-listings-page');
                            _onListingOperationComplete();
                          },
                          child: Text(
                            AppLocalizations.of(context)?.seeAll ?? "See all",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 69, 100, 201),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (activeListingsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (activeListings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.noActiveListings ?? 'No active listings',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              else
                DynamicServiceCardList(
                  items: activeListings.map((listing) {
                    return {
                      'leftText': listing.title,
                      'imageUrl': listing.imageUrl,
                      'location': listing.location,
                      'type': listing.type ?? '',
                      'bedrooms': listing.bedrooms?.toString() ?? '',
                      'bathrooms': listing.bathrooms?.toString() ?? '',
                      'size': listing.size?.toString() ?? '',
                      'condition': listing.condition ?? '',
                      'buildingAge': listing.buildingAge?.toString() ?? '',
                      'papers': listing.papers ?? '',
                      'listingFor': listing.listingFor ?? '',
                      'currency': listing.currency ?? 'USD',
                      'status': listing.status ?? '',
                      'price': listing.price,
                      'description': listing.description ?? '',
                      'amenities': (listing.amenityList ?? []).join(', '),
                    };
                  }).toList(),
                  onItemTap: (title) {
                    // Find the listing by title and show details
                    final listing = activeListings.firstWhere(
                      (l) => l.title == title,
                      orElse: () => activeListings.first,
                    );
                    _showListingDetails(listing);
                  },
                  onDelete: _deleteListingFromDashboard,
                  onEdit: _editListingFromDashboard,
                  onSold: (title) {
                    // TODO: Implement sold functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)?.soldFunctionalityNotImplemented ?? 'Sold functionality not implemented yet')),
                    );
                  },
                  onBoost: (title) {
                    // TODO: Implement boost functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)?.boostFunctionalityNotImplemented ?? 'Boost functionality not implemented yet')),
                    );
                  },
                  onArchive: _archiveByTitle,
                ),

              const SizedBox(height: 15),


              // Reviews section with "See all" button
              SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)?.ratingAndReviews ?? "Rating & Reviews",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/my-reviews');
                          },
                          child: Text(
                            AppLocalizations.of(context)?.seeAll ?? "See all",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 69, 100, 201),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildReviewsSection(),
              ),

              const SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)?.links ?? "Links",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: 0.3,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    AddSocialAccountWidget(
                      onRefresh: _refreshData,
                    ),
                    const SizedBox(height: 10),
                    // Display existing social links
                    if (agentInfo != null && agentInfo!['user'] != null && agentInfo!['user']['socialLinks'] != null)
                      SocialLinksDisplayWidget(
                        socialLinks: agentInfo!['user']['socialLinks'],
                        onRefresh: _refreshData,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // ---------------------------------
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 30,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Favorites button
            Positioned(
              top: 30,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/favorites');
                  },
                  borderRadius: BorderRadius.circular(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.favorites ?? 'Favorites',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFBA00),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Profile avatar overlapping AppBar
            Positioned(
              top: 75,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: user!.profileImage != null &&
                            user!.profileImage!.isNotEmpty
                        ? Image.network(
                            '${Environment.apiUrl}assets/${user!.profileImage!}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/defaultProfileImage.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/defaultProfileImage.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Padding userInfoAndEditButton(
      String district, String governance, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // vertical alignment
        children: [
          // Left column: user info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // fit to content height
              children: [
                // First row: Hi, firstname lastname
                Text(
                  'Hi, ${user!.fullName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Second row: district + governance
                if (district.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        governance.isNotEmpty
                            ? '$district, $governance'
                            : district,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.blue),
                      ),
                    ],
                  ),

                // Third row: city
                if (user!.city != null && user!.city!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user!.city!,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.blue),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Right: Edit Profile button
          Center(
            child: DynamicGradientButton(
              buttonText: AppLocalizations.of(context)?.editProfile ?? 'Edit Profile',
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              padding: const EdgeInsets.symmetric(
                  horizontal: 17, vertical: 5.5), // optional
            ),
          ),
        ],
      ),
    );
  }
}

// Removed AgentPlanSection and related classes - using ActivePlanWidget instead

Widget _buildStars(double rating) {
  final int full = rating.floor();
  final bool hasHalf = (rating - full) >= 0.5;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      if (i < full) {
        return const Icon(Icons.star, color: Colors.amber, size: 18);
      } else if (i == full && hasHalf) {
        return const Icon(Icons.star_half, color: Colors.amber, size: 18);
      } else {
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }
    }),
  );
}
