import 'package:flutter/material.dart';
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
          sort: 'date_desc',
        );
      } else if (widget.category == ServiceCategory.featuredCompanies) {
        // featured companies: combine isFeatured with providerType=company
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          isFeatured: true,
          providerType: 'company',
          sort: 'date_desc',
        );
      } else if (widget.category == ServiceCategory.topRated) {
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          sort: 'rating_desc',
        );
      } else {
        // types (company / individual)
        resp = await ServiceService.getAllServiceProviders(
          page: pageToFetch,
          limit: limit,
          providerType: widget.category.providerType,
          sort: 'date_desc',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.displayName),
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
                  'Failed to load ${widget.category.displayName}: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: isLoading && agents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : agents.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 80),
                                Center(child: Text('No services found')),
                              ],
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: agents.length,
                              itemBuilder: (context, index) {
                                final agent = agents[index];
                                return AgentCard(
                                  agent: agent,
                                  showPropertyCount: false,
                                  onTap: _onAgentTap,
                                );
                              },
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
                    child: const Text('Previous'),
                  ),
                  Text('Page ${meta?.page ?? page} of ${meta?.pages ?? '?'}'),
                  ElevatedButton(
                    onPressed: (meta == null || (meta!.pages != 0 && page >= meta!.pages)) ? null : () => _goToPage(page + 1),
                    child: const Text('Next'),
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