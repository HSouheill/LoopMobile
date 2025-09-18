import 'package:flutter/material.dart';
import '/services/listing_service.dart';

class SingleListingPage extends StatefulWidget {
  final PropertyListing listing;

  const SingleListingPage({super.key, required this.listing});

  @override
  State<SingleListingPage> createState() => _SingleListingPageState();
}

class _SingleListingPageState extends State<SingleListingPage> {
  PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isExpanded = false;

  // Sample additional images - in real app, these would come from the listing data
  List<String> get _allImages => [
    widget.listing.imageUrl,
    // Add more sample images - replace with actual listing images
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500',
    'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=500',
  ];

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
                    itemCount: _allImages.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        _allImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // Navigation arrows
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
                  
                  // Page indicators
                  if (_allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _allImages.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          );
                        }).toList(),
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
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    // Add to favorites functionality
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ),
            ],
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
                    // Title and Location
                    Text(
                      widget.listing.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.listing.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.listing.price,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Agent Info
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.listing.agentName,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Property Details Section
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
                              const Icon(Icons.search, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Property Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Property details list
                          _buildPropertyDetail('Size: 120 sqm'),
                          _buildPropertyDetail('2 Bedrooms, 2 Bathrooms + Guest Toilet'),
                          _buildPropertyDetail('Fully equipped kitchen'),
                          _buildPropertyDetail('AC & Heating system'),
                          _buildPropertyDetail('1 Underground parking space'),
                          _buildPropertyDetail('Elevator & Generator'),
                          _buildPropertyDetail('Close to ABC Mall, Sassine Square, and all main attractions'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Description Section
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
                                'Description',
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
                            'Situated on a quiet street yet just minutes away from popular cafes, shops, schools, and hospitals, the apartment features a bright...',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              height: 1.5,
                            ),
                            maxLines: _isExpanded ? null : 3,
                            overflow: _isExpanded ? null : TextOverflow.ellipsis,
                          ),
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
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Property Code and Listed Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            children: [
                              const TextSpan(
                                text: 'Property Code: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: 'APT-DXB-9234 '),
                              WidgetSpan(
                                child: Icon(Icons.copy, size: 16, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: 'Listed Date: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'Thursday, 8 April 2025',
                                style: TextStyle(color: Colors.blue),
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
  
  Widget _buildPropertyDetail(String detail) {
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