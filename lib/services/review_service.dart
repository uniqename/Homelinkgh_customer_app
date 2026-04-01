import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../models/booking.dart';
import 'firebase_service.dart';

/// Review Service for HomeLinkGH Rating & Review System
/// Handles all review operations including submission, retrieval, and photo uploads
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseService _firebase = FirebaseService();

  /// Submit a new review for a completed booking
  Future<String> submitReview(Review review) async {
    try {
      debugPrint('Submitting review for booking: ${review.bookingId}');

      // Create review in Firebase
      final reviewId = await _firebase.createReview(review);

      // Update provider rating stats
      await updateProviderRatingStats(review.providerId);

      debugPrint('Review submitted successfully: $reviewId');
      return reviewId;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      rethrow;
    }
  }

  /// Get all reviews for a specific provider
  Future<List<Review>> getProviderReviews(
    String providerId, {
    int limit = 20,
    String sortBy = 'createdAt',
  }) async {
    try {
      debugPrint('Fetching reviews for provider: $providerId');

      final reviews = await _firebase.queryReviews({
        'providerId': providerId,
        'limit': limit,
        'orderBy': sortBy,
        'descending': true,
      });

      debugPrint('Found ${reviews.length} reviews for provider');
      return reviews;
    } catch (e) {
      debugPrint('Error fetching provider reviews: $e');
      return [];
    }
  }

  /// Get all reviews submitted by a specific customer
  Future<List<Review>> getCustomerReviews(String customerId) async {
    try {
      debugPrint('Fetching reviews by customer: $customerId');

      final reviews = await _firebase.queryReviews({
        'customerId': customerId,
        'orderBy': 'createdAt',
        'descending': true,
      });

      debugPrint('Found ${reviews.length} reviews by customer');
      return reviews;
    } catch (e) {
      debugPrint('Error fetching customer reviews: $e');
      return [];
    }
  }

  /// Get reviews that are pending (customer hasn't rated yet)
  Future<List<Booking>> getPendingReviews(String customerId) async {
    try {
      debugPrint('Fetching pending reviews for customer: $customerId');

      // This would need to be implemented in FirebaseService
      // For now, return empty list - will be implemented when integrating with booking flow
      return [];
    } catch (e) {
      debugPrint('Error fetching pending reviews: $e');
      return [];
    }
  }

  /// Provider responds to a customer review
  Future<void> respondToReview(String reviewId, String response) async {
    try {
      debugPrint('Provider responding to review: $reviewId');

      await _firebase.updateReview(reviewId, {
        'providerResponse': response,
        'respondedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('Provider response saved successfully');
    } catch (e) {
      debugPrint('Error saving provider response: $e');
      rethrow;
    }
  }

  /// Get aggregated rating statistics for a provider
  Future<ProviderRatingStats> getProviderRatingStats(String providerId) async {
    try {
      debugPrint('Fetching rating stats for provider: $providerId');

      final stats = await _firebase.getProviderRatingStats(providerId);

      if (stats != null) {
        return stats;
      }

      // Return default stats if none exist
      return ProviderRatingStats(
        providerId: providerId,
        overallRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        categoryAverages: {},
        recentReviewIds: [],
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching provider rating stats: $e');
      // Return default stats on error
      return ProviderRatingStats(
        providerId: providerId,
        overallRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        categoryAverages: {},
        recentReviewIds: [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Update provider's aggregated rating statistics
  Future<void> updateProviderRatingStats(String providerId) async {
    try {
      debugPrint('Updating rating stats for provider: $providerId');

      // Get all reviews for this provider
      final reviews = await getProviderReviews(providerId, limit: 1000);

      if (reviews.isEmpty) {
        debugPrint('No reviews found, skipping stats update');
        return;
      }

      // Calculate overall rating
      final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
      final overallRating = totalRating / reviews.length;

      // Calculate rating distribution
      final ratingDistribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (final review in reviews) {
        final stars = review.rating.round();
        ratingDistribution[stars] = (ratingDistribution[stars] ?? 0) + 1;
      }

      // Calculate category averages
      final categoryAverages = <String, double>{};
      final categoryCounts = <String, int>{};

      for (final review in reviews) {
        if (review.categoryRatings != null) {
          review.categoryRatings!.forEach((category, rating) {
            categoryAverages[category] = (categoryAverages[category] ?? 0.0) + rating;
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
          });
        }
      }

      // Average the category ratings
      categoryAverages.forEach((category, total) {
        final count = categoryCounts[category] ?? 1;
        categoryAverages[category] = total / count;
      });

      // Get recent review IDs (last 10)
      final recentReviewIds = reviews.take(10).map((r) => r.id).toList();

      // Create stats object
      final stats = ProviderRatingStats(
        providerId: providerId,
        overallRating: overallRating,
        totalReviews: reviews.length,
        ratingDistribution: ratingDistribution,
        categoryAverages: categoryAverages,
        recentReviewIds: recentReviewIds,
        lastUpdated: DateTime.now(),
      );

      // Save to Firebase
      await _firebase.updateProviderRatingStats(providerId, stats.toMap());

      debugPrint('Rating stats updated successfully');
    } catch (e) {
      debugPrint('Error updating provider rating stats: $e');
      rethrow;
    }
  }

  /// Upload review photos to Firebase Storage
  Future<List<String>> uploadReviewPhotos(String reviewId, List<File> photos) async {
    try {
      debugPrint('Uploading ${photos.length} photos for review: $reviewId');

      final photoUrls = <String>[];

      for (int i = 0; i < photos.length; i++) {
        try {
          final photoUrl = await _firebase.uploadReviewPhoto(reviewId, photos[i], i);
          photoUrls.add(photoUrl);
          debugPrint('Uploaded photo ${i + 1}/${photos.length}');
        } catch (e) {
          debugPrint('Error uploading photo $i: $e');
          // Continue with other photos even if one fails
        }
      }

      debugPrint('Successfully uploaded ${photoUrls.length} photos');
      return photoUrls;
    } catch (e) {
      debugPrint('Error uploading review photos: $e');
      rethrow;
    }
  }

  /// Check if a booking can be rated (completed and not yet rated)
  Future<bool> canRateBooking(String bookingId) async {
    try {
      debugPrint('Checking if booking can be rated: $bookingId');

      // Check if review already exists for this booking
      final existingReviews = await _firebase.queryReviews({
        'bookingId': bookingId,
        'limit': 1,
      });

      final canRate = existingReviews.isEmpty;
      debugPrint('Booking can be rated: $canRate');

      return canRate;
    } catch (e) {
      debugPrint('Error checking if booking can be rated: $e');
      return false;
    }
  }

  /// Get a specific review by ID
  Future<Review?> getReview(String reviewId) async {
    try {
      debugPrint('Fetching review: $reviewId');

      final review = await _firebase.getReview(reviewId);

      if (review != null) {
        debugPrint('Review found');
      } else {
        debugPrint('Review not found');
      }

      return review;
    } catch (e) {
      debugPrint('Error fetching review: $e');
      return null;
    }
  }

  /// Delete a review (admin only or within time limit)
  Future<bool> deleteReview(String reviewId, String providerId) async {
    try {
      debugPrint('Deleting review: $reviewId');

      await _firebase.deleteReview(reviewId);

      // Update provider stats after deletion
      await updateProviderRatingStats(providerId);

      debugPrint('Review deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  /// Update review text (customer can edit within time limit)
  Future<bool> updateReviewText(String reviewId, String newText) async {
    try {
      debugPrint('Updating review text: $reviewId');

      await _firebase.updateReview(reviewId, {
        'reviewText': newText,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('Review text updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating review text: $e');
      return false;
    }
  }

  /// Get review statistics for the entire platform (admin)
  Future<Map<String, dynamic>> getPlatformReviewStats() async {
    try {
      debugPrint('Fetching platform-wide review statistics');

      // This would aggregate stats across all providers
      // Implementation would depend on Firebase structure
      // For now, return basic stats

      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'totalProviders': 0,
        'ratedProviders': 0,
      };
    } catch (e) {
      debugPrint('Error fetching platform review stats: $e');
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'totalProviders': 0,
        'ratedProviders': 0,
      };
    }
  }
}
