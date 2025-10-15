import 'package:flutter/material.dart';
import '../agent_company_dashboard_screens/edit_agent_screen.dart';

class AgentListSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function()? onAgentUpdated;

  const AgentListSection({super.key, required this.items, this.onAgentUpdated});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: items.map((agent) {
        return Column(
          children: [
            // 🟢 Agent row
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 40, bottom: 8),
              child: Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left section: image + name + edit
                    Row(
                      children: [
                        // 🟦 Circular image
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0048FF),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: agent['imageUrl'] != null && agent['imageUrl'].toString().isNotEmpty
                                ? Image.network(
                                    agent['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Image.asset('assets/defaultProfileImage.png'),
                                  )
                                : Image.asset('assets/defaultProfileImage.png'),
                          ),
                        ),
                        const SizedBox(width: 5),

                        // 👤 Full name + Edit in same row
                        Row(
                          children: [
                            Text(
                              agent['fullName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                _handleEditAgent(context, agent);
                              },
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: Color(0xFF0048FF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF0048FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Right section: Joined + date (same row)
                    Row(
                      children: [
                        const Text(
                          'Joined ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          agent['joinedDate'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 💙 Continuous Divider (blue with white edges)
            Center(
              child: Container(
                width: screenWidth * 0.9,
                height: 0.8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFF0048FF),
                      Color(0xFF0048FF),
                      Colors.white,
                    ],
                    stops: [0.0, 0.15, 0.85, 1.5],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  void _handleEditAgent(BuildContext context, Map<String, dynamic> agent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAgentScreen(agent: agent),
      ),
    );
    
    if (result == true && onAgentUpdated != null) {
      onAgentUpdated!();
    }
  }
}
