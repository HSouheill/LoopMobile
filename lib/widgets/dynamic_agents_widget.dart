// lib/widgets/agent_widgets/dynamic_agents_widget.dart
import 'package:flutter/material.dart';
import 'agent_widgets/agent_service.dart';
import './recommended_agents_widget.dart';
import '../screens/agents/category_agents_page.dart';

// Enum for different agent categories/filters
enum AgentCategory {
  featured,
  topRated,
  forYou,
}

class DynamicAgentsWidget extends StatefulWidget {
  final AgentCategory category;
  final String? customTitle; // Optional custom title override
  final int limit; // Add limit parameter like listings
  final VoidCallback? onSeeAll; // Add onSeeAll callback

  const DynamicAgentsWidget({
    super.key,
    required this.category,
    this.customTitle,
    this.limit = 3, // Default to 3 like listings
    this.onSeeAll,
  });

  @override
  State<DynamicAgentsWidget> createState() => _DynamicAgentsWidgetState();
}

class _DynamicAgentsWidgetState extends State<DynamicAgentsWidget> {
  List<Agent> agents = [];
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  // Get title based on category
  String get title {
    if (widget.customTitle != null) return widget.customTitle!;

    switch (widget.category) {
      case AgentCategory.featured:
        return 'Featured Agents';
      case AgentCategory.topRated:
        return 'Top Agents';
      case AgentCategory.forYou:
        return 'For You';
    }
  }

  // Get filter parameters based on category
  Map<String, String> get filterParams {
    final params = <String, String>{'limit': widget.limit.toString()};
    switch (widget.category) {
      case AgentCategory.featured:
        params.addAll({'isFeatured': 'true', 'sort': 'featured'});
        break;
      case AgentCategory.topRated:
        params.addAll({'sort': 'featured', 'minRating': '4.5'});
        break;
      case AgentCategory.forYou:
        params.addAll({'sort': 'featured', 'personalized': 'true'});
        break;
    }
    return params;
  }

  Future<void> _loadAgents() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final fetchedAgents = await AgentService.getAgents(filterParams);
      if (mounted) {
        setState(() {
          agents = fetchedAgents;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load agents: $e';
          isLoading = false;
        });
      }
    }
  }


  void _handleSeeAll() {
    if (widget.onSeeAll != null) {
      widget.onSeeAll!();
      return;
    }
    // Navigate to paginated agents page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryAgentsPage(category: widget.category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title, filters, and "See all" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filter chips
                  ],
                ),
              ),
              TextButton(
                onPressed: _handleSeeAll,
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content area
          if (isLoading)
            const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error.isNotEmpty)
            SizedBox(
              height: 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade400, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAgents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (agents.isEmpty)
            const SizedBox(
              height: 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No agents found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            // Horizontal list of agent cards
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  return AgentCard(
                    agent: agents[index],
                    showPropertyCount: true, // Show property count by default
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

}
