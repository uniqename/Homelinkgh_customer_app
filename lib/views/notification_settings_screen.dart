import 'package:flutter/material.dart';
import '../services/push_notification_service.dart';

/// Notification Settings Screen for HomeLinkGH
/// Allows users to manage push notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final PushNotificationService _notificationService = PushNotificationService();
  
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  Map<String, bool> _categoryPreferences = {};
  List<Map<String, dynamic>> _notificationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoading = true);

    try {
      // Initialize notification service if needed
      if (!_notificationService.isInitialized) {
        await _notificationService.initialize();
      }

      // Load current preferences
      _notificationsEnabled = _notificationService.notificationsEnabled;
      
      // Initialize category preferences
      for (String category in PushNotificationService.notificationCategories.keys) {
        _categoryPreferences[category] = true; // Default to enabled
      }

      // Load notification history
      final history = await _notificationService.getNotificationHistory(
        userId: 'current_user', // Replace with actual user ID
        limit: 20,
      );
      
      setState(() {
        _notificationHistory = history;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
      _showError('Failed to load notification settings: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateNotificationSettings() async {
    try {
      final success = await _notificationService.updateNotificationPreferences(
        enabled: _notificationsEnabled,
        categoryPreferences: _categoryPreferences,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Failed to update notification preferences');
      }
    } catch (e) {
      print('Error updating notification settings: $e');
      _showError('Failed to update preferences: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _testNotification() async {
    try {
      await _notificationService.sendNotification(
        userId: 'current_user', // Replace with actual user ID
        title: 'Test Notification 🔔',
        body: 'This is a test notification from HomeLinkGH',
        category: 'system_updates',
        data: {'test': 'true'},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      _showError('Failed to send test notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: _testNotification,
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildSettingsContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading notification settings...'),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationStatus(),
          const SizedBox(height: 20),
          _buildMasterToggle(),
          const SizedBox(height: 20),
          if (_notificationsEnabled) ...[
            _buildCategorySettings(),
            const SizedBox(height: 20),
            _buildNotificationHistory(),
          ] else ...[
            _buildDisabledState(),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                  color: _notificationsEnabled ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _notificationsEnabled ? 'Notifications Enabled' : 'Notifications Disabled',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _notificationsEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                      Text(
                        _notificationsEnabled 
                          ? 'You\'ll receive notifications for important updates'
                          : 'You won\'t receive any push notifications',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_notificationService.fcmToken != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Device Token: ${_notificationService.fcmToken!.substring(0, 20)}...',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Master Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable or disable all push notifications from HomeLinkGH',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Push Notifications'),
              subtitle: const Text('Receive important updates and alerts'),
              value: _notificationsEnabled,
              activeColor: const Color(0xFF006B3C),
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await _updateNotificationSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySettings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose which types of notifications you want to receive',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...PushNotificationService.notificationCategories.entries.map((entry) {
              final category = entry.key;
              final info = entry.value;
              final isEnabled = _categoryPreferences[category] ?? true;

              return Column(
                children: [
                  SwitchListTile(
                    title: Text(info['title']!),
                    subtitle: Text(info['description']!),
                    value: isEnabled,
                    activeColor: const Color(0xFF006B3C),
                    secondary: _getCategoryIcon(info['icon']!),
                    onChanged: (value) async {
                      setState(() => _categoryPreferences[category] = value);
                      await _updateNotificationSettings();
                    },
                  ),
                  if (category != PushNotificationService.notificationCategories.keys.last)
                    const Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledState() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Notifications Disabled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable notifications to receive important updates about your bookings, payments, and service providers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                setState(() => _notificationsEnabled = true);
                await _updateNotificationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enable Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHistory() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _loadNotificationSettings,
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Your recent notification history',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_notificationHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No notifications yet'),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: _notificationHistory.take(5).map((notification) {
                  return _buildNotificationHistoryItem(notification);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHistoryItem(Map<String, dynamic> notification) {
    final isRead = notification['read'] ?? false;
    final category = notification['category'] ?? 'system_updates';
    final sentAt = DateTime.tryParse(notification['sent_at'] ?? '');

    return ListTile(
      leading: _getCategoryIcon(
        PushNotificationService.notificationCategories[category]?['icon'] ?? 'system',
        isRead: isRead,
      ),
      title: Text(
        notification['title'] ?? 'Notification',
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification['body'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (sentAt != null)
            Text(
              _formatNotificationTime(sentAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      trailing: isRead ? null : Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
      onTap: () async {
        if (!isRead) {
          await _notificationService.markNotificationAsRead(notification['id']);
          _loadNotificationSettings(); // Refresh to update read status
        }
      },
    );
  }

  Widget _getCategoryIcon(String iconType, {bool isRead = true}) {
    IconData iconData;
    Color iconColor = isRead ? Colors.grey : const Color(0xFF006B3C);

    switch (iconType) {
      case 'booking':
        iconData = Icons.book_online;
        break;
      case 'message':
        iconData = Icons.message;
        break;
      case 'payment':
        iconData = Icons.payment;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        break;
      case 'system':
      default:
        iconData = Icons.system_update;
        break;
    }

    return Icon(iconData, color: iconColor);
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}