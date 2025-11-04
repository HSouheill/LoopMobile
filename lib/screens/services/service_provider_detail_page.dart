import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../models/service_provider.dart';
import '../../models/review.dart';
import '../../services/service_service.dart';
import '../../widgets/service_provider_reviews_widget.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../models/chat.dart';
import '../chat/chat_conversation_page.dart';
import 'package:loopflutter/screens/services/agent_services_page.dart';
import '../../widgets/agent_report_dialog.dart';
import '../../services/portfolio_service.dart';

class ServiceProviderDetailPage extends StatefulWidget {
  final ServiceProvider serviceProvider;

  const ServiceProviderDetailPage({super.key, required this.serviceProvider});

  @override
  State<ServiceProviderDetailPage> createState() => _ServiceProviderDetailPageState();
}

class _ServiceProviderDetailPageState extends State<ServiceProviderDetailPage> {
  PageController _pageController = PageController();
  bool _isExpanded = false;
  ServiceProviderWithReviews? _serviceProviderData;
  bool _isLoading = true;
  String? _error;

  // Get all images from the service provider (profile image + service images)
  List<String> get _allImages {
    List<String> images = [];
    
    // First priority: Add user's profile image (already assembled with full URL)
    final profileImg = widget.serviceProvider.profileImage;
    if (profileImg.isNotEmpty && !profileImg.contains('placeholder')) {
      images.add(profileImg);
    }
    
    // Return just profile image if we have it
    if (images.isNotEmpty) {
      return images;
    }
    
    // Fallback to placeholder
    return ['https://via.placeholder.com/300x200?text=No+Image'];
  }

  @override
  void initState() {
    super.initState();
    _loadServiceProviderData();
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AgentReportDialog(
        agentId: widget.serviceProvider.id,
        agentName: widget.serviceProvider.displayName,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceProviderData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use the service provider ID from the service provider object
      final serviceProviderId = widget.serviceProvider.id;
    
      final serviceProviderData = await ServiceService.getServiceProviderWithReviews(serviceProviderId);
       
      setState(() {
        _serviceProviderData = serviceProviderData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startChat() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final token = AuthService.token;
      if (token == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.pleaseLoginToStartChat ?? 'Please log in to start a chat')),
        );
        return;
      }

      // First, try to get existing chat with the service provider
      Chat? existingChat = await ChatService.getChatWithUser(token, widget.serviceProvider.id);
      
      Chat? chat = existingChat;
      
      // If no existing chat, create a new one
      if (chat == null) {
        chat = await ChatService.createChat(
          token: token,
          otherUserId: widget.serviceProvider.id,
        );
      }

      Navigator.pop(context); // Close loading dialog

      if (chat != null) {
        // Navigate to chat conversation page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(
              chat: chat!,
              otherParticipantName: widget.serviceProvider.displayName,
              otherParticipantImage: widget.serviceProvider.profileImage.isNotEmpty ? widget.serviceProvider.profileImage : null,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.failedToStartChat ?? 'Failed to start chat. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n != null ? '${l10n.failedToStartChat}: ${e.toString()}' : 'Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      final l10n = AppLocalizations.of(context);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.couldNotMakePhoneCall ?? 'Could not make phone call')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)?.couldNotMakePhoneCall ?? 'Error making phone call'}: ${e.toString()}')),
      );
    }
  }

  Future<void> _openSocialLink(String url) async {
    try {
      // Ensure the URL has a proper scheme
      String formattedUrl = url.trim();
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      
      final Uri uri = Uri.parse(formattedUrl);
      
      // Launch directly without checking canLaunchUrl
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n?.couldNotOpenLink ?? 'Error opening link'}: ${e.toString()}')),
      );
    }
  }

  Future<void> _viewPortfolioPDF() async {
    final portfolioLink = widget.serviceProvider.portfolioLink;
    if (portfolioLink.isNotEmpty) {
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
              final l10n = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n?.couldNotOpenLink ?? 'Could not open portfolio'}. URL: $url'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.errorOpeningPortfolio ?? 'Error opening portfolio'}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.noPortfolioAvailable ?? 'No portfolio available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  SocialLink? _getSocialLink(String platform) {
    if (_serviceProviderData?.socialLinks == null) return null;
    try {
      return _serviceProviderData!.socialLinks.firstWhere(
        (link) => link.name.toLowerCase() == platform.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Helper to render stars
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Image Slider AppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.flag, color: Color.fromARGB(255, 254, 0, 0)),
                onPressed: _showReportDialog,
                tooltip: AppLocalizations.of(context)?.reportServiceProviderTooltip ?? 'Report this service provider',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image PageView
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _allImages.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        _allImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      );
                    },
                  ),

                  // Dark gradient bottom overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),

                  // Top-left back button
                  Positioned(
                    left: 12,
                    top: topPadding + 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Provider details at the bottom of the image
                  Positioned(
                    left: 20,
                    bottom: 24,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Circular avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _allImages.isNotEmpty
                                ? Image.network(
                                    _allImages.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.business, size: 40, color: Colors.grey);
                                    },
                                  )
                                : const Icon(Icons.business, size: 40, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name, Location, and Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.serviceProvider.displayName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.serviceProvider.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '|',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStars(widget.serviceProvider.averageRating),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content - white rounded card
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.black, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)?.about ?? 'About',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Social media icons
                            Row(
                              children: [
                                // Phone call icon
                                if (_serviceProviderData?.phone.isNotEmpty == true)
                                  _socialIcon(
                                    icon: Icons.phone,
                                    color: Colors.green,
                                    onTap: () => _makePhoneCall(_serviceProviderData!.phone),
                                  ),
                                if (_serviceProviderData?.phone.isNotEmpty == true)
                                  const SizedBox(width: 8),
                                // Instagram icon (purple)
                                if (_getSocialLink('instagram') != null)
                                  _socialIcon(
                                    icon: Icons.camera_alt,
                                    color: Colors.purple,
                                    onTap: () => _openSocialLink(_getSocialLink('instagram')!.link),
                                  ),
                                if (_getSocialLink('instagram') != null)
                                  const SizedBox(width: 8),
                                // Facebook icon (blue)
                                if (_getSocialLink('facebook') != null)
                                  _socialIcon(
                                    icon: Icons.facebook,
                                    color: Colors.blue,
                                    onTap: () => _openSocialLink(_getSocialLink('facebook')!.link),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.serviceProvider.role == 'service-provider-company' 
                              ? (AppLocalizations.of(context)?.professionalServiceProviderDescription(
                                    widget.serviceProvider.displayName,
                                    widget.serviceProvider.city ?? '',
                                    widget.serviceProvider.country ?? '',
                                  ) ?? 'Professional ${widget.serviceProvider.displayName} providing quality services in ${widget.serviceProvider.city}, ${widget.serviceProvider.country}.')
                              : (AppLocalizations.of(context)?.individualServiceProviderDescription(
                                    widget.serviceProvider.firstName,
                                    widget.serviceProvider.lastName,
                                    widget.serviceProvider.city ?? '',
                                    widget.serviceProvider.country ?? '',
                                  ) ?? '${widget.serviceProvider.firstName} ${widget.serviceProvider.lastName} is a professional service provider based in ${widget.serviceProvider.city}, ${widget.serviceProvider.country}.'),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          maxLines: _isExpanded ? null : 3,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Text(
                                  _isExpanded ? (AppLocalizations.of(context)?.readLess ?? 'Read Less') : (AppLocalizations.of(context)?.readMore ?? 'Read More'),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 24),

                    // Services Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.work, color: Colors.black, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)?.services ?? 'Services',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgentServicesPage(
                                      agentId: widget.serviceProvider.id,
                                      agentName: widget.serviceProvider.displayName,
                                    ),
                                  ),
                                );
                              },
                              child: Text(AppLocalizations.of(context)?.seeAll ?? 'See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (widget.serviceProvider.services.isEmpty)
                          Text(
                            AppLocalizations.of(context)?.noServicesAvailable ?? 'No services available',
                            style: const TextStyle(color: Colors.grey),
                          )
                        else
                          ...widget.serviceProvider.services.map((service) => 
                            _buildServiceCard(service)
                          ).toList(),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 24),

                    // Contact Details Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.contact_phone, color: Colors.black, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)?.contactDetails ?? 'Contact Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.email,
                          label: AppLocalizations.of(context)?.email ?? 'Email:',
                          value: widget.serviceProvider.email,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.phone,
                          label: AppLocalizations.of(context)?.phone ?? 'Phone:',
                          value: widget.serviceProvider.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.location_on,
                          label: AppLocalizations.of(context)?.location ?? 'Location:',
                          value: widget.serviceProvider.location,
                        ),
                        if (widget.serviceProvider.companyName != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.business,
                            label: AppLocalizations.of(context)?.company ?? 'Company:',
                            value: widget.serviceProvider.companyName!,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 24),

                    // Portfolio Section
                    _buildPortfolioSection(),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 24),

                    // Reviews Section
                    _buildServiceProviderReviews(),

                    // Start Chat Button - now part of scrollable content
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _startChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.startChat ?? 'Start Chat',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _showReportDialog,
                              icon: const Icon(Icons.flag, color: Colors.red),
                              label: Text(AppLocalizations.of(context)?.reportServiceProvider ?? 'Report this service provider', style: const TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: service.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          service.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.work,
                              size: 24,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.work,
                        size: 24,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          service.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon({required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.business, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'No image available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 8, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label $value',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceProviderReviews() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.failedToLoadFeaturedServices ?? 'Failed to load reviews',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadServiceProviderData,
                child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_serviceProviderData == null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(AppLocalizations.of(context)?.noServiceProviderDataAvailable ?? 'No service provider data available'),
        ),
      );
    }

    return ServiceProviderReviewsWidget(
      serviceProvider: _serviceProviderData!,
      onReviewSubmitted: _loadServiceProviderData,
    );
  }

  Widget _buildPortfolioSection() {
    final l10n = AppLocalizations.of(context)!;
    final portfolioLink = widget.serviceProvider.portfolioLink;
    final hasPortfolio = portfolioLink.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.black, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.portfolio,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasPortfolio) ...[
          // Show existing portfolio
          Center(
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0048FF)),
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
                            l10n.viewPortfolio,
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
        ] else ...[
          Text(
            l10n.noPortfolioAvailable,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}
