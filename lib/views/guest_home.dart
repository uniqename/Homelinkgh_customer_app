import 'package:flutter/material.dart';
import '../services/standalone_service.dart';
import '../services/app_tracking_service.dart';
import '../models/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/payment_method_selector.dart';
import 'auth_screen.dart';
import 'role_selection.dart';
import 'food_delivery_screen.dart';
import 'smart_service_booking.dart';

/// Real guest home screen without demo data
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final StandaloneService _service = StandaloneService();
  List<Provider> _featuredProviders = [];
  List<Map<String, dynamic>> _serviceCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    // Initialize App Tracking Transparency
    AppTrackingService.initializeTracking();
  }

  Future<void> _loadData() async {
    try {
      // Load service categories from standalone service
      final categories = await _service.getServiceCategories();
      
      setState(() {
        _serviceCategories = categories;
        _isLoading = false;
      });
      
      print('✅ Loaded ${categories.length} service categories');

      // Load featured providers in the background
      _service.getAllProvidersStream().listen((providers) {
        if (mounted) {
          setState(() {
            _featuredProviders = providers.take(6).toList();
          });
          print('✅ Loaded ${providers.length} providers');
        }
      });
    } catch (e) {
      print('❌ Service failed: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.darkBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            _buildQuickActions(),
            _buildServiceCategories(),
            _buildProvidersComingSoon(),
            _buildDonateWidget(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [Color(0x80006B3C), AppConstants.darkBackground],
          stops: [0.0, 0.75],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006B3C), Color(0xFF004D2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF006B3C).withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.home, color: Colors.white, size: 22),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Connecting Ghana\'s Diaspora',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthScreen(userType: 'customer')),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.ghanaGold,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0x66FCD116)),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 56),

              // Logo glow
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006B3C), Color(0xFF003D1F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006B3C).withValues(alpha: 0.6),
                      blurRadius: 40,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF006B3C).withValues(alpha: 0.25),
                      blurRadius: 80,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 48),
              ),

              const SizedBox(height: 32),

              const Text(
                'Welcome to HomeLinkGH',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Book verified home service providers\nin Ghana from anywhere in the world.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white60,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Ghana badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD116).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCD116).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '🇬🇭  Made in Ghana · Serving the Diaspora',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFCD116),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: _GlowButton(
              label: 'Get Started',
              icon: Icons.arrow_forward_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OutlineButton(
              label: 'Sign In',
              icon: Icons.login_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthScreen(userType: 'customer')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006B3C), Color(0xFFFCD116)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF006B3C)),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
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
    return GestureDetector(
      onTap: () => _navigateToService(category['name'] ?? 'Service'),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006B3C).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF006B3C).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF006B3C).withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  category['icon'] ?? '🏠',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'] ?? 'Service',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'From GH₵${category['basePrice'] ?? 50}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFFCD116),
                fontWeight: FontWeight.w500,
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
      // Get service details for the smart booking screen
      IconData serviceIcon = Icons.home_repair_service;
      Color serviceColor = const Color(0xFF006B3C);
      
      // Customize icon and color based on service
      switch (serviceName.toLowerCase()) {
        case 'house cleaning':
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
        case 'plumbing':
          serviceIcon = Icons.build;
          serviceColor = const Color(0xFFFF9800);
          break;
        case 'electrical':
          serviceIcon = Icons.electrical_services;
          serviceColor = const Color(0xFFFFC107);
          break;
        case 'personal care':
          serviceIcon = Icons.spa;
          serviceColor = const Color(0xFF9C27B0);
          break;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmartServiceBookingScreen(
            serviceName: serviceName,
            serviceIcon: serviceIcon,
            serviceColor: serviceColor,
          ),
        ),
      );
    }
  }

  Widget _buildProvidersComingSoon() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF006B3C).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006B3C).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF006B3C).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF006B3C).withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.people, size: 32, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Service Providers Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We are onboarding trusted providers across Ghana. Sign up to be notified when services are available in your area.',
              style: TextStyle(fontSize: 14, color: Colors.white54, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Widget _buildDonateWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF003D1F), Color(0xFF001F10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFCD116).withValues(alpha: 0.3)),
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
                _DonateChip(
                  label: 'GH₵ 20',
                  amount: 20,
                  onTap: (amt) => _donate(amt),
                ),
                const SizedBox(width: 8),
                _DonateChip(
                  label: 'GH₵ 50',
                  amount: 50,
                  onTap: (amt) => _donate(amt),
                ),
                const SizedBox(width: 8),
                _DonateChip(
                  label: 'GH₵ 100',
                  amount: 100,
                  onTap: (amt) => _donate(amt),
                ),
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
      ),
    );
  }

  Future<void> _donate(double? fixedAmount) async {
    double amount = fixedAmount ?? 10.0;
    if (fixedAmount == null) {
      // Ask for custom amount
      final controller = TextEditingController(text: '');
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
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
      customerName: 'HomeLinkGH Supporter',
      description: 'Donation to HomeLinkGH',
    );

    if (result != null && result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your donation of GH₵ ${amount.toStringAsFixed(2)}! 🙏'),
          backgroundColor: const Color(0xFF006B3C),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006B3C), Color(0xFFFCD116)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Why HomeLinkGH?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTrustPillar(
                icon: Icons.verified_user,
                title: 'Verified',
                subtitle: 'Ghana Card\nchecked',
                color: const Color(0xFF4CAF50),
              ),
              _buildTrustPillar(
                icon: Icons.payment,
                title: 'Secure Pay',
                subtitle: 'PayStack\nprotected',
                color: const Color(0xFFFCD116),
              ),
              _buildTrustPillar(
                icon: Icons.public,
                title: 'Diaspora',
                subtitle: 'Book for\nfamily back home',
                color: const Color(0xFF2196F3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '🇬🇭  Made in Ghana · Connecting the World',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTrustPillar({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ── Shared premium button widgets ─────────────────────────────────────────────

class _GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlowButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006B3C), Color(0xFF003D1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006B3C).withValues(alpha: 0.50),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonateChip extends StatelessWidget {
  final String label;
  final double amount;
  final void Function(double) onTap;

  const _DonateChip({required this.label, required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(amount),
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
}
