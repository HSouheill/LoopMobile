import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../services/job_application_service.dart';
import '../../models/job_application.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../environment.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  List<JobApplication> applications = [];
  bool isLoading = true;
  int currentPage = 1;
  final int perPage = 5;
  int totalPages = 1;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications({bool resetPage = false}) async {
    if (resetPage) {
      currentPage = 1;
    }
    
    setState(() {
      isLoading = true;
    });

    try {
      final response = await JobApplicationService.getMyJobApplications(
        page: currentPage,
        limit: perPage,
        status: selectedStatus,
      );

      setState(() {
        applications = response.applications;
        totalPages = response.meta.pages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading applications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleStatusChange(JobApplication application, String newStatus) async {
    try {
      await JobApplicationService.updateApplicationStatus(
        applicationId: application.id,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application ${newStatus == 'accepted' ? 'accepted' : 'rejected'}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload applications
      _loadApplications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewPortfolioPDF(String portfolioLink) async {
    if (portfolioLink.isNotEmpty) {
      final url = '${Environment.apiUrl}assets/$portfolioLink';
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
            if (mounted) {
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL copied to clipboard'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Failed to copy URL: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening PDF: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portfolio URL is not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 69, 100, 201),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadApplications(),
        child: Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('All', null),
                  _buildFilterChip('Pending', 'pending'),
                  _buildFilterChip('Accepted', 'accepted'),
                  _buildFilterChip('Rejected', 'rejected'),
                ],
              ),
            ),

            // Applications list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : applications.isEmpty
                      ? const Center(child: Text('No applications found'))
                      : ListView.builder(
                          itemCount: applications.length,
                          itemBuilder: (context, index) {
                            final application = applications[index];
                            return _buildApplicationCard(application);
                          },
                        ),
            ),

            // Pagination
            if (!isLoading && applications.isNotEmpty)
              _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = selectedStatus == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedStatus = selected ? status : null;
        });
        _loadApplications(resetPage: true);
      },
      selectedColor: const Color.fromARGB(255, 69, 100, 201),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x570048FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  application.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(application.status),
            ],
          ),
          const SizedBox(height: 8),

          // Job Title
          if (application.title.isNotEmpty) ...[
            Text(
              application.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 69, 100, 201),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Details
          _buildDetailRow(Icons.email_outlined, application.email),
          _buildDetailRow(Icons.phone_outlined, application.phone),
          _buildDetailRow(
            Icons.work_outline,
            '${application.experience} years experience',
          ),
          _buildDetailRow(
            Icons.attach_money_outlined,
            'Expected salary: ${application.expectedSalary}',
          ),

          // Portfolio Section
          const SizedBox(height: 12),
          _buildPortfolioSection(application.portfolio),

          const SizedBox(height: 12),

          // Action buttons
          if (application.status == 'pending') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showRejectConfirmation(application),
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                DynamicGradientButton(
                  buttonText: 'Accept',
                  onTap: () => _handleStatusChange(application, 'accepted'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPortfolioSection(String? portfolioLink) {
    final hasPortfolio = portfolioLink != null && portfolioLink.isNotEmpty;
    
    String? linkToUse = hasPortfolio ? portfolioLink : null;
    
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: InkWell(
        onTap: linkToUse != null
            ? () => _viewPortfolioPDF(linkToUse)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasPortfolio 
                ? const Color.fromARGB(255, 69, 100, 201)
                : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    hasPortfolio ? Icons.picture_as_pdf : Icons.work_off_outlined,
                    size: 32,
                    color: hasPortfolio ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    hasPortfolio ? "View Portfolio" : "No portfolio provided",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasPortfolio ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (hasPortfolio)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRejectConfirmation(JobApplication application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Text('Are you sure you want to reject ${application.fullName}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _handleStatusChange(application, 'rejected');
    }
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () {
                    setState(() => currentPage--);
                    _loadApplications();
                  }
                : null,
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() => currentPage++);
                    _loadApplications();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

