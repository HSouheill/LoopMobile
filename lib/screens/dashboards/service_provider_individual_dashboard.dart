import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/agent_info_service.dart';
import '../../services/portfolio_service.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import 'widgets/my_services_widget.dart';
import './widgets/add_social_account_card.dart';
import './widgets/social_links_display_widget.dart';
import './widgets/statistics_card.dart';
import '../../environment.dart';

class ServiceProviderIndividualDashboardPage extends StatefulWidget {
  const ServiceProviderIndividualDashboardPage({super.key});

  @override
  State<ServiceProviderIndividualDashboardPage> createState() =>
      _ServiceProviderIndividualDashboardPageState();
}

class _ServiceProviderIndividualDashboardPageState
    extends State<ServiceProviderIndividualDashboardPage> {
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
                UserPlanSection(agentInfo: agentInfo),

                // ✅ PDF Uploaded Section
                PdfUploadedSection(agentInfo: agentInfo),

                const SizedBox(height: 30),

                // Title for all cards
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // left + right
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          AppLocalizations.of(context)?.myServices ?? "My Services",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0), // space from right edge
                        child: DynamicGradientButton(
                          buttonText: AppLocalizations.of(context)?.addService ?? "Add Service",
                          textSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          onTap: () {
                            Navigator.pushNamed(context, '/add-service');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // My Services Widget with real data and pagination
                const MyServicesWidget(),

                const SizedBox(height: 40),

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
                      Text(
                        AppLocalizations.of(context)?.activePlan ?? "Active Plan:",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        agentInfo?['subscribedPlan']?['name'] ?? (AppLocalizations.of(context)?.noPlan ?? 'No Plan'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)?.validUntil(_formatDate(agentInfo?['user']?['planExpiresAt'])) ?? 'Valid Until: ${_formatDate(agentInfo?['user']?['planExpiresAt'])}',
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
                {"title": AppLocalizations.of(context)?.totalChats ?? "Total Chats:", "value": "${agentInfo?['totalChats'] ?? 0}"},
                {"title": AppLocalizations.of(context)?.profileViews ?? "Profile Views:", "value": "${agentInfo?['user']?['profileViews'] ?? 0}"},
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Manage button
        // Center(
        //   child: DynamicGradientButton(
        //     buttonText: 'Manage Service',
        //     onTap: () {
        //       Navigator.pushNamed(context, '/edit-my-service');
        //     },
        //     padding: const EdgeInsets.symmetric(
        //         horizontal: 17, vertical: 5.5), // optional
        //   ),
        // ),
      ],
    );
  }
}

// ✅ PDF Uploaded Section
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
              final parentState = context.findAncestorStateOfType<_ServiceProviderIndividualDashboardPageState>();
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
          final parentState = context.findAncestorStateOfType<_ServiceProviderIndividualDashboardPageState>();
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        : (AppLocalizations.of(context)?.addPortfolio ?? "Add Portfolio"),
                    textSize: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
