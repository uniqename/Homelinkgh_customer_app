import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../models/service_request.dart';
import '../services/smart_selection_service.dart';
import 'tracking_screen.dart';
import 'auth_screen.dart';

class FoodDeliveryScreen extends StatefulWidget {
  const FoodDeliveryScreen({super.key});

  @override
  State<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends State<FoodDeliveryScreen> {
  final SmartSelectionService _smartService = SmartSelectionService();
  List<Provider> _availableProviders = [];
  bool _isLoading = false;
  String _selectedRestaurant = '';
  String _deliveryAddress = '';
  final _addressController = TextEditingController();
  
  // Mock customer location (East Legon, Accra)
  final LatLng _customerLocation = const LatLng(5.6037, -0.1870);

  // Popular restaurants in Accra
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'KFC East Legon',
      'cuisine': 'Fast Food',
      'rating': 4.3,
      'deliveryTime': '20-30 min',
      'deliveryFee': 'GH₵8',
      'image': '🍗',
      'location': const LatLng(5.6045, -0.1865),
    },
    {
      'name': 'Papaye Restaurant',
      'cuisine': 'Local & Continental',
      'rating': 4.5,
      'deliveryTime': '25-35 min',
      'deliveryFee': 'GH₵10',
      'image': '🍛',
      'location': const LatLng(5.6020, -0.1875),
    },
    {
      'name': 'Pizza Inn Accra Mall',
      'cuisine': 'Pizza & Italian',
      'rating': 4.2,
      'deliveryTime': '30-40 min',
      'deliveryFee': 'GH₵12',
      'image': '🍕',
      'location': const LatLng(5.5502, -0.2174),
    },
    {
      'name': 'Chop Bar Junction',
      'cuisine': 'Ghanaian',
      'rating': 4.7,
      'deliveryTime': '15-25 min',
      'deliveryFee': 'GH₵5',
      'image': '🍲',
      'location': const LatLng(5.6050, -0.1880),
    },
    {
      'name': 'Dynasty Chinese',
      'cuisine': 'Chinese',
      'rating': 4.4,
      'deliveryTime': '35-45 min',
      'deliveryFee': 'GH₵15',
      'image': '🥡',
      'location': const LatLng(5.5557, -0.1963),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableProviders();
    _addressController.text = 'East Legon, Accra, Ghana';
  }

  Future<void> _loadAvailableProviders() async {
    setState(() => _isLoading = true);
    
    try {
      final providers = await _smartService.getProvidersNearLocation(
        location: _customerLocation,
        serviceType: 'Food Delivery',
      );
      
      setState(() {
        _availableProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading providers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showLocationPicker,
          ),
        ],
      ),
      body: Column(
        children: [
          // Delivery Address Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deliver to:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on, color: Color(0xFF006B3C)),
                    border: OutlineInputBorder(),
                    hintText: 'Enter delivery address',
                  ),
                  onChanged: (value) => _deliveryAddress = value,
                ),
              ],
            ),
          ),
          
          // Available Providers Section
          if (_availableProviders.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining, color: Color(0xFF006B3C)),
                  const SizedBox(width: 8),
                  Text(
                    '${_availableProviders.length} delivery partners available',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Restaurants List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = _restaurants[index];
                      return _buildRestaurantCard(restaurant);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _selectRestaurant(restaurant),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Restaurant Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    restaurant['image'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Restaurant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      restaurant['cuisine'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['rating'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['deliveryTime'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delivery Fee
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    restaurant['deliveryFee'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                  const Text('delivery'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRestaurant(Map<String, dynamic> restaurant) async {
    // Check if user is logged in
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!isLoggedIn) {
      if (mounted) {
        _showAuthDialog(restaurant);
        return;
      }
    }
    
    setState(() => _selectedRestaurant = restaurant['name']);
    
    // Find best delivery provider
    setState(() => _isLoading = true);
    
    final serviceRequest = ServiceRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceType: 'Food Delivery',
      description: 'Food delivery from ${restaurant['name']}',
      scheduledDate: DateTime.now(),
      budget: 50.0, // Default budget for food delivery
      isUrgent: false,
    );
    
    // Simulate finding a provider for production app
    setState(() => _isLoading = false);
    
    // Create a simulated provider for the order
    final simulatedProvider = Provider(
      id: 'delivery_partner_001',
      name: 'HomeLinkGH Delivery',
      email: 'delivery@homelinkgh.com',
      phone: '+233 30 123 4567',
      services: ['Food Delivery'],
      location: _customerLocation,
      address: 'Accra, Ghana',
      bio: 'Professional food delivery service',
      rating: 4.8,
      totalRatings: 250,
      completedJobs: 500,
      isVerified: true,
      isActive: true,
      profileImageUrl: '',
      certifications: ['Food Safety Certificate'],
      availability: {'monday': true, 'tuesday': true, 'wednesday': true},
    );
    
    // Simulate ETA calculation
    final eta = 25.0 + (restaurant['deliveryTime']?.contains('20-30') == true ? 5.0 : 10.0);
    
    _showOrderConfirmation(restaurant, simulatedProvider, eta);
  }

  void _showOrderConfirmation(
    Map<String, dynamic> restaurant,
    Provider provider,
    double eta,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restaurant: ${restaurant['name']}'),
            Text('Delivery Partner: ${provider.name}'),
            Text('Rating: ${provider.rating}⭐'),
            Text('Estimated Delivery: ${eta.round()} minutes'),
            const SizedBox(height: 8),
            Text('Delivery to: ${_addressController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTracking(restaurant, provider, eta);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _startTracking(
    Map<String, dynamic> restaurant,
    Provider provider,
    double eta,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingScreen(
          restaurant: restaurant,
          provider: provider,
          estimatedDeliveryTime: eta,
          customerLocation: _customerLocation,
          deliveryAddress: _addressController.text,
        ),
      ),
    );
  }

  void _showAuthDialog(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Food'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  restaurant['image'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to order from ${restaurant['name']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account or sign in to place your food order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(userType: 'customer'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Order Food Now'),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    // In a real app, this would open a map picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: const Text('Map location picker would open here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}