import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

/// Push Notification Service for HomeLinkGH
/// Handles Firebase Cloud Messaging for real-time notifications
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  
  // FCM Configuration
  static const String _fcmSendUrl = 'https://fcm.googleapis.com/v1/projects/homelinkgh-production/messages:send';
  static const String _fcmServerKey = 'your_fcm_server_key_here'; // To be configured
  
  String? _fcmToken;
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  
  // Notification categories for HomeLinkGH
  static const Map<String, Map<String, String>> notificationCategories = {
    'booking_updates': {
      'title': 'Booking Updates',
      'description': 'Updates about your service bookings',
      'icon': 'booking',
    },
    'provider_messages': {
      'title': 'Provider Messages',
      'description': 'Messages from your service providers',
      'icon': 'message',
    },
    'payment_updates': {
      'title': 'Payment Updates',
      'description': 'Payment confirmations and receipts',
      'icon': 'payment',
    },
    'service_reminders': {
      'title': 'Service Reminders',
      'description': 'Upcoming service appointments',
      'icon': 'reminder',
    },
    'promotions': {
      'title': 'Promotions & Offers',
      'description': 'Special deals and promotions',
      'icon': 'promotion',
    },
    'system_updates': {
      'title': 'System Updates',
      'description': 'App updates and announcements',
      'icon': 'system',
    },
  };

  /// Initialize push notification service
  Future<bool> initialize() async {
    try {
      print('Initializing push notification service...');
      
      // Load notification preferences
      await _loadNotificationPreferences();
      
      // Initialize FCM token
      await _initializeFCMToken();
      
      // Set up notification handlers
      _setupNotificationHandlers();
      
      // Register device for notifications
      await _registerDevice();
      
      _isInitialized = true;
      print('Push notification service initialized successfully!');
      return true;
    } catch (e) {
      print('Error initializing push notifications: $e');
      return false;
    }
  }

  /// Load notification preferences from storage
  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      // Load category preferences
      for (String category in notificationCategories.keys) {
        final enabled = prefs.getBool('notification_${category}_enabled') ?? true;
        // Store category preferences for later use
      }
    } catch (e) {
      print('Error loading notification preferences: $e');
    }
  }

  /// Initialize FCM token
  Future<void> _initializeFCMToken() async {
    try {
      // In a real implementation, this would use firebase_messaging package
      // For now, we'll simulate token generation
      _fcmToken = _generateMockFCMToken();
      
      // Save token to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', _fcmToken!);
      
      print('FCM token initialized: ${_fcmToken!.substring(0, 20)}...');
    } catch (e) {
      print('Error initializing FCM token: $e');
    }
  }

  /// Generate mock FCM token for development
  String _generateMockFCMToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'fcm_token_${timestamp}_homelinkgh_${_generateRandomString(20)}';
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt((DateTime.now().millisecondsSinceEpoch % chars.length))
    ));
  }

  /// Setup notification handlers
  void _setupNotificationHandlers() {
    // In a real implementation, this would set up FCM message handlers
    print('Setting up notification handlers...');
    
    // Simulate periodic notification checks
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkForPendingNotifications();
    });
  }

  /// Register device for notifications
  Future<void> _registerDevice() async {
    try {
      if (_fcmToken == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userRole = prefs.getString('user_role');
      
      if (userId == null) return;

      final deviceData = {
        'fcm_token': _fcmToken,
        'user_id': userId,
        'user_role': userRole ?? 'customer',
        'platform': 'flutter',
        'app_version': '3.1.1',
        'registered_at': DateTime.now().toIso8601String(),
        'notification_preferences': _getNotificationPreferences(),
      };

      await _firebaseService.registerDeviceForNotifications(deviceData);
      print('Device registered for notifications');
    } catch (e) {
      print('Error registering device: $e');
    }
  }

  /// Get current notification preferences
  Map<String, bool> _getNotificationPreferences() {
    return {
      'enabled': _notificationsEnabled,
      ...notificationCategories.map((key, value) => MapEntry(key, true)), // Default all to true
    };
  }

  /// Send push notification
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String category,
    Map<String, String>? data,
    String? imageUrl,
    DateTime? scheduledTime,
  }) async {
    try {
      if (!_isInitialized) {
        print('Push notification service not initialized');
        return false;
      }

      // Get user's FCM token
      final userToken = await _getUserFCMToken(userId);
      if (userToken == null) {
        print('No FCM token found for user: $userId');
        return false;
      }

      // Prepare notification payload
      final notification = {
        'message': {
          'token': userToken,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': {
            'category': category,
            'user_id': userId,
            'timestamp': DateTime.now().toIso8601String(),
            ...?data,
          },
          'android': {
            'notification': {
              'icon': 'ic_notification',
              'color': '#006B3C', // Ghana green
              'channel_id': 'homelinkgh_$category',
              'priority': 'high',
              'default_sound': true,
              'default_vibrate': true,
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'badge': 1,
                'sound': 'default',
                'category': category,
              },
            },
          },
        },
      };

      // Send notification via FCM
      final result = await _sendFCMNotification(notification);
      
      // Save notification to database
      await _saveNotificationRecord(userId, title, body, category, data);
      
      return result;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  /// Send FCM notification via HTTP
  Future<bool> _sendFCMNotification(Map<String, dynamic> payload) async {
    try {
      // In production, this would use OAuth 2.0 token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_fcmServerKey',
      };

      final response = await http.post(
        Uri.parse(_fcmSendUrl),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true;
      } else {
        print('Failed to send notification: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
      return false;
    }
  }

  /// Get user's FCM token from Firebase
  Future<String?> _getUserFCMToken(String userId) async {
    try {
      final userData = await _firebaseService.getUserNotificationData(userId);
      return userData?['fcm_token'];
    } catch (e) {
      print('Error getting user FCM token: $e');
      return null;
    }
  }

  /// Save notification record
  Future<void> _saveNotificationRecord(
    String userId,
    String title,
    String body,
    String category,
    Map<String, String>? data,
  ) async {
    try {
      final notificationData = {
        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'title': title,
        'body': body,
        'category': category,
        'data': data ?? {},
        'sent_at': DateTime.now().toIso8601String(),
        'read': false,
        'delivered': true,
      };

      await _firebaseService.saveNotificationRecord(notificationData);
    } catch (e) {
      print('Error saving notification record: $e');
    }
  }

  // BOOKING-SPECIFIC NOTIFICATIONS

  /// Send booking confirmation notification
  Future<bool> sendBookingConfirmation({
    required String userId,
    required String bookingId,
    required String serviceType,
    required String providerName,
    required DateTime scheduledDate,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Booking Confirmed! 🎉',
      body: 'Your $serviceType booking with $providerName is confirmed for ${_formatDate(scheduledDate)}',
      category: 'booking_updates',
      data: {
        'booking_id': bookingId,
        'action': 'booking_confirmed',
        'provider_name': providerName,
        'service_type': serviceType,
      },
    );
  }

  /// Send provider assigned notification
  Future<bool> sendProviderAssigned({
    required String userId,
    required String bookingId,
    required String providerName,
    required String serviceType,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Provider Assigned',
      body: '$providerName has been assigned to your $serviceType booking',
      category: 'booking_updates',
      data: {
        'booking_id': bookingId,
        'action': 'provider_assigned',
        'provider_name': providerName,
      },
    );
  }

  /// Send service started notification
  Future<bool> sendServiceStarted({
    required String userId,
    required String bookingId,
    required String providerName,
    required String serviceType,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Service Started',
      body: '$providerName has started your $serviceType service',
      category: 'booking_updates',
      data: {
        'booking_id': bookingId,
        'action': 'service_started',
        'provider_name': providerName,
      },
    );
  }

  /// Send service completed notification
  Future<bool> sendServiceCompleted({
    required String userId,
    required String bookingId,
    required String providerName,
    required String serviceType,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Service Completed! ✅',
      body: '$providerName has completed your $serviceType service. Please rate your experience!',
      category: 'booking_updates',
      data: {
        'booking_id': bookingId,
        'action': 'service_completed',
        'provider_name': providerName,
      },
    );
  }

  // PAYMENT NOTIFICATIONS

  /// Send payment successful notification
  Future<bool> sendPaymentSuccessful({
    required String userId,
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Payment Successful 💳',
      body: 'Your payment of GH₵${amount.toStringAsFixed(2)} was processed successfully',
      category: 'payment_updates',
      data: {
        'booking_id': bookingId,
        'action': 'payment_successful',
        'amount': amount.toString(),
        'payment_method': paymentMethod,
      },
    );
  }

  /// Send payment failed notification
  Future<bool> sendPaymentFailed({
    required String userId,
    required String bookingId,
    required double amount,
    required String reason,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Payment Failed ❌',
      body: 'Your payment of GH₵${amount.toStringAsFixed(2)} failed. Reason: $reason',
      category: 'payment_updates',
      data: {
        'booking_id': bookingId,
        'action': 'payment_failed',
        'amount': amount.toString(),
        'reason': reason,
      },
    );
  }

  // PROVIDER NOTIFICATIONS

  /// Send new booking request notification (for providers)
  Future<bool> sendNewBookingRequest({
    required String providerId,
    required String bookingId,
    required String customerName,
    required String serviceType,
    required DateTime scheduledDate,
  }) async {
    return await sendNotification(
      userId: providerId,
      title: 'New Booking Request! 📋',
      body: '$customerName has requested $serviceType for ${_formatDate(scheduledDate)}',
      category: 'booking_updates',
      data: {
        'booking_id': bookingId,
        'action': 'new_booking_request',
        'customer_name': customerName,
        'service_type': serviceType,
      },
    );
  }

  /// Send booking cancelled notification
  Future<bool> sendBookingCancelled({
    required String userId,
    required String bookingId,
    required String serviceType,
    required String reason,
  }) async {
    return await sendNotification(
      userId: userId,
      title: 'Booking Cancelled',
      body: 'Your $serviceType booking has been cancelled. Reason: $reason',
      category: 'booking_updates',
      data: {
        'booking_id': bookingId,
        'action': 'booking_cancelled',
        'reason': reason,
      },
    );
  }

  // REMINDER NOTIFICATIONS

  /// Send service reminder notification
  Future<bool> sendServiceReminder({
    required String userId,
    required String bookingId,
    required String serviceType,
    required String providerName,
    required DateTime scheduledDate,
    required int hoursBeforeService,
  }) async {
    String timeText;
    if (hoursBeforeService <= 1) {
      timeText = 'in ${hoursBeforeService * 60} minutes';
    } else if (hoursBeforeService < 24) {
      timeText = 'in $hoursBeforeService hours';
    } else {
      timeText = 'tomorrow';
    }

    return await sendNotification(
      userId: userId,
      title: 'Service Reminder ⏰',
      body: 'Your $serviceType with $providerName is scheduled $timeText',
      category: 'service_reminders',
      data: {
        'booking_id': bookingId,
        'action': 'service_reminder',
        'provider_name': providerName,
        'hours_before': hoursBeforeService.toString(),
      },
    );
  }

  // PROMOTIONAL NOTIFICATIONS

  /// Send promotional notification
  Future<bool> sendPromotionalNotification({
    required String userId,
    required String title,
    required String body,
    String? imageUrl,
    String? promoCode,
    DateTime? expiryDate,
  }) async {
    return await sendNotification(
      userId: userId,
      title: title,
      body: body,
      category: 'promotions',
      imageUrl: imageUrl,
      data: {
        'action': 'promotion',
        if (promoCode != null) 'promo_code': promoCode,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
      },
    );
  }

  // UTILITY METHODS

  /// Check for pending notifications
  Future<void> _checkForPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null) return;
      
      // Check for scheduled notifications, service reminders, etc.
      await _checkServiceReminders(userId);
      await _checkPromotionalNotifications(userId);
    } catch (e) {
      print('Error checking pending notifications: $e');
    }
  }

  /// Check for service reminders
  Future<void> _checkServiceReminders(String userId) async {
    try {
      final upcomingBookings = await _firebaseService.getUpcomingBookings(userId);
      
      for (var booking in upcomingBookings) {
        final scheduledDate = DateTime.parse(booking['scheduled_date']);
        final now = DateTime.now();
        final timeDifference = scheduledDate.difference(now);
        
        // Send reminders at 24 hours, 2 hours, and 30 minutes before service
        if (timeDifference.inHours == 24 || 
            timeDifference.inHours == 2 || 
            timeDifference.inMinutes == 30) {
          await sendServiceReminder(
            userId: userId,
            bookingId: booking['id'],
            serviceType: booking['service_type'],
            providerName: booking['provider_name'],
            scheduledDate: scheduledDate,
            hoursBeforeService: timeDifference.inHours,
          );
        }
      }
    } catch (e) {
      print('Error checking service reminders: $e');
    }
  }

  /// Check for promotional notifications
  Future<void> _checkPromotionalNotifications(String userId) async {
    try {
      final pendingPromotions = await _firebaseService.getPendingPromotions(userId);
      
      for (var promotion in pendingPromotions) {
        await sendPromotionalNotification(
          userId: userId,
          title: promotion['title'],
          body: promotion['body'],
          imageUrl: promotion['image_url'],
          promoCode: promotion['promo_code'],
          expiryDate: promotion['expiry_date'] != null 
            ? DateTime.parse(promotion['expiry_date'])
            : null,
        );
      }
    } catch (e) {
      print('Error checking promotional notifications: $e');
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences({
    required bool enabled,
    Map<String, bool>? categoryPreferences,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      
      _notificationsEnabled = enabled;
      
      if (categoryPreferences != null) {
        for (var entry in categoryPreferences.entries) {
          await prefs.setBool('notification_${entry.key}_enabled', entry.value);
        }
      }
      
      // Update preferences in Firebase
      final userId = prefs.getString('user_id');
      if (userId != null) {
        await _firebaseService.updateNotificationPreferences(userId, {
          'enabled': enabled,
          ...?categoryPreferences,
        });
      }
      
      return true;
    } catch (e) {
      print('Error updating notification preferences: $e');
      return false;
    }
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      return await _firebaseService.getNotificationHistory(userId, limit);
    } catch (e) {
      print('Error getting notification history: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firebaseService.markNotificationAsRead(notificationId);
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Format date for notifications
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays == 0) {
      return 'today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'tomorrow at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  bool get notificationsEnabled => _notificationsEnabled;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Cleanup resources
  void dispose() {
    // Clean up timers and streams if any
  }
}