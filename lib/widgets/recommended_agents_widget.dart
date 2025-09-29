// lib/widgets/agent_widgets/recommended_agents_widget.dart

import 'package:flutter/material.dart';
import '../environment.dart';
import '../../screens/agents/single_agent_page.dart';

// Data model for an agent
class Agent {
  final String imageUrl;
  final String name;
  final int propertyCount;
  final String location;
  final double rating;
  final int reviewCount;
  final String? customText;

  Agent({
    required this.imageUrl,
    required this.name,
    required this.propertyCount,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.customText,
  });

  // Enhanced factory constructor for JSON parsing
  factory Agent.fromJson(Map<String, dynamic> json) {
    // Debug print the JSON being parsed
    print('DEBUG: Parsing agent JSON: $json');
    
    return Agent(
      // Handle the actual backend field names
      imageUrl: _buildImageUrl(_getStringValue(json, ['profileImage', 'imageUrl', 'image_url', 'avatar'])) ?? '',
      name: _buildFullName(json) ?? _getStringValue(json, ['name', 'fullName', 'agentName']) ?? 'Unknown Agent',
      propertyCount: _getIntValue(json, ['propertyCount', 'property_count', 'properties']) ?? 0,
      location: _buildLocation(json) ?? _getStringValue(json, ['location', 'city', 'area']) ?? '',
      rating: _getDoubleValue(json, ['rating', 'averageRating', 'score']) ?? 4.5, // Default rating
      reviewCount: _getIntValue(json, ['reviewCount', 'review_count', 'totalReviews']) ?? 0,
      customText: _getStringValue(json, ['customText', 'custom_text', 'description', 'bio']),
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
    };
  }
}

// The main widget that holds the title and the horizontal list
class RecommendedAgentsWidget extends StatelessWidget {
  final String title;
  final List<Agent> agents;
  final bool showPropertyCount; // Toggle between property count and custom text
  final VoidCallback? onSeeAll;

  const RecommendedAgentsWidget({
    super.key,
    required this.title,
    required this.agents,
    this.showPropertyCount = true, // Default to showing property count
    this.onSeeAll,
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
                  child: const Text('See all'),
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
class AgentCard extends StatelessWidget {
  final Agent agent;
  final bool showPropertyCount;

  const AgentCard({
    super.key, 
    required this.agent,
    required this.showPropertyCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleAgentPage(agent: agent),
          ),
        );
      },
      child: Container(
      width: 200, // Card width
      margin: const EdgeInsets.only(right: 16.0),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparent background
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay icons
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: agent.imageUrl.trim().isNotEmpty
                    ? Image.network(
                        agent.imageUrl,
                        height: 140, // increased slightly for better visual
                        width: double.infinity,
                        fit: BoxFit.cover,
                        // Loading and error builders for better UX
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
                        height: 140, // placeholder height matches real image height
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey.shade300,
                                child: const Icon(Icons.person, size: 40, color: Colors.grey),
                              ),
                             
                            ],
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  radius: 16,
                  child: const Icon(Icons.favorite_border,
                      color: Colors.blue, size: 20),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  radius: 16,
                  child: Icon(Icons.shortcut,
                      color: Colors.blue.shade700, size: 20),
                ),
              ),
            ],
          ),
          // Agent details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Conditional rendering of property count or custom text
                if (showPropertyCount)
                  _buildInfoRow(Icons.business_center_outlined,
                      '${agent.propertyCount} Properties')
                else
                  _buildCustomTextRow(agent.customText ?? 'No description available'),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.location_on_outlined, agent.location),
                const SizedBox(height: 4),
                _buildInfoRow(
                    Icons.star, '${agent.rating} (${agent.reviewCount} Reviews)',
                    iconColor: Colors.amber),
              ],
            ),
          ),
        ],
      ),
    ),
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
