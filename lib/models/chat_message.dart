import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat message model for real-time communication between customers and providers
class ChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String senderType; // 'customer' or 'provider'
  final String message;
  final String messageType; // 'text', 'image', 'location', 'system'
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata; // For images, locations, etc.

  ChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    this.messageType = 'text',
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? bookingId,
    String? senderId,
    String? senderName,
    String? senderType,
    String? message,
    String? messageType,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'messageType': messageType,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      bookingId: map['bookingId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderType: map['senderType'] ?? '',
      message: map['message'] ?? '',
      messageType: map['messageType'] ?? 'text',
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      metadata: map['metadata'],
    );
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromMap(data, doc.id);
  }

  /// Creates a system message for booking status updates
  factory ChatMessage.systemMessage({
    required String bookingId,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: '',
      bookingId: bookingId,
      senderId: 'system',
      senderName: 'HomeLinkGH',
      senderType: 'system',
      message: message,
      messageType: 'system',
      timestamp: DateTime.now(),
      isRead: false,
      metadata: metadata,
    );
  }

  /// Check if message is from current user
  bool isFromUser(String currentUserId) {
    return senderId == currentUserId;
  }

  /// Check if message is a system message
  bool get isSystemMessage => senderType == 'system';

  /// Get display time for message
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}