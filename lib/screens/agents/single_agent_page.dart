import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/recommended_agents_widget.dart';
import '../../widgets/agent_listings_reviews_widget.dart';
import '../../models/review.dart';
import '../../services/agent_service.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../models/chat.dart';
import '../chat/chat_conversation_page.dart';
import '../../widgets/agent_report_dialog.dart';

class SingleAgentPage extends StatefulWidget {
  final Agent agent;

  const SingleAgentPage({super.key, required this.agent});

  @override
  State<SingleAgentPage> createState() => _SingleAgentPageState();
}

class _SingleAgentPageState extends State<SingleAgentPage> {
  PageController _pageController = PageController();
  bool _isExpanded = false;
  AgentWithListingsAndReviews? _agentData;
  bool _isLoading = true;
  String? _error;

  // Service areas derived from the agent's own location fields (city, district,
  // governance, country). Falls back to the list-card location string while the
  // by-id data is still loading. Returns "" when nothing is available so the
  // caller can hide the row entirely.
  String get _serviceAreas {
    final parts = <String?>[
      _agentData?.city,
      _agentData?.district,
      _agentData?.governance,
      _agentData?.country,
    ].where((p) => p != null && p.trim().isNotEmpty).map((p) => p!.trim()).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return widget.agent.location.trim();
  }

  // Get all images from the agent (for now just the profile image, but can be extended)
  List<String> get _allImages {
    if (widget.agent.imageUrl.isNotEmpty) {
      return [widget.agent.imageUrl];
    }
    // Fallback to placeholder
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AgentReportDialog(
        agentId: widget.agent.id,
        agentName: widget.agent.name,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAgentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use the agent ID from the agent object
      final agentId = widget.agent.id;
      
      final agentData = await AgentService.getAgentWithReviewsAndListings(agentId);
      
      setState(() {
        _agentData = agentData;
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
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final l10n = AppLocalizations.of(context);
      final token = AuthService.token;
      if (token == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.pleaseLoginToStartChatAgent ?? 'Please log in to start a chat')),
        );
        return;
      }

      // First, try to get existing chat with the agent
      Chat? existingChat = await ChatService.getChatWithUser(token, widget.agent.id);
      
      Chat? chat = existingChat;
      
      // If no existing chat, create a new one
      if (chat == null) {
        chat = await ChatService.createChat(
          token: token,
          otherUserId: widget.agent.id,
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
              otherParticipantName: widget.agent.name,
              otherParticipantImage: widget.agent.imageUrl.isNotEmpty ? widget.agent.imageUrl : null,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.failedToStartChatAgent ?? 'Failed to start chat. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
          SnackBar(content: Text(l10n?.couldNotMakePhoneCallAgent ?? 'Could not make phone call')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making phone call: ${e.toString()}')),
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
        SnackBar(content: Text(l10n?.errorOpeningLinkAgent(e.toString()) ?? 'Error opening link: ${e.toString()}')),
      );
    }
  }

  // helper to render stars similar to screenshot (five yellow stars; partial support)
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

  // Helper method to extract city and country from location string
  String _getCityAndCountry(String location) {
    if (location.isEmpty) return location;
    
    // Split by comma and trim each part
    final parts = location.split(',').map((part) => part.trim()).toList();
    
    if (parts.isEmpty) return location;
    
    // If only one part, return it as city (or assume it's the full location)
    if (parts.length == 1) return parts[0];
    
    // Take first part as city and last part as country
    final city = parts[0];
    final country = parts[parts.length - 1];
    
    // Only show city and country if they're different, otherwise just show city
    if (city == country) {
      return city;
    }
    
    return '$city, $country';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      // set to white so no gray gap appears between header and card
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
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return IconButton(
                    icon: const Icon(Icons.flag, color: Colors.transparent, size: 0),
                    onPressed: _showReportDialog,
                    tooltip: l10n?.reportAgentTooltip ?? 'Report this agent',
                  );
                }
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image PageView
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _allImages.isNotEmpty ? _allImages.length : 1,
                    itemBuilder: (context, index) {
                      if (_allImages.isNotEmpty) {
                        return Image.network(
                          _allImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        );
                      } else {
                        return _buildPlaceholderImage();
                      }
                    },
                  ),

                  // dark gradient bottom overlay so white text is readable
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

                  // Agent avatar and details at the bottom of the image
                  Positioned(
                    left: 20,
                    bottom: 24,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Circular avatar with a white border
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
                            child: widget.agent.imageUrl.isNotEmpty
                                ? Image.network(
                                    widget.agent.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person, size: 40, color: Colors.grey);
                                    },
                                  )
                                : const Icon(Icons.person, size: 40, color: Colors.grey),
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
                                widget.agent.name,
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
                                    _getCityAndCountry(widget.agent.location),
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
                                  _buildStars(widget.agent.rating),
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
                                  AppLocalizations.of(context)?.aboutAgent ?? 'About',
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
                                if (_agentData?.phone.isNotEmpty == true)
                                  _socialIcon(
                                    icon: Icons.phone,
                                    color: Colors.green,
                                    onTap: () => _makePhoneCall(_agentData!.phone),
                                  ),
                                if (_agentData?.phone.isNotEmpty == true)
                                  const SizedBox(width: 8),
                                // Display all social links with proper icons
                                ...(_agentData?.socialLinks ?? []).map((socialLink) {
                                  final platformData = _getPlatformIconAndColor(socialLink.name);
                                  if (platformData == null) return const SizedBox.shrink();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _socialIcon(
                                      icon: platformData['icon'] as IconData,
                                      color: platformData['color'] as Color,
                                      onTap: () => _openSocialLink(socialLink.link),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.agent.customText ?? (AppLocalizations.of(context)?.noDescriptionAvailable ?? 'No description available.'),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          maxLines: _isExpanded ? null : 3,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        if ((widget.agent.customText?.length ?? 0) > 150)
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
                                    _isExpanded 
                                        ? (AppLocalizations.of(context)?.readLessAgent ?? 'Read Less')
                                        : (AppLocalizations.of(context)?.readMoreAgent ?? 'Read More'),
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

                    // Details Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)?.detailsAgent ?? 'Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Email — pull the real value from the loaded agent data.
                        // While loading (or if it failed to load) we simply omit
                        // the row instead of showing a hardcoded placeholder.
                        if ((_agentData?.email.isNotEmpty ?? false)) ...[
                          _buildDetailRow(
                            icon: Icons.email,
                            label: AppLocalizations.of(context)?.emailAgent ?? 'Email:',
                            value: _agentData!.email,
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Service areas — derive from the agent's own location
                        // fields rather than a hardcoded list.
                        if (_serviceAreas.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.map,
                            label: AppLocalizations.of(context)?.serviceAreas ?? 'Service Areas:',
                            value: _serviceAreas,
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 24),

                    // Agent Listings and Reviews Section
                    _buildAgentListingsAndReviews(),

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
                              icon: const Icon(Icons.flag, color: Colors.transparent, size: 0),
                              label: Text(
                                AppLocalizations.of(context)?.reportAgent ?? 'Report this agent',
                                style: const TextStyle(color: Colors.red)
                              ),
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

  SocialLink? _getSocialLink(String platform) {
    if (_agentData?.socialLinks == null) return null;
    try {
      return _agentData!.socialLinks.firstWhere(
        (link) => link.name.toLowerCase() == platform.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Helper function to get icon and color for a platform
  Map<String, dynamic>? _getPlatformIconAndColor(String platformName) {
    final platform = platformName.toLowerCase();
    
    switch (platform) {
      case 'facebook':
        return {
          'icon': FontAwesomeIcons.facebook,
          'color': const Color(0xFF1877F2), // Facebook blue
        };
      case 'instagram':
        return {
          'icon': FontAwesomeIcons.instagram,
          'color': const Color(0xFFE4405F), // Instagram pink/red
        };
      case 'twitter':
        return {
          'icon': FontAwesomeIcons.twitter,
          'color': const Color(0xFF1DA1F2), // Twitter blue
        };
      case 'linkedin':
        return {
          'icon': FontAwesomeIcons.linkedin,
          'color': const Color(0xFF0077B5), // LinkedIn blue
        };
      case 'youtube':
        return {
          'icon': FontAwesomeIcons.youtube,
          'color': const Color(0xFFFF0000), // YouTube red
        };
      case 'tiktok':
        return {
          'icon': FontAwesomeIcons.tiktok,
          'color': const Color(0xFF000000), // TikTok black
        };
      case 'snapchat':
        return {
          'icon': FontAwesomeIcons.snapchat,
          'color': const Color(0xFFFFFC00), // Snapchat yellow
        };
      case 'pinterest':
        return {
          'icon': FontAwesomeIcons.pinterest,
          'color': const Color(0xFFBD081C), // Pinterest red
        };
      case 'reddit':
        return {
          'icon': FontAwesomeIcons.reddit,
          'color': const Color(0xFFFF4500), // Reddit orange
        };
      case 'discord':
        return {
          'icon': FontAwesomeIcons.discord,
          'color': const Color(0xFF5865F2), // Discord blurple
        };
      case 'telegram':
        return {
          'icon': FontAwesomeIcons.telegram,
          'color': const Color(0xFF0088CC), // Telegram blue
        };
      case 'whatsapp':
        return {
          'icon': FontAwesomeIcons.whatsapp,
          'color': const Color(0xFF25D366), // WhatsApp green
        };
      default:
        return {
          'icon': Icons.link,
          'color': Colors.grey,
        };
    }
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
              child: const Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text(
                  l10n?.noProfileImage ?? 'No profile image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                );
              }
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

  Widget _buildAgentListingsAndReviews() {
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
                AppLocalizations.of(context)?.failedToLoadAgentData ?? 'Failed to load agent data',
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
                onPressed: _loadAgentData,
                child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_agentData == null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(AppLocalizations.of(context)?.noAgentDataAvailable ?? 'No agent data available'),
        ),
      );
    }

    return AgentListingsReviewsWidget(
      agent: _agentData!,
      onReviewSubmitted: _loadAgentData,
    );
  }

}
