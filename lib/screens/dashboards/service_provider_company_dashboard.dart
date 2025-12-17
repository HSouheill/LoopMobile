import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/agent_info_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/job_service.dart';
import '../../services/job_application_service.dart';
import '../../models/job_application.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/job_form_widget.dart';
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
  List<Job> myJobs = [];
  bool isLoadingJobs = false;
  List<JobApplication> applications = [];
  bool isLoadingApplications = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAgentInfo();
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
    });
    await _loadAgentInfo();
    await _loadMyJobs();
    await _loadApplications();
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

    // Convert myJobs to the format expected by the UI
    final jobs = myJobs.map((job) {
      // Safely extract experience range values
      final minExp = job.experienceRange['min'] ?? 0;
      final maxExp = job.experienceRange['max'] ?? 1;
      final l10n = AppLocalizations.of(context);
      
      return {
        "imageUrl": job.imageUrl,
        "title": job.title,
        "contractType": job.jobType,
        "time": l10n?.experienceYears(minExp, maxExp) ?? "Experience: $minExp-$maxExp years"
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

                  // ✅ List New Jobs Section
                  listNewJobsSection(context, screenWidth, jobs, isLoadingJobs, myJobs, _loadMyJobs),

                  applicationsSection(context, screenWidth, applications, isLoadingApplications),

                  const SizedBox(height: 20),

                  // Links Title
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

                  const SizedBox(height: 40),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left column: user info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (AppLocalizations.of(context)?.hiUser(user!.fullName)) ?? 'Hi, ${user!.fullName}',
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
                            fontSize: 10, color: Colors.blue),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.88;
    final cardHeight = 140.0;

    return Column(
      children: [
        // Active Plan Card with wavy curve design
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                // Wavy green line separator
                Positioned(
                  left: cardWidth * 0.38 - 2,
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
                            AppLocalizations.of(context)?.activePlan ?? "Active Plan:",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            agentInfo?['subscribedPlan']?['name'] ?? AppLocalizations.of(context)?.noPlan ?? 'No Plan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)?.validUntil(_formatDate(agentInfo?['user']?['planExpiresAt'])) ?? 'Valid Until: ${_formatDate(agentInfo?['user']?['planExpiresAt'])}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  "title": AppLocalizations.of(context)?.totalChats ?? "Total Chats:",
                  "value": "${agentInfo?['totalChats'] ?? 0}"
                },
                {
                  "title": AppLocalizations.of(context)?.profileViews ?? "Profile Views:",
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

// Custom clipper for curved edge on the right side of the image
class ImageCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    
    // Create a more organic, flowing wave pattern
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
      ..color = const Color(0xFF4CAF50) // Green color
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
                content: Text(AppLocalizations.of(context)?.errorUploadingFile(uploadError.toString()) ?? 'Error uploading file: ${uploadError.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.errorSelectingFile(e.toString()) ?? 'Error selecting file: ${e.toString()}'),
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
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.deletePortfolio ?? 'Delete Portfolio'),
          content: Text(l10n?.deletePortfolioConfirm ?? 'Are you sure you want to delete your portfolio PDF?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n?.delete ?? 'Delete', style: const TextStyle(color: Colors.red)),
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
                  content: Text(AppLocalizations.of(context)?.couldNotOpenPdfBrowser(url) ?? 'Could not open PDF in browser. URL: $url'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)?.urlCopiedToClipboard ?? 'Copy URL',
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        await Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)?.urlCopiedToClipboard ?? 'URL copied to clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)?.failedToCopyUrl(e.toString()) ?? 'Failed to copy URL: ${e.toString()}'),
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
              content: Text(AppLocalizations.of(context)?.errorOpeningPdf(e.toString()) ?? 'Error opening PDF: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.portfolioUrlNotAvailable ?? 'Portfolio URL is not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.noPortfolioAvailable ?? 'No portfolio available'),
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
          Text(
            AppLocalizations.of(context)?.portfolioPdf ?? "Portfolio PDF",
            style: const TextStyle(
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
                    border: Border.all(color: Colors.blue),
                  ),
                  child: InkWell(
                    onTap: _viewPortfolioPDF,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              size: 32,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              AppLocalizations.of(context)?.viewPortfolio ?? "View Portfolio",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                    buttonText: hasPortfolio 
                        ? (AppLocalizations.of(context)?.updatePortfolio ?? "Update Portfolio")
                        : (AppLocalizations.of(context)?.addNewPdf ?? "+ Add New PDF"),
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
                                  AppLocalizations.of(context)?.delete ?? "Delete",
                                  style: const TextStyle(
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
    BuildContext context, double screenWidth, List<Map<String, String>> jobs, bool isLoadingJobs, List<Job> myJobs, VoidCallback onRefresh) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)?.myJobs ?? "My Jobs",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (jobs.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/my-jobs');
                },
                child: Text(
                  AppLocalizations.of(context)?.seeAll ?? "See All",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 69, 100, 201),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoadingJobs)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (jobs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                AppLocalizations.of(context)?.noJobsPostedYet ?? "No jobs posted yet",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              job['imageUrl'] ?? 'https://via.placeholder.com/50',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.work,
                                  color: Colors.white,
                                  size: 20,
                                );
                              },
                            ),
                          ),
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
                                    Text(
                                      AppLocalizations.of(context)?.contractType ?? "Contract Type: ",
                                      style: const TextStyle(
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
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Color.fromARGB(255, 69, 100, 201),
                                ),
                                onPressed: () {
                                  // Find the corresponding job object
                                  final jobIndex = jobs.indexOf(job);
                                  if (jobIndex < myJobs.length) {
                                    final jobToEdit = myJobs[jobIndex];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobFormWidget(
                                          existingJob: jobToEdit,
                                          onSuccess: () {
                                            onRefresh(); // Refresh the jobs list
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Find the corresponding job object
                                  final jobIndex = jobs.indexOf(job);
                                  if (jobIndex < myJobs.length) {
                                    final jobToDelete = myJobs[jobIndex];
                                    _showDeleteConfirmation(context, jobToDelete, onRefresh);
                                  }
                                },
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: Colors.black,
                              ),
                            ],
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
            buttonText: AppLocalizations.of(context)?.postNewJob ?? "Post New Job",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobFormWidget(
                    onSuccess: () {
                      onRefresh(); // Refresh the jobs list
                    },
                  ),
                ),
              );
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
    BuildContext context, double screenWidth, List<JobApplication> applications, bool isLoadingApplications) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.applications ?? "Applications",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoadingApplications)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (applications.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                AppLocalizations.of(context)?.noApplicationsYet ?? "No applications yet",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          Column(
            children: applications.map((application) {
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(135, 238, 238, 238),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  application.fullName,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.experience ?? "Experience: ",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    Text(
                                      "${application.experience} years",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                if (application.title.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    application.title,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                           if (application.status == 'pending')
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: Colors.orange.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(12),
                                 border: Border.all(color: Colors.orange),
                               ),
                               child: Text(
                                 AppLocalizations.of(context)?.newBadge ?? "NEW",
                                 style: const TextStyle(
                                   color: Colors.orange,
                                   fontSize: 8,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                          const SizedBox(width: 8),
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
            buttonText: AppLocalizations.of(context)?.viewAll ?? "View All",
            onTap: () {
              Navigator.pushNamed(context, '/applications');
            },
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            textSize: 14,
          ),
        ),
      ],
    ),
  );
}

// Delete confirmation method
Future<void> _showDeleteConfirmation(BuildContext context, Job job, VoidCallback onRefresh) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(l10n?.deleteJob ?? 'Delete Job'),
        content: Text(l10n?.deleteJobConfirm(job.title) ?? 'Are you sure you want to delete "${job.title}"? This action cannot be undone.'),
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
    await _deleteJob(context, job, onRefresh);
  }
}

Future<void> _deleteJob(BuildContext context, Job job, VoidCallback onRefresh) async {
  try {
    await JobService.deleteJob(job.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.jobDeletedSuccessfully ?? 'Job deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the jobs list
      onRefresh();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.errorDeletingJob(e.toString()) ?? 'Error deleting job: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
