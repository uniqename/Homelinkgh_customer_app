import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/referral.dart';
import 'firebase_service.dart';
import 'gamification_service.dart';

/// Referral Service for HomeLinkGH Referral Program
/// Manages referral codes, tracking, and rewards
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  final FirebaseService _firebase = FirebaseService();
  final GamificationService _gamification = GamificationService();

  // Referral rewards configuration
  static const double REFERRER_REWARD = 40.0; // GHS
  static const double REFERRED_REWARD = 20.0; // GHS
  static const int REFERRAL_POINTS = 100; // Gamification points

  /// Generate unique referral code for user
  Future<String> generateReferralCode(String userId) async {
    try {
      // Check if user already has a code
      final existingCode = await _getUserReferralCode(userId);
      if (existingCode != null) {
        return existingCode;
      }

      // Generate new code: HOMELINK_GH_[timestamp]
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final code = 'HOMELINK_GH_$timestamp';

      // Save to Firebase
      await _firebase.createReferralCode(userId, code);

      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('referral_code_$userId', code);

      debugPrint('Generated referral code for user $userId: $code');
      return code;
    } catch (e) {
      debugPrint('Error generating referral code: $e');
      rethrow;
    }
  }

  /// Get user's referral code
  Future<String?> _getUserReferralCode(String userId) async {
    try {
      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedCode = prefs.getString('referral_code_$userId');
      if (cachedCode != null) return cachedCode;

      // Fetch from Firebase
      return await _firebase.getReferralCodeByUserId(userId);
    } catch (e) {
      debugPrint('Error getting user referral code: $e');
      return null;
    }
  }

  /// Validate referral code
  Future<bool> validateReferralCode(String code) async {
    try {
      debugPrint('Validating referral code: $code');
      final isValid = await _firebase.checkReferralCodeExists(code);
      debugPrint('Code validation result: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('Error validating referral code: $e');
      return false;
    }
  }

  /// Apply referral code during registration
  Future<void> applyReferralCode({
    required String newUserId,
    required String newUserName,
    required String newUserPhone,
    required String referralCode,
  }) async {
    try {
      debugPrint('Applying referral code $referralCode for new user $newUserId');

      // Get referrer user ID
      final referrerId = await _firebase.getUserIdByReferralCode(referralCode);
      if (referrerId == null) {
        throw Exception('Invalid referral code');
      }

      // Create referral record
      final referral = Referral(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        referrerId: referrerId,
        referredUserId: newUserId,
        referralCode: referralCode,
        createdAt: DateTime.now(),
        status: 'pending',
        referrerReward: REFERRER_REWARD,
        referredReward: REFERRED_REWARD,
        referredUserName: newUserName,
        referredUserPhone: newUserPhone,
      );

      await _firebase.createReferral(referral);

      debugPrint('Referral created successfully');
    } catch (e) {
      debugPrint('Error applying referral code: $e');
      rethrow;
    }
  }

  /// Complete referral after first booking
  Future<void> completeReferral({
    required String referredUserId,
    required String firstBookingId,
  }) async {
    try {
      debugPrint('Completing referral for user $referredUserId');

      // Find pending referral for this user
      final referral = await _firebase.getPendingReferralByUserId(referredUserId);
      if (referral == null) {
        debugPrint('No pending referral found');
        return;
      }

      // Update referral status
      await _firebase.updateReferral(referral.id, {
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
        'firstBookingId': firstBookingId,
      });

      // Award rewards
      await awardReferralRewards(referral.id);

      debugPrint('Referral completed successfully');
    } catch (e) {
      debugPrint('Error completing referral: $e');
    }
  }

  /// Award referral rewards to both parties
  Future<void> awardReferralRewards(String referralId) async {
    try {
      debugPrint('Awarding referral rewards for referral $referralId');

      final referral = await _firebase.getReferral(referralId);
      if (referral == null) return;

      // Award gamification points to referrer
      await _gamification.awardPoints(
        referral.referrerId,
        REFERRAL_POINTS,
        'Successful referral',
      );

      // Award achievement
      await _gamification.awardAchievement(referral.referrerId, 'referral_rewards');

      // Update referral status
      await _firebase.updateReferral(referralId, {'status': 'rewarded'});

      // Update referral stats
      await _updateReferralStats(referral.referrerId);

      debugPrint('Rewards awarded successfully');
    } catch (e) {
      debugPrint('Error awarding referral rewards: $e');
    }
  }

  /// Get referral stats for user
  Future<ReferralStats> getReferralStats(String userId) async {
    try {
      debugPrint('Fetching referral stats for user $userId');

      // Get user's referral code
      final code = await generateReferralCode(userId);

      // Get all referrals by this user
      final referrals = await _firebase.getReferralsByReferrerId(userId);

      final totalReferrals = referrals.length;
      final completedReferrals = referrals.where((r) => r.isCompleted).length;
      final pendingReferrals = referrals.where((r) => r.isPending).length;
      final earnedRewards = completedReferrals * REFERRER_REWARD;

      // Get leaderboard rank
      final rank = await _firebase.getReferralLeaderboardRank(userId);

      // Get last referral date
      final lastReferral = referrals.isNotEmpty
          ? referrals.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
          : null;

      return ReferralStats(
        userId: userId,
        referralCode: code,
        totalReferrals: totalReferrals,
        completedReferrals: completedReferrals,
        pendingReferrals: pendingReferrals,
        earnedRewards: earnedRewards,
        leaderboardRank: rank,
        lastReferralDate: lastReferral?.createdAt,
      );
    } catch (e) {
      debugPrint('Error fetching referral stats: $e');
      return ReferralStats(
        userId: userId,
        referralCode: 'HOMELINK_GH_ERROR',
        totalReferrals: 0,
        completedReferrals: 0,
        pendingReferrals: 0,
        earnedRewards: 0.0,
        leaderboardRank: 0,
      );
    }
  }

  /// Get referral history
  Future<List<Referral>> getReferralHistory(String userId) async {
    try {
      return await _firebase.getReferralsByReferrerId(userId);
    } catch (e) {
      debugPrint('Error fetching referral history: $e');
      return [];
    }
  }

  /// Get referral leaderboard
  Future<List<Map<String, dynamic>>> getReferralLeaderboard({
    String period = 'all-time',
    int limit = 50,
  }) async {
    try {
      return await _firebase.getReferralLeaderboard(period: period, limit: limit);
    } catch (e) {
      debugPrint('Error fetching referral leaderboard: $e');
      return [];
    }
  }

  /// Track referral link click (analytics)
  Future<void> trackReferralLinkClick(String referralCode, String source) async {
    try {
      debugPrint('Tracking referral link click: $referralCode from $source');
      // Could implement analytics tracking here
    } catch (e) {
      debugPrint('Error tracking referral link click: $e');
    }
  }

  /// Update referral stats
  Future<void> _updateReferralStats(String userId) async {
    try {
      final stats = await getReferralStats(userId);
      await _firebase.updateReferralStats(userId, stats.toMap());
    } catch (e) {
      debugPrint('Error updating referral stats: $e');
    }
  }

  /// Check if user was referred
  Future<bool> wasUserReferred(String userId) async {
    try {
      final referral = await _firebase.getReferralByReferredUserId(userId);
      return referral != null;
    } catch (e) {
      debugPrint('Error checking if user was referred: $e');
      return false;
    }
  }

  /// Get referrer info for referred user
  Future<String?> getReferrerName(String userId) async {
    try {
      final referral = await _firebase.getReferralByReferredUserId(userId);
      if (referral != null) {
        final referrerInfo = await _firebase.getUserInfo(referral.referrerId);
        return referrerInfo?['displayName'] ?? referrerInfo?['email'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting referrer name: $e');
      return null;
    }
  }
}
