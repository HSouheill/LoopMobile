import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/agent_info_service.dart';
import '../../services/agent_service.dart';
import '../../services/listing_service.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import './widgets/statistics_card.dart';
import './widgets/agent_list_section.dart';
import './widgets/dynamic_service_card.dart';
import './widgets/add_social_account_card.dart';
import './widgets/social_links_display_widget.dart';
import './widgets/inactive_listing_card_list.dart';
import '../../widgets/listing_details_modal.dart';
import '../../environment.dart';

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
  List<Map<String, dynamic>> myAgents = [];
  bool myAgentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAgentInfo();
    _loadInactiveListings();
    _loadActiveListings();
    _loadMyAgents();
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

  Future<void> _loadMyAgents() async {
    try {
      final response = await AgentService.getMyAgents(page: 1, limit: 3);
      setState(() {
        myAgents = List<Map<String, dynamic>>.from(response['agents'] ?? []);
        myAgentsLoading = false;
      });
    } catch (e) {
      setState(() {
        myAgentsLoading = false;
      });
      print('Error loading my agents: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      inactiveListingsLoading = true;
      activeListingsLoading = true;
      myAgentsLoading = true;
    });
    await _loadAgentInfo();
    await _loadInactiveListings();
    await _loadActiveListings();
    await _loadMyAgents();
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

                // ✅ New Active Plan section
                UserPlanSection(
                  agentInfo: agentInfo, 
                  onRefresh: _refreshData,
                  myAgents: myAgents,
                  myAgentsLoading: myAgentsLoading,
                  onAgentUpdated: _refreshData,
                ),

                const SizedBox(height: 40),

                // Inactive Listings section
                SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "Inactive Listings",
                          style: TextStyle(
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
                              Navigator.pushNamed(context, '/inactive-listings-page');
                            },
                            child: const Text(
                              "See all",
                              style: TextStyle(
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
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No inactive listings',
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

                const SizedBox(height: 20),

                // My Listings section with "See all" button
                SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "My Listings",
                          style: TextStyle(
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
                              Navigator.pushNamed(context, '/my-listings-page');
                            },
                            child: const Text(
                              "See all",
                              style: TextStyle(
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
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No active listings',
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
                  ),

                const SizedBox(height: 30),

                // Links section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Links",
                      style: TextStyle(
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
                const SizedBox(height: 20),
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
                      color: Color(0xFF0048FF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF0048FF),
                      size: 16,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    color: const Color(0xFF0048FF),
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
                            fontSize: 10, color: Color(0xFF0048FF)),
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
                            fontSize: 10, color: Color(0xFF0048FF)),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Right: Edit Profile button
          Center(
            child: DynamicGradientButton(
              buttonText: 'Edit Profile',
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

/// ✅ Active Plan Section (dynamic)
class UserPlanSection extends StatelessWidget {
  final Map<String, dynamic>? agentInfo;
  final VoidCallback? onRefresh;
  final List<Map<String, dynamic>> myAgents;
  final bool myAgentsLoading;
  final VoidCallback? onAgentUpdated;
  
  const UserPlanSection({
    super.key, 
    this.agentInfo, 
    this.onRefresh,
    required this.myAgents,
    required this.myAgentsLoading,
    this.onAgentUpdated,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Active Plan Card
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          width: 250,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Background image (now clipped to rounded corners)
                Positioned.fill(
                  child: Image.asset(
                    "assets/serverProviderBackground.png",
                    fit: BoxFit.cover,
                  ),
                ),

                // Optional gradient overlay for readability
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

                // Text info
                Padding(
                  padding: const EdgeInsets.only(left: 75, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Active Plan:",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        agentInfo?['subscribedPlan']?['name'] ?? 'No Plan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Valid Until: ${_formatDate(agentInfo?['user']?['planExpiresAt'])}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatCardList(
              items: [
                {"title": "Total Chats:", "value": "${agentInfo?['totalChats'] ?? 0}"},
                {"title": "Profile Views:", "value": "${agentInfo?['user']?['profileViews'] ?? 0}"},
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.only(left: 16.0), // adjust as needed
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Agents",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Agents section with loading and see all
        if (myAgentsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (myAgents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No agents found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: [
              AgentListSection(
                items: myAgents.map((agent) {
                  return {
                    "fullName": "${agent['firstName'] ?? ''} ${agent['lastName'] ?? ''}".trim(),
                    "imageUrl": agent['profileImage'] != null && agent['profileImage'].toString().isNotEmpty
                        ? '${Environment.apiUrl}assets/${agent['profileImage']}'
                        : null, // Use null to trigger placeholder in AgentListSection
                    "joinedDate": agent['createdAt'] != null 
                        ? DateTime.parse(agent['createdAt']).toString().split(' ')[0]
                        : "N/A",
                    "_id": agent['_id'], // Add agent ID for editing
                    "firstName": agent['firstName'],
                    "lastName": agent['lastName'],
                    "email": agent['email'],
                    "phone": agent['phone'],
                    "role": agent['role'],
                    "companyName": agent['companyName'],
                    "description": agent['description'],
                    "DOB": agent['DOB'],
                    "gender": agent['gender'],
                    "profileImage": agent['profileImage'],
                    "country": agent['country'],
                    "governance": agent['governance'],
                    "district": agent['district'],
                    "city": agent['city'],
                    "isFeatured": agent['isFeatured'],
                    "portfolioLink": agent['portfolioLink'],
                    "socialLinks": agent['socialLinks'],
                  };
                }).toList(),
                onAgentUpdated: onAgentUpdated,
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/my-agents-page');
                  },
                  child: const Text(
                    "See all agents",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 15),

        Center(
          child: DynamicGradientButton(
            buttonText: "+ Add New Agent",
            onTap: () {
              Navigator.pushNamed(context, '/add-new-agent');
            },
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            textSize: 16,
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
