import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/agent_service.dart';
import '../../widgets/recommended_agents_widget.dart';
import 'single_agent_page.dart';

class AgentSearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const AgentSearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<AgentSearchResultsPage> createState() => _AgentSearchResultsPageState();
}

class _AgentSearchResultsPageState extends State<AgentSearchResultsPage> {
  List<Agent> agents = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 1;
  bool hasMoreData = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchAgents();
  }

  Future<void> _searchAgents({bool loadMore = false}) async {
    if (!mounted) return;

    if (loadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
        currentPage = 1;
        hasMoreData = true;
      });
    }

    try {
      final response = await AgentService.searchAgents(
        query: widget.searchQuery,
        page: currentPage,
        limit: 20,
      );

      if (mounted) {
        // Parse the response to get agents
        List<dynamic> agentsJson = [];
        if (response['users'] != null) {
          agentsJson = response['users'] as List<dynamic>;
        }

        final newAgents = agentsJson.map((json) => Agent.fromJson(json)).toList();

        setState(() {
          if (loadMore) {
            agents.addAll(newAgents);
            isLoadingMore = false;
          } else {
            agents = newAgents;
            isLoading = false;
          }
          
          hasMoreData = newAgents.length == 20; // If we got less than 20, no more data
          currentPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = e.toString();
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  void _loadMore() {
    if (!isLoadingMore && hasMoreData) {
      _searchAgents(loadMore: true);
    }
  }

  void _retry() {
    _searchAgents();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.searchResultsFor(widget.searchQuery) ?? 'Search Results for "${widget.searchQuery}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search info header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        l10n?.foundAgentsFor(agents.length, widget.searchQuery) ?? 'Found ${agents.length} agents for "${widget.searchQuery}"',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          
          // Results content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                return Text(AppLocalizations.of(context)?.searchingAgents ?? 'Searching agents...');
              }
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.errorSearchingAgents ?? 'Error searching agents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retry,
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (agents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noAgentsFound ?? 'No agents found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.tryDifferentKeywordsAgent ?? 'Try searching with different keywords',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            hasMoreData &&
            !isLoadingMore) {
          _loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: agents.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == agents.length) {
            // Loading indicator for pagination
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }

          final agent = agents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: AgentCard(
              agent: agent,
              showPropertyCount: true,
              onTap: (selectedAgent) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleAgentPage(agent: selectedAgent),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
