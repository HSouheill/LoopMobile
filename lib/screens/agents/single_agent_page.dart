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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Slider AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
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
                  
                  // Navigation arrows (only show if multiple images)
                  if (_allImages.length > 1) ...[
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex < _allImages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Title & Location overlay at bottom of image
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.agent.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
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
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: const [],
          ),
          
          // Content
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Rating and Property Count
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.agent.rating}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.agent.reviewCount} reviews)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${widget.agent.propertyCount} Properties',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Agent Details Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Dynamic agent details
                          ...(_buildAgentDetailsList()),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Description Section
                    if (widget.agent.customText != null && widget.agent.customText!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
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
                            const SizedBox(height: 16),
                            Text(
                              widget.agent.customText!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                height: 1.5,
                              ),
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                            if (widget.agent.customText!.length > 150) ...[
                              const SizedBox(height: 12),
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
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
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
                    
                    const SizedBox(height: 40),
                    
                    // Contact Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Call functionality
                              // You can implement url_launcher here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Call functionality coming soon')),
                              );
                            },
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: const Text('Call', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // WhatsApp functionality
                              // You can implement url_launcher here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('WhatsApp functionality coming soon')),
                              );
                            },
                            icon: const Icon(Icons.message, color: Colors.white),
                            label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
          ),
        ],
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
  
  List<Widget> _buildAgentDetailsList() {
    List<Widget> details = [];
    
    // Name
    details.add(_buildAgentDetail('Name: ${widget.agent.name}'));
    
    // Location
    details.add(_buildAgentDetail('Location: ${widget.agent.location}'));
    
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
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
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
