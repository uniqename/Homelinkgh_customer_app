import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({super.key});

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Initialize push notifications
    _notificationService.initializePushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Demo'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Push Notification Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Test the push notification system with different notification types.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Quote Update Notifications
            _buildSectionHeader('Quote Update Notifications'),
            const SizedBox(height: 16),
            
            _buildNotificationButton(
              title: 'Quote Accepted',
              description: 'Simulate customer accepting a quote',
              color: Colors.green,
              onPressed: () => _sendQuoteUpdateNotification('accepted'),
            ),
            
            _buildNotificationButton(
              title: 'Quote Rejected',
              description: 'Simulate customer rejecting a quote',
              color: Colors.red,
              onPressed: () => _sendQuoteUpdateNotification('rejected'),
            ),
            
            _buildNotificationButton(
              title: 'Service Completed',
              description: 'Simulate service completion',
              color: Colors.blue,
              onPressed: () => _sendQuoteUpdateNotification('completed'),
            ),

            const SizedBox(height: 24),

            // New Request Notifications
            _buildSectionHeader('New Request Notifications'),
            const SizedBox(height: 16),
            
            _buildNotificationButton(
              title: 'Emergency Request',
              description: 'Simulate urgent service request',
              color: Colors.orange,
              onPressed: () => _sendNewRequestNotification('Emergency (within 2 hours)'),
            ),
            
            _buildNotificationButton(
              title: 'Regular Request',
              description: 'Simulate regular service request',
              color: const Color(0xFF006B3C),
              onPressed: () => _sendNewRequestNotification('Scheduled (within 3 days)'),
            ),

            const SizedBox(height: 24),

            // Service Reminders
            _buildSectionHeader('Service Reminders'),
            const SizedBox(height: 16),
            
            _buildNotificationButton(
              title: 'Upcoming Service',
              description: 'Remind about scheduled service',
              color: Colors.purple,
              onPressed: () => _sendServiceReminder('upcoming_service'),
            ),
            
            _buildNotificationButton(
              title: 'Follow-up Reminder',
              description: 'Remind to follow up with customer',
              color: Colors.teal,
              onPressed: () => _sendServiceReminder('follow_up'),
            ),

            const Spacer(),

            // FCM Token Display
            FutureBuilder<String?>(
              future: _notificationService.getFCMToken(),
              builder: (context, snapshot) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FCM Token:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.data ?? 'Loading...',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF006B3C),
      ),
    );
  }

  Widget _buildNotificationButton({
    required String title,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuoteUpdateNotification(String status) {
    _notificationService.sendQuoteUpdateNotification(
      quoteId: 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
      customerName: 'Demo Customer',
      status: status,
      amount: 250.0,
    );

    _showSuccessSnackBar('$status notification sent!');
  }

  void _sendNewRequestNotification(String urgency) {
    _notificationService.sendNewQuoteRequestNotification(
      requestId: 'REQ_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: 'Demo Service',
      customerLocation: 'East Legon, Accra',
      urgency: urgency,
    );

    _showSuccessSnackBar('New request notification sent!');
  }

  void _sendServiceReminder(String reminderType) {
    _notificationService.sendServiceReminderNotification(
      serviceId: 'SVC_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: 'Demo Service',
      reminderType: reminderType,
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
    );

    _showSuccessSnackBar('Service reminder sent!');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}