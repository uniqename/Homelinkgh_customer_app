import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedFoodDeliveryScreen extends StatefulWidget {
  const EnhancedFoodDeliveryScreen({super.key});

  @override
  State<EnhancedFoodDeliveryScreen> createState() => _EnhancedFoodDeliveryScreenState();
}

class _EnhancedFoodDeliveryScreenState extends State<EnhancedFoodDeliveryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String _selectedRestaurant = '';
  String _selectedCommunicationMethod = 'In-app';
  List<Map<String, dynamic>> _menuItems = [];
  List<Map<String, dynamic>> _selectedItems = [];
  
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Papaye Restaurant',
      'location': 'East Legon, Accra',
      'coordinates': {'lat': 5.6037, 'lng': -0.1870},
      'rating': 4.5,
      'deliveryTime': '20-30 mins',
      'deliveryFee': 15.0,
      'menu': [
        {'name': 'Jollof Rice with Chicken', 'price': 35.0, 'description': 'Traditional Ghanaian jollof with grilled chicken', 'category': 'Main Course'},
        {'name': 'Banku with Tilapia', 'price': 45.0, 'description': 'Fresh tilapia with traditional banku', 'category': 'Main Course'},
        {'name': 'Waakye', 'price': 25.0, 'description': 'Rice and beans with traditional sides', 'category': 'Main Course'},
        {'name': 'Kelewele', 'price': 15.0, 'description': 'Spiced fried plantain cubes', 'category': 'Appetizer'},
      ]
    },
    {
      'name': 'KFC Ghana',
      'location': 'Accra Mall, Tetteh Quarshie',
      'coordinates': {'lat': 5.6108, 'lng': -0.1821},
      'rating': 4.2,
      'deliveryTime': '15-25 mins',
      'deliveryFee': 12.0,
      'menu': [
        {'name': 'Original Recipe Chicken', 'price': 28.0, 'description': '2 pieces of original recipe chicken', 'category': 'Main Course'},
        {'name': 'Zinger Burger', 'price': 25.0, 'description': 'Spicy chicken burger with fries', 'category': 'Main Course'},
        {'name': 'Family Feast', 'price': 85.0, 'description': '8 pieces chicken, 4 sides, 4 drinks', 'category': 'Family Meal'},
        {'name': 'Krushems', 'price': 18.0, 'description': 'Thick milkshake dessert', 'category': 'Dessert'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildRestaurantSelectionStep(),
                _buildMenuSelectionStep(),
                _buildLocationConfirmationStep(),
                _buildCommunicationPreferencesStep(),
                _buildOrderSummaryStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Restaurant', 'Menu', 'Location', 'Communication', 'Summary'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isActive = index <= _currentStep;
          
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isActive ? Colors.red : Colors.grey[300],
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.red : Colors.grey[600],
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRestaurantSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Restaurant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRestaurant = restaurant['name'];
                        _menuItems = List<Map<String, dynamic>>.from(restaurant['menu']);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.restaurant, color: Colors.red, size: 30),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant['name'],
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      restaurant['location'],
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(' ${restaurant['rating']}'),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.access_time, color: Colors.grey, size: 16),
                                        Text(' ${restaurant['deliveryTime']}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: restaurant['name'],
                                groupValue: _selectedRestaurant,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRestaurant = value!;
                                    _menuItems = List<Map<String, dynamic>>.from(restaurant['menu']);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.delivery_dining, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Delivery: GH₵${restaurant['deliveryFee']}',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildMenuSelectionStep() {
    if (_menuItems.isEmpty) {
      return const Center(
        child: Text('Please select a restaurant first'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedRestaurant Menu',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedItems.any((selected) => selected['name'] == item['name']);
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.red),
                    ),
                    title: Text(item['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['description']),
                        const SizedBox(height: 4),
                        Text(
                          'GH₵${item['price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.add_circle_outline),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedItems.removeWhere((selected) => selected['name'] == item['name']);
                        } else {
                          _selectedItems.add({...item, 'quantity': 1});
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (_selectedItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedItems.length} items selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    'Total: GH₵${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationConfirmationStep() {
    final selectedRestaurant = _restaurants.firstWhere(
      (r) => r['name'] == _selectedRestaurant,
      orElse: () => _restaurants.first,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restaurant Location',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedRestaurant['location'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Google Maps Integration'),
                          Text('Restaurant location preview'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Delivery Address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Your delivery address',
              hintText: 'Enter your full address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationPreferencesStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Communication Preferences',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.timer, color: Colors.blue, size: 32),
                SizedBox(height: 8),
                Text(
                  '10-Minute Response Guarantee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Our delivery partner will respond to your messages within 10 minutes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How would you like to communicate with your delivery partner?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: const Text('In-app messaging'),
            subtitle: const Text('Chat directly through the app'),
            value: 'In-app',
            groupValue: _selectedCommunicationMethod,
            onChanged: (value) {
              setState(() {
                _selectedCommunicationMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('SMS text messages'),
            subtitle: const Text('Receive updates via SMS'),
            value: 'SMS',
            groupValue: _selectedCommunicationMethod,
            onChanged: (value) {
              setState(() {
                _selectedCommunicationMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Phone call'),
            subtitle: const Text('Direct phone communication'),
            value: 'Phone',
            groupValue: _selectedCommunicationMethod,
            onChanged: (value) {
              setState(() {
                _selectedCommunicationMethod = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Disclaimer: The delivery partner may contact you for order clarification or address confirmation. Response time guarantee applies during business hours.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryStep() {
    final selectedRestaurant = _restaurants.firstWhere(
      (r) => r['name'] == _selectedRestaurant,
      orElse: () => _restaurants.first,
    );
    
    final subtotal = _calculateTotal();
    final deliveryFee = selectedRestaurant['deliveryFee'] as double;
    final total = subtotal + deliveryFee;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedRestaurant,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Communication: $_selectedCommunicationMethod'),
                  const Divider(),
                  ..._selectedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(item['name'])),
                        Text('GH₵${item['price'].toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(child: Text('Subtotal:')),
                      Text('GH₵${subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('Delivery Fee:')),
                      Text('GH₵${deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'GH₵${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? () {
                if (_currentStep < 4) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _placeOrder();
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentStep < 4 ? 'Continue' : 'Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedRestaurant.isNotEmpty;
      case 1:
        return _selectedItems.isNotEmpty;
      case 2:
        return true; // Address validation would go here
      case 3:
        return _selectedCommunicationMethod.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  double _calculateTotal() {
    return _selectedItems.fold(0.0, (sum, item) => sum + (item['price'] as double));
  }

  void _placeOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed!'),
        content: const Text('Your food order has been placed successfully. You will receive updates via your preferred communication method.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}