import 'package:flutter/material.dart';
import '../services/real_firebase_service.dart';
import '../models/provider.dart';
import 'simple_login.dart';
import 'role_selection.dart';
import 'food_delivery_screen.dart';
import 'service_booking.dart';

/// Real guest home screen without demo data
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  RealFirebaseService? _firebaseService;
  List<Provider> _featuredProviders = [];
  List<Map<String, dynamic>> _serviceCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Initialize real Firebase service for production use
      _firebaseService = RealFirebaseService();
      
      // Load real service categories from Firebase
      final categories = await _firebaseService!.getServiceCategories();
      
      if (categories.isNotEmpty) {
        setState(() {
          _serviceCategories = categories;
          _isLoading = false;
        });
        
        print('✅ Loaded ${categories.length} service categories from Firebase');
      } else {
        print('⚠️ No service categories found, loading default structure');
        _loadDemoData();
      }

      // Load featured providers in the background
      _firebaseService!.getAllProvidersStream().listen((providers) {
        if (mounted) {
          setState(() {
            _featuredProviders = providers.take(6).toList();
          });
          print('✅ Loaded ${providers.length} providers from Firebase');
        }
      });
    } catch (e) {
      print('❌ Firebase service failed: $e');
      print('🔄 Using fallback service structure');
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    // Only basic service structure when Firebase is unavailable
    setState(() {
      _serviceCategories = [
        {
          'name': 'Home Services',
          'icon': '🏠',
          'description': 'Connect to Firebase for full service catalog',
          'providers': 0,
        },
        {
          'name': 'Setup Required',
          'icon': '⚙️',
          'description': 'Configure Firebase to access real services',
          'providers': 0,
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildWelcomeSection(),
              _buildQuickActions(),
              _buildServiceCategories(),
              _buildFeaturedProviders(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF006B3C), Color(0xFF008A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home,
              color: Color(0xFF006B3C),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HomeLinkGH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Connecting Ghana\'s Diaspora',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimpleLoginScreen(userType: 'customer')),
              );
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to HomeLinkGH',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trusted platform for home services in Ghana. Book verified service providers for yourself or your family back home.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SimpleLoginScreen(userType: 'customer')),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF006B3C),
                side: const BorderSide(color: Color(0xFF006B3C)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategories() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _serviceCategories.length,
              itemBuilder: (context, index) {
                final category = _serviceCategories[index];
                return _buildServiceCard(category);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> category) {
    return InkWell(
      onTap: () {
        _navigateToService(category['name'] ?? 'Service');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category['icon'] ?? '🏠',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            category['name'] ?? 'Service',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006B3C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'From GH₵${category['basePrice'] ?? 50}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _navigateToService(String serviceName) {
    // Navigate to different screens based on service type
    if (serviceName.toLowerCase().contains('food') || serviceName.toLowerCase().contains('delivery')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoodDeliveryScreen()),
      );
    } else {
      // Get service details for the booking screen
      IconData serviceIcon = Icons.home_repair_service;
      Color serviceColor = const Color(0xFF006B3C);
      
      // Customize icon and color based on service
      switch (serviceName.toLowerCase()) {
        case 'home cleaning':
          serviceIcon = Icons.cleaning_services;
          serviceColor = const Color(0xFF2196F3);
          break;
        case 'transportation':
          serviceIcon = Icons.directions_car;
          serviceColor = const Color(0xFF4CAF50);
          break;
        case 'beauty services':
          serviceIcon = Icons.face_retouching_natural;
          serviceColor = const Color(0xFFE91E63);
          break;
        case 'repairs & maintenance':
          serviceIcon = Icons.build;
          serviceColor = const Color(0xFFFF9800);
          break;
        case 'personal care':
          serviceIcon = Icons.spa;
          serviceColor = const Color(0xFF9C27B0);
          break;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceBookingScreen(
            serviceName: serviceName,
            serviceIcon: serviceIcon,
            serviceColor: serviceColor,
          ),
        ),
      );
    }
  }

  Widget _buildFeaturedProviders() {
    if (_featuredProviders.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Providers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProviders.length,
              itemBuilder: (context, index) {
                final provider = _featuredProviders[index];
                return _buildProviderCard(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF006B3C),
                  child: Text(
                    provider.name.isNotEmpty ? provider.name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            provider.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.services.join(', '),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const Text(
            'Why Choose HomeLinkGH?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.verified_user, color: Color(0xFF006B3C), size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Verified Providers',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All providers verified with Ghana Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.payment, color: Color(0xFF006B3C), size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Secure Payments',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PayStack integration for safe transactions',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.public, color: Color(0xFF006B3C), size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Diaspora Friendly',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Book services for family in Ghana',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '🇬🇭 Made in Ghana, Connecting the World',
            style: TextStyle(
              color: Color(0xFF006B3C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}