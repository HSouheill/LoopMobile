// lib/widgets/agent_widgets/recommended_agents_widget.dart

import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../environment.dart';
import '../../screens/agents/single_agent_page.dart';
import '../../services/favorite_service.dart';

// Data model for an agent
class Agent {
  final String id;
  final String imageUrl;
  final String name;
  final int propertyCount;
  final String location;
  final double rating;
  final int reviewCount;
  final String? customText;
  final bool isFeatured;

  Agent({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.propertyCount,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.customText,
    this.isFeatured = false,
  });

  // Enhanced factory constructor for JSON parsing
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      // Handle the actual backend field names
      id: _getStringValue(json, ['_id', 'id']) ?? '',
      imageUrl: _buildImageUrl(_getStringValue(json, ['profileImage', 'imageUrl', 'image_url', 'avatar'])) ?? '',
      name: _buildFullName(json) ?? _getStringValue(json, ['name', 'fullName', 'agentName']) ?? 'Unknown Agent',
      propertyCount: _getIntValue(json, ['propertyCount', 'property_count', 'properties']) ?? 0,
      location: _buildLocation(json) ?? _getStringValue(json, ['location', 'city', 'area']) ?? '',
      rating: _getDoubleValue(json, ['rating', 'averageRating', 'score']) ?? 4.5, // Default rating
      reviewCount: _getIntValue(json, ['reviewCount', 'review_count', 'totalReviews']) ?? 0,
      customText: _getStringValue(json, ['customText', 'custom_text', 'description', 'bio']),
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
    );
  }

  // Helper method to build full image URL
  static String? _buildImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return null;
    }
    
    // If it's already a full URL, return as is
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    
    // Build full URL - you'll need to adjust this based on your backend setup
    // For now, using a placeholder. Replace with your actual image server URL
    return '${Environment.apiUrl}assets/$filename';
  }

  // Helper method to build full name from firstName and lastName
  static String? _buildFullName(Map<String, dynamic> json) {
    final firstName = json['firstName']?.toString();
    final lastName = json['lastName']?.toString();
    
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    }
    return null;
  }

  // Helper method to build location from city, district, country
  static String? _buildLocation(Map<String, dynamic> json) {
    final city = json['city']?.toString();
    final district = json['district']?.toString();
    final country = json['country']?.toString();
    
    List<String> locationParts = [];
    if (city != null) locationParts.add(city);
    if (district != null) locationParts.add(district);
    if (country != null) locationParts.add(country);
    
    return locationParts.isNotEmpty ? locationParts.join(', ') : null;
  }

  // Helper method to get string value from multiple possible keys
  static String? _getStringValue(Map<String, dynamic> json, List<String> keys) {
    for (String key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key].toString();
      }
    }
    return null;
  }

  // Helper method to get int value from multiple possible keys
  static int? _getIntValue(Map<String, dynamic> json, List<String> keys) {
    for (String key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        if (json[key] is int) return json[key];
        if (json[key] is double) return json[key].toInt();
        if (json[key] is String) {
          return int.tryParse(json[key]);
        }
      }
    }
    return null;
  }

  // Helper method to get double value from multiple possible keys
  static double? _getDoubleValue(Map<String, dynamic> json, List<String> keys) {
    for (String key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        if (json[key] is double) return json[key];
        if (json[key] is int) return json[key].toDouble();
        if (json[key] is String) {
          return double.tryParse(json[key]);
        }
      }
    }
    return null;
  }

  // Optional: Add toJson method if you need to send data back to API
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'propertyCount': propertyCount,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'customText': customText,
      'isFeatured': isFeatured,
    };
  }
}

// The main widget that holds the title and the horizontal list
class RecommendedAgentsWidget extends StatelessWidget {
  final String title;
  final List<Agent> agents;
  final bool showPropertyCount; // Toggle between property count and custom text
  final VoidCallback? onSeeAll;
  final Function(Agent)? onAgentTap; // Custom navigation callback

  const RecommendedAgentsWidget({
    super.key,
    required this.title,
    required this.agents,
    this.showPropertyCount = true, // Default to showing property count
    this.onSeeAll,
    this.onAgentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and "See all" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(AppLocalizations.of(context)?.seeAll ?? 'See all'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal list of agent cards
          SizedBox(
            height: 280, // Increased height to accommodate 2-line subtitles
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: agents.length,
              itemBuilder: (context, index) {
                return AgentCard(
                  agent: agents[index],
                  showPropertyCount: showPropertyCount,
                  onTap: onAgentTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for a single agent card
class AgentCard extends StatefulWidget {
  final Agent agent;
  final bool showPropertyCount;
  final Function(Agent)? onTap;
  final double? width; // Optional width for horizontal list (null = expand in grid)
  final EdgeInsets? margin; // Optional margin

  const AgentCard({
    super.key, 
    required this.agent,
    required this.showPropertyCount,
    this.onTap,
    this.width,
    this.margin,
  });

  @override
  State<AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<AgentCard> {
  bool _isFavorited = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final result = await FavoriteService.checkFavorite(
        favoritedObjectId: widget.agent.id,
        table: 'user',
      );
      
      if (mounted) {
        setState(() {
          _isFavorited = result['isFavorited'] ?? false;
        });
      }
    } catch (e) {
      // Error checking favorite status
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FavoriteService.toggleFavorite(
        favoritedObjectId: widget.agent.id,
        table: 'user',
      );

      if (mounted) {
        setState(() {
          _isFavorited = result['isFavorited'] ?? false;
          _isLoading = false;
        });

        // Show user feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Favorite status updated'),
            duration: const Duration(seconds: 2),
            backgroundColor: result['success'] == true 
                ? Colors.green 
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the card content
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image with overlay icons
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: widget.agent.imageUrl.trim().isNotEmpty
                  ? Image.network(
                      widget.agent.imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 140,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.person, size: 40, color: Colors.grey),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  radius: 16,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : Colors.blue,
                          size: 20,
                        ),
                ),
              ),
            ),
            if (widget.agent.isFeatured)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 244, 208, 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        l10n?.featuredLabel ?? 'Featured',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  ),
                ),
              ),
          ],
        ),
        // Agent details
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.agent.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (widget.showPropertyCount)
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return _buildInfoRow(Icons.business_center_outlined,
                        l10n?.properties(widget.agent.propertyCount) ?? '${widget.agent.propertyCount} Properties');
                  }
                )
              else
                Builder(
                  builder: (context) {
                    return _buildCustomTextRow(widget.agent.customText ?? (AppLocalizations.of(context)?.noDescriptionAvailable ?? 'No description available'));
                  }
                ),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.location_on_outlined, widget.agent.location),
              const SizedBox(height: 4),
              _buildInfoRow(
                  Icons.star, '${widget.agent.rating} (${widget.agent.reviewCount} Reviews)',
                  iconColor: Colors.amber),
            ],
          ),
        ),
      ],
    );

    // Wrap content with border using ClipRRect to ensure border hugs content
    Widget card = Container(
      width: widget.width ?? 200,
      margin: widget.margin ?? const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: cardContent,
    );

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!(widget.agent);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleAgentPage(agent: widget.agent),
            ),
          );
        }
      },
      child: card,
    );
  }

  // Helper method to create info rows with an icon and text
  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Custom text row without icon, positioned where the property count icon would be
  Widget _buildCustomTextRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 0), // Align with icon position
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700, 
          fontSize: 13, // Slightly larger than the regular info text (12)
          fontWeight: FontWeight.w500, // Make it slightly bolder
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2, // Allow up to 2 lines for the custom text
      ),
    );
  }
}
