import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/smart_selection_service.dart';
import '../services/local_data_service.dart';
import '../models/provider.dart';
import 'smart_booking_flow.dart';
import 'role_selection.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final LocalDataService _localData = LocalDataService();
  final SmartSelectionService _smartSelection = SmartSelectionService();
  
  List<Provider> _nearbyProviders = [];
  bool _isLoading = true;
  String _selectedCity = 'Accra';

  @override
  void initState() {
    super.initState();
    _loadNearbyProviders();
  }

  Future<void> _loadNearbyProviders() async {
    try {
      final providers = await _localData.getAllProviders();
      setState(() {
        _nearbyProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildWelcomeSection(),
          _buildQuickActions(),
          _buildPopularServices(),
          _buildNearbyProviders(),
          _buildGhanaSpecialFeatures(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person),
        label: const Text('Login / Switch Role'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF006B3C),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'HomeLinkGH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF006B3C),
                Color(0xFF228B22),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.home,
                  size: 40,
                  color: Colors.white,
                ),
                Text(
                  'Ghana\'s Home Services Platform',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Ghana! 🇬🇭',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse and book services without creating an account. You\'ll create your profile during your first booking.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF006B3C)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCity,
                  items: _localData.getGhanaCities().map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (city) {
                    setState(() {
                      _selectedCity = city!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {
        'title': 'Food Delivery',
        'icon': Icons.delivery_dining,
        'color': Colors.orange,
        'subtitle': 'Jollof, Banku, Waakye & More',
      },
      {
        'title': 'House Cleaning',
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
        'subtitle': 'Professional Home Cleaning',
      },
      {
        'title': 'Transportation',
        'icon': Icons.directions_car,
        'color': Colors.green,
        'subtitle': 'Airport, City & Shopping Trips',
      },
      {
        'title': 'Beauty Services',
        'icon': Icons.face,
        'color': Colors.pink,
        'subtitle': 'Hair, Makeup & Nail Services',
      },
    ];

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Book',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return _buildQuickActionCard(action);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SmartBookingFlowScreen(
                serviceType: action['title'],
                isGuestUser: true,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action['icon'],
                size: 32,
                color: action['color'],
              ),
              const SizedBox(height: 8),
              Text(
                action['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                action['subtitle'],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularServices() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular in Ghana 🇬🇭',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildServiceChip('Jollof Delivery', Icons.rice_bowl, Colors.orange),
                  _buildServiceChip('Banku & Fish', Icons.set_meal, Colors.blue),
                  _buildServiceChip('Airport Transfer', Icons.flight, Colors.green),
                  _buildServiceChip('Braiding Hair', Icons.face, Colors.purple),
                  _buildServiceChip('House Help', Icons.home, Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChip(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SmartBookingFlowScreen(
                serviceType: title,
                isGuestUser: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyProviders() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Providers Near You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all providers
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _nearbyProviders.take(5).map((provider) {
                    return _buildProviderCard(provider);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showProviderDetails(provider);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF006B3C),
                  child: Text(
                    provider.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      provider.rating.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: provider.isAvailable ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.isAvailable ? 'Available' : 'Busy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.specialties.join(', '),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGhanaSpecialFeatures() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF006B3C),
              Color(0xFF228B22),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Made for Ghana',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Payments in Ghana Cedis (GH₵)\n'
              '• Local phone numbers & addresses\n'
              '• Supports all major Ghanaian cities\n'
              '• Diaspora-friendly booking system\n'
              '• Smart Ghana location detection',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SmartBookingFlowScreen(
                        serviceType: 'Any Service',
                        isGuestUser: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF006B3C),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Start Booking Now',
                  style: TextStyle(
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

  void _showProviderDetails(Provider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF006B3C),
                        child: Text(
                          provider.name[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.orange[400],
                                ),
                                const SizedBox(width: 4),
                                Text('${provider.rating} (${provider.completedJobs} jobs)'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: provider.specialties.map((service) {
                      return Chip(
                        label: Text(service),
                        backgroundColor: const Color(0xFF006B3C).withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmartBookingFlowScreen(
                              serviceType: provider.specialties.first,
                              isGuestUser: true,
                              selectedProvider: provider,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book This Provider',
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
        },
      ),
    );
  }
}