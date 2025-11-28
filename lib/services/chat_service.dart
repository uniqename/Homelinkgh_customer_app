import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/booking.dart';
import 'supabase_service.dart';
import 'push_notification_service.dart';

/// Real-time chat service for communication between customers and providers
class ChatService {
  static const String _chatCollection = 'chats';
  static const String _messagesSubcollection = 'messages';

  final SupabaseService _supabase = SupabaseService();
  final PushNotificationService _notificationService = PushNotificationService();

  /// Send a new message in a chat
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String message,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageData = {
        'booking_id': bookingId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_type': senderType,
        'message': message,
        'message_type': messageType,
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
        'metadata': metadata,
      };

      // Add message to Supabase
      await _supabase.supabase.from(_messagesSubcollection).insert(messageData);

      // Update chat metadata
      await _updateChatMetadata(bookingId, messageData);

      // Send push notification to the other party
      await _sendChatNotification(bookingId, senderType, senderName, message);

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get real-time messages stream for a booking
  Stream<List<ChatMessage>> getMessagesStream(String bookingId) {
    return _supabase.supabase
        .from(_messagesSubcollection)
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('timestamp', ascending: true)
        .map((data) {
      return data.map((item) {
        return ChatMessage(
          id: item['id'].toString(),
          bookingId: item['booking_id'] ?? '',
          senderId: item['sender_id'] ?? '',
          senderName: item['sender_name'] ?? '',
          senderType: item['sender_type'] ?? '',
          message: item['message'] ?? '',
          messageType: item['message_type'] ?? 'text',
          timestamp: DateTime.parse(item['timestamp']),
          isRead: item['is_read'] ?? false,
          metadata: item['metadata'],
        );
      }).toList();
    });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    try {
      await _supabase.supabase
          .from(_messagesSubcollection)
          .update({'is_read': true})
          .eq('booking_id', bookingId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count for a booking
  Future<int> getUnreadMessageCount(String bookingId, String userId) async {
    try {
      final response = await _supabase.supabase
          .from(_messagesSubcollection)
          .select('id')
          .eq('booking_id', bookingId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Send system message for booking status updates
  Future<void> sendSystemMessage({
    required String bookingId,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageData = {
        'booking_id': bookingId,
        'sender_id': 'system',
        'sender_name': 'HomeLinkGH',
        'sender_type': 'system',
        'message': message,
        'message_type': 'system',
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
        'metadata': metadata,
      };

      await _supabase.supabase.from(_messagesSubcollection).insert(messageData);

      await _updateChatMetadata(bookingId, messageData);
    } catch (e) {
      throw Exception('Failed to send system message: $e');
    }
  }

  /// Send location share message
  Future<void> shareLocation({
    required String bookingId,
    required String senderId,
    required String senderName,
    required String senderType,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    await sendMessage(
      bookingId: bookingId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      message: address ?? 'Shared location',
      messageType: 'location',
      metadata: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      },
    );
  }

  /// Send image message
  Future<void> sendImage({
    required String bookingId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String imageUrl,
    String? caption,
  }) async {
    await sendMessage(
      bookingId: bookingId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      message: caption ?? 'Sent an image',
      messageType: 'image',
      metadata: {
        'imageUrl': imageUrl,
        'caption': caption,
      },
    );
  }

  /// Get chat metadata (last message, participants, etc.)
  Future<Map<String, dynamic>?> getChatMetadata(String bookingId) async {
    try {
      final response = await _supabase.supabase
          .from(_chatCollection)
          .select()
          .eq('booking_id', bookingId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get all chats for a user
  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    return _supabase.supabase
        .from(_chatCollection)
        .stream(primaryKey: ['id'])
        .contains('participants', [userId])
        .order('last_message_time', ascending: false)
        .map((data) {
      return data.map((item) {
        return {
          ...item,
          'bookingId': item['booking_id'],
        };
      }).toList();
    });
  }

  /// Initialize chat for a new booking
  Future<void> initializeChat({
    required String bookingId,
    required String customerId,
    required String providerId,
    required String customerName,
    required String providerName,
  }) async {
    try {
      final chatData = {
        'booking_id': bookingId,
        'participants': [customerId, providerId],
        'participant_names': {
          customerId: customerName,
          providerId: providerName,
        },
        'participant_types': {
          customerId: 'customer',
          providerId: 'provider',
        },
        'created_at': DateTime.now().toIso8601String(),
        'last_message': 'Chat started',
        'last_message_time': DateTime.now().toIso8601String(),
        'last_message_sender': 'system',
        'unread_count': {
          customerId: 0,
          providerId: 0,
        },
      };

      await _supabase.supabase.from(_chatCollection).insert(chatData);

      // Send welcome system message
      await sendSystemMessage(
        bookingId: bookingId,
        message: 'Chat started. You can now communicate with your service provider.',
      );

    } catch (e) {
      throw Exception('Failed to initialize chat: $e');
    }
  }

  /// Update chat metadata when a new message is sent
  Future<void> _updateChatMetadata(String bookingId, Map<String, dynamic> messageData) async {
    try {
      final updateData = {
        'last_message': messageData['message'],
        'last_message_time': messageData['timestamp'],
        'last_message_sender': messageData['sender_id'],
        'last_message_type': messageData['message_type'],
      };

      await _supabase.supabase
          .from(_chatCollection)
          .update(updateData)
          .eq('booking_id', bookingId);

    } catch (e) {
      // If document doesn't exist, it will be created when chat is initialized
    }
  }

  /// Send push notification for new chat message
  Future<void> _sendChatNotification(
    String bookingId,
    String senderType,
    String senderName,
    String message,
  ) async {
    try {
      // Get booking details to find recipient
      final bookingData = await _supabase.supabase
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      if (bookingData == null) return;

      final booking = Booking.fromMap(bookingData, bookingId);

      // Determine recipient
      final recipientId = senderType == 'customer'
          ? booking.providerId
          : booking.customerId;

      // Send notification
      await _notificationService.sendNotification(
        userId: recipientId,
        title: 'New message from $senderName',
        body: message,
        data: {
          'type': 'chat_message',
          'bookingId': bookingId,
          'senderId': senderName,
        },
      );

    } catch (e) {
      // Notification failure shouldn't break chat functionality
      print('Failed to send chat notification: $e');
    }
  }

  /// Delete chat (for completed/cancelled bookings)
  Future<void> deleteChat(String bookingId) async {
    try {
      // Delete all messages first
      await _supabase.supabase
          .from(_messagesSubcollection)
          .delete()
          .eq('booking_id', bookingId);

      // Delete chat document
      await _supabase.supabase
          .from(_chatCollection)
          .delete()
          .eq('booking_id', bookingId);

    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  /// Archive chat (keep messages but mark as archived)
  Future<void> archiveChat(String bookingId) async {
    try {
      await _supabase.supabase
          .from(_chatCollection)
          .update({
        'archived': true,
        'archived_at': DateTime.now().toIso8601String(),
      })
          .eq('booking_id', bookingId);
    } catch (e) {
      throw Exception('Failed to archive chat: $e');
    }
  }

  /// Upload image to storage and return URL
  Future<String> uploadChatImage(Uint8List imageBytes, String bookingId) async {
    try {
      return await _supabase.uploadFile(
        'chat-images',
        'chat_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        imageBytes,
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}