import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_booking_flow.dart';
import '../services/local_data_service.dart';
import '../services/ai_recommendations_service.dart';
import '../services/smart_personalization_service.dart';
import 'role_selection.dart';
import 'guest_home.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  final AIRecommendationsService _aiRecommendations = AIRecommendationsService();
  final SmartPersonalizationService _personalization = SmartPersonalizationService();
  List<Map<String, dynamic>> _personalizedRecommendations = [];
  bool _isLoadingRecommendations = true;

  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'name': 'Food Delivery',
      'icon': Icons.delivery_dining,
      'color': Colors.red,
      'description': 'Restaurant delivery, groceries, and more',
      'isPopular': true,
    },
    {
      'name': 'Grocery',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'description': 'Fresh groceries delivered to your door',
      'isPopular': true,
    },
    {
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.blue,
      'description': 'House cleaning and maintenance services',
      'isPopular': true,
    },
    {
      'name': 'Laundry',
      'icon': Icons.local_laundry_service,
      'color': Colors.teal,
      'description': 'Pickup, wash, dry, and delivery service',
      'isPopular': false,
    },
    {
      'name': 'Nail Tech / Makeup',
      'icon': Icons.face_retouching_natural,
      'color': Colors.pink,
      'description': 'Beauty services at your location',
      'isPopular': false,
    },
    {
      'name': 'Plumbing',
      'icon': Icons.plumbing,
      'color': Colors.indigo,
      'description': 'Pipes, fixtures, and water system repairs',
      'isPopular': false,
    },
    {
      'name': 'Electrical',
      'icon': Icons.electrical_services,
      'color': Colors.amber,
      'description': 'Wiring, outlets, and electrical installations',
      'isPopular': false,
    },
    {
      'name': 'HVAC',
      'icon': Icons.hvac,
      'color': Colors.cyan,
      'description': 'Heating, ventilation, and air conditioning',
      'isPopular': false,
    },
    {
      'name': 'Painting',
      'icon': Icons.format_paint,
      'color': Colors.deepOrange,
      'description': 'Interior and exterior painting services',
      'isPopular': false,
    },
    {
      'name': 'Carpentry',
      'icon': Icons.handyman,
      'color': Colors.brown,
      'description': 'Custom woodwork and furniture repair',
      'isPopular': false,
    },
    {
      'name': 'Landscaping',
      'icon': Icons.grass,
      'color': Colors.lightGreen,
      'description': 'Garden design, lawn care, and outdoor spaces',
      'isPopular': false,
    },
    {
      'name': 'Babysitting',
      'icon': Icons.child_care,
      'color': Colors.purple,
      'description': 'Trusted childcare services',
      'isPopular': true,
    },
    {
      'name': 'Adult Sitter',
      'icon': Icons.elderly,
      'color': Colors.deepPurple,
      'description': 'Elderly care and companion services',
      'isPopular': false,
    },
  ];

  final List<Map<String, dynamic>> _recentBookings = [
    {
      'service': 'Food Delivery',
      'provider': 'QuickBites Restaurant',
      'date': 'Today, 1:30 PM',
      'status': 'Delivered',
      'amount': 'GH₵145',
    },
    {
      'service': 'Cleaning',
      'provider': 'CleanPro Services',
      'date': 'Yesterday',
      'status': 'Completed',
      'amount': 'GH₵250',
    },
    {
      'service': 'Grocery',
      'provider': 'FreshMart Express',
      'date': '2 days ago',
      'status': 'Delivered',
      'amount': 'GH₵189',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializePersonalization();
  }

  Future<void> _initializePersonalization() async {
    await _personalization.initializePersonalization();
    await _loadPersonalizedRecommendations();
  }

  Future<void> _loadPersonalizedRecommendations() async {
    try {
      final recommendations = _personalization.getPersonalizedRecommendations();
      setState(() {
        _personalizedRecommendations = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRecommendations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildBookingsTab(),
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final popularServices = _serviceCategories.where((service) => service['isPopular']).toList();
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Blazer Services'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('3 new notifications')),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'switch_role':
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleSelectionScreen(),
                      ),
                    );
                    break;
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'switch_role',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz),
                      SizedBox(width: 8),
                      Text('Switch Role'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'What service do you need?',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Personalized Recommendations
                if (_personalizedRecommendations.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF006B3C)),
                      const SizedBox(width: 8),
                      const Text(
                        'Just for You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_personalization.userPersonalityType.replaceAll('_', ' ').toUpperCase()}',
                          style: const TextStyle(
                            color: Color(0xFF006B3C),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _personalizedRecommendations.take(3).length,
                      itemBuilder: (context, index) {
                        final rec = _personalizedRecommendations[index];
                        return _buildPersonalizedCard(rec);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Popular Services
                const Text(
                  'Popular Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularServices.length,
                    itemBuilder: (context, index) {
                      final service = popularServices[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: _buildServiceCard(service, isCompact: true),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // All Services
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildServiceCard(_serviceCategories[index]);
              },
              childCount: _serviceCategories.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, {bool isCompact = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Track service usage for personalization
          _personalization.trackUserAction('service_browsed', {
            'serviceType': service['name'],
          });
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SmartBookingFlowScreen(
                serviceType: service['name'],
                isGuestUser: false,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 8 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                service['color'].withValues(alpha: 0.1),
                service['color'].withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                service['icon'],
                size: isCompact ? 30 : 40,
                color: service['color'],
              ),
              SizedBox(height: isCompact ? 4 : 8),
              Text(
                service['name'],
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isCompact) ...[
                const SizedBox(height: 4),
                Text(
                  service['description'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (service['isPopular'] && !isCompact)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'My Bookings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _recentBookings.length,
              itemBuilder: (context, index) {
                final booking = _recentBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(booking['status']),
                      child: Icon(
                        _getStatusIcon(booking['status']),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(booking['service']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['provider']),
                        Text(booking['date']),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          booking['amount'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            booking['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showBookingDetails(booking);
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

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'john.doe@email.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileOption(
            icon: Icons.location_on,
            title: 'Addresses',
            subtitle: '2 saved addresses',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Credit cards, Mobile Money',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.history,
            title: 'Order History',
            subtitle: 'View all past bookings',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get help with your orders',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences and privacy',
            onTap: () {},
          ),
        ],
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
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'in progress':
      case 'on the way':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Icons.check;
      case 'in progress':
      case 'on the way':
        return Icons.local_shipping;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  void _showFoodDeliveryOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Food Delivery Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.red),
              title: const Text('Order Food'),
              subtitle: const Text('Browse restaurants and place orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartBookingFlowScreen(
                      serviceType: 'Food Delivery',
                      isGuestUser: false,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes, color: Colors.blue),
              title: const Text('Track Order'),
              subtitle: const Text('Track your current delivery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order tracking feature coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.store, color: Colors.green),
              title: const Text('Restaurant Dashboard'),
              subtitle: const Text('View restaurant partner portal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartBookingFlowScreen(
                      serviceType: 'Restaurant Partnership',
                      isGuestUser: false,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking['service']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${booking['provider']}'),
            Text('Date: ${booking['date']}'),
            Text('Status: ${booking['status']}'),
            Text('Amount: ${booking['amount']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (booking['status'].toLowerCase() == 'in progress' || booking['status'].toLowerCase() == 'on the way')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order tracking feature coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text('Track Order'),
            ),
          if (booking['status'].toLowerCase() == 'completed')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rate & Review feature coming soon!')),
                );
              },
              child: const Text('Rate & Review'),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedCard(Map<String, dynamic> recommendation) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _personalization.trackUserAction('personalized_recommendation_clicked', {
              'type': recommendation['type'],
              'title': recommendation['title'],
            });
            
            final services = recommendation['services'] as List<dynamic>?;
            if (services != null && services.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SmartBookingFlowScreen(
                    serviceType: services.first.toString(),
                    isGuestUser: false,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF006B3C).withOpacity(0.1),
                  const Color(0xFF006B3C).withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006B3C).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF006B3C),
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006B3C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((recommendation['priority'] ?? 0.5) * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation['title'] ?? 'Smart Suggestion',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['subtitle'] ?? 'Personalized for you',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (recommendation['services'] != null)
                  Wrap(
                    spacing: 4,
                    children: (recommendation['services'] as List).take(2).map<Widget>((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3C).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.toString(),
                          style: const TextStyle(
                            color: Color(0xFF006B3C),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GuestHomeScreen(),
        ),
      );
    }
  }
}