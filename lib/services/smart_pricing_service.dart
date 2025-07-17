import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_personalization_service.dart';
import 'gamification_service.dart';

class SmartPricingService {
  static final SmartPricingService _instance = SmartPricingService._internal();
  factory SmartPricingService() => _instance;
  SmartPricingService._internal();

  final SmartPersonalizationService _personalization = SmartPersonalizationService();
  final GamificationService _gamification = GamificationService();
  
  // Pricing data
  Map<String, Map<String, double>> _dynamicPricing = {};
  Map<String, List<Map<String, dynamic>>> _activeDeals = {};
  Map<String, double> _userLoyaltyDiscounts = {};
  Map<String, Map<String, dynamic>> _seasonalPricing = {};
  Map<String, double> _demandMultipliers = {};
  List<Map<String, dynamic>> _smartDeals = [];
  
  // Base pricing for Ghana services (in GH₵)
  final Map<String, Map<String, dynamic>> _basePricing = {
    'Food Delivery': {
      'base': 25.0,
      'per_km': 2.0,
      'premium_multiplier': 1.5,
      'peak_hours': [12, 13, 18, 19, 20],
      'peak_multiplier': 1.3,
    },
    'House Cleaning': {
      'base': 80.0,
      'per_hour': 25.0,
      'premium_multiplier': 2.0,
      'peak_hours': [9, 10, 11, 14, 15],
      'peak_multiplier': 1.2,
    },
    'Beauty Services': {
      'base': 120.0,
      'per_service': 50.0,
      'premium_multiplier': 2.5,
      'peak_hours': [10, 11, 14, 15, 16],
      'peak_multiplier': 1.4,
    },
    'Transportation': {
      'base': 15.0,
      'per_km': 1.5,
      'premium_multiplier': 1.8,
      'peak_hours': [7, 8, 17, 18, 19],
      'peak_multiplier': 1.5,
    },
    'Grocery': {
      'base': 20.0,
      'per_item': 2.0,
      'premium_multiplier': 1.3,
      'peak_hours': [10, 11, 16, 17],
      'peak_multiplier': 1.2,
    },
    'Laundry': {
      'base': 35.0,
      'per_kg': 8.0,
      'premium_multiplier': 1.6,
      'peak_hours': [9, 10, 11],
      'peak_multiplier': 1.1,
    },
    'Plumbing': {
      'base': 150.0,
      'per_hour': 80.0,
      'premium_multiplier': 1.8,
      'peak_hours': [9, 10, 11, 14, 15],
      'peak_multiplier': 1.3,
    },
    'Electrical': {
      'base': 180.0,
      'per_hour': 100.0,
      'premium_multiplier': 1.9,
      'peak_hours': [9, 10, 11, 14, 15],
      'peak_multiplier': 1.3,
    },
  };

  Future<void> initializePricing() async {
    await _loadPricingData();
    await _generateSmartDeals();
    await _updateDynamicPricing();
  }

  Future<Map<String, dynamic>> calculateSmartPrice({
    required String serviceType,
    required DateTime requestedTime,
    required Map<String, dynamic> serviceDetails,
    String? userLocation,
  }) async {
    final basePricing = _basePricing[serviceType];
    if (basePricing == null) {
      return _getDefaultPricing(serviceType);
    }

    double finalPrice = basePricing['base'] as double;
    final List<String> priceBreakdown = [];
    final List<Map<String, dynamic>> appliedDiscounts = [];
    final List<Map<String, dynamic>> suggestions = [];

    // Base service calculations
    if (serviceDetails.containsKey('distance')) {
      final distance = serviceDetails['distance'] as double;
      final perKm = basePricing['per_km'] as double? ?? 0.0;
      final distanceCost = distance * perKm;
      finalPrice += distanceCost;
      priceBreakdown.add('Distance (${distance.toStringAsFixed(1)}km): +GH₵${distanceCost.toStringAsFixed(2)}');
    }

    if (serviceDetails.containsKey('duration_hours')) {
      final hours = serviceDetails['duration_hours'] as double;
      final perHour = basePricing['per_hour'] as double? ?? 0.0;
      final timeCost = hours * perHour;
      finalPrice += timeCost;
      priceBreakdown.add('Duration (${hours.toStringAsFixed(1)}h): +GH₵${timeCost.toStringAsFixed(2)}');
    }

    // Premium service multiplier
    final isPremium = serviceDetails['is_premium'] as bool? ?? false;
    if (isPremium) {
      final multiplier = basePricing['premium_multiplier'] as double;
      final premiumCost = finalPrice * (multiplier - 1);
      finalPrice *= multiplier;
      priceBreakdown.add('Premium service: +GH₵${premiumCost.toStringAsFixed(2)}');
    }

    // Peak time pricing
    final peakHours = basePricing['peak_hours'] as List<int>;
    final isPeakTime = peakHours.contains(requestedTime.hour);
    if (isPeakTime) {
      final multiplier = basePricing['peak_multiplier'] as double;
      final peakCost = finalPrice * (multiplier - 1);
      finalPrice *= multiplier;
      priceBreakdown.add('Peak time (${requestedTime.hour}:00): +GH₵${peakCost.toStringAsFixed(2)}');
      
      // Suggest off-peak times
      suggestions.add({
        'type': 'time_optimization',
        'title': 'Save with Off-Peak Booking',
        'description': 'Book 2 hours earlier or later to save GH₵${peakCost.toStringAsFixed(2)}',
        'savings': peakCost,
      });
    }

    // Apply loyalty discounts
    final loyaltyDiscount = await _calculateLoyaltyDiscount(serviceType);
    if (loyaltyDiscount > 0) {
      final discountAmount = finalPrice * loyaltyDiscount;
      finalPrice -= discountAmount;
      appliedDiscounts.add({
        'type': 'loyalty',
        'title': 'Loyalty Discount',
        'description': '${(loyaltyDiscount * 100).round()}% off for being a valued customer',
        'amount': discountAmount,
      });
    }

    // Apply gamification discounts
    final gamificationDiscount = await _calculateGamificationDiscount();
    if (gamificationDiscount > 0) {
      final discountAmount = finalPrice * gamificationDiscount;
      finalPrice -= discountAmount;
      appliedDiscounts.add({
        'type': 'level',
        'title': 'Level Bonus',
        'description': 'Level ${_gamification.currentLevel} discount applied',
        'amount': discountAmount,
      });
    }

    // Apply seasonal adjustments
    final seasonalMultiplier = _getSeasonalMultiplier(serviceType, requestedTime);
    if (seasonalMultiplier != 1.0) {
      final adjustment = finalPrice * (seasonalMultiplier - 1);
      finalPrice *= seasonalMultiplier;
      if (adjustment > 0) {
        priceBreakdown.add('Seasonal adjustment: +GH₵${adjustment.toStringAsFixed(2)}');
      } else {
        appliedDiscounts.add({
          'type': 'seasonal',
          'title': 'Seasonal Discount',
          'description': 'Perfect timing for this service',
          'amount': -adjustment,
        });
      }
    }

    // Check for available deals
    final availableDeals = await _getAvailableDeals(serviceType, finalPrice);
    
    // Apply best deal automatically
    if (availableDeals.isNotEmpty) {
      final bestDeal = availableDeals.first;
      final dealSavings = _calculateDealSavings(bestDeal, finalPrice);
      if (dealSavings > 0) {
        finalPrice -= dealSavings;
        appliedDiscounts.add({
          'type': 'deal',
          'title': bestDeal['title'],
          'description': bestDeal['description'],
          'amount': dealSavings,
        });
      }
    }

    // Generate money-saving suggestions
    suggestions.addAll(await _generateSavingSuggestions(serviceType, finalPrice, requestedTime));

    return {
      'final_price': finalPrice.round(),
      'original_price': (basePricing['base'] as double).round(),
      'price_breakdown': priceBreakdown,
      'applied_discounts': appliedDiscounts,
      'available_deals': availableDeals,
      'savings_suggestions': suggestions,
      'confidence': _calculatePriceConfidence(serviceType),
      'currency': 'GH₵',
      'next_price_drop': _predictNextPriceDrop(serviceType),
    };
  }

  Future<double> _calculateLoyaltyDiscount(String serviceType) async {
    final userStats = _gamification.getUserStats();
    final totalBookings = userStats['totalBookings'] as int;
    
    // Loyalty discount tiers
    if (totalBookings >= 20) return 0.15; // 15% for 20+ bookings
    if (totalBookings >= 10) return 0.10; // 10% for 10+ bookings
    if (totalBookings >= 5) return 0.05;  // 5% for 5+ bookings
    
    return 0.0;
  }

  Future<double> _calculateGamificationDiscount() async {
    final userStats = _gamification.getUserStats();
    final level = userStats['level'] as int;
    
    // Level-based discounts
    if (level >= 7) return 0.25; // 25% for max level
    if (level >= 5) return 0.20; // 20% for premium level
    if (level >= 3) return 0.15; // 15% for regular level
    if (level >= 2) return 0.10; // 10% for explorer level
    
    return 0.0;
  }

  double _getSeasonalMultiplier(String serviceType, DateTime requestedTime) {
    final month = requestedTime.month;
    
    // Ghana seasonal patterns
    final Map<String, Map<int, double>> seasonalMultipliers = {
      'House Cleaning': {
        12: 1.3, 1: 1.3, // Holiday season - higher demand
        3: 1.2, 4: 1.2, // Spring cleaning
        8: 0.9, 9: 0.9, // Rainy season - lower demand
      },
      'Beauty Services': {
        12: 1.5, 1: 1.4, // Holiday/wedding season
        6: 1.3, 7: 1.3, // Summer events
        2: 0.9, 3: 0.9, // Post-holiday lull
      },
      'Landscaping': {
        11: 1.4, 12: 1.3, 1: 1.3, // Dry season - high demand
        5: 0.8, 6: 0.8, 7: 0.8, 8: 0.8, // Rainy season - low demand
      },
    };
    
    return seasonalMultipliers[serviceType]?[month] ?? 1.0;
  }

  Future<List<Map<String, dynamic>>> _getAvailableDeals(String serviceType, double currentPrice) async {
    final allDeals = _smartDeals.where((deal) {
      return deal['applicable_services'].contains(serviceType) ||
             deal['applicable_services'].contains('all');
    }).toList();
    
    // Filter deals based on user eligibility
    final eligibleDeals = <Map<String, dynamic>>[];
    
    for (final deal in allDeals) {
      if (await _isUserEligibleForDeal(deal)) {
        // Calculate potential savings
        final savings = _calculateDealSavings(deal, currentPrice);
        if (savings > 0) {
          final dealCopy = Map<String, dynamic>.from(deal);
          dealCopy['potential_savings'] = savings;
          eligibleDeals.add(dealCopy);
        }
      }
    }
    
    // Sort by savings amount
    eligibleDeals.sort((a, b) => b['potential_savings'].compareTo(a['potential_savings']));
    
    return eligibleDeals.take(3).toList();
  }

  double _calculateDealSavings(Map<String, dynamic> deal, double currentPrice) {
    switch (deal['type']) {
      case 'percentage':
        return currentPrice * (deal['discount_value'] as double);
      case 'fixed_amount':
        return min(deal['discount_value'] as double, currentPrice * 0.5); // Max 50% off
      case 'buy_one_get_discount':
        return currentPrice * (deal['discount_value'] as double);
      default:
        return 0.0;
    }
  }

  Future<bool> _isUserEligibleForDeal(Map<String, dynamic> deal) async {
    final userStats = _gamification.getUserStats();
    
    // Check minimum level requirement
    if (deal.containsKey('min_level')) {
      if (userStats['level'] < deal['min_level']) return false;
    }
    
    // Check minimum bookings requirement
    if (deal.containsKey('min_bookings')) {
      if (userStats['totalBookings'] < deal['min_bookings']) return false;
    }
    
    // Check if deal is time-limited
    if (deal.containsKey('expires_at')) {
      final expiresAt = DateTime.parse(deal['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) return false;
    }
    
    return true;
  }

  Future<List<Map<String, dynamic>>> _generateSavingSuggestions(
    String serviceType,
    double currentPrice,
    DateTime requestedTime,
  ) async {
    final suggestions = <Map<String, dynamic>>[];
    
    // Time-based savings
    final peakHours = _basePricing[serviceType]?['peak_hours'] as List<int>? ?? [];
    if (peakHours.contains(requestedTime.hour)) {
      final offPeakSavings = currentPrice * 0.2; // Estimate 20% savings
      suggestions.add({
        'type': 'reschedule',
        'title': 'Schedule for Later',
        'description': 'Book 2 hours later to save approximately GH₵${offPeakSavings.toStringAsFixed(2)}',
        'potential_savings': offPeakSavings,
        'effort': 'low',
      });
    }
    
    // Bundle suggestions
    suggestions.add({
      'type': 'bundle',
      'title': 'Bundle Services',
      'description': 'Add another service for 15% off both',
      'potential_savings': currentPrice * 0.15,
      'effort': 'medium',
    });
    
    // Subscription savings
    if (['House Cleaning', 'Laundry', 'Food Delivery'].contains(serviceType)) {
      suggestions.add({
        'type': 'subscription',
        'title': 'Weekly Subscription',
        'description': 'Save 25% with weekly ${serviceType.toLowerCase()}',
        'potential_savings': currentPrice * 0.25,
        'effort': 'low',
      });
    }
    
    // Loyalty program
    final nextLoyaltyLevel = _getNextLoyaltyLevel();
    if (nextLoyaltyLevel != null) {
      suggestions.add({
        'type': 'loyalty_progress',
        'title': 'Loyalty Bonus Coming',
        'description': '${nextLoyaltyLevel['bookings_needed']} more bookings for ${nextLoyaltyLevel['discount']}% discount',
        'potential_savings': currentPrice * (nextLoyaltyLevel['discount'] / 100),
        'effort': 'medium',
      });
    }
    
    return suggestions;
  }

  Map<String, dynamic>? _getNextLoyaltyLevel() {
    final userStats = _gamification.getUserStats();
    final totalBookings = userStats['totalBookings'] as int;
    
    if (totalBookings < 5) {
      return {'bookings_needed': 5 - totalBookings, 'discount': 5};
    } else if (totalBookings < 10) {
      return {'bookings_needed': 10 - totalBookings, 'discount': 10};
    } else if (totalBookings < 20) {
      return {'bookings_needed': 20 - totalBookings, 'discount': 15};
    }
    
    return null;
  }

  double _calculatePriceConfidence(String serviceType) {
    // Base confidence on data availability and market stability
    final hasHistoricalData = _dynamicPricing.containsKey(serviceType);
    final marketStability = 0.85; // Assume relatively stable market
    
    return hasHistoricalData ? marketStability : 0.7;
  }

  DateTime? _predictNextPriceDrop(String serviceType) {
    // Predict when prices might be lower
    final now = DateTime.now();
    
    // Generally, prices are lower during off-peak hours
    final basePricing = _basePricing[serviceType];
    if (basePricing != null) {
      final peakHours = basePricing['peak_hours'] as List<int>;
      
      // Find next non-peak hour
      for (int i = 1; i <= 24; i++) {
        final nextHour = (now.hour + i) % 24;
        if (!peakHours.contains(nextHour)) {
          return DateTime(now.year, now.month, now.day, nextHour)
              .add(Duration(days: nextHour < now.hour ? 1 : 0));
        }
      }
    }
    
    return null;
  }

  Future<void> _generateSmartDeals() async {
    _smartDeals = [
      {
        'id': 'new_user_discount',
        'title': '🎉 Welcome Bonus',
        'description': '20% off your first booking',
        'type': 'percentage',
        'discount_value': 0.20,
        'applicable_services': ['all'],
        'max_bookings': 1,
        'min_level': 1,
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'weekend_special',
        'title': '🌅 Weekend Special',
        'description': '15% off weekend services',
        'type': 'percentage',
        'discount_value': 0.15,
        'applicable_services': ['House Cleaning', 'Beauty Services', 'Landscaping'],
        'valid_days': [6, 7], // Saturday, Sunday
      },
      {
        'id': 'loyalty_reward',
        'title': '👑 Loyalty Reward',
        'description': '25% off for valued customers',
        'type': 'percentage',
        'discount_value': 0.25,
        'applicable_services': ['all'],
        'min_bookings': 10,
      },
      {
        'id': 'bundle_deal',
        'title': '📦 Bundle & Save',
        'description': 'GH₵50 off when you book 2+ services',
        'type': 'fixed_amount',
        'discount_value': 50.0,
        'applicable_services': ['all'],
        'min_services': 2,
      },
      {
        'id': 'early_bird',
        'title': '🌅 Early Bird',
        'description': '10% off bookings before 9 AM',
        'type': 'percentage',
        'discount_value': 0.10,
        'applicable_services': ['all'],
        'valid_hours': [6, 7, 8],
      },
      {
        'id': 'rainy_season',
        'title': '🌧️ Rainy Season Special',
        'description': '20% off indoor services during rainy season',
        'type': 'percentage',
        'discount_value': 0.20,
        'applicable_services': ['House Cleaning', 'Beauty Services', 'Food Delivery'],
        'valid_months': [5, 6, 7, 8, 9], // Rainy season in Ghana
      },
    ];
  }

  Future<void> _updateDynamicPricing() async {
    // Update pricing based on demand patterns
    for (final serviceType in _basePricing.keys) {
      _dynamicPricing[serviceType] = {
        'current_demand': _simulateDemand(serviceType),
        'price_multiplier': _calculateDemandMultiplier(serviceType),
        'last_updated': DateTime.now().millisecondsSinceEpoch.toDouble(),
      };
    }
    
    await _savePricingData();
  }

  double _simulateDemand(String serviceType) {
    // Simulate demand based on time of day and service type
    final hour = DateTime.now().hour;
    final basePricing = _basePricing[serviceType];
    
    if (basePricing != null) {
      final peakHours = basePricing['peak_hours'] as List<int>;
      if (peakHours.contains(hour)) {
        return 0.8 + Random().nextDouble() * 0.2; // High demand: 0.8-1.0
      }
    }
    
    return Random().nextDouble() * 0.6; // Low demand: 0.0-0.6
  }

  double _calculateDemandMultiplier(String serviceType) {
    final demand = _dynamicPricing[serviceType]?['current_demand'] ?? 0.5;
    
    // Convert demand to price multiplier
    return 0.9 + (demand * 0.3); // Range: 0.9x to 1.2x
  }

  Map<String, dynamic> _getDefaultPricing(String serviceType) {
    return {
      'final_price': 100,
      'original_price': 100,
      'price_breakdown': ['Standard pricing applied'],
      'applied_discounts': [],
      'available_deals': [],
      'savings_suggestions': [],
      'confidence': 0.5,
      'currency': 'GH₵',
      'next_price_drop': null,
    };
  }

  // Public methods for UI
  Future<List<Map<String, dynamic>>> getTrendingDeals() async {
    return _smartDeals.where((deal) => 
        !deal.containsKey('expires_at') || 
        DateTime.parse(deal['expires_at']).isAfter(DateTime.now())
    ).take(5).toList();
  }

  Future<Map<String, dynamic>> getPersonalizedDeal(String serviceType) async {
    final availableDeals = await _getAvailableDeals(serviceType, 200.0); // Sample price
    return availableDeals.isNotEmpty ? availableDeals.first : {};
  }

  Future<double> estimateBasicPrice(String serviceType) async {
    final basePricing = _basePricing[serviceType];
    return basePricing?['base'] as double? ?? 100.0;
  }

  // Data persistence
  Future<void> _savePricingData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'dynamicPricing': _dynamicPricing,
      'userLoyaltyDiscounts': _userLoyaltyDiscounts,
      'smartDeals': _smartDeals,
    };
    await prefs.setString('pricing_data', json.encode(data));
  }

  Future<void> _loadPricingData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('pricing_data');
    if (dataString != null) {
      final data = Map<String, dynamic>.from(json.decode(dataString));
      
      _dynamicPricing = (data['dynamicPricing'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, Map<String, double>.from(value))) ?? {};
      _userLoyaltyDiscounts = Map<String, double>.from(data['userLoyaltyDiscounts'] ?? {});
      _smartDeals = List<Map<String, dynamic>>.from(data['smartDeals'] ?? []);
    }
  }
}