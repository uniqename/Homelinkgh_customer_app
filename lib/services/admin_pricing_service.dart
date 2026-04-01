import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'supabase_service.dart';

/// Admin Pricing Control Service for HomeLinkGH
/// Allows administrators to manage and override pricing for services and parts
/// Now uses Supabase for persistent storage across devices
class AdminPricingService {
  static final SupabaseService _supabase = SupabaseService();

  // Cache keys for fallback to SharedPreferences (backward compatibility)
  static const String _laborRatesKey = 'admin_labor_rates';
  static const String _partsOverridesKey = 'admin_parts_overrides';
  static const String _serviceMultipliersKey = 'admin_service_multipliers';
  static const String _globalSettingsKey = 'admin_global_settings';
  static const String _discountCodesKey = 'admin_discount_codes';
  
  /// Save labor rate overrides for different services (now uses Supabase)
  static Future<bool> saveLaborRateOverrides(Map<String, double> laborRates) async {
    try {
      // Save each rate to Supabase
      for (var entry in laborRates.entries) {
        await _supabase.setLaborRate(entry.key, entry.value);
      }

      // Also cache locally for offline access
      final prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(laborRates);
      await prefs.setString(_laborRatesKey, jsonString);

      return true;
    } catch (e) {
      print('Error saving labor rate overrides: $e');
      return false;
    }
  }

  /// Get labor rate overrides (now from Supabase)
  static Future<Map<String, double>> getLaborRateOverrides() async {
    try {
      // Try to get from Supabase first
      final laborRatesList = await _supabase.getAllLaborRates();
      if (laborRatesList.isNotEmpty) {
        final laborRates = <String, double>{};
        for (var rate in laborRatesList) {
          final serviceType = rate['service_type'] as String;
          final rateValue = double.tryParse(rate['rate_per_hour'].toString()) ?? 0.0;
          laborRates[serviceType] = rateValue;
        }

        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_laborRatesKey, json.encode(laborRates));

        return laborRates;
      }

      // Fallback to local cache if Supabase fails
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_laborRatesKey);
      if (jsonString != null) {
        Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
    } catch (e) {
      print('Error loading labor rate overrides: $e');

      // Try local cache on error
      try {
        final prefs = await SharedPreferences.getInstance();
        String? jsonString = prefs.getString(_laborRatesKey);
        if (jsonString != null) {
          Map<String, dynamic> decoded = json.decode(jsonString);
          return decoded.map((key, value) => MapEntry(key, value.toDouble()));
        }
      } catch (_) {}
    }
    return getDefaultLaborRates();
  }
  
  /// Save parts price overrides (now uses Supabase)
  static Future<bool> savePartsOverrides(Map<String, double> partsOverrides) async {
    try {
      // Save each part to Supabase
      for (var entry in partsOverrides.entries) {
        // Parse format: "category:part_name"
        final parts = entry.key.split(':');
        if (parts.length == 2) {
          await _supabase.upsertPart(
            category: parts[0],
            partName: parts[1],
            price: entry.value,
          );
        }
      }

      // Also cache locally
      final prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(partsOverrides);
      await prefs.setString(_partsOverridesKey, jsonString);

      return true;
    } catch (e) {
      print('Error saving parts overrides: $e');
      return false;
    }
  }

  /// Get parts price overrides (now from Supabase)
  static Future<Map<String, double>> getPartsOverrides() async {
    try {
      // Try to get from Supabase first
      final partsList = await _supabase.getAllParts();
      if (partsList.isNotEmpty) {
        final partsMap = <String, double>{};
        for (var part in partsList) {
          final category = part['category'] as String;
          final partName = part['part_name'] as String;
          final price = double.tryParse(part['base_price'].toString()) ?? 0.0;
          partsMap['$category:$partName'] = price;
        }

        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_partsOverridesKey, json.encode(partsMap));

        return partsMap;
      }

      // Fallback to local cache
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_partsOverridesKey);
      if (jsonString != null) {
        Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
    } catch (e) {
      print('Error loading parts overrides: $e');

      // Try local cache on error
      try {
        final prefs = await SharedPreferences.getInstance();
        String? jsonString = prefs.getString(_partsOverridesKey);
        if (jsonString != null) {
          Map<String, dynamic> decoded = json.decode(jsonString);
          return decoded.map((key, value) => MapEntry(key, value.toDouble()));
        }
      } catch (_) {}
    }
    return {};
  }
  
  /// Save service multipliers (for transportation, peak hours, etc.)
  static Future<bool> saveServiceMultipliers(Map<String, double> multipliers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(multipliers);
      return await prefs.setString(_serviceMultipliersKey, jsonString);
    } catch (e) {
      print('Error saving service multipliers: $e');
      return false;
    }
  }
  
  /// Get service multipliers
  static Future<Map<String, double>> getServiceMultipliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_serviceMultipliersKey);
      if (jsonString != null) {
        Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
    } catch (e) {
      print('Error loading service multipliers: $e');
    }
    return {};
  }
  
  /// Save global pricing settings (now uses Supabase)
  static Future<bool> saveGlobalSettings(Map<String, dynamic> settings) async {
    try {
      // Save each setting to Supabase
      for (var entry in settings.entries) {
        await _supabase.setPlatformSetting(
          entry.key,
          entry.value,
          settingType: _getSettingType(entry.value),
          isPublic: true,
        );
      }

      // Also cache locally
      final prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(settings);
      await prefs.setString(_globalSettingsKey, jsonString);

      return true;
    } catch (e) {
      print('Error saving global settings: $e');
      return false;
    }
  }

  /// Get global pricing settings (now from Supabase)
  static Future<Map<String, dynamic>> getGlobalSettings() async {
    try {
      // Try to get from Supabase first
      final settings = await _supabase.getAllPlatformSettings();
      if (settings.isNotEmpty) {
        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_globalSettingsKey, json.encode(settings));

        return settings;
      }

      // Fallback to local cache
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_globalSettingsKey);
      if (jsonString != null) {
        return json.decode(jsonString);
      }
    } catch (e) {
      print('Error loading global settings: $e');

      // Try local cache on error
      try {
        final prefs = await SharedPreferences.getInstance();
        String? jsonString = prefs.getString(_globalSettingsKey);
        if (jsonString != null) {
          return json.decode(jsonString);
        }
      } catch (_) {}
    }
    return _getDefaultGlobalSettings();
  }

  /// Helper to determine setting type
  static String _getSettingType(dynamic value) {
    if (value is num) return 'number';
    if (value is bool) return 'boolean';
    if (value is String) return 'string';
    if (value is List) return 'array';
    return 'object';
  }
  
  /// Get default global settings
  static Map<String, dynamic> _getDefaultGlobalSettings() {
    return {
      'base_transportation_rate': 2.5,
      'fuel_surcharge_percentage': 15.0,
      'peak_hours_multiplier': 1.2,
      'urgency_multiplier': 1.5,
      'default_profit_margin': 20.0,
      'weekend_surcharge': 30.0,
      'night_surcharge': 40.0,
      'currency': 'GHS',
      'tax_rate': 12.5, // VAT in Ghana
      'platform_commission': 15.0,
    };
  }
  
  /// Save discount codes (now uses Supabase)
  static Future<bool> saveDiscountCodes(List<Map<String, dynamic>> discountCodes) async {
    try {
      // Note: In a real implementation, you'd want to update/create individual codes
      // For now, just cache locally (Supabase discount codes are managed through admin UI)
      final prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(discountCodes);
      return await prefs.setString(_discountCodesKey, jsonString);
    } catch (e) {
      print('Error saving discount codes: $e');
      return false;
    }
  }

  /// Get discount codes (now from Supabase)
  static Future<List<Map<String, dynamic>>> getDiscountCodes() async {
    try {
      // Try to get from Supabase first
      final codes = await _supabase.getAllDiscountCodes();
      if (codes.isNotEmpty) {
        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_discountCodesKey, json.encode(codes));

        return codes;
      }

      // Fallback to local cache
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_discountCodesKey);
      if (jsonString != null) {
        List<dynamic> decoded = json.decode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error loading discount codes: $e');

      // Try local cache on error
      try {
        final prefs = await SharedPreferences.getInstance();
        String? jsonString = prefs.getString(_discountCodesKey);
        if (jsonString != null) {
          List<dynamic> decoded = json.decode(jsonString);
          return decoded.cast<Map<String, dynamic>>();
        }
      } catch (_) {}
    }
    return [];
  }
  
  /// Apply discount code
  static Future<Map<String, dynamic>> applyDiscountCode({
    required String code,
    required double totalAmount,
    required String serviceType,
  }) async {
    List<Map<String, dynamic>> discountCodes = await getDiscountCodes();
    
    for (var discount in discountCodes) {
      if (discount['code']?.toString().toUpperCase() == code.toUpperCase() &&
          discount['is_active'] == true) {
        
        // Check expiry date
        if (discount['expiry_date'] != null) {
          DateTime expiryDate = DateTime.parse(discount['expiry_date']);
          if (DateTime.now().isAfter(expiryDate)) {
            return {
              'success': false,
              'message': 'Discount code has expired',
            };
          }
        }
        
        // Check service type restrictions
        if (discount['applicable_services'] != null && 
            discount['applicable_services'].isNotEmpty) {
          List<String> applicableServices = List<String>.from(discount['applicable_services']);
          if (!applicableServices.contains(serviceType.toLowerCase())) {
            return {
              'success': false,
              'message': 'Discount code not applicable to this service',
            };
          }
        }
        
        // Check minimum amount
        if (discount['minimum_amount'] != null && 
            totalAmount < discount['minimum_amount']) {
          return {
            'success': false,
            'message': 'Minimum amount of GHS ${discount['minimum_amount']} required',
          };
        }
        
        // Calculate discount
        double discountAmount = 0.0;
        if (discount['type'] == 'percentage') {
          discountAmount = totalAmount * (discount['value'] / 100);
          if (discount['max_discount'] != null) {
            discountAmount = discountAmount > discount['max_discount'] 
                ? discount['max_discount'].toDouble() 
                : discountAmount;
          }
        } else if (discount['type'] == 'fixed') {
          discountAmount = discount['value'].toDouble();
        }
        
        return {
          'success': true,
          'discount_amount': discountAmount.roundToDouble(),
          'new_total': (totalAmount - discountAmount).roundToDouble(),
          'discount_code': code,
          'discount_description': discount['description'] ?? 'Discount applied',
        };
      }
    }
    
    return {
      'success': false,
      'message': 'Invalid or inactive discount code',
    };
  }
  
  /// Get pricing analytics
  static Future<Map<String, dynamic>> getPricingAnalytics() async {
    // This would typically fetch from a database
    // For now, return mock analytics data
    return {
      'total_services': 1250,
      'average_service_cost': 85.50,
      'most_expensive_service': 'Emergency Plumbing',
      'least_expensive_service': 'Basic Cleaning',
      'price_ranges': {
        'cleaning': {'min': 25.0, 'max': 80.0, 'average': 45.0},
        'plumbing': {'min': 50.0, 'max': 300.0, 'average': 120.0},
        'electrical': {'min': 40.0, 'max': 250.0, 'average': 95.0},
        'beauty_services': {'min': 30.0, 'max': 200.0, 'average': 75.0},
        'appliance_repair': {'min': 60.0, 'max': 400.0, 'average': 150.0},
      },
      'monthly_trends': [
        {'month': 'Jan', 'average_price': 82.0},
        {'month': 'Feb', 'average_price': 85.0},
        {'month': 'Mar', 'average_price': 88.0},
        {'month': 'Apr', 'average_price': 90.0},
        {'month': 'May', 'average_price': 87.0},
        {'month': 'Jun', 'average_price': 85.0},
      ],
      'transportation_impact': {
        'average_transport_cost': 15.50,
        'percentage_of_total': 18.2,
        'most_affected_service': 'Appliance Repair',
      },
      'parts_impact': {
        'average_parts_cost': 25.80,
        'percentage_of_total': 30.2,
        'most_parts_intensive': 'Electrical Services',
      }
    };
  }
  
  /// Get default parts catalog with prices
  static Map<String, Map<String, dynamic>> getDefaultPartsCatalog() {
    return {
      // Plumbing parts
      'pipe_pvc_1inch': {
        'name': 'PVC Pipe 1 inch',
        'base_price': 8.50,
        'type': 'standard',
        'category': 'plumbing',
        'unit': 'meter',
      },
      'pipe_fitting_elbow': {
        'name': 'Pipe Fitting Elbow',
        'base_price': 3.20,
        'type': 'standard',
        'category': 'plumbing',
        'unit': 'piece',
      },
      'faucet_kitchen': {
        'name': 'Kitchen Faucet',
        'base_price': 45.00,
        'type': 'standard',
        'category': 'plumbing',
        'unit': 'piece',
      },
      
      // Electrical parts
      'wire_copper_2.5mm': {
        'name': 'Copper Wire 2.5mm',
        'base_price': 12.00,
        'type': 'standard',
        'category': 'electrical',
        'unit': 'meter',
      },
      'socket_outlet': {
        'name': 'Socket Outlet',
        'base_price': 8.50,
        'type': 'standard',
        'category': 'electrical',
        'unit': 'piece',
      },
      'circuit_breaker_20a': {
        'name': 'Circuit Breaker 20A',
        'base_price': 25.00,
        'type': 'standard',
        'category': 'electrical',
        'unit': 'piece',
      },
      
      // Cleaning supplies
      'detergent_all_purpose': {
        'name': 'All Purpose Detergent',
        'base_price': 15.00,
        'type': 'standard',
        'category': 'cleaning',
        'unit': 'bottle',
      },
      'microfiber_cloth': {
        'name': 'Microfiber Cleaning Cloth',
        'base_price': 5.50,
        'type': 'standard',
        'category': 'cleaning',
        'unit': 'piece',
      },
      
      // Appliance parts
      'refrigerator_compressor': {
        'name': 'Refrigerator Compressor',
        'base_price': 180.00,
        'type': 'premium',
        'category': 'appliance',
        'unit': 'piece',
      },
      'washing_machine_belt': {
        'name': 'Washing Machine Belt',
        'base_price': 25.00,
        'type': 'standard',
        'category': 'appliance',
        'unit': 'piece',
      },
    };
  }
  
  /// Get default labor rates by service type
  static Map<String, double> getDefaultLaborRates() {
    return {
      'cleaning': 25.00,
      'plumbing': 60.00,
      'electrical': 55.00,
      'beauty_services': 40.00,
      'appliance_repair': 70.00,
      'tutoring': 30.00,
      'gardening': 35.00,
      'painting': 45.00,
      'carpentry': 50.00,
      'moving': 40.00,
      'laundry': 20.00,
      'cooking': 35.00,
      'massage': 60.00,
      'hair_styling': 45.00,
      'nail_services': 30.00,
      'makeup': 50.00,
      'childcare': 25.00,
      'elder_care': 30.00,
      'pet_care': 20.00,
      'driving': 35.00,
      'translation': 40.00,
    };
  }
  
  /// Reset all pricing to defaults
  static Future<bool> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_laborRatesKey);
      await prefs.remove(_partsOverridesKey);
      await prefs.remove(_serviceMultipliersKey);
      await prefs.remove(_globalSettingsKey);
      await prefs.remove(_discountCodesKey);
      return true;
    } catch (e) {
      print('Error resetting pricing to defaults: $e');
      return false;
    }
  }
  
  /// Export pricing configuration
  static Future<Map<String, dynamic>> exportPricingConfiguration() async {
    return {
      'labor_rates': await getLaborRateOverrides(),
      'parts_overrides': await getPartsOverrides(),
      'service_multipliers': await getServiceMultipliers(),
      'global_settings': await getGlobalSettings(),
      'discount_codes': await getDiscountCodes(),
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }
  
  /// Import pricing configuration
  static Future<bool> importPricingConfiguration(Map<String, dynamic> config) async {
    try {
      if (config['labor_rates'] != null) {
        Map<String, double> laborRates = Map<String, double>.from(config['labor_rates']);
        await saveLaborRateOverrides(laborRates);
      }
      
      if (config['parts_overrides'] != null) {
        Map<String, double> partsOverrides = Map<String, double>.from(config['parts_overrides']);
        await savePartsOverrides(partsOverrides);
      }
      
      if (config['service_multipliers'] != null) {
        Map<String, double> multipliers = Map<String, double>.from(config['service_multipliers']);
        await saveServiceMultipliers(multipliers);
      }
      
      if (config['global_settings'] != null) {
        await saveGlobalSettings(config['global_settings']);
      }
      
      if (config['discount_codes'] != null) {
        List<Map<String, dynamic>> discountCodes = List<Map<String, dynamic>>.from(config['discount_codes']);
        await saveDiscountCodes(discountCodes);
      }
      
      return true;
    } catch (e) {
      print('Error importing pricing configuration: $e');
      return false;
    }
  }
}