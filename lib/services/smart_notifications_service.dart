import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_personalization_service.dart';
import 'gamification_service.dart';

// Notification types
enum NotificationType {
  smartRecommendation,
  timeBased,
  achievement,
  reward,
  streak,
  levelUp,
  deal,
  engagement,
  reminder,
  weather,
  location,
}

class SmartNotificationsService {
  static final SmartNotificationsService _instance = SmartNotificationsService._internal();
  factory SmartNotificationsService() => _instance;
  SmartNotificationsService._internal();

  final SmartPersonalizationService _personalization = SmartPersonalizationService();
  final GamificationService _gamification = GamificationService();
  
  List<Map<String, dynamic>> _activeNotifications = [];
  List<Map<String, dynamic>> _notificationHistory = [];
  Map<String, DateTime> _lastNotificationSent = {};

  Future<void> initializeNotifications() async {
    await _loadNotificationData();
    await _scheduleSmartNotifications();
  }

  Future<void> _scheduleSmartNotifications() async {
    final now = DateTime.now();
    
    // Morning motivation (8 AM)
    if (now.hour == 8 && !_wasNotificationSentToday('morning_motivation')) {
      await _createMorningMotivation();
    }
    
    // Lunch time suggestion (12 PM)
    if (now.hour == 12 && !_wasNotificationSentToday('lunch_suggestion')) {
      await _createLunchSuggestion();
    }
    
    // Evening reminder (6 PM)
    if (now.hour == 18 && !_wasNotificationSentToday('evening_reminder')) {
      await _createEveningReminder();
    }
    
    // Weekend planning (Friday 5 PM)
    if (now.weekday == 5 && now.hour == 17 && !_wasNotificationSentToday('weekend_planning')) {
      await _createWeekendPlanning();
    }
    
    // Check for achievement notifications
    await _checkAchievementNotifications();
    
    // Check for engagement notifications
    await _checkEngagementNotifications();
    
    // Check for streak notifications
    await _checkStreakNotifications();
  }

  Future<void> _createMorningMotivation() async {
    final userStats = _gamification.getUserStats();
    final motivationalMessage = _gamification.getMotivationalMessage();
    
    final notification = {
      'id': 'morning_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.engagement.toString(),
      'title': '🌅 Good Morning!',
      'body': motivationalMessage,
      'priority': 'medium',
      'category': 'motivation',
      'actionable': true,
      'actions': [
        {'label': 'Book Service', 'action': 'open_booking'},
        {'label': 'View Rewards', 'action': 'open_rewards'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'level': userStats['level'],
        'points': userStats['points'],
      }
    };
    
    await _addNotification(notification);
    _lastNotificationSent['morning_motivation'] = DateTime.now();
  }

  Future<void> _createLunchSuggestion() async {
    final personalityType = _personalization.userPersonalityType;
    final predictedNeeds = _personalization.predictedNeeds;
    
    String title = '🍽️ Lunch Time!';
    String body = 'Perfect time to order your favorite meal';
    
    if (predictedNeeds.contains('Food Delivery') || predictedNeeds.contains('Lunch Delivery')) {
      switch (personalityType) {
        case 'budget_conscious':
          body = 'Great lunch deals under GH₵50 available now!';
          break;
        case 'premium_seeker':
          body = 'Premium restaurants are ready to serve you';
          break;
        case 'efficiency_focused':
          body = 'Quick delivery options - food in 20 minutes!';
          break;
        case 'explorer':
          body = 'Try a new cuisine today - adventure awaits!';
          break;
      }
    }
    
    final notification = {
      'id': 'lunch_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.timeBased.toString(),
      'title': title,
      'body': body,
      'priority': 'high',
      'category': 'suggestion',
      'actionable': true,
      'actions': [
        {'label': 'Order Food', 'action': 'book_food_delivery'},
        {'label': 'View Menu', 'action': 'browse_food'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'serviceType': 'Food Delivery',
        'personalityType': personalityType,
      }
    };
    
    await _addNotification(notification);
    _lastNotificationSent['lunch_suggestion'] = DateTime.now();
  }

  Future<void> _createEveningReminder() async {
    final recentSearches = _personalization.recentSearches;
    final predictedNeeds = _personalization.predictedNeeds;
    
    String title = '🌆 Evening Plans?';
    String body = 'End your day with relaxing services';
    
    if (predictedNeeds.isNotEmpty) {
      final topNeed = predictedNeeds.first;
      body = 'Perfect time for $topNeed - let us help you unwind';
    }
    
    final notification = {
      'id': 'evening_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.timeBased.toString(),
      'title': title,
      'body': body,
      'priority': 'medium',
      'category': 'reminder',
      'actionable': true,
      'actions': [
        {'label': 'Browse Services', 'action': 'open_services'},
        {'label': 'Book Now', 'action': 'open_booking'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'timeContext': 'evening',
        'predictedNeeds': predictedNeeds,
      }
    };
    
    await _addNotification(notification);
    _lastNotificationSent['evening_reminder'] = DateTime.now();
  }

  Future<void> _createWeekendPlanning() async {
    final notification = {
      'id': 'weekend_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.timeBased.toString(),
      'title': '🎉 Weekend Ready?',
      'body': 'Plan your perfect weekend with house cleaning, beauty services, and more!',
      'priority': 'high',
      'category': 'planning',
      'actionable': true,
      'actions': [
        {'label': 'Plan Weekend', 'action': 'weekend_planning'},
        {'label': 'View Deals', 'action': 'weekend_deals'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'context': 'weekend_preparation',
      }
    };
    
    await _addNotification(notification);
    _lastNotificationSent['weekend_planning'] = DateTime.now();
  }

  Future<void> _checkAchievementNotifications() async {
    final nextAchievements = _gamification.getNextAchievements();
    
    for (final achievement in nextAchievements) {
      final progress = achievement['progress'] as double;
      final achievementId = achievement['id'] as String;
      
      // Notify when user is close to achievement (80% progress)
      if (progress >= 0.8 && !_wasNotificationSentToday('achievement_$achievementId')) {
        final notification = {
          'id': 'achievement_${achievementId}_${DateTime.now().millisecondsSinceEpoch}',
          'type': NotificationType.achievement.toString(),
          'title': '🏆 Almost There!',
          'body': '${achievement['title']} is almost yours! ${(progress * 100).round()}% complete',
          'priority': 'high',
          'category': 'achievement',
          'actionable': true,
          'actions': [
            {'label': 'Complete Now', 'action': 'complete_achievement'},
            {'label': 'View Progress', 'action': 'view_achievements'},
          ],
          'timestamp': DateTime.now(),
          'userData': {
            'achievementId': achievementId,
            'progress': progress,
            'points': achievement['points'],
          }
        };
        
        await _addNotification(notification);
        _lastNotificationSent['achievement_$achievementId'] = DateTime.now();
      }
    }
  }

  Future<void> _checkEngagementNotifications() async {
    final lastBookingDate = DateTime.now().subtract(const Duration(days: 7)); // Simulate last booking
    final daysSinceLastBooking = DateTime.now().difference(lastBookingDate).inDays;
    
    // Re-engagement notifications
    if (daysSinceLastBooking >= 3 && !_wasNotificationSentToday('reengagement')) {
      final notification = {
        'id': 'reengagement_${DateTime.now().millisecondsSinceEpoch}',
        'type': NotificationType.engagement.toString(),
        'title': '👋 We Miss You!',
        'body': 'Special 20% discount waiting for you - come back and save!',
        'priority': 'high',
        'category': 'reengagement',
        'actionable': true,
        'actions': [
          {'label': 'Claim Discount', 'action': 'claim_return_discount'},
          {'label': 'Browse Services', 'action': 'browse_services'},
        ],
        'timestamp': DateTime.now(),
        'userData': {
          'daysSinceLastBooking': daysSinceLastBooking,
          'discountPercent': 20,
        }
      };
      
      await _addNotification(notification);
      _lastNotificationSent['reengagement'] = DateTime.now();
    }
  }

  Future<void> _checkStreakNotifications() async {
    final streakDays = _gamification.streakDays;
    
    // Celebrate streak milestones
    if ([3, 7, 14, 30].contains(streakDays) && !_wasNotificationSentToday('streak_$streakDays')) {
      String emoji = '🔥';
      String title = 'Streak Master!';
      
      switch (streakDays) {
        case 3:
          emoji = '🔥';
          title = 'Hot Streak!';
          break;
        case 7:
          emoji = '⚡';
          title = 'Week Warrior!';
          break;
        case 14:
          emoji = '💪';
          title = 'Two Week Champion!';
          break;
        case 30:
          emoji = '👑';
          title = 'Monthly Master!';
          break;
      }
      
      final notification = {
        'id': 'streak_${streakDays}_${DateTime.now().millisecondsSinceEpoch}',
        'type': NotificationType.streak.toString(),
        'title': '$emoji $title',
        'body': '$streakDays days straight! You\'re on fire! Bonus points earned.',
        'priority': 'high',
        'category': 'celebration',
        'actionable': true,
        'actions': [
          {'label': 'Keep Going', 'action': 'continue_streak'},
          {'label': 'Share Achievement', 'action': 'share_streak'},
        ],
        'timestamp': DateTime.now(),
        'userData': {
          'streakDays': streakDays,
          'bonusPoints': streakDays * 10,
        }
      };
      
      await _addNotification(notification);
      _lastNotificationSent['streak_$streakDays'] = DateTime.now();
    }
  }

  Future<void> createSmartRecommendationNotification(Map<String, dynamic> recommendation) async {
    final notification = {
      'id': 'smart_rec_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.smartRecommendation.toString(),
      'title': '🤖 ${recommendation['title']}',
      'body': recommendation['subtitle'],
      'priority': 'medium',
      'category': 'recommendation',
      'actionable': true,
      'actions': [
        {'label': 'Book Now', 'action': 'book_recommendation'},
        {'label': 'Learn More', 'action': 'view_recommendation'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'recommendation': recommendation,
        'aiConfidence': recommendation['aiConfidence'],
      }
    };
    
    await _addNotification(notification);
  }

  Future<void> createWeatherBasedNotification(String weather, List<String> suggestedServices) async {
    if (_wasNotificationSentToday('weather_$weather')) return;
    
    String title = '☀️ Perfect Weather!';
    String body = 'Great day for outdoor services';
    
    switch (weather) {
      case 'sunny':
        title = '☀️ Sunny Day!';
        body = 'Perfect for outdoor cleaning and landscaping';
        break;
      case 'rainy':
        title = '🌧️ Rainy Day';
        body = 'Stay cozy - we\'ll handle the outdoor work';
        break;
      case 'hot':
        title = '🔥 Hot Day!';
        body = 'Beat the heat with indoor services and cold delivery';
        break;
    }
    
    final notification = {
      'id': 'weather_${weather}_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.weather.toString(),
      'title': title,
      'body': body,
      'priority': 'medium',
      'category': 'weather',
      'actionable': true,
      'actions': [
        {'label': 'View Services', 'action': 'weather_services'},
        {'label': 'Book Now', 'action': 'book_weather_service'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'weather': weather,
        'suggestedServices': suggestedServices,
      }
    };
    
    await _addNotification(notification);
    _lastNotificationSent['weather_$weather'] = DateTime.now();
  }

  Future<void> createLevelUpNotification(int newLevel, String levelTitle) async {
    final notification = {
      'id': 'levelup_${newLevel}_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.levelUp.toString(),
      'title': '🎉 Level Up!',
      'body': 'Congratulations! You\'re now Level $newLevel: $levelTitle',
      'priority': 'high',
      'category': 'achievement',
      'actionable': true,
      'actions': [
        {'label': 'View Benefits', 'action': 'view_level_benefits'},
        {'label': 'Claim Rewards', 'action': 'claim_level_rewards'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'newLevel': newLevel,
        'levelTitle': levelTitle,
        'bonusPoints': newLevel * 100,
      }
    };
    
    await _addNotification(notification);
  }

  Future<void> createDealNotification(Map<String, dynamic> deal) async {
    final notification = {
      'id': 'deal_${DateTime.now().millisecondsSinceEpoch}',
      'type': NotificationType.deal.toString(),
      'title': '💰 Special Deal!',
      'body': '${deal['discount']} off ${deal['service']} - Limited time!',
      'priority': 'high',
      'category': 'deal',
      'actionable': true,
      'actions': [
        {'label': 'Grab Deal', 'action': 'claim_deal'},
        {'label': 'View Details', 'action': 'view_deal'},
      ],
      'timestamp': DateTime.now(),
      'userData': {
        'deal': deal,
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
      }
    };
    
    await _addNotification(notification);
  }

  Future<void> _addNotification(Map<String, dynamic> notification) async {
    _activeNotifications.add(notification);
    _notificationHistory.add(notification);
    
    // Keep only last 50 notifications in history
    if (_notificationHistory.length > 50) {
      _notificationHistory.removeAt(0);
    }
    
    await _saveNotificationData();
  }

  bool _wasNotificationSentToday(String notificationKey) {
    final lastSent = _lastNotificationSent[notificationKey];
    if (lastSent == null) return false;
    
    final now = DateTime.now();
    return lastSent.year == now.year && 
           lastSent.month == now.month && 
           lastSent.day == now.day;
  }

  Future<void> markAsRead(String notificationId) async {
    for (final notification in _activeNotifications) {
      if (notification['id'] == notificationId) {
        notification['read'] = true;
        notification['readAt'] = DateTime.now();
        break;
      }
    }
    await _saveNotificationData();
  }

  Future<void> dismissNotification(String notificationId) async {
    _activeNotifications.removeWhere((notification) => notification['id'] == notificationId);
    await _saveNotificationData();
  }

  List<Map<String, dynamic>> getActiveNotifications() {
    // Remove old notifications (older than 7 days)
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    _activeNotifications.removeWhere((notification) {
      final timestamp = notification['timestamp'] as DateTime;
      return timestamp.isBefore(cutoffDate);
    });
    
    // Sort by priority and timestamp
    _activeNotifications.sort((a, b) {
      final aPriority = a['priority'] == 'high' ? 3 : (a['priority'] == 'medium' ? 2 : 1);
      final bPriority = b['priority'] == 'high' ? 3 : (b['priority'] == 'medium' ? 2 : 1);
      
      if (aPriority != bPriority) {
        return bPriority.compareTo(aPriority);
      }
      
      final aTime = a['timestamp'] as DateTime;
      final bTime = b['timestamp'] as DateTime;
      return bTime.compareTo(aTime);
    });
    
    return _activeNotifications;
  }

  List<Map<String, dynamic>> getUnreadNotifications() {
    return _activeNotifications.where((notification) => 
        notification['read'] != true).toList();
  }

  int getUnreadCount() {
    return getUnreadNotifications().length;
  }

  Future<void> _saveNotificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'activeNotifications': _activeNotifications.map((notification) {
        final Map<String, dynamic> serializable = Map.from(notification);
        serializable['timestamp'] = (notification['timestamp'] as DateTime).millisecondsSinceEpoch;
        if (notification['readAt'] != null) {
          serializable['readAt'] = (notification['readAt'] as DateTime).millisecondsSinceEpoch;
        }
        return serializable;
      }).toList(),
      'lastNotificationSent': _lastNotificationSent.map((key, value) => 
          MapEntry(key, value.millisecondsSinceEpoch)),
    };
    await prefs.setString('notifications_data', json.encode(data));
  }

  Future<void> _loadNotificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('notifications_data');
    if (dataString != null) {
      final data = Map<String, dynamic>.from(json.decode(dataString));
      
      _activeNotifications = (data['activeNotifications'] as List<dynamic>?)
          ?.map((notification) {
            final Map<String, dynamic> restored = Map.from(notification);
            restored['timestamp'] = DateTime.fromMillisecondsSinceEpoch(notification['timestamp']);
            if (notification['readAt'] != null) {
              restored['readAt'] = DateTime.fromMillisecondsSinceEpoch(notification['readAt']);
            }
            return restored;
          }).toList() ?? [];
      
      final lastSentData = data['lastNotificationSent'] ?? {};
      _lastNotificationSent = lastSentData.map<String, DateTime>(
        (key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value))
      );
    }
  }
}