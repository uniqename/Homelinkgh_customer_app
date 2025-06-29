import 'dart:math';
import '../models/provider.dart';
import '../models/booking.dart';
import 'local_data_service.dart';
import 'smart_personalization_service.dart';

// Smart recommendation types
enum RecommendationType {
  instantNeed,      // What you need right now
  perfectTiming,    // Based on time patterns
  smartCombo,       // Services that work well together
  trendingNow,      // What's popular
  personalFavorite, // Based on your history
  weatherBased,     // Based on weather/season
  locationSmart,    // Based on your location
  budgetOptimized,  // Best value for money
}

class AIRecommendationsService {
  static final AIRecommendationsService _instance = AIRecommendationsService._internal();
  factory AIRecommendationsService() => _instance;
  AIRecommendationsService._internal();

  final LocalDataService _localData = LocalDataService();
  final SmartPersonalizationService _personalization = SmartPersonalizationService();

  /// Initialize recommendations service
  Future<void> initializeRecommendations() async {
    // Initialize any required data or connections
    await _personalization.initializePersonalization();
  }

  /// Get recommendations (alias for getSmartRecommendations)
  Future<List<Map<String, dynamic>>> getRecommendations(Map<String, dynamic> context) async {
    return getSmartRecommendations(
      currentLocation: context['location'],
      currentBudget: context['budget']?.toDouble(),
      timeContext: context['timeContext'],
    );
  }

  Future<List<Map<String, dynamic>>> getSmartRecommendations({
    String? currentLocation,
    double? currentBudget,
    String? timeContext, // 'morning', 'afternoon', 'evening', 'weekend'
  }) async {
    final recommendations = <Map<String, dynamic>>[];
    final providers = await _localData.getAllProviders();
    
    // Get personalized data
    final personalizedRecs = _personalization.getPersonalizedRecommendations();
    
    // 1. Instant Need Recommendations (What you likely need right now)
    final instantNeeds = await _generateInstantNeedRecommendations();
    recommendations.addAll(instantNeeds);
    
    // 2. Perfect Timing Recommendations
    final timingRecs = await _generateTimingRecommendations(timeContext);
    recommendations.addAll(timingRecs);
    
    // 3. Smart Combo Recommendations
    final comboRecs = await _generateSmartComboRecommendations();
    recommendations.addAll(comboRecs);
    
    // 4. Trending Now
    final trendingRecs = await _generateTrendingRecommendations();
    recommendations.addAll(trendingRecs);
    
    // 5. Personal Favorites Evolution
    final favoriteRecs = await _generatePersonalFavoriteEvolution();
    recommendations.addAll(favoriteRecs);
    
    // 6. Weather/Season Based
    final weatherRecs = await _generateWeatherBasedRecommendations();
    recommendations.addAll(weatherRecs);
    
    // 7. Location Smart
    if (currentLocation != null) {
      final locationRecs = await _generateLocationSmartRecommendations(currentLocation);
      recommendations.addAll(locationRecs);
    }
    
    // 8. Budget Optimized
    if (currentBudget != null) {
      final budgetRecs = await _generateBudgetOptimizedRecommendations(currentBudget);
      recommendations.addAll(budgetRecs);
    }
    
    // Sort by AI confidence score and return top recommendations
    recommendations.sort((a, b) => b['aiConfidence'].compareTo(a['aiConfidence']));
    
    return recommendations.take(8).toList();
  }

  Future<List<Map<String, dynamic>>> _generateInstantNeedRecommendations() async {
    final recommendations = <Map<String, dynamic>>[];
    final currentHour = DateTime.now().hour;
    final currentMinute = DateTime.now().minute;
    final dayOfWeek = DateTime.now().weekday;
    
    // Morning Rush (6:30 - 9:30 AM)
    if (currentHour >= 6 && currentHour <= 9 && currentMinute >= 30) {
      recommendations.add({
        'type': RecommendationType.instantNeed,
        'title': '☕ Morning Fuel',
        'subtitle': 'Coffee & breakfast to kickstart your day',
        'services': ['Coffee Delivery', 'Breakfast Delivery'],
        'reasoning': 'Most people need their morning boost around this time',
        'aiConfidence': 0.9,
        'urgency': 'high',
        'estimatedTime': '15-25 min',
        'icon': '☕',
        'color': 0xFFD4A574,
      });
    }
    
    // Lunch Time (11:30 AM - 2:30 PM)
    if (currentHour >= 11 && currentHour <= 14 && currentMinute >= 30) {
      recommendations.add({
        'type': RecommendationType.instantNeed,
        'title': '🍛 Lunch Break',
        'subtitle': 'Perfect timing for your lunch delivery',
        'services': ['Jollof Delivery', 'Banku & Fish', 'Fast Food'],
        'reasoning': 'Peak lunch hours - avoid the rush',
        'aiConfidence': 0.95,
        'urgency': 'high',
        'estimatedTime': '20-30 min',
        'icon': '🍛',
        'color': 0xFFE57373,
      });
    }
    
    // Evening Dinner (6:00 - 9:00 PM)
    if (currentHour >= 18 && currentHour <= 21) {
      recommendations.add({
        'type': RecommendationType.instantNeed,
        'title': '🍽️ Dinner Time',
        'subtitle': 'Family dinner or personal treat',
        'services': ['Waakye', 'Local Dishes', 'International Cuisine'],
        'reasoning': 'Prime dinner time for families',
        'aiConfidence': 0.88,
        'urgency': 'medium',
        'estimatedTime': '25-40 min',
        'icon': '🍽️',
        'color': 0xFF81C784,
      });
    }
    
    // Friday Evening (Weekend prep)
    if (dayOfWeek == 5 && currentHour >= 17) {
      recommendations.add({
        'type': RecommendationType.instantNeed,
        'title': '🎉 Weekend Prep',
        'subtitle': 'Get ready for the weekend',
        'services': ['House Cleaning', 'Beauty Services', 'Grocery'],
        'reasoning': 'Friday evening is perfect for weekend preparation',
        'aiConfidence': 0.75,
        'urgency': 'medium',
        'estimatedTime': '1-2 hours',
        'icon': '🎉',
        'color': 0xFF9C27B0,
      });
    }
    
    return recommendations;
  }

  Future<List<Map<String, dynamic>>> _generateTimingRecommendations(String? timeContext) async {
    final recommendations = <Map<String, dynamic>>[];
    
    switch (timeContext) {
      case 'morning':
        recommendations.add({
          'type': RecommendationType.perfectTiming,
          'title': '🌅 Morning Productivity',
          'subtitle': 'Start your day efficiently',
          'services': ['Breakfast Delivery', 'House Cleaning', 'Laundry Pickup'],
          'reasoning': 'Morning is perfect for setting up your day',
          'aiConfidence': 0.82,
          'timeOptimal': true,
          'icon': '🌅',
          'color': 0xFFFFB74D,
        });
        break;
        
      case 'afternoon':
        recommendations.add({
          'type': RecommendationType.perfectTiming,
          'title': '☀️ Midday Momentum',
          'subtitle': 'Keep your energy high',
          'services': ['Lunch Delivery', 'Quick Beauty Touch-up', 'Errands'],
          'reasoning': 'Afternoon energy boost services',
          'aiConfidence': 0.79,
          'timeOptimal': true,
          'icon': '☀️',
          'color': 0xFFFFD54F,
        });
        break;
        
      case 'evening':
        recommendations.add({
          'type': RecommendationType.perfectTiming,
          'title': '🌅 Evening Comfort',
          'subtitle': 'Wind down in style',
          'services': ['Dinner Delivery', 'Massage Therapy', 'Home Spa'],
          'reasoning': 'Evening relaxation and comfort',
          'aiConfidence': 0.85,
          'timeOptimal': true,
          'icon': '🌙',
          'color': 0xFF7986CB,
        });
        break;
        
      case 'weekend':
        recommendations.add({
          'type': RecommendationType.perfectTiming,
          'title': '🏖️ Weekend Vibes',
          'subtitle': 'Make the most of your weekend',
          'services': ['Brunch Delivery', 'Spa Services', 'Home Organization'],
          'reasoning': 'Weekend leisure and self-care',
          'aiConfidence': 0.87,
          'timeOptimal': true,
          'icon': '🏖️',
          'color': 0xFF4FC3F7,
        });
        break;
    }
    
    return recommendations;
  }

  Future<List<Map<String, dynamic>>> _generateSmartComboRecommendations() async {
    final smartCombos = [
      {
        'type': RecommendationType.smartCombo,
        'title': '🏠 Complete Home Care',
        'subtitle': 'House cleaning + laundry service',
        'services': ['House Cleaning', 'Laundry Service'],
        'reasoning': 'These services complement each other perfectly',
        'aiConfidence': 0.91,
        'savings': '25%',
        'comboDiscount': true,
        'icon': '🏠',
        'color': 0xFF66BB6A,
        'estimatedTime': '2-3 hours',
        'totalSavings': 'GH₵75',
      },
      {
        'type': RecommendationType.smartCombo,
        'title': '✨ Beauty & Photography',
        'subtitle': 'Perfect look + capture the moment',
        'services': ['Beauty Services', 'Photography'],
        'reasoning': 'Great for events and special occasions',
        'aiConfidence': 0.88,
        'savings': '20%',
        'comboDiscount': true,
        'icon': '✨',
        'color': 0xFFEC407A,
        'estimatedTime': '2-4 hours',
        'totalSavings': 'GH₵100',
      },
      {
        'type': RecommendationType.smartCombo,
        'title': '🍽️ Food & Grocery',
        'subtitle': 'Dinner tonight + groceries for tomorrow',
        'services': ['Food Delivery', 'Grocery Shopping'],
        'reasoning': 'One trip for immediate and future needs',
        'aiConfidence': 0.84,
        'savings': '15%',
        'comboDiscount': true,
        'icon': '🍽️',
        'color': 0xFFFF8A65,
        'estimatedTime': '45-60 min',
        'totalSavings': 'GH₵30',
      },
    ];
    
    return smartCombos;
  }

  Future<List<Map<String, dynamic>>> _generateTrendingRecommendations() async {
    // Simulate trending data based on current patterns
    final trendingServices = [
      {
        'service': 'Beauty Services',
        'trendScore': 0.95,
        'reason': 'Wedding season in Ghana',
        'growth': '+45%'
      },
      {
        'service': 'Food Delivery',
        'trendScore': 0.92,
        'reason': 'More people working from home',
        'growth': '+38%'
      },
      {
        'service': 'House Cleaning',
        'trendScore': 0.89,
        'reason': 'Post-holiday cleaning',
        'growth': '+32%'
      },
    ];
    
    return [
      {
        'type': RecommendationType.trendingNow,
        'title': '🔥 Trending in Ghana',
        'subtitle': 'What everyone\'s booking right now',
        'services': trendingServices.map((s) => s['service']).toList(),
        'reasoning': 'Based on real-time booking data across Ghana',
        'aiConfidence': 0.86,
        'trending': true,
        'trendingData': trendingServices,
        'icon': '🔥',
        'color': 0xFFFF7043,
      }
    ];
  }

  Future<List<Map<String, dynamic>>> _generatePersonalFavoriteEvolution() async {
    final personalityType = _personalization.userPersonalityType;
    final usageCount = _personalization.serviceUsageCount;
    
    if (usageCount.isEmpty) {
      return [];
    }
    
    final topService = usageCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    final evolutionMap = {
      'Food Delivery': ['Personal Chef', 'Meal Planning', 'Kitchen Organization'],
      'House Cleaning': ['Deep Cleaning', 'Organization Services', 'Maintenance'],
      'Beauty Services': ['Spa Packages', 'Personal Styling', 'Wellness Coaching'],
      'Transportation': ['Personal Driver', 'Luxury Rides', 'Travel Planning'],
    };
    
    final nextLevel = evolutionMap[topService.key];
    if (nextLevel != null) {
      return [
        {
          'type': RecommendationType.personalFavorite,
          'title': '🎯 Your Next Level',
          'subtitle': 'Evolve your ${topService.key.toLowerCase()} experience',
          'services': nextLevel,
          'reasoning': 'Based on your love for ${topService.key.toLowerCase()}',
          'aiConfidence': 0.83,
          'personalEvolution': true,
          'currentFavorite': topService.key,
          'usageCount': topService.value,
          'icon': '🎯',
          'color': 0xFF8E24AA,
        }
      ];
    }
    
    return [];
  }

  Future<List<Map<String, dynamic>>> _generateWeatherBasedRecommendations() async {
    // Simulate weather data (in real app, this would come from weather API)
    final currentSeason = _getCurrentSeason();
    final recommendations = <Map<String, dynamic>>[];
    
    switch (currentSeason) {
      case 'dry_season':
        recommendations.add({
          'type': RecommendationType.weatherBased,
          'title': '☀️ Dry Season Specials',
          'subtitle': 'Perfect weather for outdoor services',
          'services': ['Landscaping', 'Exterior Cleaning', 'Event Planning'],
          'reasoning': 'Dry season is ideal for outdoor work',
          'aiConfidence': 0.78,
          'weatherOptimal': true,
          'season': 'Dry Season',
          'icon': '☀️',
          'color': 0xFFFFA726,
        });
        break;
        
      case 'rainy_season':
        recommendations.add({
          'type': RecommendationType.weatherBased,
          'title': '🌧️ Rainy Season Comfort',
          'subtitle': 'Stay cozy while we handle the rest',
          'services': ['Food Delivery', 'Indoor Cleaning', 'Beauty Services'],
          'reasoning': 'Perfect indoor activities during rainy season',
          'aiConfidence': 0.82,
          'weatherOptimal': true,
          'season': 'Rainy Season',
          'icon': '🌧️',
          'color': 0xFF42A5F5,
        });
        break;
    }
    
    return recommendations;
  }

  Future<List<Map<String, dynamic>>> _generateLocationSmartRecommendations(String location) async {
    // Location-based service availability and popularity
    final locationData = {
      'Accra': {
        'popular': ['Food Delivery', 'Transportation', 'Beauty Services'],
        'available': ['Fast WiFi Setup', 'Business Services', 'Tech Support'],
        'cultural': ['Traditional Catering', 'Kente Design', 'Cultural Events'],
      },
      'Kumasi': {
        'popular': ['Traditional Crafts', 'Local Food', 'Market Shopping'],
        'available': ['Ashanti Cultural Tours', 'Traditional Healing', 'Craft Learning'],
        'cultural': ['Adinkra Designs', 'Traditional Music', 'Cultural Education'],
      },
      'Takoradi': {
        'popular': ['Marine Services', 'Oil & Gas Support', 'Coastal Activities'],
        'available': ['Beach Cleaning', 'Fishing Assistance', 'Marine Equipment'],
        'cultural': ['Coastal Cuisine', 'Maritime Culture', 'Beach Events'],
      },
    };
    
    final data = locationData[location];
    if (data != null) {
      return [
        {
          'type': RecommendationType.locationSmart,
          'title': '📍 Popular in $location',
          'subtitle': 'Services that locals love',
          'services': data['popular'],
          'reasoning': 'Based on location-specific preferences',
          'aiConfidence': 0.81,
          'locationSpecific': true,
          'location': location,
          'icon': '📍',
          'color': 0xFF26A69A,
        }
      ];
    }
    
    return [];
  }

  Future<List<Map<String, dynamic>>> _generateBudgetOptimizedRecommendations(double budget) async {
    final budgetTiers = [
      {
        'range': [0, 100],
        'title': '💰 Budget Smart',
        'services': ['Quick Food Delivery', 'Basic Cleaning', 'Standard Transportation'],
        'features': ['Best value', 'Quality assured', 'Quick service'],
      },
      {
        'range': [100, 300],
        'title': '⭐ Great Value',
        'services': ['Premium Food', 'Deep Cleaning', 'Comfort Transportation'],
        'features': ['Enhanced experience', 'Trusted providers', 'Extra care'],
      },
      {
        'range': [300, 1000],
        'title': '👑 Premium Choice',
        'services': ['Gourmet Delivery', 'Premium Cleaning', 'Luxury Transportation'],
        'features': ['Top-rated providers', 'Premium experience', 'White-glove service'],
      },
    ];
    
    for (final tier in budgetTiers) {
      final range = tier['range'] as List<int>;
      if (budget >= range[0] && budget < range[1]) {
        return [
          {
            'type': RecommendationType.budgetOptimized,
            'title': tier['title'],
            'subtitle': 'Perfect services for your budget of GH₵${budget.round()}',
            'services': tier['services'],
            'reasoning': 'Optimized for your spending preference',
            'aiConfidence': 0.89,
            'budgetOptimized': true,
            'budgetRange': 'GH₵${range[0]} - GH₵${range[1]}',
            'features': tier['features'],
            'icon': '💎',
            'color': 0xFFAB47BC,
          }
        ];
      }
    }
    
    return [];
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    // Ghana's seasons: Dry season (Nov-Mar), Rainy season (Apr-Oct)
    if (month >= 11 || month <= 3) {
      return 'dry_season';
    } else {
      return 'rainy_season';
    }
  }

  // Smart matching algorithms
  Future<List<Provider>> getAIMatchedProviders({
    required String serviceType,
    Map<String, dynamic>? preferences,
  }) async {
    final allProviders = await _localData.getProvidersByService(serviceType);
    final personalityType = _personalization.userPersonalityType;
    
    // Apply AI matching based on personality and preferences
    final scoredProviders = <Map<String, dynamic>>[];
    
    for (final provider in allProviders) {
      double score = provider.rating * 0.3; // Base rating score
      
      // Personality-based scoring
      switch (personalityType) {
        case 'premium_seeker':
          if (provider.rating >= 4.8) score += 0.3;
          if (provider.completedJobs > 150) score += 0.2;
          break;
        case 'budget_conscious':
          // Favor providers with good ratings but competitive pricing
          if (provider.rating >= 4.5 && provider.averageResponseTime < 20) score += 0.3;
          break;
        case 'efficiency_focused':
          if (provider.averageResponseTime < 15) score += 0.4;
          if (provider.isAvailable) score += 0.2;
          break;
        case 'explorer':
          // Favor diverse providers or newer ones
          if (provider.completedJobs < 100) score += 0.2;
          score += Random().nextDouble() * 0.1; // Add some randomness
          break;
      }
      
      // Availability bonus
      if (provider.isAvailable) score += 0.2;
      
      scoredProviders.add({
        'provider': provider,
        'aiScore': score,
        'reasons': _generateMatchingReasons(provider, personalityType),
      });
    }
    
    // Sort by AI score
    scoredProviders.sort((a, b) => b['aiScore'].compareTo(a['aiScore']));
    
    return scoredProviders.map((item) => item['provider'] as Provider).take(5).toList();
  }

  List<String> _generateMatchingReasons(Provider provider, String personalityType) {
    final reasons = <String>[];
    
    if (provider.rating >= 4.8) {
      reasons.add('Top-rated provider (${provider.rating}⭐)');
    }
    
    if (provider.averageResponseTime < 15) {
      reasons.add('Super fast response (${provider.averageResponseTime} min)');
    }
    
    if (provider.completedJobs > 150) {
      reasons.add('Highly experienced (${provider.completedJobs} jobs)');
    }
    
    switch (personalityType) {
      case 'premium_seeker':
        reasons.add('Perfect for premium experience seekers');
        break;
      case 'budget_conscious':
        reasons.add('Great value for money');
        break;
      case 'efficiency_focused':
        reasons.add('Known for efficient service');
        break;
      case 'explorer':
        reasons.add('Offers unique service experiences');
        break;
    }
    
    return reasons;
  }
}