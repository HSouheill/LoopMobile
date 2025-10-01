import 'package:flutter/material.dart';
import '../services/service_service.dart';
import 'recommended_agents_widget.dart';

class DynamicServicesWidget extends StatefulWidget {
  final ServiceCategory category;
  final int limit;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  const DynamicServicesWidget({
    super.key,
    required this.category,
    this.limit = 3,
    this.showSeeAll = true,
    this.onSeeAll,
  });

  @override
  State<DynamicServicesWidget> createState() => _DynamicServicesWidgetState();
}

class _DynamicServicesWidgetState extends State<DynamicServicesWidget> {
  List<Agent> agents = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      ServicesResponse response;
      
      switch (widget.category) {
        case ServiceCategory.featured:
          response = await ServiceService.getFeaturedServices(limit: widget.limit);
          break;
        case ServiceCategory.topRated:
          response = await ServiceService.getTopRatedServices(limit: widget.limit);
          break;
        case ServiceCategory.companies:
          response = await ServiceService.getServicesByType(
            type: 'company',
            limit: widget.limit,
          );
          break;
        case ServiceCategory.individual:
          response = await ServiceService.getServicesByType(
            type: 'individual',
            limit: widget.limit,
          );
          break;
      }

      // Convert services to agents
      final agentList = response.services.map((service) {
        return Agent.fromJson(service.toAgentJson());
      }).toList();

      setState(() {
        agents = agentList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (agents.isEmpty) {
      return _buildEmptyState();
    }

    return RecommendedAgentsWidget(
      title: widget.category.displayName,
      agents: agents,
      showPropertyCount: false, // Services don't have property count
      onSeeAll: widget.showSeeAll ? widget.onSeeAll : null,
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load ${widget.category.displayName.toLowerCase()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadServices,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business_center_outlined, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'No ${widget.category.displayName.toLowerCase()} found',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
