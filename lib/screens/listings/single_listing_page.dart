import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/listing_service.dart';
import 'package:intl/intl.dart';

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

  // Get all images from the listing
  List<String> get _allImages {
    if (widget.listing.images != null && widget.listing.images!.isNotEmpty) {
      return widget.listing.images!;
    }
    // Fallback to main image if no additional images
    return [widget.listing.imageUrl];
  }

  String get _formattedPrice {
    if (widget.listing.priceValue != null) {
      final currency = widget.listing.currency ?? 'USD';
      final price = widget.listing.priceValue;
      final formatter = NumberFormat.currency(symbol: currency == 'USD' ? '\$' : currency);
      return formatter.format(price);
    }
    return widget.listing.price;
  }

  String get _formattedDate {
    if (widget.listing.createdAt != null) {
      return DateFormat('EEEE, d MMMM yyyy').format(widget.listing.createdAt!);
    }
    return 'Date not available';
  }

  String get _propertyCode {
    return widget.listing.id;
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
                            _formattedPrice,
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
                          
                          // Dynamic property details
                          ...(_buildPropertyDetailsList()),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Description Section
                    if (widget.listing.description != null && widget.listing.description!.isNotEmpty)
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
                              widget.listing.description!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                height: 1.5,
                              ),
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                            if (widget.listing.description!.length > 150) ...[
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
                    
                    // Amenities Section (if available)
                    if (widget.listing.amenityList != null && widget.listing.amenityList!.isNotEmpty)
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
                                const Icon(Icons.star_outline, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Amenities',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: widget.listing.amenityList!.map((amenity) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    _formatAmenityName(amenity),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Property Code and Listed Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _propertyCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Property code copied to clipboard')),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              children: [
                                const TextSpan(
                                  text: 'Property Code: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: _propertyCode),
                                const TextSpan(text: ' '),
                                WidgetSpan(
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
                                text: 'Listed Date: ',
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
                              // Call functionality using contactPhone
                              // You can implement url_launcher here
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
                              // WhatsApp functionality using contactPhone
                              // You can implement url_launcher here
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
  
  List<Widget> _buildPropertyDetailsList() {
    List<Widget> details = [];
    
    // Size
    if (widget.listing.size != null) {
      details.add(_buildPropertyDetail('Size: ${widget.listing.size} sqm'));
    }
    
    // Bedrooms and Bathrooms
    String roomInfo = '';
    if (widget.listing.bedrooms != null && widget.listing.bathrooms != null) {
      roomInfo = '${widget.listing.bedrooms} Bedrooms, ${widget.listing.bathrooms} Bathrooms';
    } else if (widget.listing.bedrooms != null) {
      roomInfo = '${widget.listing.bedrooms} Bedrooms';
    } else if (widget.listing.bathrooms != null) {
      roomInfo = '${widget.listing.bathrooms} Bathrooms';
    }
    if (roomInfo.isNotEmpty) {
      details.add(_buildPropertyDetail(roomInfo));
    }
    
    // Property type
    if (widget.listing.type != null) {
      details.add(_buildPropertyDetail('Type: ${widget.listing.type!.toUpperCase()}'));
    }
    
    // Floor
    if (widget.listing.floor != null) {
      details.add(_buildPropertyDetail('Floor: ${widget.listing.floor}'));
    }
    
    // Condition
    if (widget.listing.condition != null) {
      details.add(_buildPropertyDetail('Condition: ${widget.listing.condition!.toUpperCase()}'));
    }
    
    // Building age
    if (widget.listing.buildingAge != null) {
      details.add(_buildPropertyDetail('Building Age: ${widget.listing.buildingAge} years'));
    }
    
    // Papers
    if (widget.listing.papers != null) {
      details.add(_buildPropertyDetail('Papers: ${_formatPapers(widget.listing.papers!)}'));
    }
    
    // Listing type
    if (widget.listing.listingFor != null) {
      details.add(_buildPropertyDetail('Available for: ${widget.listing.listingFor!.toUpperCase()}'));
    }
    
    // Available from
    if (widget.listing.availableFrom != null) {
      final availableDate = DateFormat('MMMM yyyy').format(widget.listing.availableFrom!);
      details.add(_buildPropertyDetail('Available from: $availableDate'));
    }
    
    return details;
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
  
  String _formatAmenityName(String amenity) {
    // Convert camelCase to readable format
    String formatted = amenity.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    
    // Capitalize first letter and handle special cases
    formatted = formatted.trim();
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    
    // Handle special cases
    formatted = formatted.replaceAll('24 7', '24/7');
    formatted = formatted.replaceAll('A C', 'AC');
    
    return formatted;
  }
  
  String _formatPapers(String papers) {
    switch (papers.toLowerCase()) {
      case 'title_deed':
        return 'Title Deed';
      case 'contract':
        return 'Contract';
      case 'permit':
        return 'Building Permit';
      default:
        return papers.toUpperCase();
    }
  }
}