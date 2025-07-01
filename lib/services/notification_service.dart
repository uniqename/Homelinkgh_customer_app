import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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