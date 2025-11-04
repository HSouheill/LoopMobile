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
      print('Error loading agent info: $e');
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
      print('Error loading reviews: $e');
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
      print('Error loading inactive listings: $e');
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
      print('Error loading active listings: $e');
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
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.reviews_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  return Text(
                    AppLocalizations.of(context)?.noReviewsYet ?? 'No reviews yet',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
        color: const Color.fromARGB(152, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0048FF), width: 1),
            ),
            child: ClipOval(
              child: review.userProfileImage.isNotEmpty
                  ? Image.network(
                      '${Environment.apiUrl}assets/${review.userProfileImage}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF0048FF),
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: Color(0xFF0048FF),
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Container(
            padding: const EdgeInsets.only(top: 15, left: 50),
            child: Text(
              AppLocalizations.of(context)?.agentDashboard ?? "Agent Dashboard",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF82A6FF),
                  Color(0xFF487CFF),
                  Color(0xFF3770FF),
                  Color(0xFF0048FF),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.only(top: 15),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF0048FF), width: 1),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0048FF),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          titleSpacing: 0,
        ),
      ),
      // To allow scrolling for more listings, wrap the Column in a SingleChildScrollView
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)?.stats ?? "Stats",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 30),

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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  textSize: 16,
                ),
              ),

              const SizedBox(height: 20),

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
                              color: Color(0xFF1E1E1E),
                              fontWeight: FontWeight.w300,
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
                    child: Text(
                      AppLocalizations.of(context)?.noInactiveListings ?? 'No inactive listings',
                      style: TextStyle(color: Colors.grey),
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
                  Row(
                    children: [
                      Text(
                        "${agentInfo?['listingsLeft'] ?? 0}", // Use backend value for listings left
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0048FF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)?.listingsLeft ?? "Listings Left",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0048FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // Right Column
                  GestureDetector(
                    onTap: () {
                      // action for "Upgrade Plan"
                    },
                    child: Text(
                      AppLocalizations.of(context)?.upgradePlan ?? "Upgrade Plan",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEA4435),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFEA4435),
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
                              color: Color(0xFF1E1E1E),
                              fontWeight: FontWeight.w300,
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
                    child: Text(
                      AppLocalizations.of(context)?.noActiveListings ?? 'No active listings',
                      style: TextStyle(color: Colors.grey),
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
                              color: Color(0xFF1E1E1E),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildReviewsSection(),

              const SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)?.plansAndSubscription ?? "Plans & Subscription",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E1E),
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4), // spacing between the two rows
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                1), // space between border and icon
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0XFF1E1E1E), // border color
                                width: 1, // border thickness
                              ),
                            ),
                            child: const Icon(
                              Icons.priority_high,
                              size: 10,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _calculateDaysLeft(agentInfo?['user']?['planExpiresAt']),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0XFF0048FF),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            AppLocalizations.of(context)?.daysLeft ?? "days left",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0XFF0048FF),
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
                      Text(
                        agentInfo?['subscribedPlan']?['name'] ?? 'No Plan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0048FF),
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

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    AppLocalizations.of(context)?.links ?? "Links",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              Column(
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

              const SizedBox(height: 40),
              // ---------------------------------
            ],
          ),
        ),
        ),
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      width: screenWidth * 0.76,
      height: 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/serverProviderBackground.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 55, top: 15, right: 10),
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
                    width: screenWidth * 0.76 * 0.5,
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
          ],
        ),
      ),
    );
  }
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
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateBottom,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
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
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1E1E),
              ),
            ),
            Text(
              totalPaid, // dynamic number only
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
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
              height: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00666666),
                      Color(0xFF666666),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Billing History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: screenWidth * 0.27,
              height: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF666666),
                      Color(0x00666666),
                    ],
                  ),
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
          children: const [
            Text(
              "Date",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1E1E),
              ),
            ),
            Text(
              "Total Paid",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1E1E),
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
