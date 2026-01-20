import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/service_service.dart';
import '../../models/service_provider.dart';
import '../../widgets/recommended_agents_widget.dart';
import 'service_provider_detail_page.dart';
import 'service_provider_advanced_filters_page.dart';

class ServiceProviderSearchResultsPage extends StatefulWidget {
  final String searchQuery;
  final Map<String, dynamic>? initialFilters;

  const ServiceProviderSearchResultsPage({
    super.key,
    required this.searchQuery,
    this.initialFilters,
  });

  @override
  State<ServiceProviderSearchResultsPage> createState() => _ServiceProviderSearchResultsPageState();
}

class _ServiceProviderSearchResultsPageState extends State<ServiceProviderSearchResultsPage> {
  List<Agent> agents = [];
  List<ServiceProvider> serviceProviders = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _currentFilters;
  late String _currentSearchQuery;

  @override
  void initState() {
    super.initState();
    _currentSearchQuery = widget.searchQuery;
    _currentFilters = widget.initialFilters;
    _loadSearchResults();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _loadSearchResults({bool isRefresh = false}) async {
    try {
      setState(() {
        if (isRefresh) {
          currentPage = 1;
          hasMoreData = true;
        }
        isLoading = true;
        error = null;
      });

      final response = await ServiceService.searchServiceProviders(
        query: _currentSearchQuery,
        page: currentPage,
        limit: 20,
        withServices: true,
        withReviews: false,
        sort: _currentFilters?['sort']?.toString(),
        city: _currentFilters?['city']?.toString(),
        district: _currentFilters?['district']?.toString(),
        role: _currentFilters?['role']?.toString(),
        providerType: _currentFilters?['role'] == null ? (_currentFilters?['providerType']?.toString()) : null,
      );

      // Convert service providers to agents
      final agentList = response.users.map((provider) {
        return Agent.fromJson(provider.toAgentJson());
      }).toList();

      setState(() {
        if (isRefresh) {
          serviceProviders = response.users;
          agents = agentList;
        } else {
          serviceProviders.addAll(response.users);
          agents.addAll(agentList);
        }
        isLoading = false;
        hasMoreData = response.users.length == 20; // If we got less than 20, no more data
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final response = await ServiceService.searchServiceProviders(
        query: _currentSearchQuery,
        page: currentPage,
        limit: 20,
        withServices: true,
        withReviews: false,
        sort: _currentFilters?['sort']?.toString(),
        city: _currentFilters?['city']?.toString(),
        district: _currentFilters?['district']?.toString(),
        role: _currentFilters?['role']?.toString(),
        providerType: _currentFilters?['role'] == null ? (_currentFilters?['providerType']?.toString()) : null,
      );

      // Convert service providers to agents
      final agentList = response.users.map((provider) {
        return Agent.fromJson(provider.toAgentJson());
      }).toList();

      setState(() {
        serviceProviders.addAll(response.users);
        agents.addAll(agentList);
        isLoadingMore = false;
        hasMoreData = response.users.length == 20; // If we got less than 20, no more data
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
        currentPage--; // Revert page increment on error
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

  void _openAdvancedFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProviderAdvancedFiltersPage(
          initialQuery: _currentSearchQuery,
          initialFilters: _currentFilters,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentSearchQuery = result['query'] ?? '';
        _currentFilters = result['filters'];
        currentPage = 1;
        hasMoreData = true;
      });
      _loadSearchResults(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.searchFor(_currentSearchQuery) ?? 'Search: "${_currentSearchQuery}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openAdvancedFilters,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadSearchResults(isRefresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadSearchResults(isRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (agents.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResultsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)?.searchingServiceProviders ?? 'Searching service providers...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.failedToSearchServiceProviders ?? 'Failed to search service providers',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error ?? (AppLocalizations.of(context)?.unknownError ?? 'Unknown error occurred'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadSearchResults(isRefresh: true),
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noServiceProvidersFound ?? 'No service providers found',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.tryDifferentKeywords ?? 'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.goBack ?? 'Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '${agents.length} service provider${agents.length == 1 ? '' : 's'} found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Results using the same card layout as main services page
        Expanded(
          child: _buildCardsGrid(),
        ),
      ],
    );
  }

  Widget _buildCardsGrid() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: (agents.length / 2).ceil() + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == (agents.length / 2).ceil()) {
          // Loading indicator for pagination
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Create a row with 2 cards
        final leftIndex = index * 2;
        final rightIndex = leftIndex + 1;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left card
              Expanded(
                child: AgentCard(
                  agent: agents[leftIndex],
                  showPropertyCount: false,
                  onTap: _onAgentTap,
                  width: null,
                  margin: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 16.0),
              // Right card (if exists)
              Expanded(
                child: rightIndex < agents.length
                    ? AgentCard(
                        agent: agents[rightIndex],
                        showPropertyCount: false,
                        onTap: _onAgentTap,
                        width: null,
                        margin: EdgeInsets.zero,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

}
