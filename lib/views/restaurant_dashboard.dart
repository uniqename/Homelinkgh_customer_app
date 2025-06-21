import 'package:flutter/material.dart';

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  int _selectedIndex = 0;
  bool isOnline = true;
  
  final List<Map<String, dynamic>> _pendingOrders = [
    {
      'id': 'ORD001',
      'customer': 'John Smith',
      'items': ['2x Fried Chicken', '1x Coleslaw', '1x Coke'],
      'total': 45.50,
      'time': '12:30 PM',
      'prep_time': 15,
      'status': 'new'
    },
    {
      'id': 'ORD002',
      'customer': 'Sarah Johnson',
      'items': ['1x Zinger Burger', '1x Large Fries', '1x Sprite'],
      'total': 32.75,
      'time': '12:35 PM',
      'prep_time': 12,
      'status': 'preparing'
    },
    {
      'id': 'ORD003',
      'customer': 'Mike Davis',
      'items': ['3x Hot Wings', '1x Gravy', '1x Pepsi'],
      'total': 28.90,
      'time': '12:40 PM',
      'prep_time': 10,
      'status': 'ready'
    },
  ];

  final Map<String, int> _todaysStats = {
    'orders': 47,
    'revenue': 1250,
    'avg_prep_time': 14,
    'customer_rating': 48, // 4.8 * 10
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KFC Restaurant'),
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        foregroundColor: Colors.red,
        actions: [
          Switch(
            value: isOnline,
            onChanged: (value) {
              setState(() {
                isOnline = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isOnline ? 'Restaurant is now ONLINE' : 'Restaurant is now OFFLINE'),
                  backgroundColor: isOnline ? Colors.green : Colors.red,
                ),
              );
            },
            activeColor: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOrdersTab(),
          _buildMenuTab(),
          _buildAnalyticsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
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

  Widget _buildOrdersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(child: _buildStatCard('Orders Today', _todaysStats['orders'].toString(), Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Revenue', '₵${_todaysStats['revenue']}', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Avg Prep', '${_todaysStats['avg_prep_time']}m', Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Rating', '${(_todaysStats['customer_rating']! / 10).toStringAsFixed(1)}★', Colors.purple)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pendingOrders.length,
            itemBuilder: (context, index) {
              final order = _pendingOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getOrderStatusColor(order['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order['status'].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Order #${order['id']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₵${order['total'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(order['customer']),
                          const Spacer(),
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(order['time']),
                          const SizedBox(width: 16),
                          const Icon(Icons.timer, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('${order['prep_time']}m'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...order['items'].map<Widget>((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('• $item'),
                            )).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (order['status'] == 'new') ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _rejectOrder(order['id']),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () => _acceptOrder(order['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Accept & Start'),
                              ),
                            ),
                          ] else if (order['status'] == 'preparing') ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _markReady(order['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Mark Ready'),
                              ),
                            ),
                          ] else if (order['status'] == 'ready') ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _callDriver(order['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Call Driver'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handOverOrder(order['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Hand Over'),
                              ),
                            ),
                          ],
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

  Widget _buildMenuTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Menu Management'),
          SizedBox(height: 8),
          Text('Add, edit, or disable menu items'),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAnalyticsCard('Total Orders', '47', '+12%', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildAnalyticsCard('Revenue', '₵1,250', '+8%', Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildAnalyticsCard('Avg Prep Time', '14m', '-2m', Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildAnalyticsCard('Customer Rating', '4.8★', '+0.2', Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Popular Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Fried Chicken'),
                  subtitle: Text('32 orders today'),
                  trailing: Text('₵18.50'),
                ),
                ListTile(
                  title: Text('Zinger Burger'),
                  subtitle: Text('28 orders today'),
                  trailing: Text('₵22.00'),
                ),
                ListTile(
                  title: Text('Hot Wings'),
                  subtitle: Text('24 orders today'),
                  trailing: Text('₵15.75'),
                ),
              ],
            ),
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
          'Restaurant Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.store),
          title: const Text('Store Information'),
          subtitle: const Text('Update restaurant details'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('Operating Hours'),
          subtitle: const Text('Set store hours'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.delivery_dining),
          title: const Text('Delivery Settings'),
          subtitle: const Text('Manage delivery zones and fees'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          subtitle: const Text('Order and system notifications'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Payment & Payouts'),
          subtitle: const Text('Banking and payment settings'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Support'),
          subtitle: const Text('Get help and contact support'),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String change, Color color) {
    final isPositive = change.startsWith('+');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _acceptOrder(String orderId) {
    setState(() {
      final order = _pendingOrders.firstWhere((o) => o['id'] == orderId);
      order['status'] = 'preparing';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order $orderId accepted and preparation started')),
    );
  }

  void _rejectOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: const Text('Are you sure you want to reject this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingOrders.removeWhere((o) => o['id'] == orderId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order $orderId rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _markReady(String orderId) {
    setState(() {
      final order = _pendingOrders.firstWhere((o) => o['id'] == orderId);
      order['status'] = 'ready';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order $orderId marked as ready for pickup')),
    );
  }

  void _callDriver(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling assigned driver for order $orderId...')),
    );
  }

  void _handOverOrder(String orderId) {
    setState(() {
      _pendingOrders.removeWhere((o) => o['id'] == orderId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order $orderId handed over to driver'),
        backgroundColor: Colors.green,
      ),
    );
  }
}