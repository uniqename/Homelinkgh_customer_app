import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PricingApiService {
  static final PricingApiService _instance = PricingApiService._internal();
  factory PricingApiService() => _instance;
  PricingApiService._internal();

  late final Dio _dio;
  static const String baseUrl = 'https://api.homelinkgh.com'; // Replace with actual API URL

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      timeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // Get real-time pricing for a service
  Future<Map<String, dynamic>> getServicePricing({
    required String serviceName,
    required Map<String, dynamic> serviceDetails,
    required String location,
  }) async {
    try {
      final response = await _dio.post(
        '/pricing/calculate',
        data: {
          'serviceName': serviceName,
          'serviceDetails': serviceDetails,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get pricing: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Pricing API Error: $e');
      // Fallback to local pricing calculation
      return _getFallbackPricing(serviceName, serviceDetails);
    }
  }

  // Get provider availability and pricing
  Future<List<Map<String, dynamic>>> getProviderQuotes({
    required String serviceName,
    required Map<String, dynamic> serviceDetails,
    required String location,
  }) async {
    try {
      final response = await _dio.post(
        '/providers/quotes',
        data: {
          'serviceName': serviceName,
          'serviceDetails': serviceDetails,
          'location': location,
          'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['quotes'] ?? []);
      } else {
        throw Exception('Failed to get provider quotes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Provider Quotes API Error: $e');
      // Fallback to mock provider data
      return _getMockProviderQuotes(serviceName);
    }
  }

  // Submit service request to providers
  Future<String> submitServiceRequest({
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final response = await _dio.post(
        '/requests/submit',
        data: requestData,
      );

      if (response.statusCode == 201) {
        return response.data['requestId'] as String;
      } else {
        throw Exception('Failed to submit request: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Submit Request API Error: $e');
      // Generate mock request ID
      return 'REQ${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Get market rates for different services in Ghana
  Future<Map<String, dynamic>> getMarketRates() async {
    try {
      final response = await _dio.get('/pricing/market-rates');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get market rates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Market Rates API Error: $e');
      return _getGhanaMarketRates();
    }
  }

  // Fallback pricing when API is unavailable
  Map<String, dynamic> _getFallbackPricing(String serviceName, Map<String, dynamic> details) {
    final baseRates = {
      'Plumbing': {'min': 80, 'max': 300, 'average': 150},
      'Electrical Services': {'min': 100, 'max': 500, 'average': 200},
      'House Cleaning': {'min': 40, 'max': 200, 'average': 80},
      'Masonry': {'min': 200, 'max': 1000, 'average': 400},
      'Carpentry': {'min': 150, 'max': 800, 'average': 300},
      'Roofing': {'min': 300, 'max': 2000, 'average': 800},
      'Laundry Service': {'min': 20, 'max': 100, 'average': 40},
      'Beauty Services': {'min': 50, 'max': 300, 'average': 120},
    };

    final rates = baseRates[serviceName] ?? {'min': 50, 'max': 200, 'average': 100};
    
    // Apply urgency multiplier
    double multiplier = 1.0;
    if (details['urgency']?.toString().contains('Emergency') == true) {
      multiplier = 2.0;
    } else if (details['urgency']?.toString().contains('Urgent') == true) {
      multiplier = 1.5;
    }

    return {
      'success': true,
      'pricing': {
        'minPrice': (rates['min']! * multiplier).round(),
        'maxPrice': (rates['max']! * multiplier).round(),
        'averagePrice': (rates['average']! * multiplier).round(),
        'currency': 'GHS',
        'priceRange': '₵${(rates['min']! * multiplier).round()} - ₵${(rates['max']! * multiplier).round()}',
      },
      'factors': {
        'baseRate': rates['average'],
        'urgencyMultiplier': multiplier,
        'location': 'Greater Accra',
        'marketConditions': 'stable',
      },
      'note': 'Estimated pricing based on current market rates. Final quote may vary.',
    };
  }

  // Mock provider quotes for fallback
  List<Map<String, dynamic>> _getMockProviderQuotes(String serviceName) {
    return [
      {
        'providerId': 'provider_1',
        'name': 'Kwame Asante',
        'rating': 4.8,
        'reviews': 156,
        'price': 120,
        'currency': 'GHS',
        'estimatedDuration': '2-3 hours',
        'availability': 'Available today',
        'verified': true,
        'specialties': [serviceName],
      },
      {
        'providerId': 'provider_2', 
        'name': 'Akosua Mensah',
        'rating': 4.9,
        'reviews': 234,
        'price': 150,
        'currency': 'GHS',
        'estimatedDuration': '2-4 hours',
        'availability': 'Available tomorrow',
        'verified': true,
        'specialties': [serviceName],
      },
      {
        'providerId': 'provider_3',
        'name': 'Samuel Osei',
        'rating': 4.7,
        'reviews': 89,
        'price': 180,
        'currency': 'GHS',
        'estimatedDuration': '3-5 hours',
        'availability': 'Available this week',
        'verified': true,
        'specialties': [serviceName],
      },
    ];
  }

  // Ghana-specific market rates
  Map<String, dynamic> _getGhanaMarketRates() {
    return {
      'lastUpdated': DateTime.now().toIso8601String(),
      'region': 'Ghana',
      'currency': 'GHS',
      'rates': {
        'Plumbing': {
          'emergency_callout': 50,
          'hourly_rate': 30,
          'pipe_repair': 80,
          'toilet_fix': 60,
          'water_heater': 150,
        },
        'Electrical': {
          'emergency_callout': 70,
          'hourly_rate': 35,
          'outlet_installation': 40,
          'wiring_per_point': 25,
          'fuse_box_work': 200,
        },
        'House Cleaning': {
          'per_room': 15,
          'deep_cleaning_multiplier': 1.8,
          'compound_cleaning': 30,
          'boys_quarters': 20,
        },
        'Masonry': {
          'per_sqm_blocks': 25,
          'compound_wall_per_meter': 80,
          'foundation_per_sqm': 60,
          'finishing_per_sqm': 15,
        },
      },
      'factors': {
        'fuel_cost_impact': 0.15,
        'rainy_season_multiplier': 1.2,
        'distance_charge_per_km': 2,
        'weekend_multiplier': 1.1,
      },
    };
  }
}