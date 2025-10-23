import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

      final token = AuthService.token;
      if (token == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to start a chat')),
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
          const SnackBar(content: Text('Failed to start chat. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.flag, color: Color.fromARGB(255, 254, 0, 0)),
                onPressed: _showReportDialog,
                tooltip: 'Report this agent',
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
                                    widget.agent.location,
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
                                const Text(
                                  'About',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Social media icons
                            Row(
                              children: [
                                _socialIcon(
                                  icon: 'assets/whatsapp_icon.png',
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                _socialIcon(
                                  icon: 'assets/instagram_icon.png',
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 8),
                                _socialIcon(
                                  icon: 'assets/facebook_icon.png',
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.agent.customText ?? 'No description available.',
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
                                    _isExpanded ? 'Read Less' : 'Read More',
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
                            const Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.email,
                          label: 'Email:',
                          value: 'johnsmith@email.com',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.map,
                          label: 'Service Areas:',
                          value: 'Beirut, Baabda, Keserwan, Metn',
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
                              child: const Text(
                                'Start Chat',
                                style: TextStyle(
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
                              label: const Text('Report this agent', style: TextStyle(color: Colors.red)),
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

  Widget _socialIcon({required String icon, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.circle, // Placeholder for actual network icon
          color: color,
          size: 24,
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
            Text(
              'No profile image',
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
                'Failed to load agent data',
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_agentData == null) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No agent data available'),
        ),
      );
    }

    return AgentListingsReviewsWidget(
      agent: _agentData!,
      onReviewSubmitted: _loadAgentData,
    );
  }

}
