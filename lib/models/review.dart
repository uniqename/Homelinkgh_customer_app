import 'dart:io';

/// Review Model for HomeLinkGH Rating & Review System
/// Supports provider ratings with photos, category ratings, and provider responses
class Review {
  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String providerId;
  final double rating; // 1-5 stars
  final String reviewText;
  final String jobTitle; // Service type from booking
  final DateTime createdAt;
  final bool isVerifiedCustomer;
  final double jobAmount;
  final List<String> photoUrls; // Firebase Storage URLs
  final String? providerResponse;
  final DateTime? respondedAt;
  final Map<String, double>? categoryRatings; // professionalism, punctuality, quality, communication

  const Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.rating,
    required this.reviewText,
    required this.jobTitle,
    required this.createdAt,
    this.isVerifiedCustomer = true,
    this.jobAmount = 0.0,
    this.photoUrls = const [],
    this.providerResponse,
    this.respondedAt,
    this.categoryRatings,
  });

  /// Create Review from Firebase document
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? map['booking_id'] ?? '',
      customerId: map['customerId'] ?? map['customer_id'] ?? '',
      customerName: map['customerName'] ?? map['customer_name'] ?? '',
      providerId: map['providerId'] ?? map['provider_id'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewText: map['reviewText'] ?? map['review_text'] ?? '',
      jobTitle: map['jobTitle'] ?? map['job_title'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : (map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now()),
      isVerifiedCustomer: map['isVerifiedCustomer'] ?? map['is_verified_customer'] ?? true,
      jobAmount: (map['jobAmount'] ?? map['job_amount'] ?? 0.0).toDouble(),
      photoUrls: map['photoUrls'] != null
          ? List<String>.from(map['photoUrls'])
          : (map['photo_urls'] != null
              ? List<String>.from(map['photo_urls'])
              : []),
      providerResponse: map['providerResponse'] ?? map['provider_response'],
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'])
          : (map['responded_at'] != null
              ? DateTime.parse(map['responded_at'])
              : null),
      categoryRatings: map['categoryRatings'] != null
          ? Map<String, double>.from(
              (map['categoryRatings'] as Map).map(
                (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
              ),
            )
          : (map['category_ratings'] != null
              ? Map<String, double>.from(
                  (map['category_ratings'] as Map).map(
                    (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
                  ),
                )
              : null),
    );
  }

  /// Convert Review to Firebase document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'providerId': providerId,
      'rating': rating,
      'reviewText': reviewText,
      'jobTitle': jobTitle,
      'createdAt': createdAt.toIso8601String(),
      'isVerifiedCustomer': isVerifiedCustomer,
      'jobAmount': jobAmount,
      'photoUrls': photoUrls,
      'providerResponse': providerResponse,
      'respondedAt': respondedAt?.toIso8601String(),
      'categoryRatings': categoryRatings,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Review copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? customerName,
    String? providerId,
    double? rating,
    String? reviewText,
    String? jobTitle,
    DateTime? createdAt,
    bool? isVerifiedCustomer,
    double? jobAmount,
    List<String>? photoUrls,
    String? providerResponse,
    DateTime? respondedAt,
    Map<String, double>? categoryRatings,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      providerId: providerId ?? this.providerId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      jobTitle: jobTitle ?? this.jobTitle,
      createdAt: createdAt ?? this.createdAt,
      isVerifiedCustomer: isVerifiedCustomer ?? this.isVerifiedCustomer,
      jobAmount: jobAmount ?? this.jobAmount,
      photoUrls: photoUrls ?? this.photoUrls,
      providerResponse: providerResponse ?? this.providerResponse,
      respondedAt: respondedAt ?? this.respondedAt,
      categoryRatings: categoryRatings ?? this.categoryRatings,
    );
  }

  /// Get average of category ratings
  double get categoryRatingsAverage {
    if (categoryRatings == null || categoryRatings!.isEmpty) return rating;
    final values = categoryRatings!.values;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Check if review has provider response
  bool get hasProviderResponse => providerResponse != null && providerResponse!.isNotEmpty;

  /// Check if review has photos
  bool get hasPhotos => photoUrls.isNotEmpty;
}

/// Provider Rating Statistics
/// Aggregated stats for provider's overall rating performance
class ProviderRatingStats {
  final String providerId;
  final double overallRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}
  final Map<String, double> categoryAverages; // {professionalism: 4.5, punctuality: 4.8, ...}
  final List<String> recentReviewIds; // Last 10 review IDs
  final DateTime lastUpdated;

  const ProviderRatingStats({
    required this.providerId,
    required this.overallRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.categoryAverages,
    this.recentReviewIds = const [],
    required this.lastUpdated,
  });

  factory ProviderRatingStats.fromMap(Map<String, dynamic> map) {
    return ProviderRatingStats(
      providerId: map['providerId'] ?? map['provider_id'] ?? '',
      overallRating: (map['overallRating'] ?? map['overall_rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? map['total_reviews'] ?? 0,
      ratingDistribution: map['ratingDistribution'] != null
          ? Map<int, int>.from(
              (map['ratingDistribution'] as Map).map(
                (key, value) => MapEntry(int.parse(key.toString()), value as int),
              ),
            )
          : (map['rating_distribution'] != null
              ? Map<int, int>.from(
                  (map['rating_distribution'] as Map).map(
                    (key, value) => MapEntry(int.parse(key.toString()), value as int),
                  ),
                )
              : {5: 0, 4: 0, 3: 0, 2: 0, 1: 0}),
      categoryAverages: map['categoryAverages'] != null
          ? Map<String, double>.from(
              (map['categoryAverages'] as Map).map(
                (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
              ),
            )
          : (map['category_averages'] != null
              ? Map<String, double>.from(
                  (map['category_averages'] as Map).map(
                    (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
                  ),
                )
              : {}),
      recentReviewIds: map['recentReviews'] != null
          ? List<String>.from(map['recentReviews'])
          : (map['recent_reviews'] != null
              ? List<String>.from(map['recent_reviews'])
              : []),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : (map['last_updated'] != null
              ? DateTime.parse(map['last_updated'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'overallRating': overallRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'categoryAverages': categoryAverages,
      'recentReviews': recentReviewIds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Get percentage for a specific star rating
  double getPercentage(int stars) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / totalReviews) * 100;
  }

  /// Check if provider has good ratings (>= 4.0)
  bool get hasGoodRating => overallRating >= 4.0;

  /// Check if provider has excellent ratings (>= 4.5)
  bool get hasExcellentRating => overallRating >= 4.5;
}
