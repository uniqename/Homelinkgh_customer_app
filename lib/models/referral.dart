/// Referral Models for HomeLinkGH Referral Program

class Referral {
  final String id;
  final String referrerId; // User who referred
  final String referredUserId; // New user who signed up
  final String referralCode; // Code used
  final DateTime createdAt;
  final DateTime? completedAt; // When referral qualified (first booking)
  final String status; // 'pending', 'completed', 'rewarded'
  final double referrerReward; // e.g., 40 GHS
  final double referredReward; // e.g., 20 GHS
  final String? referredUserName;
  final String? referredUserPhone;
  final String? firstBookingId;

  const Referral({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.referralCode,
    required this.createdAt,
    this.completedAt,
    this.status = 'pending',
    this.referrerReward = 40.0,
    this.referredReward = 20.0,
    this.referredUserName,
    this.referredUserPhone,
    this.firstBookingId,
  });

  factory Referral.fromMap(Map<String, dynamic> map) {
    return Referral(
      id: map['id'] ?? '',
      referrerId: map['referrerId'] ?? map['referrer_id'] ?? '',
      referredUserId: map['referredUserId'] ?? map['referred_user_id'] ?? '',
      referralCode: map['referralCode'] ?? map['referral_code'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? map['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : (map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null),
      status: map['status'] ?? 'pending',
      referrerReward: (map['referrerReward'] ?? map['referrer_reward'] ?? 40.0).toDouble(),
      referredReward: (map['referredReward'] ?? map['referred_reward'] ?? 20.0).toDouble(),
      referredUserName: map['referredUserName'] ?? map['referred_user_name'],
      referredUserPhone: map['referredUserPhone'] ?? map['referred_user_phone'],
      firstBookingId: map['firstBookingId'] ?? map['first_booking_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referrerId': referrerId,
      'referredUserId': referredUserId,
      'referralCode': referralCode,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
      'referrerReward': referrerReward,
      'referredReward': referredReward,
      'referredUserName': referredUserName,
      'referredUserPhone': referredUserPhone,
      'firstBookingId': firstBookingId,
    };
  }

  Referral copyWith({
    String? id,
    String? referrerId,
    String? referredUserId,
    String? referralCode,
    DateTime? createdAt,
    DateTime? completedAt,
    String? status,
    double? referrerReward,
    double? referredReward,
    String? referredUserName,
    String? referredUserPhone,
    String? firstBookingId,
  }) {
    return Referral(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referredUserId: referredUserId ?? this.referredUserId,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      referrerReward: referrerReward ?? this.referrerReward,
      referredReward: referredReward ?? this.referredReward,
      referredUserName: referredUserName ?? this.referredUserName,
      referredUserPhone: referredUserPhone ?? this.referredUserPhone,
      firstBookingId: firstBookingId ?? this.firstBookingId,
    );
  }

  bool get isCompleted => status == 'completed' || status == 'rewarded';
  bool get isPending => status == 'pending';
}

class ReferralStats {
  final String userId;
  final String referralCode;
  final int totalReferrals;
  final int completedReferrals;
  final int pendingReferrals;
  final double earnedRewards;
  final int leaderboardRank;
  final DateTime? lastReferralDate;

  const ReferralStats({
    required this.userId,
    required this.referralCode,
    this.totalReferrals = 0,
    this.completedReferrals = 0,
    this.pendingReferrals = 0,
    this.earnedRewards = 0.0,
    this.leaderboardRank = 0,
    this.lastReferralDate,
  });

  factory ReferralStats.fromMap(Map<String, dynamic> map) {
    return ReferralStats(
      userId: map['userId'] ?? map['user_id'] ?? '',
      referralCode: map['referralCode'] ?? map['referral_code'] ?? '',
      totalReferrals: map['totalReferrals'] ?? map['total_referrals'] ?? 0,
      completedReferrals: map['completedReferrals'] ?? map['completed_referrals'] ?? 0,
      pendingReferrals: map['pendingReferrals'] ?? map['pending_referrals'] ?? 0,
      earnedRewards: (map['earnedRewards'] ?? map['earned_rewards'] ?? 0.0).toDouble(),
      leaderboardRank: map['leaderboardRank'] ?? map['leaderboard_rank'] ?? 0,
      lastReferralDate: map['lastReferralDate'] != null
          ? DateTime.parse(map['lastReferralDate'])
          : (map['last_referral_date'] != null
              ? DateTime.parse(map['last_referral_date'])
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'referralCode': referralCode,
      'totalReferrals': totalReferrals,
      'completedReferrals': completedReferrals,
      'pendingReferrals': pendingReferrals,
      'earnedRewards': earnedRewards,
      'leaderboardRank': leaderboardRank,
      'lastReferralDate': lastReferralDate?.toIso8601String(),
    };
  }
}
