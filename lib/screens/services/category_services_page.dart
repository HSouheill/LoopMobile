import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../models/service_provider.dart';
import '../../screens/services/service_provider_detail_page.dart';
import '../../widgets/vertical_services_widget.dart';
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
      } else if (widget.category == ServiceCategory.topRated) {
        // top rated: use topRated param
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

      // Convert service providers to agents
      final agentList = resp.users.map((provider) {
        return Agent.fromJson(provider.toAgentJson());
      }).toList();

      if (!mounted) return;
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

  void _goToPage(int newPage) {
    if (newPage < 1) return;
    if (meta != null && newPage > meta!.pages) return;
    _fetchPage(pageToFetch: newPage);
  }

  Future<void> _onRefresh() async {
    await _fetchPage(pageToFetch: 1);
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

  @override
  Widget build(BuildContext context) {
    final title = widget.category.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: isLoading && agents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Failed to load $title: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: agents.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text('No services found')),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                // Use VerticalServicesWidget for stacked card layout
                                VerticalServicesWidget(
                                  title: title,
                                  agents: agents,
                                  showPropertyCount: false,
                                  onAgentTap: _onAgentTap,
                                ),
                                const SizedBox(height: 20),
                              ],
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
