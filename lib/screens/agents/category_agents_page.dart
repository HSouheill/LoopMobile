import 'package:flutter/material.dart';
import '../../widgets/agent_widgets/agent_service.dart';
import '../../widgets/dynamic_agents_widget.dart'; // For AgentCategory enum
import '../../widgets/recommended_agents_widget.dart'; // For AgentCard

class CategoryAgentsPage extends StatefulWidget {
  final AgentCategory category;

  const CategoryAgentsPage({super.key, required this.category});

  @override
  State<CategoryAgentsPage> createState() => _CategoryAgentsPageState();
}

class _CategoryAgentsPageState extends State<CategoryAgentsPage> {
  int page = 1;
  final int limit = 10;
  bool isLoading = false;
  String? error;
  List<Agent> agents = [];
  AgentMeta? meta;

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
      AgentsResponse resp;

      switch (widget.category) {
        case AgentCategory.featured:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            isFeatured: true,
            sort: 'featured',
          );
          break;
        case AgentCategory.topRated:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            minRating: '4.5',
            sort: 'featured',
          );
          break;
        case AgentCategory.forYou:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            personalized: true,
            sort: 'featured',
          );
          break;
      }

      if (!mounted) return;
      setState(() {
        agents = resp.agents;
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

  String get title {
    switch (widget.category) {
      case AgentCategory.featured:
        return 'Featured Agents';
      case AgentCategory.topRated:
        return 'Top Rated Agents';
      case AgentCategory.forYou:
        return 'Recommended Agents';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              Center(child: Text('No agents found')),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: agents.length,
                            itemBuilder: (context, index) {
                              final agent = agents[index];
                              return AgentCard(
                                agent: agent,
                                showPropertyCount: true,
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
