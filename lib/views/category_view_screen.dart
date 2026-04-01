import 'package:flutter/material.dart';
import 'smart_service_booking.dart';

class CategoryViewScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String userType;

  const CategoryViewScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.userType,
  });

  @override
  State<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends State<CategoryViewScreen> {
  List<Map<String, dynamic>> _categoryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
  }

  void _loadCategoryItems() {
    setState(() => _isLoading = true);
    
    // Mock data based on category
    Map<String, List<Map<String, dynamic>>> categoryData = {
      'ghanaian': [
        {
          'name': 'Jollof Rice',
          'description': 'Authentic Ghanaian jollof rice with chicken or fish',
          'price': 25,
          'image': '🍛',
          'restaurant': 'Auntie Muni\'s Kitchen',
          'rating': 4.8,
          'deliveryTime': '20-30 min',
        },
        {
          'name': 'Banku & Tilapia',
          'description': 'Fresh tilapia with spicy banku and pepper sauce',
          'price': 35,
          'image': '🐟',
          'restaurant': 'Seaside Chop Bar',
          'rating': 4.7,
          'deliveryTime': '25-35 min',
        },
        {
          'name': 'Fufu & Goat Soup',
          'description': 'Traditional fufu with rich goat meat soup',
          'price': 30,
          'image': '🥣',
          'restaurant': 'Heritage Kitchen',
          'rating': 4.9,
          'deliveryTime': '30-40 min',
        },
        {
          'name': 'Waakye',
          'description': 'Rice and beans with stew, fish, and sides',
          'price': 20,
          'image': '🍚',
          'restaurant': 'Waakye Junction',
          'rating': 4.6,
          'deliveryTime': '15-25 min',
        },
      ],
      'fast_food': [
        {
          'name': 'Chicken Burger',
          'description': 'Crispy fried chicken burger with fries',
          'price': 28,
          'image': '🍔',
          'restaurant': 'KFC East Legon',
          'rating': 4.3,
          'deliveryTime': '20-30 min',
        },
        {
          'name': 'Pizza Margherita',
          'description': 'Classic Italian pizza with fresh mozzarella',
          'price': 45,
          'image': '🍕',
          'restaurant': 'Pizza Inn',
          'rating': 4.2,
          'deliveryTime': '30-40 min',
        },
        {
          'name': 'Beef Shawarma',
          'description': 'Tender beef in pita with vegetables and sauce',
          'price': 22,
          'image': '🌯',
          'restaurant': 'Istanbul Kebab',
          'rating': 4.5,
          'deliveryTime': '15-25 min',
        },
      ],
      'breakfast': [
        {
          'name': 'Waakye Breakfast',
          'description': 'Morning waakye with egg and sausage',
          'price': 18,
          'image': '🍳',
          'restaurant': 'Morning Glory',
          'rating': 4.7,
          'deliveryTime': '15-20 min',
        },
        {
          'name': 'Kelewele & Beans',
          'description': 'Spiced plantain with red red beans',
          'price': 15,
          'image': '🍌',
          'restaurant': 'Breakfast Corner',
          'rating': 4.4,
          'deliveryTime': '10-15 min',
        },
        {
          'name': 'Tea & Bread',
          'description': 'Hot tea with fresh butter bread',
          'price': 8,
          'image': '☕',
          'restaurant': 'Sunrise Café',
          'rating': 4.2,
          'deliveryTime': '5-10 min',
        },
      ],
      'snacks': [
        {
          'name': 'Bofrot',
          'description': 'Sweet Ghanaian donuts, freshly made',
          'price': 5,
          'image': '🍩',
          'restaurant': 'Sweet Treats',
          'rating': 4.6,
          'deliveryTime': '10-15 min',
        },
        {
          'name': 'Koose',
          'description': 'Spiced bean cakes, crispy and hot',
          'price': 3,
          'image': '🧆',
          'restaurant': 'Street Food Express',
          'rating': 4.5,
          'deliveryTime': '8-12 min',
        },
        {
          'name': 'Roasted Plantain',
          'description': 'Sweet roasted plantain with groundnuts',
          'price': 7,
          'image': '🍌',
          'restaurant': 'Roadside Grill',
          'rating': 4.3,
          'deliveryTime': '12-18 min',
        },
      ],
    };

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _categoryItems = categoryData[widget.categoryId] ?? [];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF006B3C).withValues(alpha: 0.1),
                        const Color(0xFF006B3C).withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.categoryName} Food',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_categoryItems.length} items available for delivery',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categoryItems.length,
                    itemBuilder: (context, index) {
                      final item = _categoryItems[index];
                      return _buildFoodItemCard(item);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFoodItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _orderItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Food Image/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item['image'] ?? '🍽️',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item['restaurant'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF006B3C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(
                          ' ${item['rating'] ?? 4.0}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏱️ ${item['deliveryTime'] ?? '20-30 min'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price and Order Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'GH₵${item['price'] ?? 0}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _orderItem(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Order',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _orderItem(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartServiceBookingScreen(
          serviceName: 'Food Delivery - ${item['name']}',
          serviceIcon: Icons.delivery_dining,
          serviceColor: const Color(0xFFFF6B35),
        ),
      ),
    );
  }
}