import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../services/job_service.dart';
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
  List<Job> myJobs = [];
  bool isLoading = true;
  
  // Mock provider service types - in real app, get from provider profile
  final List<String> providerServices = [
    'House Cleaning',
    'Plumbing',
    'Electrical Services'
  ];

  @override
  void initState() {
    super.initState();
    _loadProviderJobs();
  }

  void _loadProviderJobs() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      JobService.getProviderJobs(user.uid).listen((jobs) {
        setState(() {
          myJobs = jobs;
          isLoading = false;
        });
      });
    }
  }

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

    final pendingJobs = myJobs.where((job) => job.status == 'pending').length;
    final acceptedJobs = myJobs.where((job) => job.status == 'accepted' || job.status == 'in_progress').length;
    final completedJobs = myJobs.where((job) => job.status == 'completed').length;
    final totalEarnings = myJobs.where((job) => job.status == 'completed').fold(0.0, (sum, job) => sum + job.price);

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
            child: myJobs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No jobs yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Check the Available Jobs tab to find work',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: myJobs.take(5).length, // Show only recent 5
                    itemBuilder: (context, index) {
                      final job = myJobs[index];
                      return _buildJobCard(job);
                    },
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

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(job.status).withValues(alpha: 0.2),
          child: Text(ServiceTypes.getIconForService(job.serviceType)),
        ),
        title: Text('${job.serviceType} - ${job.customerName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('📍 ${job.address}'),
            Text('📅 ${DateFormat('MMM dd, yyyy - hh:mm a').format(job.scheduledDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GH₵${job.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(job.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                job.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _showJobDetails(job);
        },
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

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${job.serviceType} Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Customer:', job.customerName),
              _buildDetailRow('Service:', job.serviceType),
              _buildDetailRow('Location:', job.address),
              _buildDetailRow('Date:', DateFormat('MMM dd, yyyy').format(job.scheduledDate)),
              _buildDetailRow('Time:', DateFormat('hh:mm a').format(job.scheduledDate)),
              _buildDetailRow('Price:', 'GH₵${job.price.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(job.description),
              if (job.requirements.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...job.requirements.map((req) => Text('• $req')),
              ],
              if (job.specialInstructions != null) ...[
                const SizedBox(height: 8),
                const Text('Special Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(job.specialInstructions!),
              ],
            ],
          ),
        ),
        actions: [
          if (job.status == 'accepted') ...[
            TextButton(
              onPressed: () async {
                final success = await JobService.updateJobStatus(job.id, 'in_progress');
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job started!')),
                  );
                }
              },
              child: const Text('Start Job'),
            ),
          ],
          if (job.status == 'in_progress') ...[
            TextButton(
              onPressed: () async {
                final success = await JobService.updateJobStatus(job.id, 'completed');
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job completed!')),
                  );
                }
              },
              child: const Text('Complete Job'),
            ),
          ],
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