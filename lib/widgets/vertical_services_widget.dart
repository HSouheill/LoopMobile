import 'package:flutter/material.dart';
import 'recommended_agents_widget.dart';

class VerticalServicesWidget extends StatelessWidget {
  final String title;
  final List<Agent> agents;
  final bool showPropertyCount;
  final VoidCallback? onSeeAll;

  const VerticalServicesWidget({
    super.key,
    required this.title,
    required this.agents,
    this.showPropertyCount = false,
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
          // Grid that lines up like listings (2 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agents.length,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Reduced aspect ratio to accommodate 2-line subtitles
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final agent = agents[index];
              return AgentCard(
                agent: agent,
                showPropertyCount: showPropertyCount,
              );
            },
          ),
        ],
      ),
    );
  }
}

