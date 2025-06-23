import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'BK001',
      'service': 'Food Delivery',
      'customer': 'Kwame Asante',
      'provider': 'QuickRider Express',
      'date': '2024-06-22',
      'time': '10:00 AM',
      'status': 'completed',
      'amount': 'GH₵45.50'
    },
    {
      'id': 'BK002',
      'service': 'House Cleaning',
      'customer': 'Akosua Mensah',
      'provider': 'CleanPro Services',
      'date': '2024-06-23',
      'time': '2:00 PM',
      'status': 'in_progress',
      'amount': 'GH₵120.00'
    },
    {
      'id': 'BK003',
      'service': 'Nail Tech',
      'customer': 'Kofi Boateng',
      'provider': 'Lisa Beauty',
      'date': '2024-06-21',
      'time': '9:00 AM',
      'status': 'pending',
      'amount': 'GH₵80.00'
    },
    {
      'id': 'BK004',
      'service': 'Plumbing',
      'customer': 'Alice Osei',
      'provider': 'Mike Johnson',
      'date': '2024-06-24',
      'time': '11:00 AM',
      'status': 'completed',
      'amount': 'GH₵200.00'
    },
    {
      'id': 'BK005',
      'service': 'Babysitting',
      'customer': 'Emma Adjei',
      'provider': 'Mary Caregiver',
      'date': '2024-06-25',
      'time': '6:00 PM',
      'status': 'confirmed',
      'amount': 'GH₵150.00'
    },
  ];

  final List<Map<String, dynamic>> _providers = [
    {
      'id': 'P001',
      'name': 'Mike Johnson',
      'services': ['Plumbing', 'HVAC'],
      'rating': 4.8,
      'jobs_completed': 156,
      'status': 'active',
      'verification': 'verified',
      'joined': '2024-01-15'
    },
    {
      'id': 'P002',
      'name': 'Lisa Beauty',
      'services': ['Nail Tech', 'Makeup'],
      'rating': 4.9,
      'jobs_completed': 89,
      'status': 'active',
      'verification': 'verified',
      'joined': '2024-02-20'
    },
    {
      'id': 'P003',
      'name': 'CleanPro Services',
      'services': ['House Cleaning', 'Laundry'],
      'rating': 4.7,
      'jobs_completed': 234,
      'status': 'active',
      'verification': 'verified',
      'joined': '2024-01-08'
    },
    {
      'id': 'P004',
      'name': 'QuickRider Express',
      'services': ['Food Delivery', 'Grocery'],
      'rating': 4.6,
      'jobs_completed': 456,
      'status': 'active',
      'verification': 'verified',
      'joined': '2024-03-01'
    },
    {
      'id': 'P005',
      'name': 'Mary Caregiver',
      'services': ['Babysitting', 'Elder Care'],
      'rating': 4.9,
      'jobs_completed': 67,
      'status': 'pending',
      'verification': 'pending',
      'joined': '2024-06-15'
    },
  ];

  final List<Map<String, dynamic>> _jobSeekers = [
    {
      'id': 'JS001',
      'name': 'Samuel Owusu',
      'interests': ['Food Delivery', 'Grocery'],
      'experience': 'No Experience',
      'location': 'Accra',
      'status': 'reviewing',
      'applied': '2024-06-20'
    },
    {
      'id': 'JS002',
      'name': 'Grace Mensah',
      'interests': ['House Cleaning', 'Laundry'],
      'experience': 'Some Experience',
      'location': 'Kumasi',
      'status': 'interview_scheduled',
      'applied': '2024-06-19'
    },
    {
      'id': 'JS003',
      'name': 'Kwame Asante',
      'interests': ['Plumbing', 'Electrical'],
      'experience': 'Experienced',
      'location': 'Takoradi',
      'status': 'training',
      'applied': '2024-06-10'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeLinkGH Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('3 new notifications')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOverview(),
          _buildBookingsTab(),
          _buildProvidersTab(),
          _buildJobSeekersTab(),
          _buildReportsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Providers',
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            label: 'Job Seekers',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Bookings', '1,247', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Active Providers', '42', Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard('Job Seekers', '18', Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Revenue', 'GH₵45,820', Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(booking['status']),
                      child: Text(booking['id'].substring(2)),
                    ),
                    title: Text('${booking['service']} - ${booking['customer']}'),
                    subtitle: Text('Provider: ${booking['provider']}'),
                    trailing: Text(booking['amount']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Bookings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(booking['status']),
                      child: Text(booking['id'].substring(2)),
                    ),
                    title: Text('${booking['service']} - ${booking['customer']}'),
                    subtitle: Text('${booking['date']} at ${booking['time']}'),
                    trailing: Text(booking['amount']),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Provider: ${booking['provider']}'),
                            Text('Status: ${booking['status']}'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Contacting ${booking['customer']}')),
                                    );
                                  },
                                  child: const Text('Contact Customer'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Contacting ${booking['provider']}')),
                                    );
                                  },
                                  child: const Text('Contact Provider'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Providers',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: provider['status'] == 'active' ? Colors.green : Colors.grey,
                      child: Text(provider['name'][0]),
                    ),
                    title: Text(provider['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Services: ${(provider['services'] as List<String>).join(', ')}'),
                        Text('Rating: ${provider['rating']} ⭐'),
                        Text('Jobs Completed: ${provider['jobs_completed']}'),
                        Text('Joined: ${provider['joined']}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: provider['status'] == 'active' ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        provider['status'].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    onTap: () {
                      _showProviderDetails(provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSeekersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Seeker Applications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _jobSeekers.length,
              itemBuilder: (context, index) {
                final jobSeeker = _jobSeekers[index];
                return Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getJobSeekerStatusColor(jobSeeker['status']),
                      child: Text(jobSeeker['name'][0]),
                    ),
                    title: Text(jobSeeker['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Interests: ${(jobSeeker['interests'] as List<String>).join(', ')}'),
                        Text('Experience: ${jobSeeker['experience']}'),
                        Text('Location: ${jobSeeker['location']}'),
                        Text('Applied: ${jobSeeker['applied']}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getJobSeekerStatusColor(jobSeeker['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        jobSeeker['status'].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${jobSeeker['id']}'),
                            const SizedBox(height: 8),
                            const Text('Application Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_getJobSeekerStatusText(jobSeeker['status'])),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _updateJobSeekerStatus(jobSeeker, 'interview_scheduled');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                  child: const Text('Schedule Interview', style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateJobSeekerStatus(jobSeeker, 'training');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                  child: const Text('Start Training', style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Contacting ${jobSeeker['name']}')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Contact', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('📊 Detailed analytics coming soon!'),
                  SizedBox(height: 8),
                  Text('• Revenue trends'),
                  Text('• Service popularity'),
                  Text('• Provider performance'),
                  Text('• Customer satisfaction'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getJobSeekerStatusColor(String status) {
    switch (status) {
      case 'reviewing':
        return Colors.blue;
      case 'interview_scheduled':
        return Colors.orange;
      case 'training':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getJobSeekerStatusText(String status) {
    switch (status) {
      case 'reviewing':
        return 'Application under review by our team';
      case 'interview_scheduled':
        return 'Interview scheduled - candidate will be contacted soon';
      case 'training':
        return 'Currently in training program';
      case 'completed':
        return 'Training completed - ready to become provider';
      default:
        return 'Unknown status';
    }
  }

  void _updateJobSeekerStatus(Map<String, dynamic> jobSeeker, String newStatus) {
    setState(() {
      jobSeeker['status'] = newStatus;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ${jobSeeker['name']} status to $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showProviderDetails(Map<String, dynamic> provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Services: ${(provider['services'] as List<String>).join(', ')}'),
            Text('Rating: ${provider['rating']} ⭐'),
            Text('Jobs Completed: ${provider['jobs_completed']}'),
            Text('Status: ${provider['status']}'),
            Text('Verification: ${provider['verification']}'),
            Text('Joined: ${provider['joined']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contacting ${provider['name']}')),
              );
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}