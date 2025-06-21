import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // SMS API credentials (replace with actual credentials)
  static const String _smsApiKey = 'YOUR_SMS_API_KEY';
  static const String _smsApiUrl = 'https://api.hubtel.com/v1/messages/send';
  
  // Initialize notifications
  static Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }
  
  // Save FCM token to database
  static Future<void> _saveTokenToDatabase(String token) async {
    final userId = 'current_user_id'; // Get from auth
    await _db.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.notification?.title}');
    
    // Show in-app notification
    if (message.notification != null) {
      _showInAppNotification(
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        data: message.data,
      );
    }
  }
  
  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');
    
    // Store notification in database for later retrieval
    await _storeNotification(message);
  }
  
  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    
    // Navigate to relevant screen based on notification type
    _handleNotificationNavigation(message.data);
  }
  
  // Send push notification
  static Future<bool> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _db.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];
      
      if (fcmToken == null) {
        print('No FCM token found for user: $userId');
        return false;
      }
      
      // Send notification via FCM
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_FCM_SERVER_KEY', // Replace with actual key
        },
        body: json.encode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
            'image': imageUrl,
            'sound': 'default',
            'badge': 1,
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );
      
      if (response.statusCode == 200) {
        await _logNotification(userId, title, body, 'push', true);
        return true;
      } else {
        print('Failed to send push notification: ${response.body}');
        await _logNotification(userId, title, body, 'push', false);
        return false;
      }
    } catch (e) {
      print('Error sending push notification: $e');
      return false;
    }
  }
  
  // Send SMS notification
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_smsApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_smsApiKey',
        },
        body: json.encode({
          'From': 'HomeLinkGH',
          'To': phoneNumber,
          'Content': message,
        }),
      );
      
      if (response.statusCode == 200) {
        if (userId != null) {
          await _logNotification(userId, 'SMS', message, 'sms', true);
        }
        return true;
      } else {
        print('Failed to send SMS: ${response.body}');
        if (userId != null) {
          await _logNotification(userId, 'SMS', message, 'sms', false);
        }
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
  
  // Send email notification
  static Future<bool> sendEmail({
    required String email,
    required String subject,
    required String body,
    String? userId,
  }) async {
    // In production, integrate with SendGrid, Mailgun, or similar
    try {
      // Placeholder for email service integration
      print('Sending email to $email: $subject');
      
      if (userId != null) {
        await _logNotification(userId, subject, body, 'email', true);
      }
      
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
  
  // Send booking notifications
  static Future<void> sendBookingNotification({
    required String userId,
    required String bookingId,
    required String type, // booking_confirmed, provider_assigned, service_started, service_completed
    Map<String, dynamic>? bookingDetails,
  }) async {
    String title, body;
    Map<String, String> data = {
      'type': 'booking',
      'subtype': type,
      'bookingId': bookingId,
    };
    
    switch (type) {
      case 'booking_confirmed':
        title = '✅ Booking Confirmed';
        body = 'Your ${bookingDetails?['service']} booking has been confirmed for ${bookingDetails?['date']}';
        break;
      case 'provider_assigned':
        title = '👨‍🔧 Provider Assigned';
        body = '${bookingDetails?['providerName']} has been assigned to your booking';
        break;
      case 'provider_on_way':
        title = '🚗 Provider On The Way';
        body = 'Your provider is heading to your location. ETA: ${bookingDetails?['eta']} minutes';
        break;
      case 'service_started':
        title = '🔧 Service Started';
        body = 'Your ${bookingDetails?['service']} service has begun';
        break;
      case 'service_completed':
        title = '✨ Service Completed';
        body = 'Your service is complete! Please rate your experience';
        break;
      case 'booking_cancelled':
        title = '❌ Booking Cancelled';
        body = 'Your booking has been cancelled. ${bookingDetails?['reason'] ?? ''}';
        break;
      default:
        title = 'Booking Update';
        body = 'Your booking has been updated';
    }
    
    // Send push notification
    await sendPushNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
    
    // Send SMS for critical updates
    if (['provider_assigned', 'provider_on_way', 'booking_cancelled'].contains(type)) {
      final userDoc = await _db.collection('users').doc(userId).get();
      final phoneNumber = userDoc.data()?['phone'];
      
      if (phoneNumber != null) {
        await sendSMS(
          phoneNumber: phoneNumber,
          message: '$title - $body - HomeLinkGH',
          userId: userId,
        );
      }
    }
  }
  
  // Send dispute notifications
  static Future<void> sendDisputeNotification({
    required String disputeId,
    required String type, // dispute_submitted, provider_response, status_update, refund_processed
    String? message,
  }) async {
    // Get dispute details
    final disputeDoc = await _db.collection('disputes').doc(disputeId).get();
    final disputeData = disputeDoc.data()!;
    
    String title, body;
    Map<String, String> data = {
      'type': 'dispute',
      'subtype': type,
      'disputeId': disputeId,
      'caseId': disputeData['caseId'],
    };
    
    switch (type) {
      case 'dispute_submitted':
        title = '📋 Dispute Submitted';
        body = 'Your dispute has been received. Case ID: ${disputeData['caseId']}';
        break;
      case 'provider_response':
        title = '💬 Provider Response';
        body = 'The provider has responded to your dispute';
        break;
      case 'status_update':
        title = '🔄 Dispute Update';
        body = message ?? 'Your dispute status has been updated';
        break;
      case 'refund_processed':
        title = '💰 Refund Processed';
        body = message ?? 'Your refund has been processed successfully';
        break;
      case 'new_message':
        title = '💬 New Message';
        body = 'You have a new message in your dispute case';
        break;
      default:
        title = 'Dispute Update';
        body = 'Your dispute has been updated';
    }
    
    // Notify customer
    if (disputeData['customerUserId'] != null) {
      await sendPushNotification(
        userId: disputeData['customerUserId'],
        title: title,
        body: body,
        data: data,
      );
    }
    
    // Notify provider
    if (disputeData['providerUserId'] != null && type != 'dispute_submitted') {
      await sendPushNotification(
        userId: disputeData['providerUserId'],
        title: '⚠️ Dispute Alert',
        body: 'A customer has raised a dispute for your service',
        data: data,
      );
    }
  }
  
  // Send payment notifications
  static Future<void> sendPaymentNotification({
    required String userId,
    required String type, // payment_received, payment_failed, payout_processed, payout_failed
    required double amount,
    String? transactionId,
    String? reason,
  }) async {
    String title, body;
    Map<String, String> data = {
      'type': 'payment',
      'subtype': type,
      'amount': amount.toString(),
    };
    
    if (transactionId != null) {
      data['transactionId'] = transactionId;
    }
    
    switch (type) {
      case 'payment_received':
        title = '💰 Payment Received';
        body = 'You received ₵${amount.toStringAsFixed(2)} for your service';
        break;
      case 'payment_failed':
        title = '❌ Payment Failed';
        body = 'Payment of ₵${amount.toStringAsFixed(2)} could not be processed';
        break;
      case 'payout_processed':
        title = '📤 Payout Sent';
        body = 'Your payout of ₵${amount.toStringAsFixed(2)} has been processed';
        break;
      case 'payout_failed':
        title = '⚠️ Payout Failed';
        body = 'Your payout of ₵${amount.toStringAsFixed(2)} could not be sent. ${reason ?? ''}';
        break;
      case 'refund_received':
        title = '💸 Refund Received';
        body = 'Your refund of ₵${amount.toStringAsFixed(2)} has been processed';
        break;
      default:
        title = 'Payment Update';
        body = 'Your payment has been updated';
    }
    
    await sendPushNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }
  
  // Send marketing notifications
  static Future<void> sendMarketingNotification({
    required String userId,
    required String title,
    required String body,
    String? imageUrl,
    String? actionUrl,
  }) async {
    Map<String, String> data = {
      'type': 'marketing',
    };
    
    if (actionUrl != null) {
      data['actionUrl'] = actionUrl;
    }
    
    await sendPushNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
      imageUrl: imageUrl,
    );
  }
  
  // Bulk notification sending
  static Future<void> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) async {
    // Send in batches to avoid overwhelming the system
    const batchSize = 100;
    
    for (int i = 0; i < userIds.length; i += batchSize) {
      final batch = userIds.skip(i).take(batchSize).toList();
      
      // Process batch in parallel
      await Future.wait(
        batch.map((userId) => sendPushNotification(
          userId: userId,
          title: title,
          body: body,
          data: data,
          imageUrl: imageUrl,
        )),
      );
      
      // Small delay between batches
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  // Log notification
  static Future<void> _logNotification(
    String userId,
    String title,
    String body,
    String type,
    bool success,
  ) async {
    await _db.collection('notification_logs').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'success': success,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Store notification for later retrieval
  static Future<void> _storeNotification(RemoteMessage message) async {
    await _db.collection('stored_notifications').add({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'receivedAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
  
  // Show in-app notification
  static void _showInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    // This would show a snackbar or overlay notification
    print('In-app notification: $title - $body');
  }
  
  // Handle notification navigation
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'booking':
        // Navigate to booking details
        print('Navigate to booking: ${data['bookingId']}');
        break;
      case 'dispute':
        // Navigate to dispute screen
        print('Navigate to dispute: ${data['disputeId']}');
        break;
      case 'payment':
        // Navigate to earnings/payments
        print('Navigate to payment: ${data['transactionId']}');
        break;
      case 'marketing':
        // Handle marketing action
        if (data['actionUrl'] != null) {
          print('Open URL: ${data['actionUrl']}');
        }
        break;
    }
  }
  
  // Get user's notification preferences
  static Future<Map<String, bool>> getNotificationPreferences(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final preferences = userDoc.data()?['notificationPreferences'];
    
    return {
      'push': preferences?['push'] ?? true,
      'sms': preferences?['sms'] ?? true,
      'email': preferences?['email'] ?? true,
      'marketing': preferences?['marketing'] ?? false,
    };
  }
  
  // Update notification preferences
  static Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  ) async {
    await _db.collection('users').doc(userId).update({
      'notificationPreferences': preferences,
      'preferencesUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get notification history for user
  static Stream<QuerySnapshot> getNotificationHistory(String userId) {
    return _db
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots();
  }
}