import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/smart_recommendation_service.dart';
import '../services/location_service.dart';

class DynamicHomeScreen extends StatefulWidget {
  final String userId;
  final String userType; // diaspora_customer, family_helper, local_customer

  const DynamicHomeScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  State<DynamicHomeScreen> createState() => _DynamicHomeScreenState();
}

class _DynamicHomeScreenState extends State<DynamicHomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<String, dynamic> userProfile = {};
  List<Map<String, dynamic>> smartRecommendations = [];
  List<Map<String, dynamic>> quickAccess = [];
  List<Map<String, dynamic>> trendingServices = [];
  Map<String, dynamic> weatherInfo = {};
  String currentGreeting = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDynamicContent();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadDynamicContent() async {
    setState(() => isLoading = true);
    
    try {
      // Load personalized data
      final recommendations = await SmartRecommendationService.getPersonalizedRecommendations(
        userId: widget.userId,
        userType: widget.userType,
      );
      
      final locationData = await LocationService.getCurrentLocationContext();
      final trending = await SmartRecommendationService.getTrendingServices(locationData['region']);
      final quickAccessData = await SmartRecommendationService.getQuickAccessServices(widget.userId);
      
      setState(() {
        smartRecommendations = recommendations;
        trendingServices = trending;
        quickAccess = quickAccessData;
        weatherInfo = locationData;
        currentGreeting = _generatePersonalizedGreeting();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _generatePersonalizedGreeting() {
    final hour = DateTime.now().hour;
    final name = userProfile['firstName'] ?? 'Friend';
    
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    final greetings = [
      '$timeGreeting, $name! Hungry? 🍽️',
      'Akwaba! Fresh meals await you! 🇬🇭',
      'Welcome to Accra\'s best food delivery! ✨',
      '$timeGreeting! Craving something delicious? 🥘',
    ];
    
    return greetings[DateTime.now().millisecond % greetings.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? _buildLoadingScreen()
          : RefreshIndicator(
              onRefresh: _loadDynamicContent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildDynamicHeader(),
                        _buildFoodDeliverySection(),
                        _buildQuickAccessGrid(),
                        _buildSmartRecommendations(),
                        _buildTrendingServices(),
                        _buildLocationBasedSuggestions(),
                        _buildBookingHistory(),
                        _buildSpecialOffers(),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Personalizing your experience...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E8B57), Color(0xFF3CB371), Color(0xFF98FB98)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic greeting with time-based content
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentGreeting,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getContextualSubtitle(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildNotificationBell(),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Smart search bar with suggestions
              _buildSmartSearchBar(),
              
              const SizedBox(height: 16),
              
              // Weather and location context
              if (weatherInfo.isNotEmpty) _buildLocationWeatherCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: _getSmartSearchHint(),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF006B3C)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF006B3C)),
            onPressed: () => _startVoiceSearch(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onTap: () => _openSmartSearch(),
      ),
    );
  }

  Widget _buildLocationWeatherCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(weatherInfo['condition']),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${weatherInfo['temperature']}°C in ${weatherInfo['location']}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Spacer(),
          Text(
            weatherInfo['suggestion'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDeliverySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Food Delivery in Greater Accra',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '30 min avg',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'From local waakye to international cuisine - all delivered hot & fresh!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFoodCategory('Ghanaian', Icons.restaurant, 'Jollof, Banku, Fufu'),
                  _buildFoodCategory('Fast Food', Icons.fastfood, 'Pizza, Burgers, Fries'),
                  _buildFoodCategory('Breakfast', Icons.breakfast_dining, 'Waakye, Kelewele, Tea'),
                  _buildFoodCategory('Snacks', Icons.cookie, 'Bofrot, Koose, Plantain'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openFoodDelivery(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Order Food Now 🍽️',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCategory(String name, IconData icon, String subtitle) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              TextButton(
                onPressed: () => _customizeQuickAccess(),
                child: const Text('Customize'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: quickAccess.length,
            itemBuilder: (context, index) {
              final service = quickAccess[index];
              return _buildQuickAccessTile(service);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessTile(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () => _navigateToService(service),
      child: Container(
        decoration: BoxDecoration(
          color: service['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: service['color'].withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              service['icon'],
              size: 24,
              color: service['color'],
            ),
            const SizedBox(height: 4),
            Text(
              service['name'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: service['color'],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (service['badge'] != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service['badge'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartRecommendations() {
    if (smartRecommendations.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFF006B3C)),
              const SizedBox(width: 8),
              const Text(
                'Smart Picks for You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD116),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AI Powered',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: smartRecommendations.length,
              itemBuilder: (context, index) {
                final recommendation = smartRecommendations[index];
                return _buildRecommendationCard(recommendation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            recommendation['color'].withOpacity(0.8),
            recommendation['color'],
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: recommendation['color'].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    recommendation['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${recommendation['matchScore']}% Match',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation['description'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '₵${recommendation['startingPrice']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _bookRecommendedService(recommendation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: recommendation['color'],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingServices() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF006B3C)),
              const SizedBox(width: 8),
              const Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🔥 Hot',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trendingServices.length,
              itemBuilder: (context, index) {
                final service = trendingServices[index];
                return _buildTrendingServiceCard(service);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingServiceCard(Map<String, dynamic> service) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  service['icon'],
                  color: service['color'],
                  size: 20,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${service['growth']}%',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              'From ₵${service['price']}',
              style: TextStyle(
                fontSize: 12,
                color: service['color'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBasedSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF006B3C)),
              const SizedBox(width: 8),
              Text(
                'Popular in ${weatherInfo['region'] ?? 'Greater Accra'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationServicesList(),
        ],
      ),
    );
  }

  Widget _buildLocationServicesList() {
    final locationServices = [
      {
        'name': 'Restaurant Delivery',
        'icon': Icons.delivery_dining,
        'rating': 4.9,
        'orders': 1234,
        'price': 25,
        'color': const Color(0xFFFF6B35),
      },
      {
        'name': 'Local Food Spots',
        'icon': Icons.restaurant,
        'rating': 4.8,
        'orders': 987,
        'price': 35,
        'color': const Color(0xFFFFA500),
      },
      {
        'name': 'Grocery Shopping',
        'icon': Icons.shopping_cart,
        'rating': 4.7,
        'orders': 654,
        'price': 50,
        'color': const Color(0xFF32CD32),
      },
      {
        'name': 'House Cleaning',
        'icon': Icons.cleaning_services,
        'rating': 4.6,
        'orders': 234,
        'price': 80,
        'color': Colors.blue,
      },
    ];

    return Column(
      children: locationServices.map((service) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (service['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: service['color'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              service['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                Text(' ${service['rating']} (${service['orders']} orders)'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₵${service['price']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B3C),
                  ),
                ),
                const Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            onTap: () => _bookService(service),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingHistory() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF006B3C)),
              const SizedBox(width: 8),
              const Text(
                'Book Again',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewAllHistory(),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecentBookings(),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    final recentBookings = [
      {
        'service': 'House Cleaning',
        'provider': 'Akosua Cleaning Co.',
        'date': 'Last week',
        'rating': 5.0,
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
      },
      {
        'service': 'Plumbing Repair',
        'provider': 'Kwame Plumbing',
        'date': '2 weeks ago',
        'rating': 4.8,
        'icon': Icons.plumbing,
        'color': Colors.orange,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentBookings.length,
        itemBuilder: (context, index) {
          final booking = recentBookings[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (booking['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      booking['icon'] as IconData,
                      color: booking['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          booking['service'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          booking['provider'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 10),
                            Text(
                              ' ${booking['rating']}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Color(0xFF006B3C)),
              const SizedBox(width: 8),
              const Text(
                'Special Offers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Limited Time',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOfferCards(),
        ],
      ),
    );
  }

  Widget _buildOfferCards() {
    final offers = [
      {
        'title': 'New User Special',
        'subtitle': '50% off your first cleaning service',
        'code': 'WELCOME50',
        'color': Colors.purple,
        'icon': Icons.cleaning_services,
      },
      {
        'title': 'Diaspora Discount',
        'subtitle': '25% off for returning visitors',
        'code': 'DIASPORA25',
        'color': Colors.green,
        'icon': Icons.flight,
      },
    ];

    return Column(
      children: offers.map((offer) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [(offer['color'] as Color).withOpacity(0.1), (offer['color'] as Color).withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (offer['color'] as Color).withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (offer['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    offer['icon'] as IconData,
                    color: offer['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        offer['subtitle'] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: offer['color'] as Color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    offer['code'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => _openNotifications(),
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getContextualSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 9) return 'Fresh breakfast delivery across Greater Accra';
    if (hour < 12) return 'Lunch specials from top restaurants';
    if (hour < 17) return 'Afternoon treats and snacks available';
    return 'Dinner delivered hot to your door';
  }

  String _getSmartSearchHint() {
    final suggestions = [
      'Try "cleaning this weekend"',
      'Search "plumber near me"',
      'Type "AC repair urgent"',
      'Ask "cook for dinner party"',
    ];
    return suggestions[DateTime.now().minute % suggestions.length];
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition) {
      case 'sunny': return Icons.wb_sunny;
      case 'cloudy': return Icons.cloud;
      case 'rainy': return Icons.beach_access;
      default: return Icons.wb_sunny;
    }
  }

  // Navigation methods
  void _startVoiceSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search activated! 🎤'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _openSmartSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Smart search with AI suggestions'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _customizeQuickAccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customize your quick access tiles'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _navigateToService(Map<String, dynamic> service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${service['name']}'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _bookRecommendedService(Map<String, dynamic> recommendation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${recommendation['title']}'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _bookService(Map<String, dynamic> service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${service['name']}'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _viewAllHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening booking history'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _openNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening notifications'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _openFoodDelivery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🍽️ Opening food delivery - Order from the best restaurants in Greater Accra!'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}