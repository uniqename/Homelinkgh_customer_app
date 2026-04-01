import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

/// Notification Inbox Screen
/// Displays notification history and allows users to manage notifications
class NotificationInboxScreen extends StatefulWidget {
  final String userId;

  const NotificationInboxScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final Map<String, String> _categoryIcons = {
    'booking_updates': '📋',
    'provider_messages': '💬',
    'payment_updates': '💳',
    'service_reminders': '⏰',
    'promotions': '🎁',
    'system_updates': '🔔',
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _firebaseService.getNotificationHistory(widget.userId, 50);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firebaseService.markNotificationAsRead(notificationId);
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['read'] = true;
        }
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      for (var notification in _notifications) {
        if (notification['read'] == false) {
          await _firebaseService.markNotificationAsRead(notification['id']);
        }
      }
      await _loadNotifications();
      _showSnackBar('All notifications marked as read');
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedCategory == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n['category'] == _selectedCategory).toList();
  }

  int get _unreadCount {
    return _notifications.where((n) => n['read'] == false).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filteredNotifications;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications'),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('Mark all read', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All', 'all', _notifications.length),
                ..._categoryIcons.entries.map((entry) {
                  final count = _notifications.where((n) => n['category'] == entry.key).length;
                  return _buildCategoryChip(
                    '${entry.value} ${_getCategoryName(entry.key)}',
                    entry.key,
                    count,
                  );
                }),
              ],
            ),
          ),

          Divider(height: 1),

          // Notification List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category, int count) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ${count > 0 ? "($count)" : ""}'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Color(0xFF00A651).withOpacity(0.2),
        checkmarkColor: Color(0xFF00A651),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] ?? false;
    final category = notification['category'] ?? 'system_updates';
    final icon = _categoryIcons[category] ?? '🔔';
    final sentAt = DateTime.parse(notification['sent_at']);
    final timeAgo = _formatTimeAgo(sentAt);

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // Could implement delete functionality here
        _showSnackBar('Notification deleted');
      },
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          // Navigate to relevant screen based on notification data
        },
        child: Container(
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Color(0xFF00A651).withOpacity(0.05),
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF00A651).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification['body'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isRead)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF00A651),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            _selectedCategory == 'all'
                ? 'You\'re all caught up!'
                : 'No ${_getCategoryName(_selectedCategory).toLowerCase()} notifications',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'booking_updates':
        return 'Bookings';
      case 'provider_messages':
        return 'Messages';
      case 'payment_updates':
        return 'Payments';
      case 'service_reminders':
        return 'Reminders';
      case 'promotions':
        return 'Offers';
      case 'system_updates':
        return 'System';
      default:
        return 'Other';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
