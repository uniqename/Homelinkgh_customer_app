import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String users = 'users';
  static const String providers = 'providers';
  static const String bookings = 'bookings';
  static const String earnings = 'earnings';
  static const String payouts = 'payouts';
  static const String referrals = 'referrals';
  static const String softLaunch = 'soft_launch';
  static const String serviceRatings = 'service_ratings';
  static const String adminPaychecks = 'admin_paychecks';

  // User Management
  static Future<void> createUser({
    required String uid,
    required String email,
    required String name,
    required String userType,
    required String country,
    required String phone,
    String? referralCode,
  }) async {
    await _db.collection(users).doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType, // customer, provider, admin, diaspora_customer, family_helper
      'country': country,
      'phone': phone,
      'referralCode': referralCode,
      'referredBy': null,
      'isVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'profileComplete': false,
      'totalBookings': 0,
      'totalSpent': 0.0,
      'loyaltyPoints': 0,
      'preferredLanguage': 'en',
      'ghanaAddress': null,
      'diasporaStatus': userType.contains('diaspora') ? 'active' : null,
    });
  }

  // Provider Earnings Structure
  static Future<void> recordEarning({
    required String providerId,
    required String bookingId,
    required double amount,
    required String currency,
    required String serviceType,
    required String paymentMethod,
  }) async {
    final earningId = _db.collection(earnings).doc().id;
    
    await _db.collection(earnings).doc(earningId).set({
      'earningId': earningId,
      'providerId': providerId,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'serviceType': serviceType,
      'paymentMethod': paymentMethod,
      'status': 'pending', // pending, available, paid_out
      'earnedAt': FieldValue.serverTimestamp(),
      'availableAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      'commission': amount * 0.15, // 15% platform fee
      'netAmount': amount * 0.85,
      'tax': amount * 0.05, // 5% tax
      'finalAmount': amount * 0.80, // 80% to provider
    });

    // Update provider total earnings
    await _db.collection(providers).doc(providerId).update({
      'totalEarnings': FieldValue.increment(amount * 0.80),
      'pendingEarnings': FieldValue.increment(amount * 0.80),
      'totalJobs': FieldValue.increment(1),
      'lastEarning': FieldValue.serverTimestamp(),
    });
  }

  // Admin Paycheck Structure
  static Future<void> createAdminPaycheck({
    required String adminId,
    required String period, // weekly, monthly
    required double totalCommissions,
    required double totalTax,
    required double operationalCosts,
    required int totalBookings,
    required int activeProviders,
  }) async {
    final paycheckId = _db.collection(adminPaychecks).doc().id;
    
    await _db.collection(adminPaychecks).doc(paycheckId).set({
      'paycheckId': paycheckId,
      'adminId': adminId,
      'period': period,
      'startDate': _getPeriodStart(period),
      'endDate': _getPeriodEnd(period),
      'totalCommissions': totalCommissions,
      'totalTax': totalTax,
      'operationalCosts': operationalCosts,
      'grossRevenue': totalCommissions + totalTax,
      'netProfit': (totalCommissions + totalTax) - operationalCosts,
      'totalBookings': totalBookings,
      'activeProviders': activeProviders,
      'avgBookingValue': totalCommissions / (totalBookings > 0 ? totalBookings : 1),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'generated',
      'breakdown': {
        'paymentProcessing': operationalCosts * 0.3,
        'customerSupport': operationalCosts * 0.2,
        'marketing': operationalCosts * 0.25,
        'technology': operationalCosts * 0.15,
        'operations': operationalCosts * 0.1,
      }
    });
  }

  // Referral System
  static Future<void> processReferral({
    required String referrerId,
    required String refereeId,
    required String referralCode,
  }) async {
    final referralId = _db.collection(referrals).doc().id;
    
    await _db.collection(referrals).doc(referralId).set({
      'referralId': referralId,
      'referrerId': referrerId,
      'refereeId': refereeId,
      'referralCode': referralCode,
      'status': 'pending', // pending, completed, rewarded
      'referralReward': 20.0, // ₵20 reward
      'refereeReward': 10.0, // ₵10 for new user
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
      'rewardedAt': null,
    });

    // Update referrer's referral count
    await _db.collection(users).doc(referrerId).update({
      'totalReferrals': FieldValue.increment(1),
      'pendingReferrals': FieldValue.increment(1),
    });
  }

  // Soft Launch Tracking
  static Future<void> trackSoftLaunchMetrics({
    required String userId,
    required String action, // signup, first_booking, referral_sent
    required Map<String, dynamic> metadata,
  }) async {
    await _db.collection(softLaunch).add({
      'userId': userId,
      'action': action,
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
      'platform': 'mobile',
      'version': '1.0.0',
    });
  }

  // Payout Management
  static Future<void> processPayout({
    required String providerId,
    required double amount,
    required String payoutMethod,
    required Map<String, String> accountDetails,
  }) async {
    final payoutId = _db.collection(payouts).doc().id;
    
    await _db.collection(payouts).doc(payoutId).set({
      'payoutId': payoutId,
      'providerId': providerId,
      'amount': amount,
      'payoutMethod': payoutMethod, // mobile_money, bank_transfer, paypal
      'accountDetails': accountDetails,
      'status': 'processing', // processing, completed, failed
      'requestedAt': FieldValue.serverTimestamp(),
      'processedAt': null,
      'completedAt': null,
      'reference': 'PO_${DateTime.now().millisecondsSinceEpoch}',
    });

    // Update provider balance
    await _db.collection(providers).doc(providerId).update({
      'pendingEarnings': FieldValue.increment(-amount),
      'totalPayouts': FieldValue.increment(amount),
      'lastPayout': FieldValue.serverTimestamp(),
    });
  }

  // Helper methods
  static Timestamp _getPeriodStart(String period) {
    final now = DateTime.now();
    if (period == 'weekly') {
      return Timestamp.fromDate(now.subtract(Duration(days: now.weekday - 1)));
    } else {
      return Timestamp.fromDate(DateTime(now.year, now.month, 1));
    }
  }

  static Timestamp _getPeriodEnd(String period) {
    final now = DateTime.now();
    if (period == 'weekly') {
      return Timestamp.fromDate(now.add(Duration(days: 7 - now.weekday)));
    } else {
      return Timestamp.fromDate(DateTime(now.year, now.month + 1, 0));
    }
  }

  // Real-time earnings stream for providers
  static Stream<QuerySnapshot> getProviderEarnings(String providerId) {
    return _db
        .collection(earnings)
        .where('providerId', isEqualTo: providerId)
        .orderBy('earnedAt', descending: true)
        .snapshots();
  }

  // Admin dashboard metrics
  static Future<Map<String, dynamic>> getAdminMetrics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final earnings = await _db
        .collection(earnings)
        .where('earnedAt', isGreaterThan: Timestamp.fromDate(startOfMonth))
        .get();
    
    final users = await _db.collection(users).get();
    final activeProviders = await _db
        .collection(providers)
        .where('isActive', isEqualTo: true)
        .get();
    
    double totalRevenue = 0;
    double totalCommissions = 0;
    
    for (var doc in earnings.docs) {
      final data = doc.data();
      totalRevenue += data['amount'] ?? 0;
      totalCommissions += data['commission'] ?? 0;
    }
    
    return {
      'totalUsers': users.size,
      'activeProviders': activeProviders.size,
      'monthlyRevenue': totalRevenue,
      'monthlyCommissions': totalCommissions,
      'totalBookings': earnings.size,
    };
  }
}