import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Location {
  final double latitude;
  final double longitude;
  final String? address;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class FoodDeliveryPricingService {
  static final FoodDeliveryPricingService _instance = FoodDeliveryPricingService._internal();
  factory FoodDeliveryPricingService() => _instance;
  FoodDeliveryPricingService._internal();

  // Provider delivery pricing
  final Map<String, DeliveryProviderPricing> _providerPricing = {
    'provider_1': DeliveryProviderPricing(
      providerId: 'provider_1',
      providerName: 'QuickDelivery Accra',
      baseRate: 8.0,
      perKmRate: 2.5,
      minimumDeliveryFee: 12.0,
      maximumDeliveryDistance: 15.0,
      isAvailable: true,
      averageRating: 4.7,
      totalDeliveries: 1250,
    ),
    'provider_2': DeliveryProviderPricing(
      providerId: 'provider_2',
      providerName: 'FastRiders Ghana',
      baseRate: 10.0,
      perKmRate: 2.2,
      minimumDeliveryFee: 15.0,
      maximumDeliveryDistance: 20.0,
      isAvailable: true,
      averageRating: 4.5,
      totalDeliveries: 980,
    ),
    'provider_3': DeliveryProviderPricing(
      providerId: 'provider_3',
      providerName: 'EcoDelivery Services',
      baseRate: 7.5,
      perKmRate: 2.8,
      minimumDeliveryFee: 10.0,
      maximumDeliveryDistance: 12.0,
      isAvailable: true,
      averageRating: 4.8,
      totalDeliveries: 750,
    ),
  };

  // Platform service fees (HomeLinkGH commission)
  final double platformServiceFeePercentage = 0.15; // 15%
  final double minimumServiceFee = 2.0; // Minimum GH₵2
  final double maximumServiceFee = 25.0; // Maximum GH₵25

  Future<List<DeliveryQuote>> getDeliveryQuotes({
    required String restaurantId,
    required Location restaurantLocation,
    required Location customerLocation,
    required double orderValue,
    String? urgencyLevel, // 'normal', 'urgent', 'express'
    DateTime? preferredDeliveryTime,
  }) async {
    final distance = _calculateDistance(restaurantLocation, customerLocation);
    final quotes = <DeliveryQuote>[];

    for (final provider in _providerPricing.values) {
      if (!provider.isAvailable || distance > provider.maximumDeliveryDistance) {
        continue;
      }

      final baseDeliveryFee = _calculateBaseDeliveryFee(provider, distance);
      final urgencyMultiplier = _getUrgencyMultiplier(urgencyLevel ?? 'normal');
      final timeMultiplier = _getTimeMultiplier(preferredDeliveryTime);
      final demandMultiplier = _getDemandMultiplier(restaurantLocation);
      
      final deliveryFee = baseDeliveryFee * urgencyMultiplier * timeMultiplier * demandMultiplier;
      final platformFee = _calculatePlatformFee(orderValue);
      final totalFee = deliveryFee + platformFee;
      
      final estimatedTime = _calculateEstimatedDeliveryTime(
        provider, 
        distance, 
        urgencyLevel ?? 'normal'
      );

      quotes.add(DeliveryQuote(
        providerId: provider.providerId,
        providerName: provider.providerName,
        deliveryFee: deliveryFee,
        platformServiceFee: platformFee,
        totalCost: totalFee,
        estimatedDeliveryTime: estimatedTime,
        distance: distance,
        providerRating: provider.averageRating,
        totalDeliveries: provider.totalDeliveries,
        urgencyLevel: urgencyLevel ?? 'normal',
        breakdown: {
          'base_rate': provider.baseRate,
          'distance_cost': (distance * provider.perKmRate),
          'urgency_multiplier': urgencyMultiplier,
          'time_multiplier': timeMultiplier,
          'demand_multiplier': demandMultiplier,
        },
      ));
    }

    // Sort by total cost (cheapest first)
    quotes.sort((a, b) => a.totalCost.compareTo(b.totalCost));
    return quotes;
  }

  Future<DeliveryQuote?> getProviderQuote({
    required String providerId,
    required Location restaurantLocation,
    required Location customerLocation,
    required double orderValue,
    String urgencyLevel = 'normal',
    DateTime? preferredDeliveryTime,
  }) async {
    final provider = _providerPricing[providerId];
    if (provider == null || !provider.isAvailable) {
      return null;
    }

    final distance = _calculateDistance(restaurantLocation, customerLocation);
    if (distance > provider.maximumDeliveryDistance) {
      return null;
    }

    final baseDeliveryFee = _calculateBaseDeliveryFee(provider, distance);
    final urgencyMultiplier = _getUrgencyMultiplier(urgencyLevel);
    final timeMultiplier = _getTimeMultiplier(preferredDeliveryTime);
    final demandMultiplier = _getDemandMultiplier(restaurantLocation);
    
    final deliveryFee = baseDeliveryFee * urgencyMultiplier * timeMultiplier * demandMultiplier;
    final platformFee = _calculatePlatformFee(orderValue);
    final totalFee = deliveryFee + platformFee;
    
    final estimatedTime = _calculateEstimatedDeliveryTime(provider, distance, urgencyLevel);

    return DeliveryQuote(
      providerId: provider.providerId,
      providerName: provider.providerName,
      deliveryFee: deliveryFee,
      platformServiceFee: platformFee,
      totalCost: totalFee,
      estimatedDeliveryTime: estimatedTime,
      distance: distance,
      providerRating: provider.averageRating,
      totalDeliveries: provider.totalDeliveries,
      urgencyLevel: urgencyLevel,
      breakdown: {
        'base_rate': provider.baseRate,
        'distance_cost': (distance * provider.perKmRate),
        'urgency_multiplier': urgencyMultiplier,
        'time_multiplier': timeMultiplier,
        'demand_multiplier': demandMultiplier,
      },
    );
  }

  double _calculateBaseDeliveryFee(DeliveryProviderPricing provider, double distance) {
    final calculatedFee = provider.baseRate + (distance * provider.perKmRate);
    return math.max(calculatedFee, provider.minimumDeliveryFee);
  }

  double _getUrgencyMultiplier(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'express':
        return 1.8; // 80% premium for express delivery
      case 'urgent':
        return 1.4; // 40% premium for urgent delivery
      case 'normal':
      default:
        return 1.0; // No premium for normal delivery
    }
  }

  double _getTimeMultiplier(DateTime? preferredTime) {
    if (preferredTime == null) return 1.0;

    final hour = preferredTime.hour;
    // Peak hours multiplier
    if ((hour >= 12 && hour <= 14) || (hour >= 18 && hour <= 21)) {
      return 1.3; // 30% premium during lunch and dinner rush
    } else if (hour >= 22 || hour <= 6) {
      return 1.5; // 50% premium for late night/early morning
    }
    return 1.0;
  }

  double _getDemandMultiplier(Location location) {
    // Simulate demand-based pricing based on location
    // In a real implementation, this would be based on current demand data
    final random = math.Random(location.latitude.hashCode + location.longitude.hashCode);
    final demandLevel = random.nextDouble();
    
    if (demandLevel > 0.8) {
      return 1.4; // High demand - 40% premium
    } else if (demandLevel > 0.6) {
      return 1.2; // Medium demand - 20% premium
    }
    return 1.0; // Normal demand
  }

  double _calculatePlatformFee(double orderValue) {
    final calculatedFee = orderValue * platformServiceFeePercentage;
    return math.max(math.min(calculatedFee, maximumServiceFee), minimumServiceFee);
  }

  int _calculateEstimatedDeliveryTime(
    DeliveryProviderPricing provider, 
    double distance, 
    String urgencyLevel
  ) {
    // Base time calculation: 5 minutes per km + 10 minutes restaurant prep
    int baseTime = (distance * 5).round() + 10;
    
    // Adjust based on urgency
    switch (urgencyLevel) {
      case 'express':
        return (baseTime * 0.7).round(); // 30% faster
      case 'urgent':
        return (baseTime * 0.8).round(); // 20% faster
      default:
        return baseTime;
    }
  }

  double _calculateDistance(Location from, Location to) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = from.latitude * (math.pi / 180);
    final double lat2Rad = to.latitude * (math.pi / 180);
    final double deltaLatRad = (to.latitude - from.latitude) * (math.pi / 180);
    final double deltaLngRad = (to.longitude - from.longitude) * (math.pi / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  List<DeliveryProviderPricing> getAvailableProviders() {
    return _providerPricing.values.where((p) => p.isAvailable).toList();
  }

  Future<void> updateProviderAvailability(String providerId, bool isAvailable) async {
    if (_providerPricing.containsKey(providerId)) {
      _providerPricing[providerId] = _providerPricing[providerId]!.copyWith(
        isAvailable: isAvailable,
      );
    }
  }
}

class DeliveryProviderPricing {
  final String providerId;
  final String providerName;
  final double baseRate; // Base delivery rate in GH₵
  final double perKmRate; // Rate per kilometer in GH₵
  final double minimumDeliveryFee; // Minimum delivery fee in GH₵
  final double maximumDeliveryDistance; // Maximum delivery distance in km
  final bool isAvailable;
  final double averageRating;
  final int totalDeliveries;

  const DeliveryProviderPricing({
    required this.providerId,
    required this.providerName,
    required this.baseRate,
    required this.perKmRate,
    required this.minimumDeliveryFee,
    required this.maximumDeliveryDistance,
    required this.isAvailable,
    required this.averageRating,
    required this.totalDeliveries,
  });

  DeliveryProviderPricing copyWith({
    String? providerId,
    String? providerName,
    double? baseRate,
    double? perKmRate,
    double? minimumDeliveryFee,
    double? maximumDeliveryDistance,
    bool? isAvailable,
    double? averageRating,
    int? totalDeliveries,
  }) {
    return DeliveryProviderPricing(
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      baseRate: baseRate ?? this.baseRate,
      perKmRate: perKmRate ?? this.perKmRate,
      minimumDeliveryFee: minimumDeliveryFee ?? this.minimumDeliveryFee,
      maximumDeliveryDistance: maximumDeliveryDistance ?? this.maximumDeliveryDistance,
      isAvailable: isAvailable ?? this.isAvailable,
      averageRating: averageRating ?? this.averageRating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
    );
  }
}

class DeliveryQuote {
  final String providerId;
  final String providerName;
  final double deliveryFee;
  final double platformServiceFee;
  final double totalCost;
  final int estimatedDeliveryTime; // in minutes
  final double distance; // in kilometers
  final double providerRating;
  final int totalDeliveries;
  final String urgencyLevel;
  final Map<String, double> breakdown;

  const DeliveryQuote({
    required this.providerId,
    required this.providerName,
    required this.deliveryFee,
    required this.platformServiceFee,
    required this.totalCost,
    required this.estimatedDeliveryTime,
    required this.distance,
    required this.providerRating,
    required this.totalDeliveries,
    required this.urgencyLevel,
    required this.breakdown,
  });

  String get estimatedTimeText {
    if (estimatedDeliveryTime < 60) {
      return '$estimatedDeliveryTime mins';
    } else {
      final hours = (estimatedDeliveryTime / 60).floor();
      final minutes = estimatedDeliveryTime % 60;
      return '${hours}h ${minutes}m';
    }
  }
}