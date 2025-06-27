import 'dart:async';
import 'dart:math';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocationContext() async {
    // Simulate location detection delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock location data for Greater Accra, Ghana
    final random = Random();
    final temperatures = [26, 27, 28, 29, 30, 31, 32];
    final conditions = ['sunny', 'cloudy', 'partly_cloudy'];
    
    final temperature = temperatures[random.nextInt(temperatures.length)];
    final condition = conditions[random.nextInt(conditions.length)];
    
    return {
      'location': 'East Legon',
      'region': 'Greater Accra',
      'country': 'Ghana',
      'temperature': temperature,
      'condition': condition,
      'suggestion': _getWeatherSuggestion(condition, temperature),
      'latitude': 5.6037,
      'longitude': -0.1870,
    };
  }

  static String _getWeatherSuggestion(String condition, int temperature) {
    if (temperature > 30) {
      return 'Perfect weather for cold drinks! 🧊';
    } else if (condition == 'sunny') {
      return 'Great day for outdoor services! ☀️';
    } else if (condition == 'cloudy') {
      return 'Good time for indoor activities 🏠';
    } else {
      return 'Ideal weather for any service 👍';
    }
  }

  static Future<List<Map<String, dynamic>>> getNearbyServiceProviders({
    required double latitude,
    required double longitude,
    String? serviceType,
    double radiusKm = 10.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock nearby service providers in Greater Accra
    final providers = [
      {
        'id': 'provider_001',
        'name': 'Kwame\'s Quick Services',
        'serviceTypes': ['Food Delivery', 'Grocery Shopping'],
        'rating': 4.8,
        'distance': 1.2,
        'estimatedTime': '10-15 min',
        'location': 'East Legon',
      },
      {
        'id': 'provider_002',
        'name': 'Ama\'s Cleaning Co.',
        'serviceTypes': ['House Cleaning', 'Laundry'],
        'rating': 4.9,
        'distance': 2.1,
        'estimatedTime': '15-20 min',
        'location': 'Cantonments',
      },
      {
        'id': 'provider_003',
        'name': 'Accra Fast Foods',
        'serviceTypes': ['Food Delivery'],
        'rating': 4.6,
        'distance': 0.8,
        'estimatedTime': '8-12 min',
        'location': 'Airport Residential',
      },
      {
        'id': 'provider_004',
        'name': 'Ghana Tech Repairs',
        'serviceTypes': ['Electrical', 'Plumbing', 'HVAC'],
        'rating': 4.7,
        'distance': 3.5,
        'estimatedTime': '20-25 min',
        'location': 'Dzorwulu',
      },
    ];
    
    // Filter by service type if specified
    if (serviceType != null) {
      return providers.where((provider) => 
        (provider['serviceTypes'] as List).contains(serviceType)
      ).toList();
    }
    
    return providers;
  }

  static Future<Map<String, dynamic>> getLocationInsights({
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return {
      'area': 'East Legon',
      'popularServices': [
        {'name': 'Food Delivery', 'demand': 'High'},
        {'name': 'House Cleaning', 'demand': 'Medium'},
        {'name': 'Transportation', 'demand': 'High'},
      ],
      'peakHours': ['7-9 AM', '12-2 PM', '6-8 PM'],
      'averageWaitTime': '12 minutes',
      'serviceAvailability': 'Excellent',
    };
  }
}