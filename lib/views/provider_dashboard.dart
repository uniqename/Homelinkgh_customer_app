import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/service_types.dart';
import 'calendar.dart';
import 'available_jobs.dart';
import 'earnings_dashboard.dart';
import 'provider_profile.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _selectedIndex = 0;
  bool isLoading = false;
  
  // Mock provider service types - in real app, get from provider profile
  final List<String> providerServices = [
    'House Cleaning',
    'Plumbing',
    'Electrical Services'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderCalendar(),
                ),
              );
            },
          ),
        ],
      ),
      body: _getSelectedWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Available Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return AvailableJobsScreen(providerServices: providerServices);
      case 2:
        return const ProviderCalendar();
      case 3:
        return const EarningsDashboard();
      case 4:
        return const ProviderProfile();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingJobs = 3;
    final acceptedJobs = 2;
    final completedJobs = 15;
    final totalEarnings = 2400.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Pending', pendingJobs.toString(), Colors.orange, Icons.pending),
                      _buildStatCard('Active', acceptedJobs.toString(), Colors.green, Icons.work),
                      _buildStatCard('Completed', completedJobs.toString(), Colors.blue, Icons.check_circle),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                        Text(
                          'GH₵${totalEarnings.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Service Specialties
          const Text(
            'Your Service Specialties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: providerServices.length,
              itemBuilder: (context, index) {
                final service = providerServices[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ServiceTypes.getIconForService(service)),
                      const SizedBox(width: 4),
                      Text(service),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Recent Jobs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Switch to Available Jobs tab
                  });
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildJobCard('House Cleaning - East Legon'),
                _buildJobCard('Food Delivery - Osu'),
                _buildJobCard('Plumbing Service - Airport'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildJobCard(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.work, color: Colors.white),
        ),
        title: Text(title),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample job description',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('📍 East Legon, Accra'),
            Text('📅 Dec 25, 2024'),
          ],
        ),
        trailing: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GH₵150',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'ACTIVE',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showJobDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Job Details'),
        content: const Text('Local job details will be shown here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}