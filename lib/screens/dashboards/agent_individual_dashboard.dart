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
import '../../screens/dashboards/widgets/dynamic_service_card.dart';
import './widgets/add_social_account_card.dart';
import './widgets/inactive_listing_card_list.dart';
import './widgets/social_links_display_widget.dart';
import '../../widgets/listing_details_modal.dart';

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
        status: 'pending',
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

  String _calculateDaysLeft(String? planExpiresAt) {
    if (planExpiresAt == null) return '0';
    try {
      final expiryDate = DateTime.parse(planExpiresAt);
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;
      return difference > 0 ? difference.toString() : '0';
    } catch (e) {
      return '0';
    }
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

  void _editListingFromDashboard(String listingTitle) {
    // Find the listing by title
    final listing = activeListings.firstWhere(
      (l) => l.title == listingTitle,
      orElse: () => activeListings.first,
    );

    // Navigate to edit listing page with the listing data
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

  List<Widget> _buildPlanCards() {
    final allPlans = agentInfo?['allPlans'] as List<dynamic>?;
    if (allPlans == null || allPlans.isEmpty) {
      return planCards; // fallback to static cards
    }

    return allPlans.map((plan) {
      return AgentPlanSection(
        planTitle: plan['name'] ?? 'Unknown Plan',
        planDescription: plan['description'] ?? 'No description available',
        stats: [
          PlanStat(icon: Icons.list_alt_sharp, value: "${plan['listings'] ?? 0}", label: "Listings"),
          PlanStat(icon: Icons.calendar_month_outlined, value: "${plan['length'] ?? 0}", label: "Days"),
          PlanStat(icon: Icons.currency_exchange, value: "\$", label: "${plan['price'] ?? 0}"),
        ],
      );
    }).toList();
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
                            AssetImage("assets/serverProviderBackground.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50), // space for avatar

                // User info + button
                userInfoAndEditButton(district, governance, context),

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

              // ---------------------------------
              // NEW ROW: Listings Left + Upgrade Plan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left Column
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 103, 155, 218),
                          Color.fromARGB(255, 69, 100, 201),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${agentInfo?['listingsLeft'] ?? 0}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)?.listingsLeft ?? "Listings Left",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Column
                  GestureDetector(
                    onTap: () {
                      // action for "Upgrade Plan"
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        AppLocalizations.of(context)?.upgradePlan ?? "Upgrade Plan",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEA4435),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFEA4435),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                AppLocalizations.of(context)?.plansAndSubscription ?? "Plans & Subscription",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // 👈 Align children at the top
                children: [
                  // First Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.currentSubscription ?? "Current Subscription",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
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
                              Icons.priority_high,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _calculateDaysLeft(agentInfo?['user']?['planExpiresAt']),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 69, 100, 201),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)?.daysLeft ?? "days left",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 69, 100, 201),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(width: MediaQuery.of(context).size.width * 0.32),

                  // Wrap plan name in a Column to respect top alignment
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 103, 155, 218),
                              Color.fromARGB(255, 69, 100, 201),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          agentInfo?['subscribedPlan']?['name'] ?? 'No Plan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Column(
                children: _buildPlanCards(),
              ),

              const SizedBox(height: 15),

              Column(
                children: [
                  const SizedBox(height: 4), // spacing between rows

                  const SizedBox(height: 15),
                  billingHistorySection(context),
                  const SizedBox(height: 20),
                ],
              ),

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
              child: SizedBox(
                width: 30,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.blue,
                      size: 16,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
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

class AgentPlanSection extends StatelessWidget {
  final String planTitle;
  final String planDescription;
  final List<PlanStat> stats; // list of dynamic stat items

  const AgentPlanSection({
    super.key,
    required this.planTitle,
    required this.planDescription,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.88;
    final cardHeight = 140.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image on the left with curved edge clipping
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: cardWidth * 0.38,
              child: ClipPath(
                clipper: ImageCurvedClipper(),
                child: Image.asset(
                  "assets/serverProviderBackground.png",
                  fit: BoxFit.cover,
                  width: cardWidth * 0.38,
                  height: cardHeight,
                ),
              ),
            ),
            // Wavy green line separator - moved to align with the curve
            Positioned(
              left: cardWidth * 0.38 - 2, // Slight overlap for smooth transition
              top: 0,
              bottom: 0,
              width: 6,
              child: CustomPaint(
                painter: WavyLinePainter(),
                child: Container(),
              ),
            ),
            // Blue gradient overlay on the right
            Positioned(
              left: cardWidth * 0.38,
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 103, 155, 218),
                      Color.fromARGB(255, 69, 100, 201),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15, right: 10, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        planTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: cardWidth * 0.5,
                        child: Text(
                          planDescription,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: stats
                            .map(
                              (stat) => _PlanStatRowItem(
                                icon: stat.icon,
                                value: stat.value,
                                label: stat.label,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for curved edge on the right side of the image
class ImageCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    
    // Create a more organic, flowing wave pattern
    // These control points create the specific curve from your image
    final waveAmplitude = size.height * 0.15;
    
    // First wave (top curve)
    path.cubicTo(
      size.width + waveAmplitude, size.height * 0.15,
      size.width + waveAmplitude * 0.8, size.height * 0.35,
      size.width, size.height * 0.5,
    );
    
    // Second wave (middle dip)
    path.cubicTo(
      size.width - waveAmplitude * 0.6, size.height * 0.65,
      size.width - waveAmplitude * 0.4, size.height * 0.8,
      size.width, size.height,
    );
    
    // Complete the path
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom painter for wavy green line
class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50) // Green color from the image
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // Create a wavy line that follows the same curve pattern
    final waveHeight = size.height * 0.12;
    final waveCount = 2;
    final segmentHeight = size.height / waveCount;
    
    path.moveTo(size.width / 2, 0);
    
    for (int i = 0; i < waveCount; i++) {
      final startY = i * segmentHeight;
      final endY = startY + segmentHeight;
      
      // Create a smooth wavy curve
      path.cubicTo(
        size.width / 2 + waveHeight * 0.5, startY + segmentHeight * 0.25,
        size.width / 2 + waveHeight * 0.5, startY + segmentHeight * 0.75,
        size.width / 2, endY,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Data model for each stat
class PlanStat {
  final IconData icon;
  final String value;
  final String label;

  PlanStat({required this.icon, required this.value, required this.label});
}

/// 👇 Each column item is now horizontal
class _PlanStatRowItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PlanStatRowItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

final List<AgentPlanSection> planCards = [
  AgentPlanSection(
    planTitle: "Basic",
    planDescription: "For Freelancers or Self-employed Providers",
    stats: [
      PlanStat(icon: Icons.list_alt_sharp, value: "4", label: "Listings"),
      PlanStat(icon: Icons.calendar_month_outlined, value: "5", label: "Days"),
      PlanStat(icon: Icons.currency_exchange, value: "\$", label: "19"),
    ],
  ),
  AgentPlanSection(
    planTitle: "Standard",
    planDescription: "Ideal for Small Agencies with Moderate Needs",
    stats: [
      PlanStat(icon: Icons.list_alt_sharp, value: "12", label: "Listings"),
      PlanStat(icon: Icons.calendar_month_outlined, value: "30", label: "Days"),
      PlanStat(icon: Icons.currency_exchange, value: "\$", label: "49"),
    ],
  ),
  AgentPlanSection(
    planTitle: "Unlimited",
    planDescription: "For High-volume Professionals & Teams",
    stats: [
      PlanStat(icon: Icons.list_alt_sharp, value: "12", label: "Listings"),
      PlanStat(icon: Icons.calendar_month_outlined, value: "30", label: "Days"),
      PlanStat(icon: Icons.currency_exchange, value: "\$", label: "49"),
    ],
  ),
];


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


// Payment model
class Payment {
  final String totalPaid; // left text
  final String dateTop; // top text on right column
  final String dateBottom; // bottom text on right column

  Payment({
    required this.totalPaid,
    required this.dateTop,
    required this.dateBottom,
  });
}

// Sample payment list
final List<Payment> payments = [
  Payment(totalPaid: "900", dateTop: "12 Oct 2025", dateBottom: "12:32 pm"),
  Payment(totalPaid: "700", dateTop: "15 Oct 2025", dateBottom: "12:32 pm"),
  Payment(totalPaid: "1500", dateTop: "20 Oct 2025", dateBottom: "12:32 pm"),
];

// Build each payment row
Widget buildPaymentRow({
  required BuildContext context,
  required String totalPaid,
  required String dateTop,
  required String dateBottom,
  double horizontalPaddingPercent = 0.1,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * horizontalPaddingPercent,
        vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateTop,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateBottom,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ],
        ),

        // Right Column: Total Paid (static $ + dynamic value)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "\$",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 69, 100, 201),
              ),
            ),
            Text(
              totalPaid, // dynamic number only
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 69, 100, 201),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Billing History Section (headers swapped)
// Billing History Section (aligned like Payment row)
Widget billingHistorySection(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Column(
    children: [
      // Title with gradient lines
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: screenWidth * 0.27,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color.fromARGB(255, 69, 100, 201),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Billing History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: screenWidth * 0.27,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 69, 100, 201),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 8),

      // Header row: align like the payment rows
      Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Date",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color.fromARGB(255, 69, 100, 201),
              ),
            ),
            Text(
              "Total Paid",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color.fromARGB(255, 69, 100, 201),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 4),

      // Payment rows (aligned same way)
      Column(
        children: payments
            .map((p) => buildPaymentRow(
                  context: context,
                  totalPaid: p.totalPaid,
                  dateTop: p.dateTop,
                  dateBottom: p.dateBottom,
                  horizontalPaddingPercent: 0.1, // same as header
                ))
            .toList(),
      ),
    ],
  );
}
