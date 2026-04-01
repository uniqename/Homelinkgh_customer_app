import 'dart:async';
// Firestore dependency removed - using simplified services
import 'package:homelinkgh_customer/models/location.dart';
import '../models/booking.dart';
import '../models/provider.dart';
import 'chat_service.dart';
import 'push_notification_service.dart';
import 'gps_tracking_service.dart';

/// Enhanced booking service with real-time status updates and tracking
class BookingService {
  static const String _bookingsCollection = 'bookings';
  static const String _providersCollection = 'providers';
  static const String _customersCollection = 'customers';
  
  final _firestore // FirebaseFirestore _firestore = _firestore // FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  final PushNotificationService _notificationService = PushNotificationService();
  final GpsTrackingService _trackingService = GpsTrackingService();

  /// Booking status constants
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusConfirmed = 'confirmed';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusDisputed = 'disputed';

  /// Create a new booking
  Future<String> createBooking({
    required String customerId,
    required String providerId,
    required String serviceType,
    required String description,
    required DateTime scheduledDate,
    required String address,
    required LatLng location,
    required double price,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final booking = Booking(
        customerId: customerId,
        providerId: providerId,
        serviceType: serviceType,
        description: description,
        scheduledDate: scheduledDate,
        address: address,
        price: price,
        status: statusPending,
        createdAt: DateTime.now(),
      );

      final bookingData = booking.toMap();
      bookingData['location'] = {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };
      bookingData['additionalDetails'] = additionalDetails ?? {};

      // Create booking document
      final docRef = await _firestore
          .collection(_bookingsCollection)
          .add(bookingData);

      final bookingId = docRef.id;

      // Initialize chat for this booking
      final customerName = await _getUserName(customerId, 'customer');
      final providerName = await _getUserName(providerId, 'provider');
      
      await _chatService.initializeChat(
        bookingId: bookingId,
        customerId: customerId,
        providerId: providerId,
        customerName: customerName,
        providerName: providerName,
      );

      // Send notification to provider
      await _notificationService.sendNotification(
        userId: providerId,
        title: 'New Booking Request',
        body: 'You have a new $serviceType booking request',
        data: {
          'type': 'new_booking',
          'bookingId': bookingId,
        },
      );

      // Send system message
      await _chatService.sendSystemMessage(
        bookingId: bookingId,
        message: 'Booking created and sent to provider for review.',
      );

      return bookingId;

    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Update booking status with real-time notifications
  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
    String? updateMessage,
    Map<String, dynamic>? statusData,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      if (newStatus == statusCompleted) {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      if (statusData != null) {
        updateData.addAll(statusData);
      }

      await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update(updateData);

      // Get booking details for notifications
      final bookingDoc = await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) return;

      final booking = Booking.fromMap(bookingDoc.data()!, bookingId);

      // Send status update notifications
      await _sendStatusUpdateNotifications(booking, newStatus);

      // Send system message to chat
      final systemMessage = updateMessage ?? _getStatusUpdateMessage(newStatus);
      await _chatService.sendSystemMessage(
        bookingId: bookingId,
        message: systemMessage,
        metadata: {'statusUpdate': newStatus, 'timestamp': DateTime.now().toIso8601String()},
      );

      // Handle status-specific actions
      await _handleStatusSpecificActions(bookingId, booking, newStatus);

    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  /// Get real-time booking stream
  Stream<Booking?> getBookingStream(String bookingId) {
    return _firestore
        .collection(_bookingsCollection)
        .doc(bookingId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Booking.fromMap(doc.data()!, doc.id);
    });
  }

  /// Get user's bookings stream
  Stream<List<Booking>> getUserBookingsStream(String userId, {String? userType}) {
    Query query;
    
    if (userType == 'provider') {
      query = _firestore
          .collection(_bookingsCollection)
          .where('providerId', isEqualTo: userId);
    } else {
      query = _firestore
          .collection(_bookingsCollection)
          .where('customerId', isEqualTo: userId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Get active bookings (in-progress status)
  Stream<List<Booking>> getActiveBookingsStream(String userId, {String? userType}) {
    Query query;
    
    if (userType == 'provider') {
      query = _firestore
          .collection(_bookingsCollection)
          .where('providerId', isEqualTo: userId)
          .where('status', whereIn: [statusAccepted, statusConfirmed, statusInProgress]);
    } else {
      query = _firestore
          .collection(_bookingsCollection)
          .where('customerId', isEqualTo: userId)
          .where('status', whereIn: [statusAccepted, statusConfirmed, statusInProgress]);
    }

    return query
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Provider accepts booking
  Future<void> acceptBooking(String bookingId, {String? message}) async {
    await updateBookingStatus(
      bookingId: bookingId,
      newStatus: statusAccepted,
      updateMessage: message ?? 'Provider has accepted your booking request!',
    );
  }

  /// Provider confirms booking (ready to start)
  Future<void> confirmBooking(String bookingId, {String? message}) async {
    await updateBookingStatus(
      bookingId: bookingId,
      newStatus: statusConfirmed,
      updateMessage: message ?? 'Booking confirmed. Provider is ready to start service.',
    );
  }

  /// Start service (provider arrives)
  Future<void> startService(String bookingId, {LatLng? providerLocation}) async {
    final statusData = <String, dynamic>{};
    
    if (providerLocation != null) {
      statusData['startLocation'] = {
        'latitude': providerLocation.latitude,
        'longitude': providerLocation.longitude,
      };
      statusData['startTime'] = DateTime.now().toIso8601String();
    }

    await updateBookingStatus(
      bookingId: bookingId,
      newStatus: statusInProgress,
      updateMessage: 'Service has started! Track your provider in real-time.',
      statusData: statusData,
    );
  }

  /// Complete service
  Future<void> completeService(String bookingId, {String? completionNotes}) async {
    final statusData = <String, dynamic>{};
    
    if (completionNotes != null) {
      statusData['completionNotes'] = completionNotes;
    }

    await updateBookingStatus(
      bookingId: bookingId,
      newStatus: statusCompleted,
      updateMessage: 'Service completed successfully! Please rate your experience.',
      statusData: statusData,
    );
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId, String reason, String cancelledBy) async {
    await updateBookingStatus(
      bookingId: bookingId,
      newStatus: statusCancelled,
      updateMessage: 'Booking has been cancelled. Reason: $reason',
      statusData: {
        'cancellationReason': reason,
        'cancelledBy': cancelledBy,
        'cancelledAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get booking with full details (including provider and customer info)
  Future<Map<String, dynamic>?> getBookingWithDetails(String bookingId) async {
    try {
      final bookingDoc = await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) return null;

      final bookingData = bookingDoc.data()!;
      final booking = Booking.fromMap(bookingData, bookingId);

      // Get provider details
      final providerDoc = await _firestore
          .collection(_providersCollection)
          .doc(booking.providerId)
          .get();

      // Get customer details
      final customerDoc = await _firestore
          .collection(_customersCollection)
          .doc(booking.customerId)
          .get();

      return {
        'booking': booking,
        'bookingData': bookingData,
        'provider': providerDoc.exists ? providerDoc.data() : null,
        'customer': customerDoc.exists ? customerDoc.data() : null,
      };

    } catch (e) {
      return null;
    }
  }

  /// Get user name for chat initialization
  Future<String> _getUserName(String userId, String userType) async {
    try {
      final collection = userType == 'provider' ? _providersCollection : _customersCollection;
      final doc = await _firestore.collection(collection).doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return data['name'] ?? data['displayName'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// Send status update notifications to relevant parties
  Future<void> _sendStatusUpdateNotifications(Booking booking, String newStatus) async {
    try {
      String customerTitle = '';
      String customerBody = '';
      String providerTitle = '';
      String providerBody = '';

      switch (newStatus) {
        case statusAccepted:
          customerTitle = 'Booking Accepted';
          customerBody = 'Your ${booking.serviceType} booking has been accepted!';
          break;
        case statusConfirmed:
          customerTitle = 'Booking Confirmed';
          customerBody = 'Your provider is ready to start the service.';
          break;
        case statusInProgress:
          customerTitle = 'Service Started';
          customerBody = 'Your ${booking.serviceType} service is now in progress.';
          break;
        case statusCompleted:
          customerTitle = 'Service Completed';
          customerBody = 'Your ${booking.serviceType} service has been completed!';
          providerTitle = 'Service Completed';
          providerBody = 'You have successfully completed the ${booking.serviceType} service.';
          break;
        case statusCancelled:
          customerTitle = 'Booking Cancelled';
          customerBody = 'Your ${booking.serviceType} booking has been cancelled.';
          providerTitle = 'Booking Cancelled';
          providerBody = 'The ${booking.serviceType} booking has been cancelled.';
          break;
      }

      // Send to customer
      if (customerTitle.isNotEmpty) {
        await _notificationService.sendNotification(
          userId: booking.customerId,
          title: customerTitle,
          body: customerBody,
          data: {
            'type': 'booking_status_update',
            'bookingId': booking.id!,
            'status': newStatus,
          },
        );
      }

      // Send to provider
      if (providerTitle.isNotEmpty) {
        await _notificationService.sendNotification(
          userId: booking.providerId,
          title: providerTitle,
          body: providerBody,
          data: {
            'type': 'booking_status_update',
            'bookingId': booking.id!,
            'status': newStatus,
          },
        );
      }

    } catch (e) {
      print('Failed to send status update notifications: $e');
    }
  }

  /// Get appropriate system message for status updates
  String _getStatusUpdateMessage(String status) {
    switch (status) {
      case statusAccepted:
        return '✅ Booking accepted by provider';
      case statusConfirmed:
        return '🔄 Booking confirmed - service ready to start';
      case statusInProgress:
        return '🚀 Service started - tracking active';
      case statusCompleted:
        return '✅ Service completed successfully';
      case statusCancelled:
        return '❌ Booking cancelled';
      case statusDisputed:
        return '⚠️ Booking under dispute review';
      default:
        return 'Booking status updated';
    }
  }

  /// Handle status-specific actions
  Future<void> _handleStatusSpecificActions(String bookingId, Booking booking, String newStatus) async {
    try {
      switch (newStatus) {
        case statusInProgress:
          // Start GPS tracking for the provider
          await _trackingService.startTracking(bookingId, booking.providerId);
          break;
        case statusCompleted:
          // Stop GPS tracking
          await _trackingService.stopTracking(bookingId);
          // Archive chat after 7 days (could be scheduled)
          break;
        case statusCancelled:
          // Stop any active tracking
          await _trackingService.stopTracking(bookingId);
          break;
      }
    } catch (e) {
      print('Error in status-specific actions: $e');
    }
  }
}