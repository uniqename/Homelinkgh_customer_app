import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // User progress tracking
  int _currentPoints = 0;
  int _currentLevel = 1;
  int _totalBookings = 0;
  int _streakDays = 0;
  DateTime? _lastBookingDate;
  Map<String, int> _serviceExperiencePoints = {};
  List<String> _unlockedBadges = [];
  List<String> _availableRewards = [];
  Map<String, DateTime> _rewardsClaimed = {};
  
  // Achievement definitions
  final Map<String, Map<String, dynamic>> _achievements = {
    'first_booking': {
      'title': '🎉 First Steps',
      'description': 'Complete your first booking',
      'points': 100,
      'type': 'milestone',
      'threshold': 1,
    },
    'frequent_user': {
      'title': '⭐ Regular Customer',
      'description': 'Complete 5 bookings',
      'points': 250,
      'type': 'milestone',
      'threshold': 5,
    },
    'loyal_customer': {
      'title': '👑 Loyal Member',
      'description': 'Complete 20 bookings',
      'points': 500,
      'type': 'milestone',
      'threshold': 20,
    },
    'service_explorer': {
      'title': '🌟 Service Explorer',
      'description': 'Try 5 different service types',
      'points': 300,
      'type': 'diversity',
      'threshold': 5,
    },
    'early_bird': {
      'title': '🌅 Early Bird',
      'description': 'Book 3 services before 9 AM',
      'points': 150,
      'type': 'time_based',
      'threshold': 3,
    },
    'weekend_warrior': {
      'title': '🎯 Weekend Warrior',
      'description': 'Book 5 weekend services',
      'points': 200,
      'type': 'time_based',
      'threshold': 5,
    },
    'streak_master': {
      'title': '🔥 Streak Master',
      'description': 'Book services 7 days in a row',
      'points': 400,
      'type': 'streak',
      'threshold': 7,
    },
    'premium_seeker': {
      'title': '💎 Premium Seeker',
      'description': 'Book 5 premium services',
      'points': 350,
      'type': 'premium',
      'threshold': 5,
    },
    'budget_master': {
      'title': '💰 Budget Master',
      'description': 'Save GH₵500 with deals',
      'points': 250,
      'type': 'savings',
      'threshold': 500,
    },
    'reviewer': {
      'title': '📝 Helpful Reviewer',
      'description': 'Leave 10 helpful reviews',
      'points': 200,
      'type': 'community',
      'threshold': 10,
    },
  };

  // Level requirements
  final Map<int, Map<String, dynamic>> _levelRequirements = {
    1: {'points': 0, 'title': 'Newcomer', 'benefits': ['Welcome bonus', 'Basic support']},
    2: {'points': 500, 'title': 'Explorer', 'benefits': ['5% discount', 'Priority support']},
    3: {'points': 1500, 'title': 'Regular', 'benefits': ['10% discount', 'Free delivery']},
    4: {'points': 3000, 'title': 'Valued', 'benefits': ['15% discount', 'Express service']},
    5: {'points': 5000, 'title': 'Premium', 'benefits': ['20% discount', 'VIP support']},
    6: {'points': 8000, 'title': 'Elite', 'benefits': ['25% discount', 'Concierge service']},
    7: {'points': 12000, 'title': 'Champion', 'benefits': ['30% discount', 'Personal assistant']},
  };

  // Reward definitions
  final Map<String, Map<String, dynamic>> _rewards = {
    'free_delivery': {
      'title': '🚚 Free Delivery',
      'description': 'Free delivery for your next order',
      'cost': 200,
      'type': 'service_bonus',
      'validity_days': 30,
    },
    'discount_10': {
      'title': '💰 10% Discount',
      'description': '10% off your next booking',
      'cost': 300,
      'type': 'percentage_discount',
      'value': 0.10,
      'validity_days': 30,
    },
    'discount_20': {
      'title': '💸 20% Discount',
      'description': '20% off your next booking',
      'cost': 500,
      'type': 'percentage_discount',
      'value': 0.20,
      'validity_days': 30,
    },
    'priority_booking': {
      'title': '⚡ Priority Booking',
      'description': 'Skip the queue for 7 days',
      'cost': 400,
      'type': 'service_enhancement',
      'validity_days': 7,
    },
    'cashback_50': {
      'title': '💳 GH₵50 Cashback',
      'description': 'GH₵50 credit for future bookings',
      'cost': 800,
      'type': 'cashback',
      'value': 50,
      'validity_days': 90,
    },
    'premium_upgrade': {
      'title': '✨ Premium Upgrade',
      'description': 'Free upgrade to premium service',
      'cost': 600,
      'type': 'service_upgrade',
      'validity_days': 30,
    },
  };

  Future<void> initializeGamification() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('gamification_data');
    if (data != null) {
      await _loadGamificationData();
    } else {
      // Initialize new user
      await _saveGamificationData();
    }
  }

  Future<void> recordBooking({
    required String serviceType,
    required double amount,
    required bool isPremium,
    required DateTime bookingTime,
  }) async {
    _totalBookings++;
    _updateStreak(bookingTime);
    
    // Calculate points for this booking
    int basePoints = 50; // Base points per booking
    int bonusPoints = 0;
    
    // Time-based bonuses
    final hour = bookingTime.hour;
    if (hour < 9) {
      bonusPoints += 25; // Early bird bonus
      await _checkAchievement('early_bird');
    }
    
    // Weekend bonus
    if (bookingTime.weekday == 6 || bookingTime.weekday == 7) {
      bonusPoints += 20;
      await _checkAchievement('weekend_warrior');
    }
    
    // Premium service bonus
    if (isPremium) {
      bonusPoints += 30;
      await _checkAchievement('premium_seeker');
    }
    
    // Service experience points
    _serviceExperiencePoints[serviceType] = (_serviceExperiencePoints[serviceType] ?? 0) + 1;
    
    // Add points
    final totalPoints = basePoints + bonusPoints;
    await addPoints(totalPoints);
    
    // Check achievements
    await _checkAchievement('first_booking');
    await _checkAchievement('frequent_user');
    await _checkAchievement('loyal_customer');
    await _checkAchievement('service_explorer');
    await _checkAchievement('streak_master');
    
    await _saveGamificationData();
  }

  Future<void> addPoints(int points) async {
    _currentPoints += points;
    await _checkLevelUp();
  }

  Future<void> _checkLevelUp() async {
    final nextLevel = _currentLevel + 1;
    final nextLevelReq = _levelRequirements[nextLevel];
    
    if (nextLevelReq != null && _currentPoints >= (nextLevelReq['points'] as int)) {
      _currentLevel = nextLevel;
      
      // Level up rewards
      final levelUpBonus = nextLevel * 100;
      _currentPoints += levelUpBonus;
      
      // Show level up notification would go here
      await _saveGamificationData();
    }
  }

  Future<void> _checkAchievement(String achievementId) async {
    if (_unlockedBadges.contains(achievementId)) return;
    
    final achievement = _achievements[achievementId];
    if (achievement == null) return;
    
    bool unlocked = false;
    
    switch (achievement['type']) {
      case 'milestone':
        unlocked = _totalBookings >= achievement['threshold'];
        break;
      case 'diversity':
        unlocked = _serviceExperiencePoints.keys.length >= achievement['threshold'];
        break;
      case 'streak':
        unlocked = _streakDays >= achievement['threshold'];
        break;
      case 'time_based':
        // These are checked during booking with specific conditions
        unlocked = true; // Already validated when called
        break;
    }
    
    if (unlocked) {
      _unlockedBadges.add(achievementId);
      _currentPoints += (achievement['points'] as int);
      await _checkLevelUp();
    }
  }

  void _updateStreak(DateTime bookingTime) {
    if (_lastBookingDate == null) {
      _streakDays = 1;
    } else {
      final daysDifference = bookingTime.difference(_lastBookingDate!).inDays;
      if (daysDifference == 1) {
        _streakDays++;
      } else if (daysDifference > 1) {
        _streakDays = 1; // Reset streak
      }
      // Same day bookings don't affect streak
    }
    _lastBookingDate = bookingTime;
  }

  Future<bool> redeemReward(String rewardId) async {
    final reward = _rewards[rewardId];
    if (reward == null) return false;
    
    final cost = reward['cost'] as int;
    if (_currentPoints < cost) return false;
    
    _currentPoints -= cost;
    _rewardsClaimed[rewardId] = DateTime.now();
    
    await _saveGamificationData();
    return true;
  }

  List<Map<String, dynamic>> getAvailableRewards() {
    return _rewards.entries.map((entry) {
      final reward = Map<String, dynamic>.from(entry.value);
      reward['id'] = entry.key;
      reward['canAfford'] = _currentPoints >= reward['cost'];
      reward['alreadyClaimed'] = _rewardsClaimed.containsKey(entry.key);
      return reward;
    }).toList();
  }

  List<Map<String, dynamic>> getRecentAchievements() {
    return _unlockedBadges.take(5).map((badgeId) {
      final achievement = Map<String, dynamic>.from(_achievements[badgeId]!);
      achievement['id'] = badgeId;
      return achievement;
    }).toList();
  }

  List<Map<String, dynamic>> getNextAchievements() {
    final nextAchievements = <Map<String, dynamic>>[];
    
    for (final entry in _achievements.entries) {
      final achievementId = entry.key;
      final achievement = entry.value;
      
      if (_unlockedBadges.contains(achievementId)) continue;
      
      Map<String, dynamic> progress = Map<String, dynamic>.from(achievement);
      progress['id'] = achievementId;
      
      switch (achievement['type']) {
        case 'milestone':
          progress['current'] = _totalBookings;
          progress['progress'] = _totalBookings / achievement['threshold'];
          break;
        case 'diversity':
          progress['current'] = _serviceExperiencePoints.keys.length;
          progress['progress'] = _serviceExperiencePoints.keys.length / achievement['threshold'];
          break;
        case 'streak':
          progress['current'] = _streakDays;
          progress['progress'] = _streakDays / achievement['threshold'];
          break;
        default:
          progress['current'] = 0;
          progress['progress'] = 0.0;
      }
      
      progress['progress'] = (progress['progress'] as double).clamp(0.0, 1.0);
      nextAchievements.add(progress);
    }
    
    // Sort by progress (closest to completion first)
    nextAchievements.sort((a, b) => b['progress'].compareTo(a['progress']));
    
    return nextAchievements.take(3).toList();
  }

  Map<String, dynamic> getUserStats() {
    final currentLevelInfo = _levelRequirements[_currentLevel]!;
    final nextLevelInfo = _levelRequirements[_currentLevel + 1];
    
    int pointsToNextLevel = 0;
    double levelProgress = 1.0;
    
    if (nextLevelInfo != null) {
      pointsToNextLevel = nextLevelInfo['points'] - _currentPoints;
      final currentLevelPoints = currentLevelInfo['points'];
      final nextLevelPoints = nextLevelInfo['points'];
      levelProgress = (_currentPoints - currentLevelPoints) / (nextLevelPoints - currentLevelPoints);
    }
    
    return {
      'points': _currentPoints,
      'level': _currentLevel,
      'levelTitle': currentLevelInfo['title'],
      'levelBenefits': currentLevelInfo['benefits'],
      'pointsToNextLevel': pointsToNextLevel,
      'levelProgress': levelProgress.clamp(0.0, 1.0),
      'totalBookings': _totalBookings,
      'streakDays': _streakDays,
      'badgesCount': _unlockedBadges.length,
      'servicesExplored': _serviceExperiencePoints.keys.length,
      'nextLevelTitle': nextLevelInfo?['title'] ?? 'Max Level',
    };
  }

  String getMotivationalMessage() {
    final userStats = getUserStats();
    final nextAchievements = getNextAchievements();
    
    final messages = [
      '🎯 You\'re just ${userStats['pointsToNextLevel']} points away from ${userStats['nextLevelTitle']}!',
      '🔥 Keep your ${_streakDays}-day streak going!',
      '🚀 Level ${_currentLevel} ${userStats['levelTitle']} - you\'re doing amazing!',
      '💪 ${userStats['badgesCount']} badges earned - collect them all!',
    ];
    
    if (nextAchievements.isNotEmpty) {
      messages.add('⭐ ${nextAchievements.first['title']} is almost yours!');
    }
    
    if (_streakDays == 0) {
      return '✨ Start your journey with your first booking today!';
    }
    
    return messages[Random().nextInt(messages.length)];
  }

  Future<void> _saveGamificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'currentPoints': _currentPoints,
      'currentLevel': _currentLevel,
      'totalBookings': _totalBookings,
      'streakDays': _streakDays,
      'lastBookingDate': _lastBookingDate?.millisecondsSinceEpoch,
      'serviceExperiencePoints': _serviceExperiencePoints,
      'unlockedBadges': _unlockedBadges,
      'rewardsClaimed': _rewardsClaimed.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
    };
    await prefs.setString('gamification_data', json.encode(data));
  }

  Future<void> _loadGamificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('gamification_data');
    if (dataString != null) {
      final data = Map<String, dynamic>.from(json.decode(dataString));
      
      _currentPoints = data['currentPoints'] ?? 0;
      _currentLevel = data['currentLevel'] ?? 1;
      _totalBookings = data['totalBookings'] ?? 0;
      _streakDays = data['streakDays'] ?? 0;
      _lastBookingDate = data['lastBookingDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['lastBookingDate'])
          : null;
      _serviceExperiencePoints = Map<String, int>.from(data['serviceExperiencePoints'] ?? {});
      _unlockedBadges = List<String>.from(data['unlockedBadges'] ?? []);
      
      final rewardsData = data['rewardsClaimed'] ?? {};
      _rewardsClaimed = rewardsData.map<String, DateTime>(
        (key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value))
      );
    }
  }

  // Getters
  int get currentPoints => _currentPoints;
  int get currentLevel => _currentLevel;
  int get totalBookings => _totalBookings;
  int get streakDays => _streakDays;
  List<String> get unlockedBadges => _unlockedBadges;
}