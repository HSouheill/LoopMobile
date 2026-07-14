import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/agent_info_service.dart';
import '../../services/listing_service.dart';
import '../../services/job_service.dart';
import '../../services/job_application_service.dart';
import '../../models/job_application.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/verification_banner.dart';
import './widgets/statistics_card.dart';
import './widgets/dynamic_service_card.dart';
import './widgets/add_social_account_card.dart';
import './widgets/social_links_display_widget.dart';
import './widgets/inactive_listing_card_list.dart';
import '../../widgets/listing_details_modal.dart';
import '../../environment.dart';
import '../../widgets/active_plan_widget.dart';
import '../../widgets/all_plans_section.dart';
import '../../widgets/boost_wallet_widget.dart';
import '../../widgets/refresh_wallet_widget.dart';
import 'service_provider_company_dashboard.dart'
    show listNewJobsSection, applicationsSection;

class AgentCompanyDashboardPage extends StatefulWidget {
  const AgentCompanyDashboardPage({super.key});

  @override
  State<AgentCompanyDashboardPage> createState() =>
      _AgentCompanyDashboardPageState();
}

class _AgentCompanyDashboardPageState extends State<AgentCompanyDashboardPage> {
  User? user;
  Map<String, dynamic>? agentInfo;
  bool isLoading = true;
  List<PropertyListing> inactiveListings = [];
  List<PropertyListing> activeListings = [];
  bool inactiveListingsLoading = true;
  bool activeListingsLoading = true;
  List<Job> myJobs = [];
  bool isLoadingJobs = false;
  List<JobApplication> applications = [];
  bool isLoadingApplications = false;
  Key _activePlanKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAgentInfo();
    _loadInactiveListings();
    _loadActiveListings();
    _loadMyJobs();
    _loadApplications();
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


  Future<void> _loadMyJobs() async {
    setState(() {
      isLoadingJobs = true;
    });
    try {
      final response = await JobService.getMyJobs(page: 1, limit: 3);
      setState(() {
        myJobs = response.jobs;
        isLoadingJobs = false;
      });
    } catch (e) {
      setState(() {
        isLoadingJobs = false;
      });
    }
  }

  Future<void> _loadApplications() async {
    setState(() {
      isLoadingApplications = true;
    });
    try {
      final response = await JobApplicationService.getMyJobApplications(
        page: 1,
        limit: 3,
      );
      setState(() {
        applications = response.applications;
        isLoadingApplications = false;
      });
    } catch (e) {
      setState(() {
        isLoadingApplications = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      inactiveListingsLoading = true;
      activeListingsLoading = true;
    });
    await _loadAgentInfo();
    await _loadInactiveListings();
    await _loadActiveListings();
    await _loadMyJobs();
    await _loadApplications();
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

  // Unarchive (re-activate) an archived listing; backend blocks (403) if over plan limit.
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
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.errorDeletingListing(e.toString()) ?? 'Error deleting listing: $e')),
        );
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

  @override
  Widget build(BuildContext context) {
    if (user == null || isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;

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

    // Convert myJobs to the format expected by the shared jobs section
    final jobs = myJobs.map((job) {
      final minExp = job.experienceRange['min'] ?? 0;
      final maxExp = job.experienceRange['max'] ?? 1;
      final l10n = AppLocalizations.of(context);

      return {
        "imageUrl": job.imageUrl,
        "title": job.title,
        "contractType": job.jobType,
        "time": l10n?.experienceYears(minExp, maxExp) ??
            "Experience: $minExp-$maxExp years",
        "status": job.status,
      };
    }).toList();

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
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    // Subtle white shadow along the top edge only
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.25],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50), // space for avatar

                // User info + button
                userInfoAndEditButton(district, governance, context),

                // Verification status banner
                VerificationBanner(agentInfo: agentInfo),

                // ✅ Active Plan section (uses subscription API)
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

                // Boost Days Wallet (buy boost-day packages)
                const BoostWalletWidget(
                    boostableItems: 'profile, listings and jobs'),

                // Refreshes (bump a listing back to the top of the queue)
                const RefreshWalletWidget(),

                const SizedBox(height: 40),

                // Inactive Listings section
                SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                       Center(
                        child: Builder(
                          builder: (context) {
                            return Text(
                              AppLocalizations.of(context)?.inactiveListings ?? "Inactive Listings",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                              ),
                            );
                          }
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

                // Horizontal scrollable cards for inactive listings
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
                        const SnackBar(content: Text('Sold functionality not implemented yet')),
                      );
                    },
                    onBoost: (title) {
                      // TODO: Implement boost functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Boost functionality not implemented yet')),
                      );
                    },
                    onArchive: _archiveByTitle,
                  ),

                const SizedBox(height: 10),

                // My Jobs section (post/edit/delete jobs, same as company service providers)
                listNewJobsSection(
                    context, screenWidth, jobs, isLoadingJobs, myJobs, _loadMyJobs),

                // Applications received on this company's jobs
                applicationsSection(
                    context, screenWidth, applications, isLoadingApplications),

                const SizedBox(height: 20),

                // Links section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppLocalizations.of(context)?.links ?? "Links",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
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
              ],
            ),

            Positioned(
              top: 45,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
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

            // Favorites button moved out of header into userInfoAndEditButton (below Edit Profile)

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
                //! It is only displaying firstName, we need to display lastname also
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

          // Right: Edit Profile button with Favorites stacked below it
          IntrinsicWidth(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DynamicGradientButton(
                buttonText: AppLocalizations.of(context)?.editProfile ?? 'Edit Profile',
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                padding: const EdgeInsets.symmetric(
                    horizontal: 17, vertical: 5.5), // optional
              ),
              const SizedBox(height: 8),
              _favoritesButton(context),
            ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _favoritesButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/favorites');
      },
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5.5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.favorites ?? 'Favorites',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
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
    );
  }
}

// Removed UserPlanSection and related classes - using ActivePlanWidget instead
