import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n001',
      'title': 'Job Assignment Updated',
      'message': 'Your cleaning service at East Legon has been confirmed for 10:00 AM',
      'type': 'job_update',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': false,
      'priority': 'high',
      'userType': 'provider',
    },
    {
      'id': 'n002',
      'title': 'New Customer Question',
      'message': 'Mary Adjei has a question about tomorrow\'s service timing',
      'type': 'customer_question',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'priority': 'urgent',
      'userType': 'field_staff',
    },
    {
      'id': 'n003',
      'title': 'Payment Received',
      'message': 'Payment of GH₵150 received for house cleaning service',
      'type': 'payment',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'isRead': true,
      'priority': 'normal',
      'userType': 'provider',
    },
    {
      'id': 'n004',
      'title': 'Food Order Ready',
      'message': 'Your order from KFC East Legon is ready for pickup',
      'type': 'food_delivery',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
      'priority': 'urgent',
      'userType': 'customer',
    },
    {
      'id': 'n005',
      'title': 'Service Completed',
      'message': 'Kwame Plumbing has completed the repair work',
      'type': 'service_complete',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': false,
      'priority': 'normal',
      'userType': 'customer',
    },
    {
      'id': 'n006',
      'title': 'New Provider Application',
      'message': 'Beauty Studio by Ama has applied to join the platform',
      'type': 'provider_application',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
      'isRead': false,
      'priority': 'high',
      'userType': 'admin',
    },
    {
      'id': 'n007',
      'title': 'System Alert',
      'message': 'High traffic detected - server performance monitoring required',
      'type': 'system_alert',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': false,
      'priority': 'urgent',
      'userType': 'admin',
    },
  ];

  // Initialize push notifications (simplified for build compatibility)
  Future<void> initializePushNotifications() async {
    if (_isInitialized) return;

    try {
      debugPrint('Push notifications initialized (local mode)');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
      _isInitialized = true;
    }
  }

  // Quote update notifications (local only for now)
  Future<void> sendQuoteUpdateNotification({
    required String quoteId,
    required String customerName,
    required String status,
    required double amount,
  }) async {
    final title = _getQuoteUpdateTitle(status);
    final body = _getQuoteUpdateBody(status, customerName, amount);

    // Add to local notifications list
    addNotification(
      title: title,
      message: body,
      type: 'quote_update',
      userType: 'provider',
      priority: status == 'accepted' ? 'high' : 'normal',
    );

    debugPrint('Quote notification: $title - $body');
  }

  // New quote request notifications (local only for now)
  Future<void> sendNewQuoteRequestNotification({
    required String requestId,
    required String serviceName,
    required String customerLocation,
    required String urgency,
  }) async {
    final title = '🔔 New Quote Request';
    final body = '$serviceName needed in $customerLocation ($urgency)';

    addNotification(
      title: title,
      message: body,
      type: 'new_quote_request',
      userType: 'provider',
      priority: urgency.contains('Emergency') ? 'urgent' : 'high',
    );

    debugPrint('New request notification: $title - $body');
  }

  // Service reminder notifications (local only for now)
  Future<void> sendServiceReminderNotification({
    required String serviceId,
    required String serviceName,
    required String reminderType,
    required DateTime scheduledTime,
  }) async {
    final title = _getServiceReminderTitle(reminderType);
    final body = _getServiceReminderBody(reminderType, serviceName, scheduledTime);

    addNotification(
      title: title,
      message: body,
      type: 'service_reminder',
      userType: 'provider',
      priority: 'normal',
    );

    debugPrint('Service reminder notification: $title - $body');
  }

  // Get FCM token (placeholder for now)
  Future<String?> getFCMToken() async {
    try {
      // Return a mock token for now
      return 'local-mode-token-${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topics (placeholder for now)
  Future<void> subscribeToTopic(String topic) async {
    try {
      debugPrint('Subscribed to topic: $topic (local mode)');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  List<Map<String, dynamic>> getNotificationsForUser(String userType) {
    return _notifications
        .where((notification) => notification['userType'] == userType)
        .toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  int getUnreadCount(String userType) {
    return _notifications
        .where((n) => n['userType'] == userType && !n['isRead'])
        .length;
  }

  void markAsRead(String notificationId) {
    final notification = _notifications.firstWhere(
      (n) => n['id'] == notificationId,
      orElse: () => {},
    );
    if (notification.isNotEmpty) {
      notification['isRead'] = true;
    }
  }

  void markAllAsRead(String userType) {
    for (var notification in _notifications) {
      if (notification['userType'] == userType) {
        notification['isRead'] = true;
      }
    }
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
    required String userType,
    String priority = 'normal',
  }) {
    _notifications.insert(0, {
      'id': 'n${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'message': message,
      'type': type,
      'timestamp': DateTime.now(),
      'isRead': false,
      'priority': priority,
      'userType': userType,
    });
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
      default:
        return Colors.blue;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type) {
      case 'job_update':
        return Icons.work;
      case 'customer_question':
        return Icons.help_outline;
      case 'payment':
        return Icons.payment;
      case 'food_delivery':
        return Icons.delivery_dining;
      case 'service_complete':
        return Icons.check_circle;
      case 'provider_application':
        return Icons.business;
      case 'system_alert':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  // Helper methods for notification text
  String _getQuoteUpdateTitle(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return '🎉 Quote Accepted!';
      case 'rejected':
        return '📝 Quote Update';
      case 'revised':
        return '🔄 Quote Revised';
      case 'completed':
        return '✅ Service Completed';
      default:
        return '📬 Quote Update';
    }
  }

  String _getQuoteUpdateBody(String status, String customerName, double amount) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return '$customerName accepted your ₵${amount.toStringAsFixed(0)} quote!';
      case 'rejected':
        return '$customerName declined your quote. Consider revising.';
      case 'revised':
        return 'Customer revised quote request. Check details.';
      case 'completed':
        return 'Service completed! Payment of ₵${amount.toStringAsFixed(0)} processed.';
      default:
        return 'Your quote has been updated by $customerName';
    }
  }

  String _getServiceReminderTitle(String reminderType) {
    switch (reminderType.toLowerCase()) {
      case 'upcoming_service':
        return '⏰ Service Reminder';
      case 'follow_up':
        return '📞 Follow-up Reminder';
      case 'maintenance':
        return '🔧 Maintenance Due';
      default:
        return '📅 Reminder';
    }
  }

  String _getServiceReminderBody(String reminderType, String serviceName, DateTime scheduledTime) {
    final timeString = '${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    
    switch (reminderType.toLowerCase()) {
      case 'upcoming_service':
        return '$serviceName scheduled for today at $timeString';
      case 'follow_up':
        return 'Follow up with customer about $serviceName';
      case 'maintenance':
        return '$serviceName maintenance is due';
      default:
        return '$serviceName - $timeString';
    }
  }

  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    String type = 'info',
    Duration duration = const Duration(seconds: 4),
  }) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case 'success':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case 'warning':
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case 'info':
      default:
        backgroundColor = const Color(0xFF006B3C);
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}