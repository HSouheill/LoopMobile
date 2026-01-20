import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/service_service.dart';
import '../../models/service_provider.dart';
import '../../screens/services/service_provider_detail_page.dart';
import '../../widgets/recommended_agents_widget.dart';

class CategoryServicesPage extends StatefulWidget {
  final ServiceCategory category;

  const CategoryServicesPage({super.key, required this.category});

  @override
  State<CategoryServicesPage> createState() => _CategoryServicesPageState();
}

class _CategoryServicesPageState extends State<CategoryServicesPage> {
  int page = 1;
  final int limit = 10;
  bool isLoading = false;
  String? error;
  List<Agent> agents = [];
  List<ServiceProvider> serviceProviders = [];
  ServiceProviderMeta? meta;

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage({int pageToFetch = 1}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      ServiceProvidersResponse resp;

      if (widget.category == ServiceCategory.featured) {
        // featured: use isFeatured param
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          isFeatured: true,
        );
      } else if (widget.category == ServiceCategory.featuredCompanies) {
        // featured companies: combine isFeatured with providerType=company
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          isFeatured: true,
          providerType: 'company',
        );
      } else if (widget.category == ServiceCategory.topRated) {
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          sort: 'featured_first',
        );
      } else {
        // types (company / individual) - use featured_first sort
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          providerType: widget.category.providerType,
          sort: 'featured_first',
        );
      }

      if (!mounted) return;
      
      // Convert service providers to agents
      final agentList = resp.users.map((provider) {
        return Agent.fromJson(provider.toAgentJson());
      }).toList();

      setState(() {
        serviceProviders = resp.users;
        agents = agentList;
        meta = resp.meta;
        page = resp.meta.page;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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

  void _goToPage(int newPage) {
    if (newPage < 1) return;
    if (meta != null && newPage > meta!.pages) return;
    _fetchPage(pageToFetch: newPage);
  }

  Future<void> _refreshListings() async {
    await _fetchPage(pageToFetch: 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryName = widget.category.getDisplayNameLocalized(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshListings,
        child: Column(
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  l10n?.failedToLoadCategory(categoryName) ?? 'Failed to load $categoryName: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: isLoading && agents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : agents.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 80),
                                Center(child: Text(l10n?.noServicesFound ?? 'No services found')),
                              ],
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: agents.map((agent) {
                                  return SizedBox(
                                    width: (MediaQuery.of(context).size.width - 48) / 2,
                                    child: AgentCard(
                                      agent: agent,
                                      showPropertyCount: false,
                                      onTap: _onAgentTap,
                                      width: null,
                                      margin: EdgeInsets.zero,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
            ),
            // Pagination controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: (meta == null || page <= 1) ? null : () => _goToPage(page - 1),
                    child: Text(l10n?.previous ?? 'Previous'),
                  ),
                  Text('${l10n?.page ?? 'Page'} ${meta?.page ?? page} ${l10n?.ofText ?? 'of'} ${meta?.pages ?? '?'}'),
                  ElevatedButton(
                    onPressed: (meta == null || (meta!.pages != 0 && page >= meta!.pages)) ? null : () => _goToPage(page + 1),
                    child: Text(l10n?.next ?? 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}