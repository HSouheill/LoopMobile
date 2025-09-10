// lib/recommended_agents_widget.dart

import 'package:flutter/material.dart';

// Data model for an agent
class Agent {
  final String imageUrl;
  final String name;
  final int propertyCount;
  final String location;
  final double rating;
  final int reviewCount;

  Agent({
    required this.imageUrl,
    required this.name,
    required this.propertyCount,
    required this.location,
    required this.rating,
    required this.reviewCount,
  });
}

// The main widget that holds the title and the horizontal list
class RecommendedAgentsWidget extends StatelessWidget {
  final String title;
  final List<Agent> agents;

  const RecommendedAgentsWidget({
    super.key,
    required this.title,
    required this.agents,
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
              TextButton(
                onPressed: () {
                  // TODO: Handle "See all" tap
                },
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal list of agent cards
          SizedBox(
            height: 250, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: agents.length,
              itemBuilder: (context, index) {
                return AgentCard(agent: agents[index]);
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

  const AgentCard({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Image.network(
                  agent.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Loading and error builders for better UX
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 120,
                      child: Icon(Icons.broken_image, size: 40),
                    );
                  },
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
                _buildInfoRow(Icons.business_center_outlined,
                    '${agent.propertyCount} Properties'),
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
}
