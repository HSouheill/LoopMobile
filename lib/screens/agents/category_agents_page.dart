import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
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
            agentType: 'individual',
          );
          break;
        case AgentCategory.topRated:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            minRating: '4.5',
            sort: 'featured',
            agentType: 'individual',
          );
          break;
        case AgentCategory.forYou:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            personalized: true,
            sort: 'featured',
            agentType: 'individual',
          );
          break;
        case AgentCategory.featuredCompanies:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            isFeatured: true,
            sort: 'featured',
            agentType: 'company',
          );
          break;
        case AgentCategory.topCompanies:
          resp = await AgentService.getAllAgents(
            page: pageToFetch,
            limit: limit,
            minRating: '4.5',
            sort: 'featured',
            agentType: 'company',
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

  String title(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (widget.category) {
      case AgentCategory.featured:
        return l10n?.featuredAgents ?? 'Featured Agents';
      case AgentCategory.topRated:
        return l10n?.topRatedAgents ?? 'Top Rated Agents';
      case AgentCategory.forYou:
        return l10n?.recommendedAgentsTitle ?? 'Recommended Agents';
      case AgentCategory.featuredCompanies:
        return l10n?.featuredCompanies ?? 'Featured Companies';
      case AgentCategory.topCompanies:
        return l10n?.topCompanies ?? 'Top Companies';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title(context)),
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
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            l10n?.failedToLoadAgents(title(context)) ?? 'Failed to load ${title(context)}: $error',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                      ),
                    ),
                  Expanded(
                    child: agents.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Center(child: Text(l10n?.noAgentsFoundCategory ?? 'No agents found')),
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
