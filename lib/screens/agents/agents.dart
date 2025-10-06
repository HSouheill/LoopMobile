// Updated agents_page.dart
import 'package:flutter/material.dart';
import '../../widgets/search_only_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/dynamic_agents_widget.dart';

class AgentsPage extends StatelessWidget {
  const AgentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Slider images for agents page
    final List<String> agentSliderImages = [
      'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar component
          const SearchOnlyWidget(),
          const SizedBox(height: 10),
          
          // Image slider
          ImageSliderWidget(imageUrls: agentSliderImages),
          const SizedBox(height: 10),
          
          // Featured agents section with dynamic filtering
          const DynamicAgentsWidget(
            category: AgentCategory.featured,
          ),
          
          // Top rated agents section with dynamic filtering
          const DynamicAgentsWidget(
            category: AgentCategory.topRated,
          ),
          
          // For you agents section with dynamic filtering
          const DynamicAgentsWidget(
            category: AgentCategory.forYou,
          ),
        ],
      ),
    );
  }
}