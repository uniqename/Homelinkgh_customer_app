import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SmartRecommendationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Get personalized recommendations based on user behavior and preferences
  static Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required String userId,
    required String userType,
  }) async {
    try {
      // In a real implementation, this would analyze:
      // - User's booking history
      // - Time patterns
      // - Seasonal preferences
      // - Location data
      // - Similar user behaviors
      
      final recommendations = await _generateSmartRecommendations(userId, userType);
      return recommendations;
    } catch (e) {
      return _getDefaultRecommendations(userType);
    }
  }
  
  // Generate AI-powered smart recommendations
  static Future<List<Map<String, dynamic>>> _generateSmartRecommendations(
    String userId,
    String userType,
  ) async {
    // Simulate AI analysis of user behavior
    final userProfile = await _getUserProfile(userId);
    final bookingHistory = await _getBookingHistory(userId);
    final timePatterns = _analyzeTimePatterns(bookingHistory);
    final seasonalPreferences = _analyzeSeasonalPreferences();
    
    List<Map<String, dynamic>> recommendations = [];
    
    // Time-based recommendations
    final currentHour = DateTime.now().hour;
    final currentMonth = DateTime.now().month;
    
    // Morning recommendations (6-12)
    if (currentHour >= 6 && currentHour < 12) {
      recommendations.addAll(_getMorningRecommendations(userType));
    }
    // Afternoon recommendations (12-17)
    else if (currentHour >= 12 && currentHour < 17) {
      recommendations.addAll(_getAfternoonRecommendations(userType));
    }
    // Evening recommendations (17-22)
    else if (currentHour >= 17 && currentHour < 22) {
      recommendations.addAll(_getEveningRecommendations(userType));
    }
    
    // Seasonal recommendations
    recommendations.addAll(_getSeasonalRecommendations(currentMonth, userType));
    
    // User type specific recommendations
    if (userType == 'diaspora_customer') {
      recommendations.addAll(_getDiasporaRecommendations());
    } else if (userType == 'family_helper') {
      recommendations.addAll(_getFamilyHelperRecommendations());
    }
    
    // Sort by match score and return top recommendations
    recommendations.sort((a, b) => (b['matchScore'] as int).compareTo(a['matchScore'] as int));
    return recommendations.take(5).toList();
  }
  
  static List<Map<String, dynamic>> _getMorningRecommendations(String userType) {
    return [
      {
        'title': 'Fresh Breakfast Delivery',
        'description': 'Hot waakye, kelewele & porridge delivered across Greater Accra in 30 mins',
        'icon': Icons.breakfast_dining,
        'color': const Color(0xFFFF6B35),
        'matchScore': 95,
        'startingPrice': 25,
        'category': 'food_delivery',
        'timeOptimal': true,
      },
      {
        'title': 'Local Restaurant Specials',
        'description': 'Authentic Ghanaian breakfast from top Accra restaurants',
        'icon': Icons.restaurant,
        'color': const Color(0xFFFFA500),
        'matchScore': 92,
        'startingPrice': 35,
        'category': 'restaurant',
        'timeOptimal': true,
      },
      {
        'title': 'House Cleaning',
        'description': 'Perfect morning for thorough cleaning in Greater Accra',
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
        'matchScore': 85,
        'startingPrice': 80,
        'category': 'cleaning',
        'timeOptimal': true,
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getAfternoonRecommendations(String userType) {
    return [
      {
        'title': 'Lunch Specials Delivery',
        'description': 'Jollof rice, banku, fufu & more from Greater Accra\'s finest restaurants',
        'icon': Icons.lunch_dining,
        'color': const Color(0xFFFF6B35),
        'matchScore': 98,
        'startingPrice': 30,
        'category': 'food_delivery',
        'timeOptimal': true,
      },
      {
        'title': 'Office Catering',
        'description': 'Bulk lunch orders for teams across Accra, Tema & Kasoa',
        'icon': Icons.group,
        'color': const Color(0xFF2E8B57),
        'matchScore': 90,
        'startingPrice': 200,
        'category': 'catering',
        'timeOptimal': true,
      },
      {
        'title': 'Grocery Shopping',
        'description': 'Fresh ingredients delivered from Accra\'s best markets',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF32CD32),
        'matchScore': 87,
        'startingPrice': 50,
        'category': 'groceries',
        'timeOptimal': true,
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getEveningRecommendations(String userType) {
    return [
      {
        'title': 'Dinner Delivery',
        'description': 'Hot dinner from Accra\'s finest restaurants delivered to your door',
        'icon': Icons.dinner_dining,
        'color': const Color(0xFFFF6B35),
        'matchScore': 96,
        'startingPrice': 40,
        'category': 'food_delivery',
        'timeOptimal': true,
      },
      {
        'title': 'Private Chef Service',
        'description': 'Personal chef prepares authentic Ghanaian meals in your home',
        'icon': Icons.restaurant_menu,
        'color': const Color(0xFFFFA500),
        'matchScore': 91,
        'startingPrice': 250,
        'category': 'private_cooking',
        'timeOptimal': true,
      },
      {
        'title': 'Evening Snacks',
        'description': 'Kelewele, bofrot & local treats delivered across Greater Accra',
        'icon': Icons.fastfood,
        'color': const Color(0xFF32CD32),
        'matchScore': 88,
        'startingPrice': 15,
        'category': 'snacks',
        'timeOptimal': true,
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getSeasonalRecommendations(int month, String userType) {
    // Dry season (November - February)
    if (month >= 11 || month <= 2) {
      return [
        {
          'title': 'Deep House Cleaning',
          'description': 'Dry season perfect for thorough cleaning and maintenance',
          'icon': Icons.home_repair_service,
          'color': Colors.brown,
          'matchScore': 89,
          'startingPrice': 250,
          'category': 'cleaning',
          'seasonal': true,
        },
        {
          'title': 'Painting Services',
          'description': 'Ideal weather for interior and exterior painting projects',
          'icon': Icons.format_paint,
          'color': Colors.indigo,
          'matchScore': 86,
          'startingPrice': 300,
          'category': 'maintenance',
          'seasonal': true,
        },
      ];
    }
    // Rainy season (March - October)
    else {
      return [
        {
          'title': 'Plumbing Check',
          'description': 'Rainy season maintenance for pipes and drainage',
          'icon': Icons.plumbing,
          'color': Colors.blue,
          'matchScore': 91,
          'startingPrice': 150,
          'category': 'plumbing',
          'seasonal': true,
        },
        {
          'title': 'Roof Inspection',
          'description': 'Essential roof maintenance during rainy season',
          'icon': Icons.roofing,
          'color': Colors.grey,
          'matchScore': 87,
          'startingPrice': 200,
          'category': 'maintenance',
          'seasonal': true,
        },
      ];
    }
  }
  
  static List<Map<String, dynamic>> _getDiasporaRecommendations() {
    return [
      {
        'title': 'House Preparation',
        'description': 'Get your house ready before your arrival in Ghana',
        'icon': Icons.flight_land,
        'color': const Color(0xFF006B3C),
        'matchScore': 96,
        'startingPrice': 400,
        'category': 'preparation',
        'diasporaSpecial': true,
      },
      {
        'title': 'Family Check Service',
        'description': 'Welfare check and assistance for your family members',
        'icon': Icons.family_restroom,
        'color': Colors.pink,
        'matchScore': 93,
        'startingPrice': 100,
        'category': 'family',
        'diasporaSpecial': true,
      },
      {
        'title': 'Property Management',
        'description': 'Ongoing maintenance and security for your Ghana property',
        'icon': Icons.business,
        'color': Colors.teal,
        'matchScore': 90,
        'startingPrice': 500,
        'category': 'property',
        'diasporaSpecial': true,
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getFamilyHelperRecommendations() {
    return [
      {
        'title': 'Elderly Care',
        'description': 'Professional care services for elderly family members',
        'icon': Icons.elderly,
        'color': Colors.deepPurple,
        'matchScore': 95,
        'startingPrice': 200,
        'category': 'care',
        'familyFocused': true,
      },
      {
        'title': 'Shopping Service',
        'description': 'Grocery shopping and delivery for your family',
        'icon': Icons.shopping_cart,
        'color': Colors.green,
        'matchScore': 88,
        'startingPrice': 50,
        'category': 'shopping',
        'familyFocused': true,
      },
    ];
  }
  
  // Get trending services in Greater Accra (food-focused MVP)
  static Future<List<Map<String, dynamic>>> getTrendingServices(String? region) async {
    // Focus on Greater Accra trending services with food delivery prominence
    final trendingServices = [
      {
        'name': 'Restaurant Delivery',
        'icon': Icons.delivery_dining,
        'color': const Color(0xFFFF6B35),
        'price': 25,
        'growth': 85,
        'category': 'food_delivery',
      },
      {
        'name': 'Local Food Spots',
        'icon': Icons.restaurant,
        'color': const Color(0xFFFFA500),
        'price': 35,
        'growth': 72,
        'category': 'restaurant',
      },
      {
        'name': 'Home Cooking',
        'icon': Icons.kitchen,
        'color': const Color(0xFF2E8B57),
        'price': 150,
        'growth': 65,
        'category': 'private_cooking',
      },
      {
        'name': 'Grocery Delivery',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF32CD32),
        'price': 50,
        'growth': 58,
        'category': 'groceries',
      },
      {
        'name': 'House Cleaning',
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
        'price': 80,
        'growth': 25,
        'category': 'cleaning',
      },
    ];
    
    // Sort by growth rate
    trendingServices.sort((a, b) => (b['growth'] as int).compareTo(a['growth'] as int));
    return trendingServices.take(4).toList();
  }
  
  // Get quick access services based on user's most used services
  static Future<List<Map<String, dynamic>>> getQuickAccessServices(String userId) async {
    try {
      // In real implementation, analyze user's most frequent services
      final userHistory = await _getBookingHistory(userId);
      final frequentServices = _analyzeFrequentServices(userHistory);
      
      return frequentServices.isNotEmpty ? frequentServices : _getDefaultQuickAccess();
    } catch (e) {
      return _getDefaultQuickAccess();
    }
  }
  
  static List<Map<String, dynamic>> _getDefaultQuickAccess() {
    return [
      {
        'name': 'Food Delivery',
        'icon': Icons.delivery_dining,
        'color': const Color(0xFFFF6B35),
        'category': 'food_delivery',
        'badge': 'Most Popular',
      },
      {
        'name': 'Restaurant Meals',
        'icon': Icons.restaurant,
        'color': const Color(0xFFFFA500),
        'category': 'restaurant',
        'badge': 'Hot',
      },
      {
        'name': 'Home Cooking',
        'icon': Icons.kitchen,
        'color': const Color(0xFF2E8B57),
        'category': 'private_cooking',
        'badge': 'Fresh',
      },
      {
        'name': 'Groceries',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF32CD32),
        'category': 'groceries',
        'badge': 'New',
      },
      {
        'name': 'House Cleaning',
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
        'category': 'cleaning',
      },
      {
        'name': 'Security',
        'icon': Icons.security,
        'color': Colors.red,
        'category': 'security',
      },
      {
        'name': 'Laundry',
        'icon': Icons.local_laundry_service,
        'color': Colors.purple,
        'category': 'laundry',
      },
      {
        'name': 'Errands',
        'icon': Icons.directions_run,
        'color': Colors.teal,
        'category': 'errands',
      },
    ];
  }
  
  // Analyze user's booking patterns to predict preferences
  static Map<String, dynamic> _analyzeTimePatterns(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) return {};
    
    final hourCounts = <int, int>{};
    final categoryCounts = <String, int>{};
    
    for (final booking in bookings) {
      final hour = (booking['hour'] as int?) ?? 12;
      final category = booking['category'] as String? ?? 'general';
      
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    
    return {
      'preferredHours': hourCounts,
      'preferredCategories': categoryCounts,
    };
  }
  
  static Map<String, dynamic> _analyzeSeasonalPreferences() {
    final currentMonth = DateTime.now().month;
    return {
      'isDrySeason': currentMonth >= 11 || currentMonth <= 2,
      'isRainySeason': currentMonth >= 3 && currentMonth <= 10,
    };
  }
  
  static List<Map<String, dynamic>> _analyzeFrequentServices(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return [];
    
    final serviceCounts = <String, int>{};
    final serviceDetails = <String, Map<String, dynamic>>{};
    
    for (final booking in history) {
      final service = booking['service'] as String? ?? '';
      serviceCounts[service] = (serviceCounts[service] ?? 0) + 1;
      serviceDetails[service] = booking;
    }
    
    // Convert to quick access format
    final sortedServices = serviceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedServices.take(8).map((entry) {
      final service = serviceDetails[entry.key]!;
      return {
        'name': entry.key,
        'icon': _getServiceIcon(entry.key),
        'color': _getServiceColor(entry.key),
        'category': service['category'] ?? 'general',
        'usage': entry.value,
      };
    }).toList();
  }
  
  // Helper methods
  static Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      return {};
    }
  }
  
  static Future<List<Map<String, dynamic>>> _getBookingHistory(String userId) async {
    try {
      final query = await _db
          .collection('bookings')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
  
  static IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'cleaning': return Icons.cleaning_services;
      case 'cooking': return Icons.restaurant;
      case 'plumbing': return Icons.plumbing;
      case 'ac repair': return Icons.ac_unit;
      case 'security': return Icons.security;
      case 'gardening': return Icons.local_florist;
      case 'laundry': return Icons.local_laundry_service;
      case 'shopping': return Icons.shopping_cart;
      default: return Icons.home_repair_service;
    }
  }
  
  static Color _getServiceColor(String service) {
    switch (service.toLowerCase()) {
      case 'cleaning': return Colors.blue;
      case 'cooking': return Colors.orange;
      case 'plumbing': return Colors.brown;
      case 'ac repair': return Colors.cyan;
      case 'security': return Colors.red;
      case 'gardening': return Colors.green;
      case 'laundry': return Colors.purple;
      case 'shopping': return Colors.pink;
      default: return Colors.grey;
    }
  }
  
  static List<Map<String, dynamic>> _getDefaultRecommendations(String userType) {
    return [
      {
        'title': 'House Cleaning',
        'description': 'Professional cleaning service for your home',
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
        'matchScore': 85,
        'startingPrice': 80,
        'category': 'cleaning',
      },
      {
        'title': 'Cooking Service',
        'description': 'Delicious meals prepared by professional chefs',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'matchScore': 80,
        'startingPrice': 150,
        'category': 'cooking',
      },
    ];
  }
  
  // Update user preferences based on interactions
  static Future<void> updateUserPreferences({
    required String userId,
    required String action, // view, book, favorite, rate
    required Map<String, dynamic> serviceData,
  }) async {
    try {
      await _db.collection('user_preferences').doc(userId).set({
        'lastInteraction': FieldValue.serverTimestamp(),
        'actions': FieldValue.arrayUnion([{
          'action': action,
          'service': serviceData,
          'timestamp': FieldValue.serverTimestamp(),
        }]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user preferences: $e');
    }
  }
  
  // Get smart search suggestions based on user behavior
  static Future<List<String>> getSmartSearchSuggestions(String userId) async {
    try {
      final preferences = await _db.collection('user_preferences').doc(userId).get();
      final data = preferences.data() ?? {};
      
      // Analyze recent actions to suggest relevant searches
      final actions = data['actions'] as List? ?? [];
      final recentServices = actions
          .cast<Map<String, dynamic>>()
          .map((action) => action['service']['category'] as String?)
          .where((category) => category != null)
          .take(5)
          .toList();
      
      return recentServices.cast<String>();
    } catch (e) {
      return ['cleaning', 'cooking', 'plumbing', 'security'];
    }
  }
}