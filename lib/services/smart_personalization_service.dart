import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import 'local_data_service.dart';

class SmartPersonalizationService {
  static final SmartPersonalizationService _instance = SmartPersonalizationService._internal();
  factory SmartPersonalizationService() => _instance;
  SmartPersonalizationService._internal();

  final LocalDataService _localData = LocalDataService();
  
  // User preference tracking
  Map<String, dynamic> _userPreferences = {};
  Map<String, int> _serviceUsageCount = {};
  Map<String, double> _timeOfDayPatterns = {};
  Map<String, List<String>> _favoriteProviders = {};
  Map<String, double> _budgetPatterns = {};
  List<String> _recentSearches = [];
  Map<String, DateTime> _lastServiceUsed = {};
  
  // Smart insights
  String _userPersonalityType = 'explorer'; // explorer, efficiency_focused, budget_conscious, premium_seeker
  List<String> _predictedNeeds = [];
  Map<String, double> _locationPatterns = {};

  Future<void> initializePersonalization() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsData = prefs.getString('user_preferences');
    if (prefsData != null) {
      _userPreferences = Map<String, dynamic>.from(json.decode(prefsData));
      _loadUserBehaviorData();
    }
    await _analyzeUserPersonality();
  }

  Future<void> trackUserAction(String action, Map<String, dynamic> context) async {
    // Track service usage
    if (action == 'service_booked') {
      final serviceType = context['serviceType'] as String;
      _serviceUsageCount[serviceType] = (_serviceUsageCount[serviceType] ?? 0) + 1;
      _lastServiceUsed[serviceType] = DateTime.now();
      
      // Track time patterns
      final hour = DateTime.now().hour.toDouble();
      _timeOfDayPatterns[serviceType] = (_timeOfDayPatterns[serviceType] ?? 12.0) * 0.8 + hour * 0.2;
      
      // Track budget patterns
      if (context['price'] != null) {
        final price = context['price'] as double;
        _budgetPatterns[serviceType] = (_budgetPatterns[serviceType] ?? price) * 0.7 + price * 0.3;
      }
      
      // Track provider preferences
      if (context['providerId'] != null) {
        final providerId = context['providerId'] as String;
        _favoriteProviders[serviceType] = _favoriteProviders[serviceType] ?? [];
        if (!_favoriteProviders[serviceType]!.contains(providerId)) {
          _favoriteProviders[serviceType]!.add(providerId);
        }
      }
    }
    
    // Track search behavior
    if (action == 'search_performed') {
      final query = context['query'] as String;
      _recentSearches.add(query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeAt(0);
      }
    }
    
    // Track location patterns
    if (action == 'location_used') {
      final location = context['location'] as String;
      _locationPatterns[location] = (_locationPatterns[location] ?? 0) + 1;
    }
    
    await _saveUserBehaviorData();
    await _analyzeUserPersonality();
    await _generatePredictedNeeds();
  }

  Future<void> _analyzeUserPersonality() async {
    final totalBookings = _serviceUsageCount.values.fold<int>(0, (sum, count) => sum + count);
    
    if (totalBookings == 0) {
      _userPersonalityType = 'explorer';
      return;
    }
    
    // Analyze diversity of services
    final serviceTypes = _serviceUsageCount.keys.length;
    final averageBudget = _budgetPatterns.values.fold<double>(0, (sum, budget) => sum + budget) / 
                         (_budgetPatterns.values.length == 0 ? 1 : _budgetPatterns.values.length);
    
    if (serviceTypes > 5 && totalBookings > 8) {
      _userPersonalityType = 'explorer';
    } else if (averageBudget > 300) {
      _userPersonalityType = 'premium_seeker';
    } else if (averageBudget < 150) {
      _userPersonalityType = 'budget_conscious';
    } else {
      _userPersonalityType = 'efficiency_focused';
    }
  }

  Future<void> _generatePredictedNeeds() async {
    _predictedNeeds.clear();
    
    // Predict based on time patterns
    final currentHour = DateTime.now().hour;
    final currentDay = DateTime.now().weekday;
    
    // Morning predictions (6-11 AM)
    if (currentHour >= 6 && currentHour <= 11) {
      _predictedNeeds.addAll(['Food Delivery', 'Coffee Delivery', 'Grocery']);
    }
    
    // Afternoon predictions (12-5 PM)
    if (currentHour >= 12 && currentHour <= 17) {
      _predictedNeeds.addAll(['Lunch Delivery', 'House Cleaning', 'Laundry']);
    }
    
    // Evening predictions (6-10 PM)
    if (currentHour >= 18 && currentHour <= 22) {
      _predictedNeeds.addAll(['Dinner Delivery', 'Beauty Services', 'Transportation']);
    }
    
    // Weekend predictions
    if (currentDay == 6 || currentDay == 7) {
      _predictedNeeds.addAll(['House Cleaning', 'Beauty Services', 'Landscaping']);
    }
    
    // Predict based on usage patterns
    _serviceUsageCount.forEach((service, count) {
      final lastUsed = _lastServiceUsed[service];
      if (lastUsed != null) {
        final daysSinceLastUse = DateTime.now().difference(lastUsed).inDays;
        
        // Suggest frequently used services after some time
        if (count > 2 && daysSinceLastUse > 7) {
          if (!_predictedNeeds.contains(service)) {
            _predictedNeeds.insert(0, service);
          }
        }
      }
    });
    
    // Limit to top 5 predictions
    if (_predictedNeeds.length > 5) {
      _predictedNeeds = _predictedNeeds.take(5).toList();
    }
  }

  List<Map<String, dynamic>> getPersonalizedRecommendations() {
    final recommendations = <Map<String, dynamic>>[];
    
    // Add personality-based recommendations
    switch (_userPersonalityType) {
      case 'explorer':
        recommendations.addAll([
          {
            'title': '🌟 Try Something New',
            'subtitle': 'Discover services you haven\'t tried yet',
            'type': 'new_service',
            'services': _getUntriedServices(),
            'priority': 0.9,
          },
          {
            'title': '🎯 Perfect Match',
            'subtitle': 'Services curated just for you',
            'type': 'curated_services',
            'services': _getCuratedServices(),
            'priority': 0.8,
          },
        ]);
        break;
        
      case 'premium_seeker':
        recommendations.addAll([
          {
            'title': '👑 Premium Experience',
            'subtitle': 'Top-rated providers for the ultimate experience',
            'type': 'premium_providers',
            'providers': _getPremiumProviders(),
            'priority': 0.95,
          },
          {
            'title': '💎 Exclusive Services',
            'subtitle': 'Luxury services tailored for you',
            'type': 'luxury_services',
            'services': ['Beauty Services', 'Personal Chef', 'Luxury Transportation'],
            'priority': 0.9,
          },
        ]);
        break;
        
      case 'budget_conscious':
        recommendations.addAll([
          {
            'title': '💰 Best Value Deals',
            'subtitle': 'Quality services at great prices',
            'type': 'budget_deals',
            'deals': _getBudgetDeals(),
            'priority': 0.95,
          },
          {
            'title': '🤝 Combo Savings',
            'subtitle': 'Bundle services and save more',
            'type': 'combo_deals',
            'combos': _getComboDeals(),
            'priority': 0.85,
          },
        ]);
        break;
        
      case 'efficiency_focused':
        recommendations.addAll([
          {
            'title': '⚡ Quick & Reliable',
            'subtitle': 'Fast providers near you',
            'type': 'fast_providers',
            'providers': _getFastProviders(),
            'priority': 0.9,
          },
          {
            'title': '📅 Schedule Ahead',
            'subtitle': 'Book your regular services in advance',
            'type': 'recurring_booking',
            'services': _getRegularServices(),
            'priority': 0.8,
          },
        ]);
        break;
    }
    
    // Add time-based recommendations
    if (_predictedNeeds.isNotEmpty) {
      recommendations.add({
        'title': '🔮 Perfect Timing',
        'subtitle': 'Services you might need right now',
        'type': 'predicted_needs',
        'services': _predictedNeeds,
        'priority': 0.85,
      });
    }
    
    // Add location-based recommendations
    final popularInArea = _getPopularInArea();
    if (popularInArea.isNotEmpty) {
      recommendations.add({
        'title': '📍 Popular in Your Area',
        'subtitle': 'What neighbors are booking',
        'type': 'location_popular',
        'services': popularInArea,
        'priority': 0.7,
      });
    }
    
    // Sort by priority and return top recommendations
    recommendations.sort((a, b) => b['priority'].compareTo(a['priority']));
    return recommendations.take(6).toList();
  }

  List<String> getSmartSearchSuggestions(String query) {
    final suggestions = <String>[];
    
    // Add recent searches
    for (final search in _recentSearches.reversed) {
      if (search.toLowerCase().contains(query.toLowerCase()) && !suggestions.contains(search)) {
        suggestions.add(search);
      }
    }
    
    // Add predicted needs
    for (final need in _predictedNeeds) {
      if (need.toLowerCase().contains(query.toLowerCase()) && !suggestions.contains(need)) {
        suggestions.add(need);
      }
    }
    
    // Add popular services
    final allServices = ['Food Delivery', 'House Cleaning', 'Beauty Services', 'Transportation', 
                        'Grocery', 'Laundry', 'Plumbing', 'Electrical', 'Babysitting', 'Landscaping'];
    for (final service in allServices) {
      if (service.toLowerCase().contains(query.toLowerCase()) && !suggestions.contains(service)) {
        suggestions.add(service);
      }
    }
    
    return suggestions.take(5).toList();
  }

  Map<String, dynamic> getPersonalizedPricing(String serviceType) {
    final baseBudget = _budgetPatterns[serviceType] ?? 200.0;
    final personalityMultiplier = _getPersonalityPriceMultiplier();
    
    return {
      'suggested_budget': (baseBudget * personalityMultiplier).round(),
      'budget_range': {
        'min': (baseBudget * 0.7).round(),
        'max': (baseBudget * 1.5).round(),
      },
      'personality_note': _getPricePersonalityNote(),
      'savings_tip': _getSavingsTip(serviceType),
    };
  }

  double _getPersonalityPriceMultiplier() {
    switch (_userPersonalityType) {
      case 'premium_seeker': return 1.3;
      case 'budget_conscious': return 0.8;
      case 'efficiency_focused': return 1.0;
      case 'explorer': return 1.1;
      default: return 1.0;
    }
  }

  String _getPricePersonalityNote() {
    switch (_userPersonalityType) {
      case 'premium_seeker': return 'We\'ve selected premium options based on your preferences';
      case 'budget_conscious': return 'Great value options that fit your budget';
      case 'efficiency_focused': return 'Reliable providers with competitive pricing';
      case 'explorer': return 'Diverse options to match your adventurous spirit';
      default: return 'Personalized pricing based on your preferences';
    }
  }

  String _getSavingsTip(String serviceType) {
    final tips = [
      'Book during off-peak hours for better rates',
      'Bundle multiple services for combo discounts',
      'Book in advance for early bird pricing',
      'Consider weekly subscriptions for regular services',
      'Rate your provider for loyalty points',
    ];
    return tips[Random().nextInt(tips.length)];
  }

  // Helper methods for recommendations
  List<String> _getUntriedServices() {
    final allServices = ['Food Delivery', 'House Cleaning', 'Beauty Services', 'Transportation', 
                        'Grocery', 'Laundry', 'Plumbing', 'Electrical', 'Babysitting', 'Landscaping',
                        'Pet Care', 'Tutoring', 'Photography', 'Event Planning'];
    final triedServices = _serviceUsageCount.keys.toSet();
    return allServices.where((service) => !triedServices.contains(service)).take(4).toList();
  }

  List<String> _getCuratedServices() {
    // Return services based on user's most used services and similar users
    final topServices = _serviceUsageCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (topServices.isEmpty) {
      return ['Food Delivery', 'House Cleaning', 'Transportation'];
    }
    
    // Recommend related services
    final primaryService = topServices.first.key;
    final Map<String, List<String>> relatedServices = {
      'Food Delivery': ['Grocery', 'Personal Chef', 'Kitchen Cleaning'],
      'House Cleaning': ['Laundry', 'Organization', 'Deep Cleaning'],
      'Beauty Services': ['Photography', 'Event Planning', 'Personal Shopping'],
      'Transportation': ['Delivery Services', 'Moving Help', 'Airport Transfer'],
    };
    
    return relatedServices[primaryService] ?? ['Food Delivery', 'House Cleaning'];
  }

  List<String> _getPremiumProviders() {
    // Return provider IDs of highest rated providers
    return ['1', '2', '4']; // Kwame, Ama, Akosua - our top rated providers
  }

  List<Map<String, dynamic>> _getBudgetDeals() {
    return [
      {'service': 'Food Delivery', 'discount': '20%', 'description': 'Lunch deals under GH₵50'},
      {'service': 'House Cleaning', 'discount': '15%', 'description': 'Basic cleaning packages'},
      {'service': 'Grocery', 'discount': '10%', 'description': 'Weekly grocery runs'},
    ];
  }

  List<Map<String, dynamic>> _getComboDeals() {
    return [
      {
        'services': ['House Cleaning', 'Laundry'],
        'discount': '25%',
        'description': 'Complete home care package'
      },
      {
        'services': ['Food Delivery', 'Grocery'],
        'discount': '15%',
        'description': 'Weekly meal and shopping bundle'
      },
    ];
  }

  List<String> _getFastProviders() {
    // Return providers with fastest response times
    return ['3', '1', '2']; // Kofi, Kwame, Ama
  }

  List<String> _getRegularServices() {
    return _serviceUsageCount.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .take(3)
        .toList();
  }

  List<String> _getPopularInArea() {
    // Return services popular in user's location
    return ['Food Delivery', 'Transportation', 'Beauty Services'];
  }

  // Data persistence
  Future<void> _saveUserBehaviorData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'serviceUsageCount': _serviceUsageCount,
      'timeOfDayPatterns': _timeOfDayPatterns,
      'favoriteProviders': _favoriteProviders,
      'budgetPatterns': _budgetPatterns,
      'recentSearches': _recentSearches,
      'userPersonalityType': _userPersonalityType,
      'predictedNeeds': _predictedNeeds,
      'locationPatterns': _locationPatterns,
      'lastServiceUsed': _lastServiceUsed.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
    };
    await prefs.setString('user_behavior_data', json.encode(data));
  }

  Future<void> _loadUserBehaviorData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('user_behavior_data');
    if (dataString != null) {
      final data = Map<String, dynamic>.from(json.decode(dataString));
      
      _serviceUsageCount = Map<String, int>.from(data['serviceUsageCount'] ?? {});
      _timeOfDayPatterns = Map<String, double>.from(data['timeOfDayPatterns'] ?? {});
      _budgetPatterns = Map<String, double>.from(data['budgetPatterns'] ?? {});
      _recentSearches = List<String>.from(data['recentSearches'] ?? []);
      _userPersonalityType = data['userPersonalityType'] ?? 'explorer';
      _predictedNeeds = List<String>.from(data['predictedNeeds'] ?? []);
      _locationPatterns = Map<String, double>.from(data['locationPatterns'] ?? {});
      
      // Convert favorites back
      final favoritesData = data['favoriteProviders'] ?? {};
      _favoriteProviders = favoritesData.map<String, List<String>>(
        (key, value) => MapEntry(key, List<String>.from(value))
      );
      
      // Convert lastServiceUsed back
      final lastUsedData = data['lastServiceUsed'] ?? {};
      _lastServiceUsed = lastUsedData.map<String, DateTime>(
        (key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value))
      );
    }
  }

  // Getters for UI
  String get userPersonalityType => _userPersonalityType;
  List<String> get predictedNeeds => _predictedNeeds;
  Map<String, int> get serviceUsageCount => _serviceUsageCount;
  List<String> get recentSearches => _recentSearches;
}