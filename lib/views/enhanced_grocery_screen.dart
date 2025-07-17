import 'package:flutter/material.dart';

class EnhancedGroceryScreen extends StatefulWidget {
  const EnhancedGroceryScreen({super.key});

  @override
  State<EnhancedGroceryScreen> createState() => _EnhancedGroceryScreenState();
}

class _EnhancedGroceryScreenState extends State<EnhancedGroceryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String _selectedLocation = '';
  final List<Map<String, dynamic>> _groceryItems = [];
  final List<String> _customItems = [];
  final TextEditingController _customItemController = TextEditingController();
  
  final List<String> _locations = [
    'East Legon',
    'Accra Mall Area',
    'Airport Residential',
    'Cantonments',
    'Labone',
    'Osu',
    'Spintex',
    'Tema',
    'Other (specify)',
  ];

  final Map<String, List<Map<String, dynamic>>> _groceryCategories = {
    'Fresh Produce': [
      {'name': 'Tomatoes', 'unit': 'kg', 'price': 8.0},
      {'name': 'Onions', 'unit': 'kg', 'price': 6.0},
      {'name': 'Carrots', 'unit': 'kg', 'price': 12.0},
      {'name': 'Green Peppers', 'unit': 'kg', 'price': 15.0},
      {'name': 'Lettuce', 'unit': 'head', 'price': 5.0},
      {'name': 'Bananas', 'unit': 'bunch', 'price': 10.0},
      {'name': 'Oranges', 'unit': 'kg', 'price': 8.0},
      {'name': 'Pineapple', 'unit': 'piece', 'price': 12.0},
    ],
    'Meat & Fish': [
      {'name': 'Chicken (whole)', 'unit': 'kg', 'price': 35.0},
      {'name': 'Beef', 'unit': 'kg', 'price': 45.0},
      {'name': 'Fresh Fish (Tilapia)', 'unit': 'kg', 'price': 25.0},
      {'name': 'Salmon', 'unit': 'kg', 'price': 65.0},
      {'name': 'Shrimp', 'unit': 'kg', 'price': 55.0},
    ],
    'Pantry Staples': [
      {'name': 'Rice (Jasmine)', 'unit': '5kg bag', 'price': 45.0},
      {'name': 'Cooking Oil', 'unit': '1L bottle', 'price': 18.0},
      {'name': 'Sugar', 'unit': '1kg bag', 'price': 8.0},
      {'name': 'Salt', 'unit': '500g', 'price': 3.0},
      {'name': 'Black Pepper', 'unit': '100g', 'price': 12.0},
      {'name': 'Garlic', 'unit': '200g', 'price': 8.0},
      {'name': 'Ginger', 'unit': '200g', 'price': 10.0},
    ],
    'Dairy & Eggs': [
      {'name': 'Fresh Milk', 'unit': '1L carton', 'price': 12.0},
      {'name': 'Yogurt', 'unit': '500ml cup', 'price': 8.0},
      {'name': 'Cheese (Cheddar)', 'unit': '200g pack', 'price': 25.0},
      {'name': 'Eggs', 'unit': 'dozen', 'price': 18.0},
      {'name': 'Butter', 'unit': '250g pack', 'price': 15.0},
    ],
    'Beverages': [
      {'name': 'Bottled Water', 'unit': '12-pack', 'price': 15.0},
      {'name': 'Coca Cola', 'unit': '6-pack cans', 'price': 18.0},
      {'name': 'Fresh Orange Juice', 'unit': '1L carton', 'price': 12.0},
      {'name': 'Coffee (Ground)', 'unit': '200g pack', 'price': 25.0},
      {'name': 'Tea Bags', 'unit': '40-pack box', 'price': 15.0},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Shopping'),
        backgroundColor: Colors.green,
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
                _buildLocationSelectionStep(),
                _buildGroceryListStep(),
                _buildCustomItemsStep(),
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
    final steps = ['Location', 'Grocery List', 'Custom Items', 'Summary'];
    
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
                  backgroundColor: isActive ? Colors.green : Colors.grey[300],
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
                    color: isActive ? Colors.green : Colors.grey[600],
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

  Widget _buildLocationSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specify Shopping Location',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred shopping area to find the best local stores and prices.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location helps us find nearby stores with the best prices and freshest produce.',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<String>(
                    title: Text(location),
                    subtitle: location == 'Other (specify)' 
                        ? const Text('Enter custom location')
                        : Text('Popular shopping area in $location'),
                    value: location,
                    groupValue: _selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (_selectedLocation == 'Other (specify)')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter your location',
                  hintText: 'e.g., Kumasi, Takoradi, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_location),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroceryListStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build Your Grocery List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select items from our categories. You can add custom items in the next step.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_groceryItems.isNotEmpty)
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
                    '${_groceryItems.length} items in cart',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    'Est: GH₵${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: DefaultTabController(
              length: _groceryCategories.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    tabs: _groceryCategories.keys.map((category) => Tab(text: category)).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: _groceryCategories.values.map((items) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = _groceryItems.any((selected) => selected['name'] == item['name']);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.shopping_basket, color: Colors.green, size: 20),
                                ),
                                title: Text(item['name']),
                                subtitle: Text('${item['unit']} - GH₵${item['price']}'),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : const Icon(Icons.add_circle_outline),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _groceryItems.removeWhere((selected) => selected['name'] == item['name']);
                                    } else {
                                      _groceryItems.add({...item, 'quantity': 1});
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
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

  Widget _buildCustomItemsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Custom Items',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Forgot something? Add any items not in our standard list.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pro tip: Be specific with brands, sizes, or special instructions (e.g., "Milo 500g tin" or "Ripe avocados")',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customItemController,
                  decoration: const InputDecoration(
                    labelText: 'Add custom item',
                    hintText: 'e.g., Organic honey 250ml',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add),
                  ),
                  onFieldSubmitted: (value) {
                    _addCustomItem();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addCustomItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_customItems.isNotEmpty) ...[
            const Text(
              'Custom Items Added:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _customItems.length,
                itemBuilder: (context, index) {
                  final item = _customItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.note_add, color: Colors.orange),
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _customItems.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No custom items added yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryStep() {
    final totalItems = _groceryItems.length + _customItems.length;
    final estimatedTotal = _calculateTotal();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shopping Summary',
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
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Shopping Location: $_selectedLocation',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Total Items: $totalItems'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.receipt, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Standard Items: ${_groceryItems.length}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.note_add, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text('Custom Items: ${_customItems.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_groceryItems.isNotEmpty) ...[
            const Text(
              'Standard Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder: (context, index) {
                  final item = _groceryItems[index];
                  return ListTile(
                    dense: true,
                    title: Text(item['name']),
                    subtitle: Text(item['unit']),
                    trailing: Text('GH₵${item['price']}'),
                  );
                },
              ),
            ),
          ],
          if (_customItems.isNotEmpty) ...[
            const Text(
              'Custom Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: _customItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.note_add, size: 16),
                    title: Text(_customItems[index]),
                    subtitle: const Text('Price to be confirmed'),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimated Total (Standard Items):',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      'GH₵${estimatedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Final total will include custom items and may vary based on actual store prices.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
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
                if (_currentStep < 3) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _placeOrder();
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentStep < 3 ? 'Continue' : 'Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedLocation.isNotEmpty;
      case 1:
        return _groceryItems.isNotEmpty;
      case 2:
        return true; // Custom items are optional
      case 3:
        return true;
      default:
        return false;
    }
  }

  double _calculateTotal() {
    return _groceryItems.fold(0.0, (sum, item) => sum + (item['price'] as double));
  }

  void _addCustomItem() {
    if (_customItemController.text.trim().isNotEmpty) {
      setState(() {
        _customItems.add(_customItemController.text.trim());
        _customItemController.clear();
      });
    }
  }

  void _placeOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grocery Order Placed!'),
        content: Text('Your grocery shopping request for $_selectedLocation has been placed successfully. A shopper will contact you to confirm custom items and final pricing.'),
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