import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../widgets/vertical_services_widget.dart';
import '../../widgets/recommended_agents_widget.dart';

class FeaturedServicesPage extends StatefulWidget {
  const FeaturedServicesPage({super.key});

  @override
  State<FeaturedServicesPage> createState() => _FeaturedServicesPageState();
}

class _FeaturedServicesPageState extends State<FeaturedServicesPage> {
  List<Agent> agents = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  int totalServices = 0;
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeaturedServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedServices({int page = 1, bool append = false}) async {
    try {
      if (!append) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      final response = await ServiceService.getAllServices(
        page: page,
        limit: itemsPerPage,
        isFeatured: true,
        sort: 'date_desc',
      );

      // Convert services to agents
      final agentList = response.services.map((service) {
        return Agent.fromJson(service.toAgentJson());
      }).toList();

      setState(() {
        if (append) {
          agents.addAll(agentList);
        } else {
          agents = agentList;
        }
        currentPage = response.meta.page;
        totalPages = response.meta.pages;
        totalServices = response.meta.total;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshServices() async {
    await _loadFeaturedServices(page: 1);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _loadNextPage() {
    if (currentPage < totalPages && !isLoading) {
      _loadFeaturedServices(page: currentPage + 1, append: true);
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 1 && !isLoading) {
      _loadFeaturedServices(page: currentPage - 1);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Featured Services'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshServices,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshServices,
        child: Column(
          children: [
            // Header with count
            if (!isLoading && agents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${agents.length} of $totalServices featured services',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Page $currentPage of $totalPages',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
            
            // Pagination controls
            if (!isLoading && agents.isNotEmpty && totalPages > 1)
              _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && agents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && agents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load featured services',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (agents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No featured services found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Use VerticalServicesWidget for stacked card layout
          VerticalServicesWidget(
            title: 'Featured Services',
            agents: agents,
            showPropertyCount: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: currentPage > 1 ? _loadPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage > 1 ? null : Colors.grey[300],
            ),
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$currentPage / $totalPages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          // Next button
          ElevatedButton.icon(
            onPressed: currentPage < totalPages ? _loadNextPage : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage < totalPages ? null : Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
