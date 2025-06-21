import 'package:flutter/material.dart';
import 'earnings_dashboard.dart';
import 'food_delivery_tracking.dart';
import 'restaurant_dashboard.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _jobRequests = [
    {
      'id': 'JR001',
      'service': 'Plumbing',
      'customer': 'John Smith',
      'location': '123 Main St, Accra',
      'date': '2024-06-22',
      'time': '10:00 AM',
      'description': 'Fix leaky kitchen faucet and check water pressure',
      'price': '₵150',
      'status': 'pending',
      'distance': '2.3 km away',
    },
    {
      'id': 'JR002',
      'service': 'Electrical',
      'customer': 'Sarah Johnson',
      'location': '456 Oak Ave, Kumasi',
      'date': '2024-06-23',
      'time': '2:00 PM',
      'description': 'Install ceiling fan in bedroom',
      'price': '₵200',
      'status': 'pending',
      'distance': '1.8 km away',
    },
    {
      'id': 'JR003',
      'service': 'Cleaning',
      'customer': 'Mike Davis',
      'location': '789 Pine Rd, Takoradi',
      'date': '2024-06-21',
      'time': '9:00 AM',
      'description': 'Deep clean 3-bedroom house, including bathrooms',
      'price': '₵300',
      'status': 'accepted',
      'distance': '0.5 km away',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(),
          _buildJobsTab(),
          _buildEarningsTab(),
          _buildProfileTab(),
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
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Colors.green,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Provider Dashboard'),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green, Colors.teal],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2 new job requests')),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Pending', '2', Colors.orange)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Accepted', '1', Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Completed', '15', Colors.blue)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'View Jobs',
                        Icons.work,
                        Colors.blue,
                        () => setState(() => _selectedIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Earnings',
                        Icons.attach_money,
                        Colors.green,
                        () => setState(() => _selectedIndex = 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Recent Job Requests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Job Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _jobRequests.take(3).length,
                  itemBuilder: (context, index) {
                    final job = _jobRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(job['status']),
                          child: Text(job['id'].substring(2)),
                        ),
                        title: Text('${job['service']} - ${job['customer']}'),
                        subtitle: Text(job['description']),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              job['price'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              job['distance'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showJobDetails(job),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Available Jobs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _jobRequests.length,
              itemBuilder: (context, index) {
                final job = _jobRequests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(job['status']),
                      child: Text(job['id'].substring(2)),
                    ),
                    title: Text('${job['service']} - ${job['customer']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📍 ${job['location']}'),
                        Text('📅 ${job['date']} at ${job['time']}'),
                        Text('📏 ${job['distance']}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          job['price'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(job['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job['status'].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(job['description']),
                            const SizedBox(height: 16),
                            if (job['status'] == 'pending')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        job['status'] = 'accepted';
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Job accepted!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Job declined')),
                                      );
                                    },
                                    child: const Text('Decline'),
                                  ),
                                ],
                              ),
                            if (job['status'] == 'accepted')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Calling ${job['customer']}')),
                                      );
                                    },
                                    icon: const Icon(Icons.phone),
                                    label: const Text('Call Customer'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        job['status'] = 'completed';
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Job marked as completed!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Mark Complete'),
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

  Widget _buildEarningsTab() {
    return const EarningsDashboard();
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mike Johnson',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Professional Plumber',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 20),
              const Text(' 4.8 (156 reviews)'),
            ],
          ),
          const SizedBox(height: 32),
          _buildProfileOption(
            icon: Icons.work,
            title: 'My Services',
            subtitle: 'Plumbing, HVAC',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.schedule,
            title: 'Availability',
            subtitle: 'Set your working hours',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.wallet,
            title: 'Wallet',
            subtitle: 'Withdraw earnings',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.star_rate,
            title: 'Reviews',
            subtitle: 'View customer feedback',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get help with your account',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Account preferences',
            onTap: () {},
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

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPaymentItem(String title, String amount, String status, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status == 'Paid' ? Colors.green : Colors.orange,
          child: Icon(
            status == 'Paid' ? Icons.check : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                color: status == 'Paid' ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
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
      case 'accepted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${job['service']} Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${job['customer']}'),
            Text('Location: ${job['location']}'),
            Text('Date: ${job['date']}'),
            Text('Time: ${job['time']}'),
            Text('Distance: ${job['distance']}'),
            const SizedBox(height: 8),
            Text('Description: ${job['description']}'),
            const SizedBox(height: 8),
            Text('Price: ${job['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (job['status'] == 'pending')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  job['status'] = 'accepted';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job accepted!')),
                );
              },
              child: const Text('Accept'),
            ),
        ],
      ),
    );
  }
}