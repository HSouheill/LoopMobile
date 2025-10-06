import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import './widgets/message_card.dart';
import './widgets/statistics_card.dart';
import './widgets/agent_list_section.dart';
import './widgets/dynamic_service_card.dart';

class AgentCompanyDashboardPage extends StatefulWidget {
  const AgentCompanyDashboardPage({super.key});

  @override
  State<AgentCompanyDashboardPage> createState() =>
      _AgentCompanyDashboardPageState();
}

class _AgentCompanyDashboardPageState extends State<AgentCompanyDashboardPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await AuthService.checkAuthStatus();
    setState(() {
      user = AuthService.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
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
      body: SingleChildScrollView(
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
                const UserPlanSection(),

                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Messages",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔎 Search Row with padding
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.search_sharp,
                              color: Color(0xFF0048FF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Search ...",
                                hintStyle: TextStyle(
                                  color: Color(
                                      0xFF0048FF), // ✅ custom placeholder color
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true, // ✅ compact
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider with less spacing
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(
                        thickness: 1,
                        height: 1,
                        color: Color(0xFF0ACC00),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // Dynamic Message Cards

                MessageCardList(
                  items: [
                    {
                      "fullName": "John Doe",
                      "message": "Hello, how are you?",
                      "date": "12:45 am",
                      "imageUrl": "",
                      "isChecked": false,
                      "unreadCount": "65", // shown only if isChecked == false
                    },
                    {
                      "fullName": "Jane Smith",
                      "message": "Let’s meet tomorrow.",
                      "date": "1:20 pm",
                      "imageUrl": "",
                      "isChecked": true,
                    },
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
                            'http://localhost:3000/api/assets/${user!.profileImage!}',
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

/// ✅ Active Plan Section (static)
class UserPlanSection extends StatelessWidget {
  const UserPlanSection({super.key});

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
                    children: const [
                      Text(
                        "Active Plan:",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Basic",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Valid Until : 06 June 2025",
                        style: TextStyle(
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
          children: const [
            StatCardList(
              items: [
                {"title": "Total Chats:", "value": "12"},
              ],
            ),
            SizedBox(width: 20), // 👈 horizontal space between the two
            StatCardList(
              items: [
                {"title": "Profile Views:", "value": "12314"},
              ],
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            StatCardList(
              items: [
                {"title": "Total Listings:", "value": "112"},
              ],
            ),
            SizedBox(width: 20),
            StatCardList(
              items: [
                {"title": "Total Agents:", "value": "5"},
              ],
            ),
          ],
        ),

        const SizedBox(height: 35),

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

        AgentListSection(
          items: [
            {
              "fullName": "Sarah Johnson",
              "status": "active",
              "imageUrl": "https://i.imgur.com/G5qWJ4p.jpeg",
              "joinedDate": "9-1-2020",
            },
            {
              "fullName": "Mark Adams",
              "status": "inactive",
              "imageUrl": "https://i.imgur.com/UM9Z7xk.jpeg",
              "joinedDate": "12-4-2021",
            },
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

        Padding(
          padding: const EdgeInsets.only(left: 16.0), // adjust as needed
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              "My Listings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ),
        ),

        DynamicServiceCardList(
          items: [
            {
              'leftText': 'Service Name1',
              'imageUrl': 'https://example.com/image1.jpg'
            },
            {
              'leftText': 'Service Name2',
              'imageUrl': 'https://example.com/image2.jpg'
            },
            {
              'leftText': 'Service Name3',
              'imageUrl': 'https://example.com/image3.jpg'
            },
          ],
        ),
      ],
    );
  }
}
