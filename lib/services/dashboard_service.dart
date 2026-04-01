import '../models/booking.dart';
import '../models/review.dart';
import '../models/referral.dart';
import '../services/firebase_service.dart';
import '../services/gamification_service.dart';
import '../services/review_service.dart';
import '../services/referral_service.dart';

/// Dashboard Data Model
class DashboardData {
  final BookingsSummary bookingsSummary;
  final Map<String, dynamic> gamificationStats;
  final List<Review> pendingReviews;
  final List<Booking> recentTransactions;
  final ReferralStats? referralStats;
  final List<Booking> upcomingBookings;
  final List<Map<String, dynamic>> recentNotifications;
  final double totalSpent;
  final int rewardPoints;

  DashboardData({
    required this.bookingsSummary,
    required this.gamificationStats,
    required this.pendingReviews,
    required this.recentTransactions,
    this.referralStats,
    required this.upcomingBookings,
    required this.recentNotifications,
    required this.totalSpent,
    required this.rewardPoints,
  });
}

/// Bookings Summary Model
class BookingsSummary {
  final int totalBookings;
  final int completedBookings;
  final int activeBookings;
  final int cancelledBookings;

  BookingsSummary({
    required this.totalBookings,
    required this.completedBookings,
    required this.activeBookings,
    required this.cancelledBookings,
  });
}

/// Dashboard Service
/// Aggregates data from all features for the customer dashboard
class DashboardService {
  final _firebaseService = FirebaseService();
  final _gamificationService = GamificationService();
  final _reviewService = ReviewService();
  final _referralService = ReferralService();

  /// Get complete dashboard data for a user
  Future<DashboardData> getDashboardData(String userId) async {
    try {
      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        _getBookingsSummary(userId),
        _getGamificationStats(userId),
        _getPendingReviews(userId),
        _getRecentTransactions(userId),
        _getReferralStats(userId),
        _getUpcomingBookings(userId),
        _getRecentNotifications(userId),
      ]);

      final bookingsSummary = results[0] as BookingsSummary;
      final gamificationStats = results[1] as Map<String, dynamic>;
      final pendingReviews = results[2] as List<Review>;
      final recentTransactions = results[3] as List<Booking>;
      final referralStats = results[4] as ReferralStats?;
      final upcomingBookings = results[5] as List<Booking>;
      final recentNotifications = results[6] as List<Map<String, dynamic>>;

      // Calculate total spent from all completed bookings
      final totalSpent = recentTransactions
          .where((b) => b.status == 'completed')
          .fold(0.0, (sum, booking) => sum + booking.price);

      // Get reward points from gamification
      final rewardPoints = gamificationStats['points'] as int? ?? 0;

      return DashboardData(
        bookingsSummary: bookingsSummary,
        gamificationStats: gamificationStats,
        pendingReviews: pendingReviews,
        recentTransactions: recentTransactions,
        referralStats: referralStats,
        upcomingBookings: upcomingBookings,
        recentNotifications: recentNotifications,
        totalSpent: totalSpent,
        rewardPoints: rewardPoints,
      );
    } catch (e) {
      print('Error getting dashboard data: $e');
      rethrow;
    }
  }

  /// Get bookings summary statistics
  Future<BookingsSummary> _getBookingsSummary(String userId) async {
    try {
      final bookings = await _firebaseService.getCustomerBookings(userId);

      final totalBookings = bookings.length;
      final completedBookings = bookings.where((b) => b.status == 'completed').length;
      final activeBookings = bookings.where((b) =>
        b.status == 'pending' || b.status == 'confirmed' || b.status == 'in_progress'
      ).length;
      final cancelledBookings = bookings.where((b) => b.status == 'cancelled').length;

      return BookingsSummary(
        totalBookings: totalBookings,
        completedBookings: completedBookings,
        activeBookings: activeBookings,
        cancelledBookings: cancelledBookings,
      );
    } catch (e) {
      print('Error getting bookings summary: $e');
      return BookingsSummary(
        totalBookings: 0,
        completedBookings: 0,
        activeBookings: 0,
        cancelledBookings: 0,
      );
    }
  }

  /// Get gamification statistics
  Future<Map<String, dynamic>> _getGamificationStats(String userId) async {
    try {
      final stats = _gamificationService.getUserStats();
      return stats;
    } catch (e) {
      print('Error getting gamification stats: $e');
      return {
        'level': 1,
        'points': 0,
        'pointsToNextLevel': 100,
        'achievements': [],
      };
    }
  }

  /// Get pending reviews (completed bookings not yet rated)
  Future<List<Review>> _getPendingReviews(String userId) async {
    try {
      // Get all customer bookings
      final bookings = await _firebaseService.getCustomerBookings(userId);

      // Filter completed bookings that haven't been rated
      final pendingReviewBookings = bookings.where((b) =>
        b.status == 'completed' && !b.isRated
      ).toList();

      // Convert to Review objects (empty reviews for pending)
      return pendingReviewBookings.map((booking) => Review(
        id: '',
        bookingId: booking.id ?? '',
        customerId: userId,
        customerName: '',
        providerId: booking.providerId,
        rating: 0,
        reviewText: '',
        jobTitle: booking.serviceType,
        createdAt: DateTime.now(),
        isVerifiedCustomer: true,
        jobAmount: booking.price,
      )).toList();
    } catch (e) {
      print('Error getting pending reviews: $e');
      return [];
    }
  }

  /// Get recent transactions (last 5 bookings)
  Future<List<Booking>> _getRecentTransactions(String userId) async {
    try {
      final bookings = await _firebaseService.getCustomerBookings(userId);

      // Sort by created date and take last 5
      bookings.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.now();
        final bDate = b.createdAt ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
      return bookings.take(5).toList();
    } catch (e) {
      print('Error getting recent transactions: $e');
      return [];
    }
  }

  /// Get referral statistics
  Future<ReferralStats?> _getReferralStats(String userId) async {
    try {
      return await _referralService.getReferralStats(userId);
    } catch (e) {
      print('Error getting referral stats: $e');
      return null;
    }
  }

  /// Get upcoming bookings (next 3)
  Future<List<Booking>> _getUpcomingBookings(String userId) async {
    try {
      final bookings = await _firebaseService.getCustomerBookings(userId);

      // Filter for confirmed/pending bookings
      final upcoming = bookings.where((b) =>
        b.status == 'confirmed' || b.status == 'pending'
      ).toList();

      // Sort by scheduled date
      upcoming.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      return upcoming.take(3).toList();
    } catch (e) {
      print('Error getting upcoming bookings: $e');
      return [];
    }
  }

  /// Get recent notifications (last 5)
  Future<List<Map<String, dynamic>>> _getRecentNotifications(String userId) async {
    try {
      return await _firebaseService.getNotificationHistory(userId, 5);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Refresh dashboard data (for pull-to-refresh)
  Future<DashboardData> refreshDashboard(String userId) async {
    return getDashboardData(userId);
  }
}
