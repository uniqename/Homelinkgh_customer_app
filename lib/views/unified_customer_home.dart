import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/smart_personalization_service.dart';
import '../services/ai_recommendations_service.dart';
import '../services/gamification_service.dart';
import 'role_selection.dart';
import 'enhanced_food_delivery_screen.dart';
import 'enhanced_grocery_screen.dart';
import 'quote_request_screen.dart';
import 'streamlined_booking_flow.dart';
import 'data_privacy.dart';

class UnifiedCustomerHomeScreen extends StatefulWidget {
  const UnifiedCustomerHomeScreen({super.key});

  @override
  State<UnifiedCustomerHomeScreen> createState() => _UnifiedCustomerHomeScreenState();
}

class _UnifiedCustomerHomeScreenState extends State<UnifiedCustomerHomeScreen> {
  int _selectedIndex = 0;
  String selectedLanguage = 'English';
  String arrivalDate = '';
  String ghanaAddress = '';
  
  final SmartPersonalizationService _personalization = SmartPersonalizationService();
  final AIRecommendationsService _aiRecommendations = AIRecommendationsService();
  final GamificationService _gamification = GamificationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _smartPicks = [];
  bool _isLoadingSmartFeatures = true;
  
  @override
  void initState() {
    super.initState();
    _initializeSmartFeatures();
  }
  
  Future<void> _initializeSmartFeatures() async {
    try {
      await _personalization.initializePersonalization();
      await _aiRecommendations.initializeRecommendations();
      await _gamification.initializeGamification();
      
      final recommendations = await _aiRecommendations.getRecommendations({
        'context': 'unified_customer',
        'time_of_day': DateTime.now().hour,
        'user_location': 'ghana',
      });
      
      setState(() {
        _smartPicks = recommendations.take(3).toList();
        _isLoadingSmartFeatures = false;
      });
    } catch (e) {
      print('Error initializing smart features: $e');
      setState(() {
        _isLoadingSmartFeatures = false;
      });
    }
  }

  final List<String> languages = ['English', 'Akan/Twi', 'Ga', 'Ewe', 'Hausa'];

  // Service bundles without fixed prices - will use quote system
  final List<Map<String, dynamic>> _serviceBundles = [
    {
      'name': 'Welcome Home Starter',
      'description': 'Deep cleaning + water delivery + grocery stocking',
      'duration': 'Day 1 Setup',
      'icon': Icons.home,
      'color': const Color(0xFF006B3C),
      'services': ['Deep house cleaning', 'Fresh water delivery (5 gallons)', 'Grocery stocking (essentials)', 'Fridge organization'],
      'popular': true,
    },
    {
      'name': 'Wedding Ready',
      'description': 'Professional makeup + hair styling + tailoring',
      'duration': '4-6 hours',
      'icon': Icons.celebration,
      'color': const Color(0xFFCE1126),
      'services': ['Professional makeup', 'Hair styling', 'Traditional attire fitting', 'Photo-ready finishing'],
    },
    {
      'name': 'Family Care Weekly',
      'description': 'Elderly care + house cleaning + grocery runs',
      'duration': 'Weekly',
      'icon': Icons.family_restroom,
      'color': const Color(0xFF1E88E5),
      'services': ['Elderly companionship', 'Light house cleaning', 'Grocery shopping', 'Medication reminders'],
    },
    {
      'name': 'Airport VIP',
      'description': 'Airport pickup + house prep + welcome meal',
      'duration': 'Arrival Day',
      'icon': Icons.flight_land,
      'color': const Color(0xFFF57C00),
      'services': ['Airport pickup (AC vehicle)', 'House preparation', 'Welcome meal prep', 'Local orientation'],
    },
  ];

  // Individual services - all using quote system
  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'name': 'Food Delivery',
      'icon': Icons.delivery_dining,
      'color': Colors.red,
      'description': 'Restaurant delivery with dynamic pricing',
      'isPopular': true,
    },
    {
      'name': 'Grocery',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'description': 'Fresh groceries with location specification',
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
      'name': 'Beauty Services',
      'icon': Icons.face_retouching_natural,
      'color': Colors.pink,
      'description': 'Professional makeup, hair, and nail services',
      'isPopular': false,
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.indigo,
      'description': 'Airport pickup, city rides, and car rentals',
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
      'name': 'Home Repairs',
      'icon': Icons.handyman,
      'color': Colors.brown,
      'description': 'General repairs and maintenance',
      'isPopular': false,
    },
    {
      'name': 'Elder Care',
      'icon': Icons.elderly,
      'color': Colors.deepPurple,
      'description': 'Compassionate elderly care and companionship',
      'isPopular': false,
    },
  ];

  final List<Map<String, dynamic>> _recentBookings = [
    {
      'service': 'Food Delivery',
      'provider': 'QuickBites Restaurant',
      'date': 'Today, 1:30 PM',
      'status': 'Delivered',
    },
    {
      'service': 'Cleaning',
      'provider': 'CleanPro Services',
      'date': 'Yesterday',
      'status': 'Completed',
    },
  ];

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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('HomeLinkGH'),
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
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder: (context) => [
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
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'What do you need help with?',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Access / Popular Services
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => _showAllServices(),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceCategories.where((s) => s['isPopular'] == true).length,
                    itemBuilder: (context, index) {
                      final popularServices = _serviceCategories.where((s) => s['isPopular'] == true).toList();
                      final service = popularServices[index];
                      return _buildQuickAccessCard(service);
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Service Bundles
                const Text(
                  'Service Bundles',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Popular combinations for common needs',
                  style: TextStyle(color: Colors.grey),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceBundles.length,
                    itemBuilder: (context, index) {
                      return _buildServiceBundleCard(_serviceBundles[index]);
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // All Services Grid
                const Text(
                  'All Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 16),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _serviceCategories.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(_serviceCategories[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(Map<String, dynamic> service) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _navigateToService(service),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: service['color'].withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'],
                size: 30,
                color: service['color'],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['name'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBundleCard(Map<String, dynamic> bundle) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _requestBundleQuote(bundle),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bundle['color'].withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        bundle['icon'],
                        size: 20,
                        color: bundle['color'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bundle['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (bundle['popular'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bundle['description'],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      bundle['duration'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: bundle['color'].withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Request Quote',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToService(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                service['icon'],
                size: 32,
                color: service['color'],
              ),
              const SizedBox(height: 8),
              Text(
                service['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Get Quote',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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
          const Text(
            'Your Bookings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_recentBookings.isEmpty)
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 64),
                  Icon(Icons.book_online, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Book a service to see it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _recentBookings.length,
                itemBuilder: (context, index) {
                  final booking = _recentBookings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(booking['service']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Provider: ${booking['provider']}'),
                          Text('Date: ${booking['date']}'),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF006B3C)),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String>(
                  future: _getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'HomeLinkGH User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: _getUserEmail(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'user@homelinkgh.com',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileOption(
            icon: Icons.location_on,
            title: 'Addresses',
            subtitle: 'Manage delivery locations',
            onTap: () {
              _showAddressesScreen();
            },
          ),
          _buildProfileOption(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Credit cards, Mobile Money',
            onTap: () {
              _showPaymentMethodsScreen();
            },
          ),
          _buildProfileOption(
            icon: Icons.history,
            title: 'Order History',
            subtitle: 'View all past bookings',
            onTap: () {
              _showOrderHistoryScreen();
            },
          ),
          _buildProfileOption(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get help with your orders',
            onTap: () {
              _showHelpSupportScreen();
            },
          ),
          _buildProfileOption(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Export data, manage privacy & delete account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataPrivacyScreen(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              _showSettingsScreen();
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
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

  // Navigation methods
  void _navigateToService(Map<String, dynamic> service) {
    if (service['name'] == 'Food Delivery') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EnhancedFoodDeliveryScreen(),
        ),
      );
    } else if (service['name'] == 'Grocery') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EnhancedGroceryScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StreamlinedBookingFlow(
            serviceName: service['name'],
            serviceIcon: service['icon'],
            serviceColor: service['color'],
          ),
        ),
      );
    }
  }

  void _requestBundleQuote(Map<String, dynamic> bundle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamlinedBookingFlow(
          serviceName: bundle['name'],
          serviceIcon: bundle['icon'],
          serviceColor: bundle['color'],
        ),
      ),
    );
  }

  void _showAllServices() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _serviceCategories.length,
                  itemBuilder: (context, index) {
                    final service = _serviceCategories[index];
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToService(service);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                service['icon'],
                                size: 24,
                                color: service['color'],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service['name'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Utility methods
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

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'HomeLinkGH User';
  }

  Future<String> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? 'user@homelinkgh.com';
  }

  void _showAddressesScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address management coming soon!')),
    );
  }

  void _showPaymentMethodsScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment methods coming soon!')),
    );
  }

  void _showOrderHistoryScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order history coming soon!')),
    );
  }

  void _showHelpSupportScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon!')),
    );
  }

  void _showSettingsScreen() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive order updates'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Location Services'),
              subtitle: const Text('Help find nearby providers'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English (Ghana)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy & Data Management'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataPrivacyScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete My Account',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataPrivacyScreen(),
                  ),
                );
              },
            ),
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

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectionScreen(),
      ),
    );
  }
}