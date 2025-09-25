import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ServiceProviderIndividualDashboardPage extends StatelessWidget {
  const ServiceProviderIndividualDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user?.name ?? 'Service Provider',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Individual Service Provider',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats section
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Active Jobs', '8', Icons.build, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Completed', '45', Icons.check_circle, Colors.green),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Monthly Earnings', '\$3.2K', Icons.attach_money, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Rating', '4.7', Icons.star, Colors.purple),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions
            const Text(
              'Service Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    'Available Jobs',
                    Icons.work,
                    Colors.blue,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Available Jobs feature coming soon')),
                    ),
                  ),
                  _buildActionCard(
                    'My Services',
                    Icons.handyman,
                    Colors.green,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('My Services feature coming soon')),
                    ),
                  ),
                  _buildActionCard(
                    'Schedule',
                    Icons.schedule,
                    Colors.orange,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule feature coming soon')),
                    ),
                  ),
                  _buildActionCard(
                    'Client Reviews',
                    Icons.rate_review,
                    Colors.purple,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Client Reviews feature coming soon')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
