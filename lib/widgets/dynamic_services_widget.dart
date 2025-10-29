import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/service_service.dart';
import '../models/service_provider.dart';
import '../screens/services/service_provider_detail_page.dart';
import '../screens/services/category_services_page.dart';
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
  List<ServiceProvider> serviceProviders = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadServiceProviders();
  }

  Future<void> _loadServiceProviders() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      ServiceProvidersResponse response;
      
      switch (widget.category) {
        case ServiceCategory.featured:
          response = await ServiceService.getFeaturedServiceProviders(limit: widget.limit);
          break;
        case ServiceCategory.topRated:
          response = await ServiceService.getTopRatedServiceProviders(limit: widget.limit);
          break;
        case ServiceCategory.featuredCompanies:
          // Featured companies: filter providerType=company and isFeatured=true
          response = await ServiceService.getAllServiceProviders(
            limit: widget.limit,
            isFeatured: true,
            providerType: 'company',
            sort: 'date_desc',
          );
          break;
        case ServiceCategory.companies:
          response = await ServiceService.getServiceProvidersByType(
            providerType: 'company',
            limit: widget.limit,
          );
          break;
        case ServiceCategory.individual:
          response = await ServiceService.getServiceProvidersByType(
            providerType: 'individual',
            limit: widget.limit,
          );
          break;
      }

      // Store service providers and convert to agents
      final agentList = response.users.map((provider) {
        return Agent.fromJson(provider.toAgentJson());
      }).toList();

      setState(() {
        serviceProviders = response.users;
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

  void _onAgentTap(Agent agent) {
   
    // Find the corresponding ServiceProvider
    final serviceProvider = serviceProviders.firstWhere(
      (provider) => provider.displayName == agent.name,
      orElse: () => serviceProviders.first,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProviderDetailPage(serviceProvider: serviceProvider),
      ),
    );
  }

  void _handleSeeAll() {
    if (widget.onSeeAll != null) {
      widget.onSeeAll!();
      return;
    }
    // Open paginated page for the selected category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryServicesPage(category: widget.category),
      ),
    );
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

    final l10n = AppLocalizations.of(context);
    return RecommendedAgentsWidget(
      title: widget.category.getDisplayNameLocalized(l10n),
      agents: agents,
      showPropertyCount: false, // Services don't have property count
      onSeeAll: widget.showSeeAll ? _handleSeeAll : null,
      onAgentTap: _onAgentTap,
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.getDisplayNameLocalized(l10n),
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
    final l10n = AppLocalizations.of(context);
    final categoryName = widget.category.getDisplayNameLocalized(l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
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
                      l10n?.failedToLoadCategory(categoryName) ?? 'Failed to load ${categoryName.toLowerCase()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadServiceProviders,
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
    final l10n = AppLocalizations.of(context);
    final categoryName = widget.category.getDisplayNameLocalized(l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
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
                      l10n?.noCategoryFound(categoryName) ?? 'No ${categoryName.toLowerCase()} found',
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
