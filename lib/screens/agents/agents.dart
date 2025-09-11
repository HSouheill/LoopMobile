import 'package:flutter/material.dart';
import '../../widgets/search_and_categories_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/recommended_agents_widget.dart';

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

    // Featured agents data
    final List<Agent> featuredAgents = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Sarah Johnson',
        propertyCount: 45,
        location: 'Beverly Hills, CA',
        rating: 4.9,
        reviewCount: 184,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Michael Chen',
        propertyCount: 62,
        location: 'Manhattan, NY',
        rating: 4.8,
        reviewCount: 256,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1043473/pexels-photo-1043473.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Emily Rodriguez',
        propertyCount: 38,
        location: 'Miami, FL',
        rating: 4.9,
        reviewCount: 192,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'David Thompson',
        propertyCount: 29,
        location: 'Austin, TX',
        rating: 4.7,
        reviewCount: 143,
      ),
    ];

    // Top rated agents data
    final List<Agent> topRatedAgents = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3778966/pexels-photo-3778966.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Jessica Williams',
        propertyCount: 72,
        location: 'Los Angeles, CA',
        rating: 5.0,
        reviewCount: 298,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/2182970/pexels-photo-2182970.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Robert Martinez',
        propertyCount: 56,
        location: 'Chicago, IL',
        rating: 4.9,
        reviewCount: 234,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1680175/pexels-photo-1680175.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Amanda Davis',
        propertyCount: 41,
        location: 'Seattle, WA',
        rating: 4.9,
        reviewCount: 187,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'James Wilson',
        propertyCount: 33,
        location: 'Portland, OR',
        rating: 4.8,
        reviewCount: 156,
      ),
    ];

    // For you agents data (personalized recommendations)
    final List<Agent> forYouAgents = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3211476/pexels-photo-3211476.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Lisa Anderson',
        propertyCount: 27,
        location: 'San Diego, CA',
        rating: 4.6,
        reviewCount: 112,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Kevin Brown',
        propertyCount: 34,
        location: 'Phoenix, AZ',
        rating: 4.7,
        reviewCount: 128,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3756679/pexels-photo-3756679.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Rachel Green',
        propertyCount: 19,
        location: 'Nashville, TN',
        rating: 4.5,
        reviewCount: 89,
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/2182975/pexels-photo-2182975.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Mark Johnson',
        propertyCount: 42,
        location: 'Denver, CO',
        rating: 4.6,
        reviewCount: 164,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar component
          const SearchAndCategoriesWidget(),
          const SizedBox(height: 10),

          // Image slider
          ImageSliderWidget(imageUrls: agentSliderImages),
          const SizedBox(height: 10),

          // Featured agents section
          RecommendedAgentsWidget(
            title: 'Featured Agents',
            agents: featuredAgents,
          ),

          // Top rated agents section
          RecommendedAgentsWidget(
            title: 'Top Rated',
            agents: topRatedAgents,
          ),

          // For you agents section
          RecommendedAgentsWidget(
            title: 'For You',
            agents: forYouAgents,
          ),
        ],
      ),
    );
  }
}
