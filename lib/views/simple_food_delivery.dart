import 'package:flutter/material.dart';

class SimpleFoodDeliveryScreen extends StatefulWidget {
  const SimpleFoodDeliveryScreen({super.key});

  @override
  State<SimpleFoodDeliveryScreen> createState() => _SimpleFoodDeliveryScreenState();
}

class _SimpleFoodDeliveryScreenState extends State<SimpleFoodDeliveryScreen> {
  final _addressController = TextEditingController();
  
  // Popular restaurants in Accra
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'KFC East Legon',
      'cuisine': 'Fast Food',
      'rating': 4.3,
      'deliveryTime': '20-30 min',
      'deliveryFee': 'GH₵8',
      'image': '🍗',
    },
    {
      'name': 'Papaye Restaurant',
      'cuisine': 'Local & Continental',
      'rating': 4.5,
      'deliveryTime': '25-35 min',
      'deliveryFee': 'GH₵10',
      'image': '🍛',
    },
    {
      'name': 'Pizza Inn Accra Mall',
      'cuisine': 'Pizza & Italian',
      'rating': 4.2,
      'deliveryTime': '30-40 min',
      'deliveryFee': 'GH₵12',
      'image': '🍕',
    },
    {
      'name': 'Chop Bar Junction',
      'cuisine': 'Ghanaian',
      'rating': 4.7,
      'deliveryTime': '15-25 min',
      'deliveryFee': 'GH₵5',
      'image': '🍲',
    },
    {
      'name': 'Dynasty Chinese',
      'cuisine': 'Chinese',
      'rating': 4.4,
      'deliveryTime': '35-45 min',
      'deliveryFee': 'GH₵15',
      'image': '🥡',
    },
  ];

  @override
  void initState() {
    super.initState();
    _addressController.text = 'East Legon, Accra, Ghana';
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
                ),
              ],
            ),
          ),
          
          // Available Providers Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining, color: Color(0xFF006B3C)),
                const SizedBox(width: 8),
                Text(
                  'Delivery partners available in your area',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006B3C),
                  ),
                ),
              ],
            ),
          ),
          
          // Restaurants List
          Expanded(
            child: ListView.builder(
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

  void _selectRestaurant(Map<String, dynamic> restaurant) {
    _showOrderConfirmation(restaurant);
  }

  void _showOrderConfirmation(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restaurant: ${restaurant['name']}'),
            Text('Estimated Delivery: ${restaurant['deliveryTime']}'),
            Text('Delivery Fee: ${restaurant['deliveryFee']}'),
            const SizedBox(height: 8),
            Text('Delivery to: ${_addressController.text}'),
            const SizedBox(height: 16),
            const Text(
              'Note: This is a demo version. In the full app, you would see real-time tracking with provider location and ETA.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
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
              _showSuccessMessage(restaurant);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(Map<String, dynamic> restaurant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order placed successfully! Your food from ${restaurant['name']} will arrive in ${restaurant['deliveryTime']}.',
        ),
        backgroundColor: const Color(0xFF006B3C),
        action: SnackBarAction(
          label: 'Track Order',
          textColor: Colors.white,
          onPressed: () {
            // In the full app, this would navigate to tracking screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Real-time tracking coming soon!'),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: const Text('In the full app, this would open a map picker with GPS location.'),
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