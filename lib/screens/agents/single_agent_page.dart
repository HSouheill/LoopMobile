import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/recommended_agents_widget.dart';

class SingleAgentPage extends StatefulWidget {
  final Agent agent;

  const SingleAgentPage({super.key, required this.agent});

  @override
  State<SingleAgentPage> createState() => _SingleAgentPageState();
}

class _SingleAgentPageState extends State<SingleAgentPage> {
  PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isExpanded = false;

  // Get all images from the agent (for now just the profile image, but can be extended)
  List<String> get _allImages {
    if (widget.agent.imageUrl.isNotEmpty) {
      return [widget.agent.imageUrl];
    }
    // Fallback to placeholder
    return [];
  }

  String get _formattedDate {
    // Since Agent model doesn't have createdAt, we'll use a placeholder
    return 'Member since 2024';
  }

  String get _agentId {
    // Use name as ID for now, but this could be enhanced with actual ID
    return widget.agent.name.replaceAll(' ', '_').toLowerCase();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image PageView
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: _allImages.length > 0 ? _allImages.length : 1,
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

                  // Top-left back button (circular, semi-transparent) - preserved look
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

                  // Social icons on top-right (small circular buttons)
                  Positioned(
                    right: 12,
                    top: topPadding + 10,
                    child: Row(
                      children: [
                        _socialCircle(Icons.phone, size: 34),
                        const SizedBox(width: 8),
                        _socialCircle(Icons.message, size: 34),
                        const SizedBox(width: 8),
                        _socialCircle(Icons.facebook, size: 34),
                      ],
                    ),
                  ),

                  // Title & Location overlay at bottom-left of image
                  Positioned(
                    left: 16,
                    bottom: 24,
                    right: 120, // leave space for rating and social icons
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.agent.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.agent.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Rating stars aligned near the name (to the right)
                  Positioned(
                    right: 20,
                    bottom: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStars(widget.agent.rating),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.agent.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content - white rounded card overlapping the header
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The white card
                Container(
                  // pull up so it visually overlaps exactly under the header with no gap
                  margin: const EdgeInsets.only(top: 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    // note: no shadow so the avatar's shadow remains dominant and clean
                  ),
                  child: Padding(
                    // top padding leaves room for avatar which sits visually on top
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // small centered rating strip under the avatar (keeps existing info)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.agent.rating}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${widget.agent.reviewCount} reviews)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.withOpacity(0.18)),
                                ),
                                child: Text(
                                  '${widget.agent.propertyCount} Properties',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Agent Details Section
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Agent Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.share, size: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Dynamic agent details
                              ...(_buildAgentDetailsList()),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Description Section
                        if (widget.agent.customText != null && widget.agent.customText!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.info_outline, color: Colors.grey, size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'About',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.agent.customText!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                  maxLines: _isExpanded ? null : 3,
                                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                                ),
                                if (widget.agent.customText!.length > 150) ...[
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isExpanded = !_isExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isExpanded ? 'Read Less' : 'Read More',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                        const SizedBox(height: 18),

                        // Agent ID and Member Since
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _agentId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Agent ID copied to clipboard')),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  children: [
                                    const TextSpan(
                                      text: 'Agent ID: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: _agentId),
                                    const TextSpan(text: ' '),
                                    const WidgetSpan(
                                      child: Icon(Icons.copy, size: 16, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                                children: [
                                  const TextSpan(
                                    text: 'Member Since: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: _formattedDate,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Contact Buttons (full width)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Call functionality coming soon')),
                                  );
                                },
                                icon: const Icon(Icons.phone, color: Colors.white),
                                label: const Text('Call', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('WhatsApp functionality coming soon')),
                                  );
                                },
                                icon: const Icon(Icons.message, color: Colors.white),
                                label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Avatar placed AFTER the card so it's painted on top (overlapping)
                Positioned(
                  top: -36, // lifts avatar to overlap header and card
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (widget.agent.imageUrl.isNotEmpty)
                          ? NetworkImage(widget.agent.imageUrl)
                          : null,
                      child: widget.agent.imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 44, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialCircle(IconData icon, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.46, color: Colors.grey[700]),
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

  List<Widget> _buildAgentDetailsList() {
    List<Widget> details = [];

    // Name
    details.add(_buildAgentDetail('Name: ${widget.agent.name}'));

    // Location
    details.add(_buildAgentDetail('Service Areas: ${widget.agent.location}'));

    // Property Count
    details.add(_buildAgentDetail('Properties Listed: ${widget.agent.propertyCount}'));

    // Rating
    details.add(_buildAgentDetail('Rating: ${widget.agent.rating} stars'));

    // Review Count
    details.add(_buildAgentDetail('Total Reviews: ${widget.agent.reviewCount}'));

    // Member Since (placeholder)
    details.add(_buildAgentDetail('Member Since: 2024'));

    return details;
  }

  Widget _buildAgentDetail(String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
