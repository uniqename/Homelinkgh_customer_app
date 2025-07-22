import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'notification_screen.dart';
import 'admin_pending_approvals_screen.dart';
import 'admin_support_tickets_screen.dart';
import 'admin_commission_management_screen.dart';
import 'admin_service_configuration_screen.dart';
import 'admin_service_areas_screen.dart';
import 'admin_policy_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final NotificationService _notificationService = NotificationService();

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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(),
              ),
              if (_notificationService.getUnreadCount('admin') > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_notificationService.getUnreadCount('admin')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
    final List<Map<String, dynamic>> users = [
      {
        'name': 'Akosua Mensah',
        'email': 'akosua.mensah@email.com',
        'type': 'Customer',
        'joinDate': '2024-01-15',
        'status': 'Active',
        'totalBookings': 12,
      },
      {
        'name': 'Kwame Asante',
        'email': 'kwame.asante@email.com',
        'type': 'Provider',
        'joinDate': '2024-02-10',
        'status': 'Verified',
        'totalBookings': 45,
      },
      {
        'name': 'Ama Osei',
        'email': 'ama.osei@email.com',
        'type': 'Diaspora Customer',
        'joinDate': '2024-03-05',
        'status': 'Active',
        'totalBookings': 8,
      },
      {
        'name': 'Joseph Nkrumah',
        'email': 'joseph.nkrumah@email.com',
        'type': 'Customer',
        'joinDate': '2024-03-20',
        'status': 'Pending Verification',
        'totalBookings': 0,
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewUser,
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getUserTypeColor(user['type']),
                    child: Text(
                      user['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email']),
                      Text('${user['type']} • ${user['totalBookings']} bookings'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(user['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['joinDate'],
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () => _showUserDetails(user),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersTab() {
    final List<Map<String, dynamic>> providers = [
      {
        'name': 'Kwame Plumbing Services',
        'owner': 'Kwame Asante',
        'services': ['Plumbing', 'Water Systems'],
        'rating': 4.8,
        'totalJobs': 156,
        'status': 'Verified',
        'location': 'East Legon, Accra',
        'joinDate': '2024-01-10',
      },
      {
        'name': 'Akosua Cleaning Co.',
        'owner': 'Akosua Mensah',
        'services': ['House Cleaning', 'Office Cleaning'],
        'rating': 4.9,
        'totalJobs': 203,
        'status': 'Verified',
        'location': 'Osu, Accra',
        'joinDate': '2024-02-15',
      },
      {
        'name': 'Ama Beauty Studio',
        'owner': 'Ama Osei',
        'services': ['Hair Styling', 'Makeup'],
        'rating': 4.7,
        'totalJobs': 89,
        'status': 'Pending Review',
        'location': 'Tema, Greater Accra',
        'joinDate': '2024-03-22',
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Provider Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _reviewApplications,
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Review Apps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addNewProvider,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Provider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3C),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF006B3C),
                            child: Text(
                              provider['name'][0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Owner: ${provider['owner']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(provider['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              provider['status'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: (provider['services'] as List<String>).map((service) => 
                          Chip(
                            label: Text(service),
                            backgroundColor: const Color(0xFF006B3C).withValues(alpha: 0.1),
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${provider['rating']} (${provider['totalJobs']} jobs)'),
                          const SizedBox(width: 16),
                          Icon(Icons.location_on, color: Colors.grey, size: 16),
                          Text(' ${provider['location']}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _viewProviderDetails(provider),
                            child: const Text('View Details'),
                          ),
                          ElevatedButton(
                            onPressed: () => _manageProvider(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006B3C),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Manage'),
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
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Revenue Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Revenue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Revenue Chart\n(Chart implementation needed)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Service Categories Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Category Performance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildServiceMetric('House Cleaning', 45, Colors.blue),
                  _buildServiceMetric('Food Delivery', 32, Colors.orange),
                  _buildServiceMetric('Plumbing', 28, Colors.green),
                  _buildServiceMetric('Beauty Services', 22, Colors.pink),
                  _buildServiceMetric('Transportation', 18, Colors.purple),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Key Metrics
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_up, size: 32, color: Colors.green),
                        const SizedBox(height: 8),
                        const Text(
                          'Growth Rate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '+23.5%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('vs last month', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.sentiment_satisfied, size: 32, color: Colors.amber),
                        const SizedBox(height: 8),
                        const Text(
                          'Avg Rating',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '4.7',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                        const Text('out of 5 stars', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Admin Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        // Platform Settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Platform Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('New User Registration'),
                  subtitle: const Text('Allow new users to register'),
                  value: true,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Provider Applications'),
                  subtitle: const Text('Accept new provider applications'),
                  value: true,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Maintenance Mode'),
                  subtitle: const Text('Enable maintenance mode'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Service Configuration
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Configuration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Commission Rates'),
                  subtitle: const Text('Manage platform commission rates'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _manageCommissionRates,
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Service Areas'),
                  subtitle: const Text('Manage available service locations'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _manageServiceAreas,
                ),
                ListTile(
                  leading: const Icon(Icons.settings_applications),
                  title: const Text('Service Configuration'),
                  subtitle: const Text('Manage services, pricing, and features'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _manageServiceConfiguration,
                ),
                ListTile(
                  leading: const Icon(Icons.rule),
                  title: const Text('Platform Policies'),
                  subtitle: const Text('Terms, privacy, and service policies'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _managePolicies,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // System Administration
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Administration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Data Backup'),
                  subtitle: const Text('Backup and restore system data'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _manageBackups,
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Security Settings'),
                  subtitle: const Text('Authentication and security policies'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _manageSecuritySettings,
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('System Logs'),
                  subtitle: const Text('View system activity and error logs'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _viewSystemLogs,
                ),
              ],
            ),
          ),
        ),
      ],
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(userType: 'admin'),
      ),
    );
  }

  void _showPendingApprovals() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPendingApprovalsScreen(),
      ),
    );
  }

  void _showSupportTickets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminSupportTicketsScreen(),
      ),
    );
  }

  void _logout() {
    // Local logout - just navigate back
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Helper methods for user management
  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'Provider':
        return Colors.green;
      case 'Diaspora Customer':
        return Colors.blue;
      case 'Customer':
      default:
        return const Color(0xFF006B3C);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
      case 'Verified':
        return Colors.green;
      case 'Pending Verification':
      case 'Pending Review':
        return Colors.orange;
      case 'Suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addNewUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text('User creation form would open here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email']}'),
            Text('Type: ${user['type']}'),
            Text('Status: ${user['status']}'),
            Text('Join Date: ${user['joinDate']}'),
            Text('Total Bookings: ${user['totalBookings']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (user['status'] == 'Pending Verification')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user['name']} verified successfully')),
                );
              },
              child: const Text('Verify'),
            ),
        ],
      ),
    );
  }

  // Provider management methods
  void _reviewApplications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening provider applications for review...')),
    );
  }

  void _addNewProvider() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Provider'),
        content: const Text('Provider registration form would open here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _viewProviderDetails(Map<String, dynamic> provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: ${provider['owner']}'),
            Text('Services: ${(provider['services'] as List).join(', ')}'),
            Text('Rating: ${provider['rating']} (${provider['totalJobs']} jobs)'),
            Text('Location: ${provider['location']}'),
            Text('Status: ${provider['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _manageProvider(Map<String, dynamic> provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Provider'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit provider form would open here')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Verify Provider'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${provider['name']} verified successfully')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('Suspend Provider'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${provider['name']} suspended')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Analytics helper method
  Widget _buildServiceMetric(String serviceName, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(serviceName),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%'),
        ],
      ),
    );
  }

  // Settings management methods
  void _manageCommissionRates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCommissionManagementScreen(),
      ),
    );
  }

  void _manageServiceAreas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminServiceAreasScreen(),
      ),
    );
  }

  void _manageServiceConfiguration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminServiceConfigurationScreen(),
      ),
    );
  }

  void _managePolicies() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPolicyManagementScreen(),
      ),
    );
  }

  void _manageBackups() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup management would open here')),
    );
  }

  void _manageSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security settings would open here')),
    );
  }

  void _viewSystemLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System logs would open here')),
    );
  }
}