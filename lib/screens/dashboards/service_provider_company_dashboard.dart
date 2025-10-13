import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/agent_info_service.dart';
import '../../services/portfolio_service.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import './widgets/message_card.dart';
import './widgets/statistics_card.dart';
import './widgets/add_social_account_card.dart';
import './widgets/social_links_display_widget.dart';
import '../../environment.dart';

class ServiceProviderCompanyDashboardPage extends StatefulWidget {
  const ServiceProviderCompanyDashboardPage({super.key});

  @override
  State<ServiceProviderCompanyDashboardPage> createState() =>
      _ServiceProviderCompanyDashboardPageState();
}

class _ServiceProviderCompanyDashboardPageState
    extends State<ServiceProviderCompanyDashboardPage> {
  User? user;
  Map<String, dynamic>? agentInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAgentInfo();
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

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadAgentInfo();
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

    // Example dynamic job list
    final jobs = [
      {
        "imageUrl": "https://i.imgur.com/UM9Z7xk.jpeg",
        "title": "Software Engineer",
        "contractType": "Full-Time",
        "time": "Experience: 3+ years"
      },
      {
        "imageUrl": "https://i.imgur.com/G5qWJ4p.jpeg",
        "title": "UI/UX Designer",
        "contractType": "Part-Time",
        "time": "Remote work allowed"
      },
    ];

    final applicationsList = [
      {
        "imageUrl": "https://i.imgur.com/UM9Z7xk.jpeg",
        "name": "John Doe",
        "experienceValue": "5",
        "experienceUnit": "years",
        "pdfNumber": "PDF-12345",
      },
      {
        "imageUrl": "https://i.imgur.com/G5qWJ4p.jpeg",
        "name": "Jane Smith",
        "experienceValue": "2",
        "experienceUnit": "years",
        "pdfNumber": "PDF-98765",
      },
    ];

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

                  // ✅ Active Plan Section
                  UserPlanSection(agentInfo: agentInfo),

                  // ✅ PDF Uploaded Section
                  PdfUploadedSection(agentInfo: agentInfo),

                  const SizedBox(height: 20),

                  //! Pierre has to implement Job screen
                  // ✅ List New Jobs Section
                  listNewJobsSection(context, screenWidth, jobs),

                  //! Pierre has to implement Application screen
                  applicationsSection(context, screenWidth, applicationsList),

                  const SizedBox(height: 30),

                  // Messages Title
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

                  // Search & Divider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    color: Color(0xFF0048FF),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

                  const SizedBox(height: 15),

                  // Message Cards
                  MessageCardList(
                    items: [
                      {
                        "fullName": "John Doe",
                        "message": "Hello, how are you?",
                        "date": "12:45 am",
                        "imageUrl": "",
                        "isChecked": false,
                        "unreadCount": "65",
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

                  // Links Title
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

                  // ✅ Social Links Section
                  Column(
                    children: [
                      AddSocialAccountWidget(
                        onRefresh: _refreshData,
                      ),
                      const SizedBox(height: 10),
                      // Display existing social links
                      if (agentInfo != null &&
                          agentInfo!['user'] != null &&
                          agentInfo!['user']['socialLinks'] != null)
                        SocialLinksDisplayWidget(
                          socialLinks: agentInfo!['user']['socialLinks'],
                          onRefresh: _refreshData,
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              // Back button
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
                        color: const Color(0xFF0048FF),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left column: user info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, ${user!.fullName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (district.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.business, size: 12, color: Colors.grey),
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
                if (user!.city != null && user!.city!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: Colors.grey),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 17, vertical: 5.5),
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

  const UserPlanSection({super.key, this.agentInfo});

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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatCardList(
              items: [
                {
                  "title": "Total Chats:",
                  "value": "${agentInfo?['totalChats'] ?? 0}"
                },
                {
                  "title": "Profile Views:",
                  "value": "${agentInfo?['user']?['profileViews'] ?? 0}"
                },
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// ✅ PDF Uploaded Section (matches individual dashboard)
class PdfUploadedSection extends StatefulWidget {
  final Map<String, dynamic>? agentInfo;

  const PdfUploadedSection({super.key, this.agentInfo});

  @override
  State<PdfUploadedSection> createState() => _PdfUploadedSectionState();
}

class _PdfUploadedSectionState extends State<PdfUploadedSection> {
  bool isLoading = false;

  Future<void> _uploadPortfolioPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          isLoading = true;
        });

        try {
          File file = File(result.files.single.path!);
          final response = await PortfolioService.uploadPortfolioPDF(file);

          setState(() {
            isLoading = false;
          });

          if (response['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the parent widget to update the user data without navigation
            if (context.mounted) {
              // Trigger a refresh of the parent dashboard
              final parentState = context.findAncestorStateOfType<
                  _ServiceProviderCompanyDashboardPageState>();
              if (parentState != null) {
                parentState._refreshData();
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (uploadError) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading file: ${uploadError.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePortfolioPDF() async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Portfolio'),
          content:
              const Text('Are you sure you want to delete your portfolio PDF?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      final response = await PortfolioService.deletePortfolioPDF();

      setState(() {
        isLoading = false;
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the parent widget to update the user data without navigation
        if (context.mounted) {
          // Trigger a refresh of the parent dashboard
          final parentState = context.findAncestorStateOfType<
              _ServiceProviderCompanyDashboardPageState>();
          if (parentState != null) {
            parentState._refreshData();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewPortfolioPDF() async {
    final portfolioLink = widget.agentInfo?['user']?['portfolioLink'];
    if (portfolioLink != null && portfolioLink.isNotEmpty) {
      final url = PortfolioService.getPortfolioUrl(portfolioLink);
      if (url != null) {
        try {
          final Uri uri = Uri.parse(url);

          // Launch URL in browser
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          } else {
            // Fallback: try to launch without checking canLaunchUrl
            try {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            } catch (e) {
              // Show error message with copy option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not open PDF in browser. URL: $url'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Copy URL',
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        await Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copied to clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to copy URL: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening PDF: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portfolio URL is not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No portfolio available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final portfolioLink = widget.agentInfo?['user']?['portfolioLink'];
    final hasPortfolio = portfolioLink != null && portfolioLink.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Portfolio PDF",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 20),

          if (hasPortfolio) ...[
            // Show existing portfolio
            Center(
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  width: screenWidth * 0.75,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0048FF)),
                  ),
                  child: InkWell(
                    onTap: _viewPortfolioPDF,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 32,
                              color: Colors.red,
                            ),
                            SizedBox(width: 14),
                            Text(
                              "View Portfolio",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Add/Update button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DynamicGradientButton(
                    buttonText:
                        hasPortfolio ? "Update Portfolio" : "+ Add New PDF",
                    textSize: 12,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: isLoading ? null : _uploadPortfolioPDF,
                  ),
                ),
              ),

              // Delete button (only show if portfolio exists)
              if (hasPortfolio)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : _deletePortfolioPDF,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

/// ✅ List New Jobs Section
Widget listNewJobsSection(
    BuildContext context, double screenWidth, List<Map<String, String>> jobs) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "List New Jobs",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: jobs.map((job) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  child: Container(
                    width: screenWidth * 0.90,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x570048FF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(0, 4),
                          blurRadius: 9.4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(job['imageUrl'] ??
                              'https://via.placeholder.com/50'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['title'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 0),
                              Row(
                                children: [
                                  const Text(
                                    "Contract Type: ",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xFF1E1E1E)),
                                  ),
                                  Text(
                                    job['contractType'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 0),
                              Text(
                                job['time'] ?? '',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Center(
          child: DynamicGradientButton(
            buttonText: "Post New Job",
            onTap: () {
              Navigator.pushNamed(context, '/all-jobs');
            },
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            textSize: 14,
          ),
        ),
      ],
    ),
  );
}

/// ✅ Applications Section
Widget applicationsSection(
    BuildContext context, double screenWidth, List<Map<String, String>> jobs) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Applications",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: jobs.map((job) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  child: Container(
                    width: screenWidth * 0.90,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x570048FF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(0, 4),
                          blurRadius: 9.4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name instead of Title
                              Text(
                                job['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),

                              // Experience Row
                              Row(
                                children: [
                                  const Text(
                                    "Experience: ",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  // 🔹 First dynamic text (e.g. "Senior")
                                  Text(
                                    job['experienceValue'] ??
                                        '', // <-- add a new key like "level"
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // 🔹 Existing experience (e.g. "5 years")
                                  Text(
                                    job['experienceUnit'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              // PDF Number
                              Text(
                                "PDF Number: ${job['pdfNumber'] ?? ''}",
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Center(
          child: DynamicGradientButton(
            buttonText: "View All",
            onTap: () {
              Navigator.pushNamed(context, '/applications'); // ✅ your route
            },
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            textSize: 14,
          ),
        ),
      ],
    ),
  );
}
