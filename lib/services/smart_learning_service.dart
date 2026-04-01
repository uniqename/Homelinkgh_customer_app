import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_personalization_service.dart';

class SmartLearningService {
  static final SmartLearningService _instance = SmartLearningService._internal();
  factory SmartLearningService() => _instance;
  SmartLearningService._internal();

  final SmartPersonalizationService _personalization = SmartPersonalizationService();
  
  // Learning data structures
  Map<String, Map<String, double>> _userBehaviorPatterns = {};
  Map<String, List<Map<String, dynamic>>> _serviceJourney = {};
  Map<String, double> _preferenceLearning = {};
  Map<String, Map<String, int>> _contextualPatterns = {};
  Map<String, List<String>> _successfulCombinations = {};
  Map<String, double> _satisfactionScores = {};
  List<Map<String, dynamic>> _learningInsights = [];
  
  // User habit analysis
  Map<String, Map<String, dynamic>> _habitPatterns = {};
  Map<String, List<DateTime>> _serviceTimingPatterns = {};
  Map<String, double> _seasonalPreferences = {};
  Map<String, Map<String, dynamic>> _locationPreferences = {};
  
  // Adaptive learning parameters
  double _learningRate = 0.1;
  int _minDataPoints = 3;
  double _confidenceThreshold = 0.7;

  Future<void> initializeLearning() async {
    await _loadLearningData();
    await _analyzeUserPatterns();
  }

  Future<void> recordUserInteraction({
    required String interactionType,
    required Map<String, dynamic> context,
    double? satisfactionScore,
  }) async {
    final timestamp = DateTime.now();
    
    // Record the interaction in service journey
    final serviceType = context['serviceType'] as String?;
    if (serviceType != null) {
      _serviceJourney[serviceType] = _serviceJourney[serviceType] ?? [];
      _serviceJourney[serviceType]!.add({
        'type': interactionType,
        'context': context,
        'timestamp': timestamp,
        'satisfaction': satisfactionScore,
      });
      
      // Keep only last 20 interactions per service
      if (_serviceJourney[serviceType]!.length > 20) {
        _serviceJourney[serviceType]!.removeAt(0);
      }
    }
    
    // Update behavior patterns
    await _updateBehaviorPatterns(interactionType, context, satisfactionScore);
    
    // Update contextual patterns
    await _updateContextualPatterns(context, timestamp);
    
    // Update timing patterns
    await _updateTimingPatterns(serviceType, timestamp);
    
    // Analyze and generate insights
    await _generateLearningInsights();
    
    await _saveLearningData();
  }

  Future<void> _updateBehaviorPatterns(
    String interactionType,
    Map<String, dynamic> context,
    double? satisfactionScore,
  ) async {
    // Learn from user preferences
    final preferences = [
      'budget_preference',
      'speed_preference', 
      'quality_preference',
      'convenience_preference',
    ];
    
    for (final pref in preferences) {
      if (context.containsKey(pref)) {
        final value = context[pref] as double;
        _preferenceLearning[pref] = (_preferenceLearning[pref] ?? 0.5) * (1 - _learningRate) + 
                                   value * _learningRate;
      }
    }
    
    // Learn from satisfaction
    if (satisfactionScore != null) {
      final serviceType = context['serviceType'] as String?;
      if (serviceType != null) {
        _satisfactionScores[serviceType] = (_satisfactionScores[serviceType] ?? 0.5) * (1 - _learningRate) + 
                                         satisfactionScore * _learningRate;
      }
    }
    
    // Learn interaction patterns
    _userBehaviorPatterns[interactionType] = _userBehaviorPatterns[interactionType] ?? {};
    for (final entry in context.entries) {
      if (entry.value is num) {
        final key = entry.key;
        final value = (entry.value as num).toDouble();
        _userBehaviorPatterns[interactionType]![key] = 
            (_userBehaviorPatterns[interactionType]![key] ?? 0.5) * (1 - _learningRate) + 
            value * _learningRate;
      }
    }
  }

  Future<void> _updateContextualPatterns(Map<String, dynamic> context, DateTime timestamp) async {
    final hour = timestamp.hour;
    final dayOfWeek = timestamp.weekday;
    final month = timestamp.month;
    
    // Time-based patterns
    _contextualPatterns['hourly'] = _contextualPatterns['hourly'] ?? {};
    _contextualPatterns['daily'] = _contextualPatterns['daily'] ?? {};
    _contextualPatterns['monthly'] = _contextualPatterns['monthly'] ?? {};
    
    _contextualPatterns['hourly']![hour.toString()] = 
        (_contextualPatterns['hourly']![hour.toString()] ?? 0) + 1;
    _contextualPatterns['daily']![dayOfWeek.toString()] = 
        (_contextualPatterns['daily']![dayOfWeek.toString()] ?? 0) + 1;
    _contextualPatterns['monthly']![month.toString()] = 
        (_contextualPatterns['monthly']![month.toString()] ?? 0) + 1;
    
    // Location patterns
    final location = context['location'] as String?;
    if (location != null) {
      _contextualPatterns['location'] = _contextualPatterns['location'] ?? {};
      _contextualPatterns['location']![location] = 
          (_contextualPatterns['location']![location] ?? 0) + 1;
    }
  }

  Future<void> _updateTimingPatterns(String? serviceType, DateTime timestamp) async {
    if (serviceType == null) return;
    
    _serviceTimingPatterns[serviceType] = _serviceTimingPatterns[serviceType] ?? [];
    _serviceTimingPatterns[serviceType]!.add(timestamp);
    
    // Keep only last 50 timestamps
    if (_serviceTimingPatterns[serviceType]!.length > 50) {
      _serviceTimingPatterns[serviceType]!.removeAt(0);
    }
  }

  Future<void> _analyzeUserPatterns() async {
    await _analyzeHabitPatterns();
    await _analyzeSeasonalPreferences();
    await _analyzeLocationPreferences();
  }

  Future<void> _analyzeHabitPatterns() async {
    for (final entry in _serviceTimingPatterns.entries) {
      final serviceType = entry.key;
      final timestamps = entry.value;
      
      if (timestamps.length < _minDataPoints) continue;
      
      // Analyze time patterns
      final hours = timestamps.map((t) => t.hour).toList();
      final days = timestamps.map((t) => t.weekday).toList();
      
      // Find most common hour
      final hourCounts = <int, int>{};
      for (final hour in hours) {
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
      final mostCommonHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      
      // Find most common day
      final dayCounts = <int, int>{};
      for (final day in days) {
        dayCounts[day] = (dayCounts[day] ?? 0) + 1;
      }
      final mostCommonDay = dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      
      // Calculate frequency and consistency
      final totalBookings = timestamps.length;
      final hourConsistency = mostCommonHour.value / totalBookings;
      final dayConsistency = mostCommonDay.value / totalBookings;
      
      _habitPatterns[serviceType] = {
        'preferredHour': mostCommonHour.key,
        'preferredDay': mostCommonDay.key,
        'hourConsistency': hourConsistency,
        'dayConsistency': dayConsistency,
        'frequency': _calculateFrequency(timestamps),
        'lastUsed': timestamps.last,
        'totalUsage': totalBookings,
      };
    }
  }

  double _calculateFrequency(List<DateTime> timestamps) {
    if (timestamps.length < 2) return 0.0;
    
    final intervals = <int>[];
    for (int i = 1; i < timestamps.length; i++) {
      intervals.add(timestamps[i].difference(timestamps[i-1]).inDays);
    }
    
    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    return 1.0 / (avgInterval + 1); // Higher frequency = shorter intervals
  }

  Future<void> _analyzeSeasonalPreferences() async {
    for (final entry in _serviceTimingPatterns.entries) {
      final serviceType = entry.key;
      final timestamps = entry.value;
      
      final monthCounts = <int, int>{};
      for (final timestamp in timestamps) {
        monthCounts[timestamp.month] = (monthCounts[timestamp.month] ?? 0) + 1;
      }
      
      // Calculate seasonal preference (0-1 scale)
      final totalBookings = timestamps.length;
      for (final month in monthCounts.keys) {
        final preference = monthCounts[month]! / totalBookings;
        _seasonalPreferences['${serviceType}_month_$month'] = preference;
      }
    }
  }

  Future<void> _analyzeLocationPreferences() async {
    final locationData = _contextualPatterns['location'] ?? {};
    final totalInteractions = locationData.values.fold<int>(0, (sum, count) => sum + count);
    
    if (totalInteractions == 0) return;
    
    for (final entry in locationData.entries) {
      final location = entry.key;
      final count = entry.value;
      final preference = count / totalInteractions;
      
      _locationPreferences[location] = {
        'preference': preference,
        'usage_count': count,
        'confidence': min(1.0, count / 10.0), // Confidence increases with usage
      };
    }
  }

  Future<void> _generateLearningInsights() async {
    _learningInsights.clear();
    
    // Generate timing insights
    await _generateTimingInsights();
    
    // Generate preference insights
    await _generatePreferenceInsights();
    
    // Generate behavioral insights
    await _generateBehavioralInsights();
    
    // Generate habit insights
    await _generateHabitInsights();
  }

  Future<void> _generateTimingInsights() async {
    for (final entry in _habitPatterns.entries) {
      final serviceType = entry.key;
      final pattern = entry.value;
      
      final hourConsistency = pattern['hourConsistency'] as double;
      final preferredHour = pattern['preferredHour'] as int;
      
      if (hourConsistency > _confidenceThreshold) {
        _learningInsights.add({
          'type': 'timing_pattern',
          'service': serviceType,
          'title': '⏰ Perfect Timing',
          'description': 'You usually book $serviceType around ${_formatHour(preferredHour)}',
          'confidence': hourConsistency,
          'actionable': true,
          'action': 'smart_timing_reminder',
          'data': {
            'hour': preferredHour,
            'service': serviceType,
          },
        });
      }
    }
  }

  Future<void> _generatePreferenceInsights() async {
    for (final entry in _preferenceLearning.entries) {
      final preference = entry.key;
      final value = entry.value;
      
      String description = '';
      String emoji = '📊';
      
      switch (preference) {
        case 'budget_preference':
          if (value < 0.3) {
            description = 'You prefer budget-friendly options';
            emoji = '💰';
          } else if (value > 0.7) {
            description = 'You value premium quality services';
            emoji = '👑';
          }
          break;
        case 'speed_preference':
          if (value > 0.7) {
            description = 'You prioritize fast service delivery';
            emoji = '⚡';
          }
          break;
        case 'quality_preference':
          if (value > 0.8) {
            description = 'Quality is your top priority';
            emoji = '⭐';
          }
          break;
      }
      
      if (description.isNotEmpty) {
        _learningInsights.add({
          'type': 'preference_pattern',
          'preference': preference,
          'title': '$emoji Preference Learned',
          'description': description,
          'confidence': abs(value - 0.5) * 2, // Distance from neutral (0.5)
          'actionable': true,
          'action': 'personalize_recommendations',
          'data': {
            'preference': preference,
            'value': value,
          },
        });
      }
    }
  }

  Future<void> _generateBehavioralInsights() async {
    // Analyze satisfaction patterns
    for (final entry in _satisfactionScores.entries) {
      final serviceType = entry.key;
      final score = entry.value;
      
      if (score > 0.8) {
        _learningInsights.add({
          'type': 'satisfaction_high',
          'service': serviceType,
          'title': '😊 You Love $serviceType',
          'description': 'Your satisfaction with $serviceType is consistently high (${(score * 100).round()}%)',
          'confidence': score,
          'actionable': true,
          'action': 'recommend_similar_services',
          'data': {
            'service': serviceType,
            'score': score,
          },
        });
      } else if (score < 0.4) {
        _learningInsights.add({
          'type': 'satisfaction_low',
          'service': serviceType,
          'title': '🤔 Let\\'s Improve $serviceType',
          'description': 'We\\'ve noticed lower satisfaction with $serviceType. Let us help you find better options.',
          'confidence': 1.0 - score,
          'actionable': true,
          'action': 'improve_service_experience',
          'data': {
            'service': serviceType,
            'score': score,
          },
        });
      }
    }
  }

  Future<void> _generateHabitInsights() async {
    for (final entry in _habitPatterns.entries) {
      final serviceType = entry.key;
      final pattern = entry.value;
      
      final frequency = pattern['frequency'] as double;
      final totalUsage = pattern['totalUsage'] as int;
      
      if (frequency > 0.5 && totalUsage >= 5) {
        _learningInsights.add({
          'type': 'habit_formed',
          'service': serviceType,
          'title': '🔄 $serviceType Habit Detected',
          'description': 'You\\'ve established a regular pattern with $serviceType. We can help automate this!',
          'confidence': frequency,
          'actionable': true,
          'action': 'suggest_automation',
          'data': {
            'service': serviceType,
            'frequency': frequency,
            'pattern': pattern,
          },
        });
      }
    }
  }

  // Prediction methods
  List<Map<String, dynamic>> predictNextNeeds() {
    final predictions = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (final entry in _habitPatterns.entries) {
      final serviceType = entry.key;
      final pattern = entry.value;
      
      final preferredHour = pattern['preferredHour'] as int;
      final frequency = pattern['frequency'] as double;
      final lastUsed = pattern['lastUsed'] as DateTime;
      final hourConsistency = pattern['hourConsistency'] as double;
      
      // Predict if user is likely to need this service soon
      final daysSinceLastUse = now.difference(lastUsed).inDays;
      final expectedInterval = 1.0 / frequency;
      
      if (daysSinceLastUse >= expectedInterval * 0.8 && hourConsistency > 0.5) {
        final hoursUntilPreferredTime = _calculateHoursUntilPreferredTime(preferredHour);
        
        predictions.add({
          'service': serviceType,
          'probability': min(1.0, frequency * hourConsistency),
          'recommended_time': now.add(Duration(hours: hoursUntilPreferredTime)),
          'reason': 'Based on your ${serviceType.toLowerCase()} pattern',
          'confidence': hourConsistency,
          'urgency': daysSinceLastUse > expectedInterval ? 'high' : 'medium',
        });
      }
    }
    
    // Sort by probability
    predictions.sort((a, b) => b['probability'].compareTo(a['probability']));
    
    return predictions.take(3).toList();
  }

  int _calculateHoursUntilPreferredTime(int preferredHour) {
    final now = DateTime.now();
    final todayPreferred = DateTime(now.year, now.month, now.day, preferredHour);
    
    if (todayPreferred.isAfter(now)) {
      return todayPreferred.difference(now).inHours;
    } else {
      final tomorrowPreferred = todayPreferred.add(const Duration(days: 1));
      return tomorrowPreferred.difference(now).inHours;
    }
  }

  Map<String, dynamic> getPersonalizedTimingRecommendation(String serviceType) {
    final pattern = _habitPatterns[serviceType];
    if (pattern == null) {
      return {
        'recommended_time': null,
        'confidence': 0.0,
        'reason': 'Not enough data to recommend timing',
      };
    }
    
    final preferredHour = pattern['preferredHour'] as int;
    final hourConsistency = pattern['hourConsistency'] as double;
    
    return {
      'recommended_time': preferredHour,
      'confidence': hourConsistency,
      'reason': 'Based on your booking history, you usually prefer ${_formatHour(preferredHour)}',
      'alternative_times': _getAlternativeTimes(preferredHour),
    };
  }

  List<int> _getAlternativeTimes(int preferredHour) {
    return [
      (preferredHour - 1) % 24,
      (preferredHour + 1) % 24,
      (preferredHour - 2) % 24,
      (preferredHour + 2) % 24,
    ];
  }

  double getServiceAffinityScore(String serviceType) {
    final satisfaction = _satisfactionScores[serviceType] ?? 0.5;
    final usage = _habitPatterns[serviceType]?['frequency'] ?? 0.0;
    final recentUsage = _habitPatterns[serviceType]?['totalUsage'] ?? 0;
    
    // Combine satisfaction, usage frequency, and recency
    return (satisfaction * 0.5) + (usage * 0.3) + (min(1.0, recentUsage / 10.0) * 0.2);
  }

  List<Map<String, dynamic>> getLearningInsights() {
    return _learningInsights
        .where((insight) => insight['confidence'] > _confidenceThreshold)
        .toList()
      ..sort((a, b) => b['confidence'].compareTo(a['confidence']));
  }

  Map<String, dynamic> getUserLearningProfile() {
    return {
      'total_interactions': _calculateTotalInteractions(),
      'learning_progress': _calculateLearningProgress(),
      'habit_strength': _calculateOverallHabitStrength(),
      'preference_clarity': _calculatePreferenceClarity(),
      'insights_available': _learningInsights.length,
      'services_learned': _habitPatterns.keys.length,
      'top_preferences': _getTopPreferences(),
      'next_predictions': predictNextNeeds(),
    };
  }

  int _calculateTotalInteractions() {
    return _serviceJourney.values
        .map((journey) => journey.length)
        .fold(0, (sum, count) => sum + count);
  }

  double _calculateLearningProgress() {
    final totalServices = _serviceJourney.keys.length;
    final learnedServices = _habitPatterns.keys.length;
    return totalServices == 0 ? 0.0 : learnedServices / totalServices;
  }

  double _calculateOverallHabitStrength() {
    if (_habitPatterns.isEmpty) return 0.0;
    
    final strengths = _habitPatterns.values
        .map((pattern) => pattern['frequency'] as double)
        .toList();
    
    return strengths.reduce((a, b) => a + b) / strengths.length;
  }

  double _calculatePreferenceClarity() {
    if (_preferenceLearning.isEmpty) return 0.0;
    
    final clarities = _preferenceLearning.values
        .map((value) => abs(value - 0.5) * 2) // Distance from neutral
        .toList();
    
    return clarities.reduce((a, b) => a + b) / clarities.length;
  }

  List<Map<String, dynamic>> _getTopPreferences() {
    return _preferenceLearning.entries
        .map((entry) => {
              'preference': entry.key,
              'value': entry.value,
              'strength': abs(entry.value - 0.5) * 2,
            })
        .where((pref) => pref['strength'] > 0.3)
        .toList()
      ..sort((a, b) => b['strength'].compareTo(a['strength']))
      ..take(3);
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  // Data persistence
  Future<void> _saveLearningData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'userBehaviorPatterns': _userBehaviorPatterns,
      'serviceJourney': _serviceJourney.map((key, value) => MapEntry(key, value.map((item) {
        final Map<String, dynamic> serializable = Map.from(item);
        serializable['timestamp'] = (item['timestamp'] as DateTime).millisecondsSinceEpoch;
        return serializable;
      }).toList())),
      'preferenceLearning': _preferenceLearning,
      'contextualPatterns': _contextualPatterns,
      'satisfactionScores': _satisfactionScores,
      'habitPatterns': _habitPatterns.map((key, value) {
        final Map<String, dynamic> serializable = Map.from(value);
        serializable['lastUsed'] = (value['lastUsed'] as DateTime).millisecondsSinceEpoch;
        return MapEntry(key, serializable);
      }),
      'serviceTimingPatterns': _serviceTimingPatterns.map((key, value) => 
          MapEntry(key, value.map((dt) => dt.millisecondsSinceEpoch).toList())),
      'seasonalPreferences': _seasonalPreferences,
      'locationPreferences': _locationPreferences,
    };
    await prefs.setString('learning_data', json.encode(data));
  }

  Future<void> _loadLearningData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('learning_data');
    if (dataString != null) {
      final data = Map<String, dynamic>.from(json.decode(dataString));
      
      _userBehaviorPatterns = (data['userBehaviorPatterns'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, Map<String, double>.from(value))) ?? {};
      
      _preferenceLearning = Map<String, double>.from(data['preferenceLearning'] ?? {});
      _contextualPatterns = (data['contextualPatterns'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, Map<String, int>.from(value))) ?? {};
      _satisfactionScores = Map<String, double>.from(data['satisfactionScores'] ?? {});
      _seasonalPreferences = Map<String, double>.from(data['seasonalPreferences'] ?? {});
      _locationPreferences = (data['locationPreferences'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value))) ?? {};
      
      // Restore service journey
      final journeyData = data['serviceJourney'] as Map<String, dynamic>?;
      if (journeyData != null) {
        _serviceJourney = journeyData.map((key, value) => MapEntry(key, 
            (value as List<dynamic>).map((item) {
              final Map<String, dynamic> restored = Map.from(item);
              restored['timestamp'] = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
              return restored;
            }).toList()
        ));
      }
      
      // Restore habit patterns
      final habitsData = data['habitPatterns'] as Map<String, dynamic>?;
      if (habitsData != null) {
        _habitPatterns = habitsData.map((key, value) {
          final Map<String, dynamic> restored = Map.from(value);
          restored['lastUsed'] = DateTime.fromMillisecondsSinceEpoch(value['lastUsed']);
          return MapEntry(key, restored);
        });
      }
      
      // Restore timing patterns
      final timingData = data['serviceTimingPatterns'] as Map<String, dynamic>?;
      if (timingData != null) {
        _serviceTimingPatterns = timingData.map((key, value) => MapEntry(key,
            (value as List<dynamic>).map((timestamp) => 
                DateTime.fromMillisecondsSinceEpoch(timestamp)).toList()
        ));
      }
    }
  }
}