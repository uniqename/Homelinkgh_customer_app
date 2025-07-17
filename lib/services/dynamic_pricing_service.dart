import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Dynamic Pricing Service for HomeLinkGH
/// Handles transportation costs, parts pricing, and dynamic adjustments
class DynamicPricingService {
  static const double _baseTransportationRate = 2.5; // GHS per km
  static const double _fuelSurcharge = 0.15; // 15% fuel surcharge
  static const double _timeBasedMultiplier = 1.2; // Peak hours multiplier
  static const double _urgencyMultiplier = 1.5; // Rush service multiplier
  
  /// Calculate transportation cost based on distance and service type
  static Future<Map<String, dynamic>> calculateTransportationCost({
    required double customerLat,
    required double customerLng,
    required double providerLat,
    required double providerLng,
    required String serviceType,
    bool isUrgent = false,
    bool isPeakHours = false,
    String? vehicleType,
  }) async {
    try {
      // Calculate distance using Geolocator
      double distanceInKm = Geolocator.distanceBetween(
        providerLat, providerLng, customerLat, customerLng,
      ) / 1000; // Convert to kilometers
      
      // Base transportation cost
      double baseCost = distanceInKm * _baseTransportationRate;
      
      // Vehicle type adjustments
      double vehicleMultiplier = _getVehicleMultiplier(vehicleType);
      baseCost *= vehicleMultiplier;
      
      // Add fuel surcharge
      double fuelCost = baseCost * _fuelSurcharge;
      
      // Service type adjustments
      double serviceMultiplier = _getServiceTypeMultiplier(serviceType);
      baseCost *= serviceMultiplier;
      
      // Time-based adjustments
      if (isPeakHours) {
        baseCost *= _timeBasedMultiplier;
      }
      
      // Urgency adjustments
      if (isUrgent) {
        baseCost *= _urgencyMultiplier;
      }
      
      double totalTransportCost = baseCost + fuelCost;
      
      return {
        'distance_km': distanceInKm.roundToDouble(),
        'base_transport_cost': baseCost.roundToDouble(),
        'fuel_surcharge': fuelCost.roundToDouble(),
        'total_transport_cost': totalTransportCost.roundToDouble(),
        'vehicle_type': vehicleType ?? 'standard',
        'service_multiplier': serviceMultiplier,
        'is_peak_hours': isPeakHours,
        'is_urgent': isUrgent,
        'breakdown': {
          'base_rate_per_km': _baseTransportationRate,
          'distance': '${distanceInKm.toStringAsFixed(1)} km',
          'vehicle_adjustment': '${((vehicleMultiplier - 1) * 100).toStringAsFixed(0)}%',
          'service_adjustment': '${((serviceMultiplier - 1) * 100).toStringAsFixed(0)}%',
          'peak_hours_surcharge': isPeakHours ? '${((_timeBasedMultiplier - 1) * 100).toStringAsFixed(0)}%' : '0%',
          'urgency_surcharge': isUrgent ? '${((_urgencyMultiplier - 1) * 100).toStringAsFixed(0)}%' : '0%',
          'fuel_surcharge': '${(_fuelSurcharge * 100).toStringAsFixed(0)}%',
        }
      };
    } catch (e) {
      return {
        'error': 'Failed to calculate transportation cost: $e',
        'total_transport_cost': 15.0, // Fallback cost
      };
    }
  }
  
  /// Calculate parts and materials cost
  static Map<String, dynamic> calculatePartsAndMaterialsCost({
    required String serviceType,
    required List<Map<String, dynamic>> requiredParts,
    Map<String, double>? adminPriceOverrides,
    double qualityMultiplier = 1.0,
  }) {
    double totalPartsCost = 0.0;
    List<Map<String, dynamic>> partsBreakdown = [];
    
    for (var part in requiredParts) {
      String partName = part['name'] ?? '';
      int quantity = part['quantity'] ?? 1;
      double basePrice = part['base_price']?.toDouble() ?? 0.0;
      String partType = part['type'] ?? 'standard';
      
      // Apply admin price overrides if available
      if (adminPriceOverrides != null && adminPriceOverrides.containsKey(partName)) {
        basePrice = adminPriceOverrides[partName]!;
      }
      
      // Apply quality multipliers
      double adjustedPrice = basePrice * qualityMultiplier;
      
      // Apply part type multipliers
      double typeMultiplier = _getPartTypeMultiplier(partType);
      adjustedPrice *= typeMultiplier;
      
      double partTotalCost = adjustedPrice * quantity;
      totalPartsCost += partTotalCost;
      
      partsBreakdown.add({
        'name': partName,
        'quantity': quantity,
        'base_price': basePrice,
        'adjusted_price': adjustedPrice.roundToDouble(),
        'total_cost': partTotalCost.roundToDouble(),
        'type': partType,
        'type_multiplier': typeMultiplier,
      });
    }
    
    // Service-specific markup
    double serviceMarkup = _getServicePartsMarkup(serviceType);
    double markupAmount = totalPartsCost * serviceMarkup;
    double finalPartsCost = totalPartsCost + markupAmount;
    
    return {
      'total_parts_cost': finalPartsCost.roundToDouble(),
      'base_parts_cost': totalPartsCost.roundToDouble(),
      'service_markup': markupAmount.roundToDouble(),
      'service_markup_percentage': '${(serviceMarkup * 100).toStringAsFixed(0)}%',
      'quality_multiplier': qualityMultiplier,
      'parts_breakdown': partsBreakdown,
    };
  }
  
  /// Calculate complete dynamic pricing for a service
  static Future<Map<String, dynamic>> calculateCompletePricing({
    required String serviceType,
    required double baseLaborCost,
    required double customerLat,
    required double customerLng,
    required double providerLat,
    required double providerLng,
    List<Map<String, dynamic>> requiredParts = const [],
    Map<String, double>? adminPriceOverrides,
    Map<String, double>? adminLaborRateOverrides,
    bool isUrgent = false,
    bool isPeakHours = false,
    String? vehicleType,
    double qualityLevel = 1.0,
    String complexity = 'standard',
  }) async {
    // Calculate transportation cost
    Map<String, dynamic> transportCost = await calculateTransportationCost(
      customerLat: customerLat,
      customerLng: customerLng,
      providerLat: providerLat,
      providerLng: providerLng,
      serviceType: serviceType,
      isUrgent: isUrgent,
      isPeakHours: isPeakHours,
      vehicleType: vehicleType,
    );
    
    // Calculate parts cost
    Map<String, dynamic> partsCost = calculatePartsAndMaterialsCost(
      serviceType: serviceType,
      requiredParts: requiredParts,
      adminPriceOverrides: adminPriceOverrides,
      qualityMultiplier: qualityLevel,
    );
    
    // Calculate labor cost with admin overrides
    double adjustedLaborCost = baseLaborCost;
    if (adminLaborRateOverrides != null && adminLaborRateOverrides.containsKey(serviceType)) {
      adjustedLaborCost = adminLaborRateOverrides[serviceType]!;
    }
    
    // Apply complexity multiplier
    double complexityMultiplier = _getComplexityMultiplier(complexity);
    adjustedLaborCost *= complexityMultiplier;
    
    // Apply time-based multipliers to labor
    if (isPeakHours) {
      adjustedLaborCost *= _timeBasedMultiplier;
    }
    
    if (isUrgent) {
      adjustedLaborCost *= _urgencyMultiplier;
    }
    
    // Calculate totals
    double totalTransport = transportCost['total_transport_cost']?.toDouble() ?? 0.0;
    double totalParts = partsCost['total_parts_cost']?.toDouble() ?? 0.0;
    double totalLabor = adjustedLaborCost;
    
    double subtotal = totalTransport + totalParts + totalLabor;
    
    // Apply service-specific adjustments
    double serviceAdjustment = _getServiceAdjustment(serviceType);
    double adjustmentAmount = subtotal * serviceAdjustment;
    
    double finalTotal = subtotal + adjustmentAmount;
    
    // Calculate profit margin
    double profitMargin = _calculateProfitMargin(serviceType, finalTotal);
    double finalTotalWithProfit = finalTotal + profitMargin;
    
    return {
      'service_type': serviceType,
      'pricing_breakdown': {
        'labor_cost': totalLabor.roundToDouble(),
        'parts_cost': totalParts.roundToDouble(),
        'transportation_cost': totalTransport.roundToDouble(),
        'service_adjustment': adjustmentAmount.roundToDouble(),
        'profit_margin': profitMargin.roundToDouble(),
      },
      'subtotal': subtotal.roundToDouble(),
      'final_total': finalTotalWithProfit.roundToDouble(),
      'currency': 'GHS',
      'transportation_details': transportCost,
      'parts_details': partsCost,
      'labor_details': {
        'base_labor_cost': baseLaborCost,
        'complexity_multiplier': complexityMultiplier,
        'complexity_level': complexity,
        'peak_hours_applied': isPeakHours,
        'urgency_applied': isUrgent,
        'final_labor_cost': totalLabor.roundToDouble(),
      },
      'admin_overrides_applied': {
        'labor_rate_override': adminLaborRateOverrides?.containsKey(serviceType) ?? false,
        'parts_price_overrides': adminPriceOverrides?.isNotEmpty ?? false,
      },
      'dynamic_factors': {
        'is_peak_hours': isPeakHours,
        'is_urgent': isUrgent,
        'quality_level': qualityLevel,
        'complexity': complexity,
        'vehicle_type': vehicleType ?? 'standard',
      }
    };
  }
  
  /// Get vehicle type multiplier
  static double _getVehicleMultiplier(String? vehicleType) {
    switch (vehicleType?.toLowerCase()) {
      case 'motorcycle':
        return 0.7;
      case 'car':
        return 1.0;
      case 'van':
        return 1.3;
      case 'truck':
        return 1.8;
      case 'pickup':
        return 1.4;
      default:
        return 1.0;
    }
  }
  
  /// Get service type transportation multiplier
  static double _getServiceTypeMultiplier(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plumbing':
      case 'electrical':
        return 1.2; // Requires tools
      case 'moving':
      case 'furniture_delivery':
        return 1.5; // Heavy items
      case 'cleaning':
        return 0.9; // Lighter equipment
      case 'beauty_services':
      case 'tutoring':
        return 0.8; // Minimal equipment
      case 'appliance_repair':
        return 1.3; // Heavy tools
      default:
        return 1.0;
    }
  }
  
  /// Get part type multiplier
  static double _getPartTypeMultiplier(String partType) {
    switch (partType.toLowerCase()) {
      case 'premium':
        return 1.5;
      case 'standard':
        return 1.0;
      case 'economy':
        return 0.8;
      case 'imported':
        return 1.8;
      case 'local':
        return 0.9;
      default:
        return 1.0;
    }
  }
  
  /// Get service parts markup
  static double _getServicePartsMarkup(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plumbing':
      case 'electrical':
        return 0.25; // 25% markup
      case 'appliance_repair':
        return 0.30; // 30% markup
      case 'cleaning':
        return 0.15; // 15% markup
      case 'beauty_services':
        return 0.20; // 20% markup
      default:
        return 0.20; // 20% default markup
    }
  }
  
  /// Get complexity multiplier
  static double _getComplexityMultiplier(String complexity) {
    switch (complexity.toLowerCase()) {
      case 'simple':
        return 0.8;
      case 'standard':
        return 1.0;
      case 'complex':
        return 1.4;
      case 'expert':
        return 1.8;
      default:
        return 1.0;
    }
  }
  
  /// Get service-specific adjustment
  static double _getServiceAdjustment(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'emergency_plumbing':
      case 'emergency_electrical':
        return 0.5; // 50% emergency surcharge
      case 'weekend_service':
        return 0.3; // 30% weekend surcharge
      case 'night_service':
        return 0.4; // 40% night surcharge
      default:
        return 0.0;
    }
  }
  
  /// Calculate profit margin
  static double _calculateProfitMargin(String serviceType, double totalCost) {
    double marginPercentage;
    
    switch (serviceType.toLowerCase()) {
      case 'plumbing':
      case 'electrical':
        marginPercentage = 0.20; // 20%
        break;
      case 'cleaning':
        marginPercentage = 0.15; // 15%
        break;
      case 'beauty_services':
        marginPercentage = 0.25; // 25%
        break;
      case 'tutoring':
        marginPercentage = 0.18; // 18%
        break;
      default:
        marginPercentage = 0.20; // 20% default
    }
    
    return totalCost * marginPercentage;
  }
  
  /// Get current time-based factors
  static Map<String, dynamic> getCurrentTimeFactors() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    int weekday = now.weekday;
    
    // Peak hours: 7-9 AM, 5-7 PM on weekdays
    bool isPeakHours = (weekday <= 5) && 
                      ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19));
    
    // Weekend surcharge
    bool isWeekend = weekday >= 6;
    
    // Night hours: 10 PM - 6 AM
    bool isNightHours = hour >= 22 || hour <= 6;
    
    return {
      'is_peak_hours': isPeakHours,
      'is_weekend': isWeekend,
      'is_night_hours': isNightHours,
      'current_hour': hour,
      'weekday': weekday,
    };
  }
  
  /// Get estimated travel time
  static double estimateTravelTime(double distanceKm, String? vehicleType) {
    double averageSpeed; // km/h
    
    switch (vehicleType?.toLowerCase()) {
      case 'motorcycle':
        averageSpeed = 35.0; // Faster in traffic
        break;
      case 'car':
        averageSpeed = 25.0; // City traffic
        break;
      case 'van':
      case 'truck':
        averageSpeed = 20.0; // Slower due to size
        break;
      default:
        averageSpeed = 25.0;
    }
    
    return (distanceKm / averageSpeed) * 60; // Return minutes
  }
}