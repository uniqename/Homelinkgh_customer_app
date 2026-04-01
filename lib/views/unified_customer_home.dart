import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/smart_personalization_service.dart';
import '../services/ai_recommendations_service.dart';
import '../services/gamification_service.dart';
import '../widgets/payment_method_selector.dart';
import 'role_selection.dart';
import 'enhanced_food_delivery_screen.dart';
import 'enhanced_grocery_screen.dart';
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
          expandedHeight: 140,
          floating: false,
          pinned: true,
          backgroundColor: AppConstants.darkBackground,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
            title: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006B3C), Color(0xFF003D1F)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006B3C).withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'HomeLinkGH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [Color(0x66006B3C), AppConstants.darkBackground],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('3 new notifications')),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              color: const Color(0xFF0D1F14),
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.white70),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.white70)),
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
                // Glass Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'What do you need help with?',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.search, color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Quick Access
                _sectionHeader('Quick Access', onSeeAll: _showAllServices),
                const SizedBox(height: 14),
                SizedBox(
                  height: 112,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceCategories.where((s) => s['isPopular'] == true).length,
                    itemBuilder: (context, index) {
                      final popularServices =
                          _serviceCategories.where((s) => s['isPopular'] == true).toList();
                      return _buildQuickAccessCard(popularServices[index]);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Service Bundles
                _sectionHeader('Service Bundles'),
                const SizedBox(height: 6),
                const Text(
                  'Popular combinations for common needs',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceBundles.length,
                    itemBuilder: (context, index) =>
                        _buildServiceBundleCard(_serviceBundles[index]),
                  ),
                ),

                const SizedBox(height: 32),

                _sectionHeader('All Services'),
                const SizedBox(height: 14),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _serviceCategories.length,
                  itemBuilder: (context, index) =>
                      _buildServiceCard(_serviceCategories[index]),
                ),

                const SizedBox(height: 32),
                _buildDonateWidget(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDonateWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D1F), Color(0xFF001F10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFCD116).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD116).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🇬🇭', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Support HomeLinkGH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Help us connect more Ghanaian families with trusted home service providers.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _donateChip('GH₵ 20', 20.0),
              const SizedBox(width: 8),
              _donateChip('GH₵ 50', 50.0),
              const SizedBox(width: 8),
              _donateChip('GH₵ 100', 100.0),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _donate(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B3C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('Other',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
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

  Widget _donateChip(String label, double amount) {
    return GestureDetector(
      onTap: () => _donate(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFCD116).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD116).withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFCD116),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _donate(double? fixedAmount) async {
    double amount = fixedAmount ?? 10.0;
    if (fixedAmount == null) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0D2016),
          title: const Text('Enter Donation Amount',
            style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              prefixText: 'GH₵ ',
              prefixStyle: TextStyle(color: Colors.white54),
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.white24),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF006B3C))),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF006B3C), width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C)),
              child: const Text('Continue')),
          ],
        ),
      );
      if (confirmed != true) return;
      amount = double.tryParse(controller.text) ?? 10.0;
      if (amount <= 0) return;
    }

    final result = await showPaymentSheet(
      context,
      amount: amount,
      currency: 'GHS',
      customerEmail: 'donor@homelinkgh.com',
      customerName: 'HomeLinkGH Customer',
      description: 'Donation to HomeLinkGH',
    );

    if (result != null && result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Thank you for your donation of GH₵ ${amount.toStringAsFixed(2)}! 🙏'),
          backgroundColor: const Color(0xFF006B3C),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.ghanaGreen, AppConstants.ghanaGold],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(foregroundColor: AppConstants.ghanaGold),
            child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildQuickAccessCard(Map<String, dynamic> service) {
    final Color color = service['color'] as Color;
    return GestureDetector(
      onTap: () => _navigateToService(service),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Icon(service['icon'] as IconData, size: 22, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              service['name'] as String,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBundleCard(Map<String, dynamic> bundle) {
    final Color color = bundle['color'] as Color;
    return GestureDetector(
      onTap: () => _requestBundleQuote(bundle),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.11),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: color.withValues(alpha: 0.40)),
                  ),
                  child: Icon(bundle['icon'] as IconData, size: 22, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (bundle['popular'] == true)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.ghanaGold.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppConstants.ghanaGold.withValues(alpha: 0.50)),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppConstants.ghanaGold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              bundle['description'] as String,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  bundle['duration'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Request Quote',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final Color color = service['color'] as Color;
    return GestureDetector(
      onTap: () => _navigateToService(service),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Icon(service['icon'] as IconData, size: 22, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              service['name'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            const Text(
              'Get Quote',
              style: TextStyle(fontSize: 11, color: AppConstants.ghanaGold),
            ),
          ],
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