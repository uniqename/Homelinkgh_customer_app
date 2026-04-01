import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SmartRecommendationService {
  static Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required String userId,
    required String userType,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock personalized recommendations based on user type
    switch (userType) {
      case 'diaspora_customer':
        return [
          {
            'title': 'House Preparation Service',
            'description': 'Get your house ready before arrival with deep cleaning, restocking, and maintenance checks',
            'startingPrice': 150,
            'matchScore': 95,
            'icon': Icons.home,
            'color': const Color(0xFF2E8B57),
          },
          {
            'title': 'Airport Pickup & Transport',
            'description': 'Reliable transportation from Kotoka International Airport to your destination',
            'startingPrice': 80,
            'matchScore': 88,
            'icon': Icons.flight_land,
            'color': const Color(0xFF1E88E5),
          },
          {
            'title': 'Grocery Pre-Stocking',
            'description': 'Fresh groceries and essentials delivered and stocked before your arrival',
            'startingPrice': 120,
            'matchScore': 92,
            'icon': Icons.shopping_cart,
            'color': const Color(0xFF32CD32),
          },
        ];
      case 'family_helper':
        return [
          {
            'title': 'Elder Care Services',
            'description': 'Professional care and companion services for elderly family members',
            'startingPrice': 200,
            'matchScore': 96,
            'icon': Icons.elderly,
            'color': const Color(0xFF9C27B0),
          },
          {
            'title': 'Utility Bill Management',
            'description': 'Pay bills, manage utilities, and handle administrative tasks for family',
            'startingPrice': 50,
            'matchScore': 89,
            'icon': Icons.receipt_long,
            'color': const Color(0xFF607D8B),
          },
        ];
      default:
        return [
          {
            'title': 'Food Delivery Express',
            'description': 'Quick delivery from your favorite local restaurants in Greater Accra',
            'startingPrice': 25,
            'matchScore': 94,
            'icon': Icons.delivery_dining,
            'color': const Color(0xFFFF6B35),
          },
          {
            'title': 'House Cleaning Pro',
            'description': 'Professional deep cleaning services for your home',
            'startingPrice': 80,
            'matchScore': 87,
            'icon': Icons.cleaning_services,
            'color': const Color(0xFF2196F3),
          },
        ];
    }
  }

  static Future<List<Map<String, dynamic>>> getTrendingServices(String? region) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock trending services for Greater Accra region
    return [
      {
        'name': 'Food Delivery',
        'icon': Icons.delivery_dining,
        'color': const Color(0xFFFF6B35),
        'price': 25,
        'growth': 45,
      },
      {
        'name': 'House Cleaning',
        'icon': Icons.cleaning_services,
        'color': const Color(0xFF2196F3),
        'price': 80,
        'growth': 32,
      },
      {
        'name': 'Grocery Shopping',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF4CAF50),
        'price': 50,
        'growth': 28,
      },
      {
        'name': 'Plumbing Services',
        'icon': Icons.plumbing,
        'color': const Color(0xFF795548),
        'price': 120,
        'growth': 21,
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getQuickAccessServices(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock personalized quick access services
    return [
      {
        'name': 'Food Delivery',
        'icon': Icons.delivery_dining,
        'color': const Color(0xFFFF6B35),
        'badge': 'New',
      },
      {
        'name': 'Cleaning',
        'icon': Icons.cleaning_services,
        'color': const Color(0xFF2196F3),
        'badge': null,
      },
      {
        'name': 'Grocery',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF4CAF50),
        'badge': 'Popular',
      },
      {
        'name': 'Transport',
        'icon': Icons.directions_car,
        'color': const Color(0xFF9C27B0),
        'badge': null,
      },
      {
        'name': 'Plumbing',
        'icon': Icons.plumbing,
        'color': const Color(0xFF795548),
        'badge': null,
      },
      {
        'name': 'Electrical',
        'icon': Icons.electrical_services,
        'color': const Color(0xFFFF9800),
        'badge': null,
      },
      {
        'name': 'Beauty',
        'icon': Icons.face_retouching_natural,
        'color': const Color(0xFFE91E63),
        'badge': 'Trending',
      },
      {
        'name': 'Emergency',
        'icon': Icons.emergency,
        'color': const Color(0xFFF44336),
        'badge': '24/7',
      },
    ];
  }
}