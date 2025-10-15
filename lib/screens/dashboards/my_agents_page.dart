import 'package:flutter/material.dart';
import '../../services/agent_service.dart';
import '../../environment.dart';
import 'agent_company_dashboard_screens/edit_agent_screen.dart';

class MyAgentsPage extends StatefulWidget {
  const MyAgentsPage({super.key});

  @override
  State<MyAgentsPage> createState() => _MyAgentsPageState();
}

class _MyAgentsPageState extends State<MyAgentsPage> {
  List<Map<String, dynamic>> agents = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  int totalAgents = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        agents.clear();
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await AgentService.getMyAgents(
        page: currentPage,
        limit: limit,
      );
      
      setState(() {
        if (refresh) {
          agents = List<Map<String, dynamic>>.from(response['agents'] ?? []);
        } else {
          agents.addAll(List<Map<String, dynamic>>.from(response['agents'] ?? []));
        }
        
        totalPages = response['meta']?['pages'] ?? 1;
        totalAgents = response['meta']?['total'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading agents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading agents: $e')),
      );
    }
  }

  Future<void> _loadMoreAgents() async {
    if (currentPage < totalPages && !isLoading) {
      setState(() {
        currentPage++;
      });
      await _loadAgents();
    }
  }

  Future<void> _refreshAgents() async {
    await _loadAgents(refresh: true);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Agents'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAgents,
        child: Column(
          children: [
            // Header with total count
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Agents: $totalAgents',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Page $currentPage of $totalPages',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Agents list
            Expanded(
              child: isLoading && agents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : agents.isEmpty
                      ? const Center(
                          child: Text(
                            'No agents found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: agents.length + (currentPage < totalPages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == agents.length) {
                              // Load more button
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: isLoading
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: _loadMoreAgents,
                                          child: const Text('Load More'),
                                        ),
                                ),
                              );
                            }

                            final agent = agents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Profile image
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: agent['profileImage'] != null
                                          ? NetworkImage('${Environment.apiUrl}assets/${agent['profileImage']}')
                                          : null,
                                      child: agent['profileImage'] == null
                                          ? const Icon(Icons.person, size: 30)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Agent info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${agent['firstName'] ?? ''} ${agent['lastName'] ?? ''}'.trim(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            agent['email'] ?? 'No email',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            agent['phone'] ?? 'No phone',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${agent['city'] ?? ''}, ${agent['country'] ?? ''}'.trim(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Edit button and date
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _handleEditAgent(context, agent);
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xFF0048FF),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Joined: ${_formatDate(agent['createdAt'])}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditAgent(BuildContext context, Map<String, dynamic> agent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAgentScreen(agent: agent),
      ),
    );
    
    if (result == true) {
      // Refresh the agents list after successful edit
      await _refreshAgents();
    }
  }
}
