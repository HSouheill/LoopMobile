import 'package:flutter/material.dart';
import '../../services/agent_service.dart';
import '../recommended_agents_widget.dart';

class FeaturedAgentsWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool isMainPage;

  const FeaturedAgentsWidget({
    super.key,
    required this.title,
    this.onSeeAll,
    this.isMainPage = true,
  });

  @override
  State<FeaturedAgentsWidget> createState() => _FeaturedAgentsWidgetState();
}

class _FeaturedAgentsWidgetState extends State<FeaturedAgentsWidget> {
  List<Agent> agents = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFeaturedAgents();
  }

  Future<void> _loadFeaturedAgents() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetched = await AgentService.getFeaturedAgents(
        limit: widget.isMainPage ? 3 : 10,
      );

      setState(() {
        agents = fetched;
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (widget.isMainPage)
                TextButton(
                  onPressed: widget.onSeeAll,
                  child: const Text('See all'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const SizedBox(
            height: 330,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          SizedBox(
            height: 330,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load agents',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFeaturedAgents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (agents.isEmpty)
          const SizedBox(
            height: 330,
            child: Center(
              child: Text('No featured agents found'),
            ),
          )
        else
          SizedBox(
            height: 330,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // <- aligns with the title padding
              scrollDirection: Axis.horizontal,
              itemCount: agents.length,
              itemBuilder: (context, index) {
                return Padding(
                  // small gap between cards; edges remain aligned because of ListView padding above
                  padding: EdgeInsets.only(
                      right: index == agents.length - 1 ? 0 : 12.0),
                  child: AgentCard(
                    agent: agents[index],
                    showPropertyCount: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
