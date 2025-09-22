// lib/widgets/agent_widgets/dynamic_agents_widget.dart
import 'package:flutter/material.dart';
import '../../services/agent_service.dart';
import './recommended_agents_widget.dart';

// Enum for different agent categories/filters
enum AgentCategory {
  featured,
  topRated,
  forYou,
}

class DynamicAgentsWidget extends StatefulWidget {
  final AgentCategory category;
  final String? customTitle; // Optional custom title override

  const DynamicAgentsWidget({
    super.key,
    required this.category,
    this.customTitle,
  });

  @override
  State<DynamicAgentsWidget> createState() => _DynamicAgentsWidgetState();
}

class _DynamicAgentsWidgetState extends State<DynamicAgentsWidget> {
  List<Agent> agents = [];
  bool isLoading = false;
  String error = '';
  String selectedFilter = 'featured'; // Default filter

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
        return 'Top Rated';
      case AgentCategory.forYou:
        return 'For You';
    }
  }

  // Get filter parameters based on category
  Map<String, String> get filterParams {
    switch (widget.category) {
      case AgentCategory.featured:
        return {'isFeatured': 'true', 'sort': selectedFilter};
      case AgentCategory.topRated:
        return {'sort': selectedFilter, 'minRating': '4.5'};
      case AgentCategory.forYou:
        return {'sort': selectedFilter, 'personalized': 'true'};
    }
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

  void _onFilterChanged(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
    });
    _loadAgents();
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
                onPressed: () {
                  // TODO: Navigate to full agents list page
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) => AllAgentsPage(category: widget.category)
                  // ));
                },
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
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}