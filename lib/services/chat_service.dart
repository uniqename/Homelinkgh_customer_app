import 'dart:async';
// Firestore dependency removed - using simplified services
import '../models/chat_message.dart';
import '../models/booking.dart';
import 'push_notification_service.dart';

/// Real-time chat service for communication between customers and providers
class ChatService {
  static const String _chatCollection = 'chats';
  static const String _messagesSubcollection = 'messages';
  
  final _firestore // FirebaseFirestore _firestore = _firestore // FirebaseFirestore.instance;
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
      final chatMessage = ChatMessage(
        id: '',
        bookingId: bookingId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        message: message,
        messageType: messageType,
        timestamp: DateTime.now(),
        isRead: false,
        metadata: metadata,
      );

      // Add message to Firestore
      await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .collection(_messagesSubcollection)
          .add(chatMessage.toMap());

      // Update chat metadata
      await _updateChatMetadata(bookingId, chatMessage);

      // Send push notification to the other party
      await _sendChatNotification(bookingId, senderType, senderName, message);

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get real-time messages stream for a booking
  Stream<List<ChatMessage>> getMessagesStream(String bookingId) {
    return _firestore
        .collection(_chatCollection)
        .doc(bookingId)
        .collection(_messagesSubcollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      final unreadMessages = await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .collection(_messagesSubcollection)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count for a booking
  Future<int> getUnreadMessageCount(String bookingId, String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .collection(_messagesSubcollection)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return unreadMessages.docs.length;
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
      final systemMessage = ChatMessage.systemMessage(
        bookingId: bookingId,
        message: message,
        metadata: metadata,
      );

      await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .collection(_messagesSubcollection)
          .add(systemMessage.toMap());

      await _updateChatMetadata(bookingId, systemMessage);
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
      final doc = await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  /// Get all chats for a user
  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    return _firestore
        .collection(_chatCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['bookingId'] = doc.id;
        return data;
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
        'participants': [customerId, providerId],
        'participantNames': {
          customerId: customerName,
          providerId: providerName,
        },
        'participantTypes': {
          customerId: 'customer',
          providerId: 'provider',
        },
        'createdAt': DateTime.now().toIso8601String(),
        'lastMessage': 'Chat started',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'lastMessageSender': 'system',
        'unreadCount': {
          customerId: 0,
          providerId: 0,
        },
      };

      await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .set(chatData);

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
  Future<void> _updateChatMetadata(String bookingId, ChatMessage message) async {
    try {
      final updateData = {
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSender': message.senderId,
        'lastMessageType': message.messageType,
      };

      await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .update(updateData);

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
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) return;

      final booking = Booking.fromMap(bookingDoc.data()!, bookingDoc.id);
      
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
      final messagesQuery = await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .collection(_messagesSubcollection)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete chat document
      batch.delete(_firestore.collection(_chatCollection).doc(bookingId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  /// Archive chat (keep messages but mark as archived)
  Future<void> archiveChat(String bookingId) async {
    try {
      await _firestore
          .collection(_chatCollection)
          .doc(bookingId)
          .update({
        'archived': true,
        'archivedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to archive chat: $e');
    }
  }
}