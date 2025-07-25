import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/food_delivery_pricing_service.dart';
import 'delivery_quote_selection_screen.dart';

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
  double _estimatedTotal = 0.0;
  String _specialInstructions = '';
  final TextEditingController _instructionsController = TextEditingController();
  
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
                      _showItemCustomizationDialog(item);
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            selectedRestaurant['coordinates']['lat'],
                            selectedRestaurant['coordinates']['lng'],
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(selectedRestaurant['name']),
                            position: LatLng(
                              selectedRestaurant['coordinates']['lat'],
                              selectedRestaurant['coordinates']['lng'],
                            ),
                            infoWindow: InfoWindow(
                              title: selectedRestaurant['name'],
                              snippet: selectedRestaurant['location'],
                            ),
                          ),
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
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
            'Communication & Order Confirmation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Pre-acceptance communication notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.chat, color: Colors.orange, size: 32),
                SizedBox(height: 8),
                Text(
                  'Pre-Order Communication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Driver will contact you to confirm your order details, delivery location, and any special instructions before accepting the order. This prevents any misunderstandings and ensures loyalty.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
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
                      const Expanded(
                        child: Text(
                          'Subtotal:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'GH₵${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withAlpha(51)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Delivery fees will be calculated based on your location and chosen delivery provider',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
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
              child: Text(_currentStep < 4 ? 'Continue' : 'Choose Delivery Provider'),
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
    return _selectedItems.fold(0.0, (sum, item) => sum + ((item['price'] as double) * (item['quantity'] as int)));
  }

  void _showItemCustomizationDialog(Map<String, dynamic> item) {
    int quantity = 1;
    String specialRequests = '';
    double itemPrice = item['price'].toDouble();
    bool spicyLevel = false;
    String portionSize = 'Regular';
    
    final existingItem = _selectedItems.firstWhere(
      (selected) => selected['name'] == item['name'],
      orElse: () => {},
    );
    
    if (existingItem.isNotEmpty) {
      quantity = existingItem['quantity'];
      specialRequests = existingItem['specialRequests'] ?? '';
      spicyLevel = existingItem['spicyLevel'] ?? false;
      portionSize = existingItem['portionSize'] ?? 'Regular';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(item['name']),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['description'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity Selection
                    Row(
                      children: [
                        const Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: quantity > 1 ? () {
                            setDialogState(() {
                              quantity--;
                            });
                          } : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              quantity++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Portion Size
                    const Text('Portion Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: portionSize,
                      isExpanded: true,
                      items: ['Small', 'Regular', 'Large'].map((String size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text('$size ${size == 'Small' ? '(-GH₵2)' : size == 'Large' ? '(+GH₵5)' : ''}'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          portionSize = newValue!;
                          // Adjust price based on size
                          if (portionSize == 'Small') {
                            itemPrice = item['price'] - 2;
                          } else if (portionSize == 'Large') {
                            itemPrice = item['price'] + 5;
                          } else {
                            itemPrice = item['price'].toDouble();
                          }
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Spicy Level
                    if (item['category'] == 'Main Course')
                      CheckboxListTile(
                        title: const Text('Extra Spicy (+GH₵1)'),
                        value: spicyLevel,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            spicyLevel = value ?? false;
                          });
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Special Requests
                    const Text('Special Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Any special requests? (e.g., no onions, extra sauce)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        specialRequests = value;
                      },
                      controller: TextEditingController(text: specialRequests),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Price Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'GH₵${((itemPrice + (spicyLevel ? 1 : 0)) * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedItems.removeWhere((selected) => selected['name'] == item['name']);
                      _selectedItems.add({
                        ...item,
                        'quantity': quantity,
                        'price': itemPrice + (spicyLevel ? 1 : 0),
                        'specialRequests': specialRequests,
                        'spicyLevel': spicyLevel,
                        'portionSize': portionSize,
                      });
                      _estimatedTotal = _calculateTotal();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add to Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _placeOrder() {
    _navigateToDeliverySelection();
  }

  void _navigateToDeliverySelection() {
    final selectedRestaurant = _restaurants.firstWhere(
      (restaurant) => restaurant['name'] == _selectedRestaurant,
      orElse: () => _restaurants.first,
    );

    final restaurantLocation = Location(
      latitude: selectedRestaurant['coordinates']['lat'],
      longitude: selectedRestaurant['coordinates']['lng'],
    );

    // For demo purposes, using Accra city center as customer location
    const customerLocation = Location(
      latitude: 5.6037,
      longitude: -0.1870,
    );

    final orderValue = _calculateTotal();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryQuoteSelectionScreen(
          restaurantName: selectedRestaurant['name'],
          restaurantLocation: restaurantLocation,
          customerLocation: customerLocation,
          orderValue: orderValue,
          orderItems: _selectedItems,
        ),
      ),
    ).then((selectedQuote) {
      if (selectedQuote != null) {
        _showOrderConfirmation(selectedQuote);
      }
    });
  }

  void _showOrderConfirmation(DeliveryQuote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your food order has been placed successfully!'),
            const SizedBox(height: 12),
            Text('Delivery Provider: ${quote.providerName}'),
            Text('Delivery Fee: GH₵${quote.deliveryFee.toStringAsFixed(2)}'),
            Text('Service Fee: GH₵${quote.platformServiceFee.toStringAsFixed(2)}'),
            Text('Estimated Time: ${quote.estimatedTimeText}'),
            const SizedBox(height: 8),
            const Text(
              'You will receive updates via your preferred communication method.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
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