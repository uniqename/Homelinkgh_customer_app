import 'dart:math';

class LocationService {
  // Get current location context including weather and regional data
  static Future<Map<String, dynamic>> getCurrentLocationContext() async {
    // Simulate location detection and weather data
    await Future.delayed(const Duration(milliseconds: 500));
    
    final ghanaRegions = [
      {
        'name': 'Greater Accra',
        'cities': ['Accra', 'Tema', 'Kasoa', 'Madina', 'Adenta'],
        'popularServices': ['food_delivery', 'restaurant', 'groceries', 'cleaning', 'cooking', 'security'],
        'climate': 'coastal',
      },
      {
        'name': 'Ashanti',
        'cities': ['Kumasi', 'Obuasi', 'Ejisu', 'Mampong'],
        'popularServices': ['cleaning', 'plumbing', 'gardening', 'construction'],
        'climate': 'forest',
      },
      {
        'name': 'Western',
        'cities': ['Sekondi-Takoradi', 'Tarkwa', 'Axim'],
        'popularServices': ['security', 'cleaning', 'maintenance'],
        'climate': 'coastal',
      },
      {
        'name': 'Central',
        'cities': ['Cape Coast', 'Winneba', 'Kasoa'],
        'popularServices': ['tourism_support', 'cleaning', 'catering'],
        'climate': 'coastal',
      },
      {
        'name': 'Eastern',
        'cities': ['Koforidua', 'Akosombo', 'Nkawkaw'],
        'popularServices': ['agriculture_support', 'cleaning', 'construction'],
        'climate': 'forest',
      },
      {
        'name': 'Volta',
        'cities': ['Ho', 'Hohoe', 'Keta'],
        'popularServices': ['agriculture_support', 'construction', 'catering'],
        'climate': 'mixed',
      },
      {
        'name': 'Northern',
        'cities': ['Tamale', 'Yendi', 'Savelugu'],
        'popularServices': ['agriculture_support', 'construction', 'water_services'],
        'climate': 'savanna',
      },
      {
        'name': 'Upper East',
        'cities': ['Bolgatanga', 'Navrongo', 'Bawku'],
        'popularServices': ['agriculture_support', 'construction', 'education_support'],
        'climate': 'savanna',
      },
      {
        'name': 'Upper West',
        'cities': ['Wa', 'Lawra', 'Jirapa'],
        'popularServices': ['agriculture_support', 'water_services', 'construction'],
        'climate': 'savanna',
      },
      {
        'name': 'Brong-Ahafo',
        'cities': ['Sunyani', 'Techiman', 'Berekum'],
        'popularServices': ['agriculture_support', 'construction', 'transportation'],
        'climate': 'forest',
      },
    ];
    
    // Focus on Greater Accra region for MVP launch
    final currentRegion = ghanaRegions[0]; // Greater Accra is first in the list
    final cities = currentRegion['cities'] as List<String>;
    final currentCity = cities[Random().nextInt(cities.length)];
    
    // Generate contextual weather data
    final weatherData = _generateWeatherData(currentRegion['climate'] as String);
    
    return {
      'region': currentRegion['name'],
      'city': currentCity,
      'location': '$currentCity, ${currentRegion['name']}',
      'coordinates': _getRegionCoordinates(currentRegion['name'] as String),
      'popularServices': currentRegion['popularServices'],
      'climate': currentRegion['climate'],
      'temperature': weatherData['temperature'],
      'condition': weatherData['condition'],
      'humidity': weatherData['humidity'],
      'suggestion': weatherData['suggestion'],
      'serviceRecommendations': _getLocationBasedServiceRecommendations(
        currentRegion['climate'] as String,
        weatherData['condition'] as String,
      ),
    };
  }
  
  // Generate realistic weather data based on climate
  static Map<String, dynamic> _generateWeatherData(String climate) {
    final random = Random();
    final currentMonth = DateTime.now().month;
    final currentHour = DateTime.now().hour;
    
    int baseTemp;
    List<String> conditions;
    String suggestion;
    
    // Set base temperature and conditions based on climate and season
    switch (climate) {
      case 'coastal':
        baseTemp = (currentMonth >= 11 || currentMonth <= 2) ? 28 : 26; // Dry vs rainy season
        conditions = (currentMonth >= 3 && currentMonth <= 10) 
            ? ['cloudy', 'rainy', 'partly_cloudy']
            : ['sunny', 'partly_cloudy'];
        break;
      case 'forest':
        baseTemp = (currentMonth >= 11 || currentMonth <= 2) ? 30 : 24;
        conditions = (currentMonth >= 3 && currentMonth <= 10)
            ? ['rainy', 'cloudy', 'humid']
            : ['sunny', 'partly_cloudy'];
        break;
      case 'savanna':
        baseTemp = (currentMonth >= 11 || currentMonth <= 2) ? 35 : 28;
        conditions = (currentMonth >= 11 || currentMonth <= 2)
            ? ['sunny', 'hot', 'dusty']
            : ['rainy', 'cloudy'];
        break;
      default:
        baseTemp = 28;
        conditions = ['sunny', 'partly_cloudy'];
    }
    
    // Adjust temperature based on time of day
    int tempAdjustment = 0;
    if (currentHour >= 6 && currentHour < 12) {
      tempAdjustment = -3; // Cooler in morning
    } else if (currentHour >= 12 && currentHour < 16) {
      tempAdjustment = 3; // Hotter in afternoon
    } else if (currentHour >= 16 && currentHour < 20) {
      tempAdjustment = 0; // Moderate in evening
    } else {
      tempAdjustment = -5; // Cooler at night
    }
    
    final temperature = baseTemp + tempAdjustment + random.nextInt(4) - 2;
    final condition = conditions[random.nextInt(conditions.length)];
    
    // Generate weather-based service suggestions
    switch (condition) {
      case 'rainy':
        suggestion = 'Perfect weather for indoor services';
        break;
      case 'sunny':
        suggestion = 'Great day for outdoor maintenance';
        break;
      case 'hot':
        suggestion = 'AC maintenance recommended';
        break;
      case 'humid':
        suggestion = 'Consider ventilation services';
        break;
      default:
        suggestion = 'All services available';
    }
    
    return {
      'temperature': temperature,
      'condition': condition,
      'humidity': random.nextInt(30) + 60, // 60-90% humidity
      'suggestion': suggestion,
    };
  }
  
  // Get coordinates for Ghana regions (approximate centers)
  static Map<String, double> _getRegionCoordinates(String region) {
    final coordinates = {
      'Greater Accra': {'lat': 5.6037, 'lng': -0.1870},
      'Ashanti': {'lat': 6.7081, 'lng': -1.6230},
      'Western': {'lat': 4.8960, 'lng': -2.2000},
      'Central': {'lat': 5.4257, 'lng': -1.0381},
      'Eastern': {'lat': 6.0833, 'lng': -0.2833},
      'Volta': {'lat': 6.6000, 'lng': 0.4667},
      'Northern': {'lat': 9.4034, 'lng': -0.8424},
      'Upper East': {'lat': 10.7969, 'lng': -0.8571},
      'Upper West': {'lat': 10.0600, 'lng': -2.5000},
      'Brong-Ahafo': {'lat': 7.7270, 'lng': -2.3190},
    };
    
    return coordinates[region] ?? {'lat': 5.6037, 'lng': -0.1870};
  }
  
  // Get service recommendations based on location and weather
  static List<Map<String, dynamic>> _getLocationBasedServiceRecommendations(
    String climate,
    String condition,
  ) {
    List<Map<String, dynamic>> recommendations = [];
    
    // Climate-based recommendations
    switch (climate) {
      case 'coastal':
        recommendations.addAll([
          {
            'service': 'AC Maintenance',
            'reason': 'High humidity in coastal areas',
            'priority': 'high',
            'icon': 'ac_unit',
          },
          {
            'service': 'Anti-Corrosion Treatment',
            'reason': 'Salt air protection needed',
            'priority': 'medium',
            'icon': 'shield',
          },
        ]);
        break;
      case 'savanna':
        recommendations.addAll([
          {
            'service': 'Dust Protection',
            'reason': 'Dusty conditions require special cleaning',
            'priority': 'high',
            'icon': 'cleaning_services',
          },
          {
            'service': 'Water System Check',
            'reason': 'Water scarcity concerns in savanna',
            'priority': 'high',
            'icon': 'water_drop',
          },
        ]);
        break;
      case 'forest':
        recommendations.addAll([
          {
            'service': 'Pest Control',
            'reason': 'Forest areas prone to insects',
            'priority': 'medium',
            'icon': 'pest_control',
          },
          {
            'service': 'Humidity Control',
            'reason': 'High humidity in forest regions',
            'priority': 'medium',
            'icon': 'humidity',
          },
        ]);
        break;
    }
    
    // Weather condition-based recommendations
    switch (condition) {
      case 'rainy':
        recommendations.addAll([
          {
            'service': 'Roof Inspection',
            'reason': 'Rainy weather roof check needed',
            'priority': 'high',
            'icon': 'roofing',
          },
          {
            'service': 'Drainage Cleaning',
            'reason': 'Prevent flooding during rains',
            'priority': 'high',
            'icon': 'water_damage',
          },
        ]);
        break;
      case 'sunny':
        recommendations.addAll([
          {
            'service': 'Solar Panel Cleaning',
            'reason': 'Maximize solar efficiency in sun',
            'priority': 'medium',
            'icon': 'solar_power',
          },
          {
            'service': 'Outdoor Maintenance',
            'reason': 'Perfect weather for outdoor work',
            'priority': 'low',
            'icon': 'yard',
          },
        ]);
        break;
      case 'hot':
        recommendations.addAll([
          {
            'service': 'AC Service',
            'reason': 'Beat the heat with AC maintenance',
            'priority': 'high',
            'icon': 'ac_unit',
          },
        ]);
        break;
    }
    
    return recommendations;
  }
  
  // Get nearby service providers based on location
  static Future<List<Map<String, dynamic>>> getNearbyProviders({
    required String region,
    required String serviceType,
    int limit = 10,
  }) async {
    // Simulate fetching nearby providers
    await Future.delayed(const Duration(milliseconds: 300));
    
    final providers = [
      {
        'name': 'Accra Premium Services',
        'rating': 4.9,
        'distance': 2.3,
        'services': ['cleaning', 'cooking', 'security'],
        'verified': true,
        'responseTime': '15 min',
      },
      {
        'name': 'Ghana Home Solutions',
        'rating': 4.7,
        'distance': 3.1,
        'services': ['plumbing', 'electrical', 'maintenance'],
        'verified': true,
        'responseTime': '30 min',
      },
      {
        'name': 'Kumasi Care Services',
        'rating': 4.8,
        'distance': 1.8,
        'services': ['gardening', 'cleaning', 'catering'],
        'verified': true,
        'responseTime': '20 min',
      },
    ];
    
    // Filter providers that offer the requested service
    final filteredProviders = providers
        .where((provider) => 
            (provider['services'] as List).contains(serviceType) ||
            serviceType == 'all')
        .toList();
    
    // Sort by distance and rating
    filteredProviders.sort((a, b) {
      final scoreA = (a['rating'] as double) - (a['distance'] as double) * 0.1;
      final scoreB = (b['rating'] as double) - (b['distance'] as double) * 0.1;
      return scoreB.compareTo(scoreA);
    });
    
    return filteredProviders.take(limit).toList();
  }
  
  // Get regional service pricing
  static Map<String, dynamic> getRegionalPricing(String region, String serviceType) {
    final pricingTiers = {
      'Greater Accra': 1.2, // 20% higher in capital
      'Ashanti': 1.1, // 10% higher in Kumasi
      'Western': 1.0, // Base pricing
      'Central': 0.9, // 10% lower
      'Eastern': 0.85, // 15% lower
      'Volta': 0.8, // 20% lower
      'Northern': 0.75, // 25% lower
      'Upper East': 0.7, // 30% lower
      'Upper West': 0.7, // 30% lower
      'Brong-Ahafo': 0.8, // 20% lower
    };
    
    final basePrices = {
      'cleaning': 80,
      'cooking': 150,
      'plumbing': 120,
      'electrical': 100,
      'security': 200,
      'gardening': 90,
      'maintenance': 110,
    };
    
    final multiplier = pricingTiers[region] ?? 1.0;
    final basePrice = basePrices[serviceType] ?? 100;
    
    return {
      'basePrice': basePrice,
      'regionalPrice': (basePrice * multiplier).round(),
      'multiplier': multiplier,
      'currency': '₵',
    };
  }
  
  // Check service availability in region
  static Future<Map<String, dynamic>> checkServiceAvailability({
    required String region,
    required String serviceType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Simulate service availability based on region development
    final availabilityMap = {
      'Greater Accra': {
        'availability': 'high',
        'providers': 45,
        'averageWaitTime': '30 minutes',
        'coverage': '24/7',
      },
      'Ashanti': {
        'availability': 'high',
        'providers': 35,
        'averageWaitTime': '45 minutes',
        'coverage': '24/7',
      },
      'Western': {
        'availability': 'medium',
        'providers': 20,
        'averageWaitTime': '1 hour',
        'coverage': '6 AM - 10 PM',
      },
      'Central': {
        'availability': 'medium',
        'providers': 18,
        'averageWaitTime': '1.5 hours',
        'coverage': '6 AM - 9 PM',
      },
      'Eastern': {
        'availability': 'medium',
        'providers': 15,
        'averageWaitTime': '2 hours',
        'coverage': '7 AM - 8 PM',
      },
      'Northern': {
        'availability': 'limited',
        'providers': 8,
        'averageWaitTime': '4 hours',
        'coverage': '8 AM - 6 PM',
      },
      'Upper East': {
        'availability': 'limited',
        'providers': 5,
        'averageWaitTime': '6 hours',
        'coverage': '8 AM - 5 PM',
      },
      'Upper West': {
        'availability': 'limited',
        'providers': 4,
        'averageWaitTime': '8 hours',
        'coverage': '9 AM - 5 PM',
      },
      'Volta': {
        'availability': 'medium',
        'providers': 12,
        'averageWaitTime': '3 hours',
        'coverage': '7 AM - 7 PM',
      },
      'Brong-Ahafo': {
        'availability': 'medium',
        'providers': 10,
        'averageWaitTime': '3.5 hours',
        'coverage': '7 AM - 6 PM',
      },
    };
    
    final regionData = availabilityMap[region] ?? availabilityMap['Greater Accra']!;
    
    return {
      'region': region,
      'serviceType': serviceType,
      'available': regionData['availability'] != 'unavailable',
      'availability': regionData['availability'],
      'providerCount': regionData['providers'],
      'estimatedWaitTime': regionData['averageWaitTime'],
      'serviceHours': regionData['coverage'],
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}