import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Mock admin data
  final Map<String, dynamic> _adminStats = {
    'totalUsers': 15420,
    'activeProviders': 892,
    'totalBookings': 8765,
    'revenue': 45678.90,
    'pendingApprovals': 23,
    'supportTickets': 12,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _getSelectedWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF006B3C),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Providers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildProvidersTab();
      case 3:
        return _buildAnalyticsTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Total Users',
                _adminStats['totalUsers'].toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                'Active Providers',
                _adminStats['activeProviders'].toString(),
                Icons.verified,
                Colors.green,
              ),
              _buildStatCard(
                'Total Bookings',
                _adminStats['totalBookings'].toString(),
                Icons.book_online,
                Colors.orange,
              ),
              _buildStatCard(
                'Revenue',
                'GH₵${_adminStats['revenue'].toStringAsFixed(0)}',
                Icons.monetization_on,
                const Color(0xFF006B3C),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            'New Provider Registration',
            'Kwame Asante registered as a plumber',
            '2 minutes ago',
            Icons.person_add,
            Colors.green,
          ),
          _buildActivityCard(
            'High Value Booking',
            'Wedding package booked for GH₵2,500',
            '15 minutes ago',
            Icons.star,
            Colors.amber,
          ),
          _buildActivityCard(
            'Support Ticket',
            'Payment issue reported by customer',
            '1 hour ago',
            Icons.support_agent,
            Colors.red,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Pending Approvals',
                  '${_adminStats['pendingApprovals']}',
                  Icons.approval,
                  Colors.orange,
                  () => _showPendingApprovals(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Support Tickets',
                  '${_adminStats['supportTickets']}',
                  Icons.support,
                  Colors.red,
                  () => _showSupportTickets(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('User Management'),
          Text('Manage customers, providers, and staff'),
        ],
      ),
    );
  }

  Widget _buildProvidersTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Provider Management'),
          Text('Approve, monitor, and manage service providers'),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Analytics & Reports'),
          Text('View platform performance metrics'),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Admin Settings'),
          Text('Configure app settings and policies'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String description, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, String badge, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                children: [
                  Icon(icon, size: 32, color: color),
                  if (badge != '0')
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('5 new notifications')),
    );
  }

  void _showPendingApprovals() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening pending approvals...')),
    );
  }

  void _showSupportTickets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening support tickets...')),
    );
  }

  void _logout() {
    // Local logout - just navigate back
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}