import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/provider.dart';
import '../models/service_request.dart';
import '../services/smart_selection_service.dart';

class AdminMonitoringScreen extends StatefulWidget {
  const AdminMonitoringScreen({super.key});

  @override
  State<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();
}

class _AdminMonitoringScreenState extends State<AdminMonitoringScreen>
    with TickerProviderStateMixin {
  final SmartSelectionService _smartService = SmartSelectionService();
  late TabController _tabController;
  Timer? _refreshTimer;
  
  // Mock data for demonstration
  List<ServiceRequest> _activeOrders = [];
  List<Provider> _activeProviders = [];
  Map<String, int> _serviceStats = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
    _startAutoRefresh();
  }

  void _loadMockData() {
    // Mock active orders
    _activeOrders = [
      ServiceRequest(
        id: '001',
        customerId: 'cust_001',
        serviceType: 'Food Delivery',
        description: 'KFC East Legon order',
        customerLocation: const LatLng(5.6037, -0.1870),
        customerAddress: 'East Legon, Accra',
        requestedDateTime: DateTime.now().subtract(const Duration(minutes: 15)),
        status: ServiceStatus.inProgress,
        providerId: 'prov_001',
        priority: ServicePriority.normal,
      ),
      ServiceRequest(
        id: '002',
        customerId: 'cust_002',
        serviceType: 'House Cleaning',
        description: 'Deep cleaning for 3-bedroom house',
        customerLocation: const LatLng(5.5502, -0.2174),
        customerAddress: 'Osu, Accra',
        requestedDateTime: DateTime.now().subtract(const Duration(minutes: 45)),
        status: ServiceStatus.accepted,
        providerId: 'prov_002',
        priority: ServicePriority.high,
      ),
      ServiceRequest(
        id: '003',
        customerId: 'cust_003',
        serviceType: 'Food Delivery',
        description: 'Papaye Restaurant order',
        customerLocation: const LatLng(5.6205, -0.1731),
        customerAddress: 'Airport Residential, Accra',
        requestedDateTime: DateTime.now().subtract(const Duration(minutes: 8)),
        status: ServiceStatus.inProgress,
        providerId: 'prov_003',
        priority: ServicePriority.urgent,
        isUrgent: true,
      ),
    ];

    // Mock service statistics
    _serviceStats = {
      'Food Delivery': 24,
      'House Cleaning': 12,
      'Transportation': 8,
      'Plumbing': 5,
      'Electrical Work': 3,
    };

    setState(() {});
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshData();
    });
  }

  void _refreshData() {
    // Simulate data updates
    setState(() {
      // Update some random stats
      _serviceStats['Food Delivery'] = (_serviceStats['Food Delivery'] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Monitoring'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Live Orders'),
            Tab(text: 'Providers'),
            Tab(text: 'Analytics'),
            Tab(text: 'System'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveOrdersTab(),
          _buildProvidersTab(),
          _buildAnalyticsTab(),
          _buildSystemTab(),
        ],
      ),
    );
  }

  Widget _buildLiveOrdersTab() {
    return Column(
      children: [
        // Summary Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Active Orders',
                  _activeOrders.length.toString(),
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Urgent Orders',
                  _activeOrders.where((o) => o.isUrgent).length.toString(),
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),
        
        // Orders List
        Expanded(
          child: ListView.builder(
            itemCount: _activeOrders.length,
            itemBuilder: (context, index) {
              final order = _activeOrders[index];
              return _buildOrderCard(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(ServiceRequest order) {
    Color statusColor;
    String statusText;
    
    switch (order.status) {
      case ServiceStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case ServiceStatus.accepted:
        statusColor = Colors.blue;
        statusText = 'Accepted';
        break;
      case ServiceStatus.inProgress:
        statusColor = Colors.green;
        statusText = 'In Progress';
        break;
      case ServiceStatus.completed:
        statusColor = Colors.grey;
        statusText = 'Completed';
        break;
      case ServiceStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getServiceIcon(order.serviceType),
            color: statusColor,
          ),
        ),
        title: Text(
          order.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}'),
            Text('Location: ${order.customerAddress}'),
            Text('Time: ${_formatTime(order.requestedDateTime)}'),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (order.isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showOrderDetails(order),
      ),
    );
  }

  Widget _buildProvidersTab() {
    return FutureBuilder<List<Provider>>(
      future: _smartService.getProvidersNearLocation(
        location: const LatLng(5.6037, -0.1870), // Accra center
        serviceType: 'Food Delivery',
        radiusKm: 50,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final providers = snapshot.data ?? [];
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Active Providers',
                      providers.where((p) => p.isAvailable).length.toString(),
                      Icons.person,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Providers',
                      providers.length.toString(),
                      Icons.group,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return _buildProviderCard(provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: provider.isAvailable ? Colors.green : Colors.grey,
          child: Text(
            provider.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          provider.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: ${provider.rating} ⭐'),
            Text('Completed: ${provider.completedJobs} jobs'),
            Text('Specialties: ${provider.specialties.join(', ')}'),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: provider.isAvailable ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.isAvailable ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                color: provider.isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () => _showProviderDetails(provider),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Statistics (Today)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Service statistics
          ..._serviceStats.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getServiceIcon(entry.key),
                    color: const Color(0xFF006B3C),
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${entry.value} orders today',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B3C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Performance metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg Response Time',
                  '12 min',
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Success Rate',
                  '96.5%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Customer Rating',
                  '4.7 ⭐',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Active Users',
                  '1,234',
                  Icons.people,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildSystemStatusCard('API Server', true, 'All systems operational'),
          _buildSystemStatusCard('Database', true, 'Healthy connections'),
          _buildSystemStatusCard('Location Services', true, 'GPS tracking active'),
          _buildSystemStatusCard('Payment Gateway', false, 'Maintenance mode'),
          
          const SizedBox(height: 24),
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildActivityItem(
            'New provider registered: Akosua Boateng',
            '5 minutes ago',
            Icons.person_add,
          ),
          _buildActivityItem(
            'Order #1234 completed successfully',
            '12 minutes ago',
            Icons.check_circle,
          ),
          _buildActivityItem(
            'System backup completed',
            '1 hour ago',
            Icons.backup,
          ),
          _buildActivityItem(
            'Weekly reports generated',
            '2 hours ago',
            Icons.assessment,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
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
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard(String service, bool isHealthy, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHealthy ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isHealthy ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            color: isHealthy ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006B3C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'Food Delivery':
        return Icons.delivery_dining;
      case 'House Cleaning':
        return Icons.cleaning_services;
      case 'Transportation':
        return Icons.directions_car;
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electrical Work':
        return Icons.electrical_services;
      default:
        return Icons.work;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showOrderDetails(ServiceRequest order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${order.serviceType}'),
            Text('Customer: ${order.customerId}'),
            Text('Provider: ${order.providerId ?? 'Not assigned'}'),
            Text('Status: ${order.status.toString().split('.').last}'),
            Text('Address: ${order.customerAddress}'),
            Text('Requested: ${order.requestedDateTime}'),
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

  void _showProviderDetails(Provider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: ${provider.rating} ⭐'),
            Text('Completed Jobs: ${provider.completedJobs}'),
            Text('Response Time: ${provider.averageResponseTime} min'),
            Text('Specialties: ${provider.specialties.join(', ')}'),
            Text('Status: ${provider.isAvailable ? 'Available' : 'Busy'}'),
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

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
}