import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';

class DisputeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Submit a new dispute
  static Future<Map<String, dynamic>> submitDispute({
    required String bookingId,
    required String issueType,
    required String description,
    required List<String> evidencePhotos,
    required bool requestRefund,
    double? refundAmount,
  }) async {
    try {
      final disputeId = _db.collection('disputes').doc().id;
      final caseId = 'DIS-${DateTime.now().year}-${disputeId.substring(0, 6).toUpperCase()}';
      
      await _db.collection('disputes').doc(disputeId).set({
        'disputeId': disputeId,
        'caseId': caseId,
        'bookingId': bookingId,
        'issueType': issueType,
        'description': description,
        'evidencePhotos': evidencePhotos,
        'requestRefund': requestRefund,
        'refundAmount': refundAmount,
        'status': 'submitted', // submitted, under_review, provider_response, investigating, resolved
        'priority': _calculatePriority(issueType),
        'submittedAt': FieldValue.serverTimestamp(),
        'expectedResolutionAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 72)),
        ),
        'customerUserId': 'current_user_id', // Get from auth
        'providerUserId': null, // Will be populated from booking
        'mediatorId': null,
        'resolution': null,
        'refundProcessed': false,
        'communicationLog': [],
      });

      // Auto-assign priority and mediator
      await _autoAssignDispute(disputeId, issueType);
      
      // Notify relevant parties
      await NotificationService.sendDisputeNotification(
        disputeId: disputeId,
        type: 'dispute_submitted',
      );
      
      // Auto-process immediate refunds for certain cases
      if (requestRefund && _isEligibleForImmediateRefund(issueType)) {
        await _processImmediateRefund(disputeId, bookingId, refundAmount ?? 0);
      }
      
      return {
        'success': true,
        'disputeId': disputeId,
        'caseId': caseId,
        'expectedResolution': '72 hours',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Auto-assign dispute based on type and priority
  static Future<void> _autoAssignDispute(String disputeId, String issueType) async {
    final priority = _calculatePriority(issueType);
    String mediatorId;
    
    // Assign specialized mediators
    switch (issueType) {
      case 'Safety Concern':
      case 'Property Damage':
        mediatorId = 'safety_specialist_1';
        break;
      case 'Billing Error':
      case 'Payment Issue':
        mediatorId = 'billing_specialist_1';
        break;
      default:
        mediatorId = 'general_mediator_1';
    }
    
    await _db.collection('disputes').doc(disputeId).update({
      'mediatorId': mediatorId,
      'priority': priority,
      'status': 'under_review',
      'assignedAt': FieldValue.serverTimestamp(),
    });
    
    // Set auto-escalation if high priority
    if (priority == 'high') {
      await _scheduleEscalation(disputeId, 4); // 4 hours for high priority
    }
  }
  
  // Calculate dispute priority
  static String _calculatePriority(String issueType) {
    switch (issueType) {
      case 'Safety Concern':
      case 'Property Damage':
        return 'high';
      case 'Provider No-Show':
      case 'Service Quality':
        return 'medium';
      default:
        return 'low';
    }
  }
  
  // Check if eligible for immediate refund
  static bool _isEligibleForImmediateRefund(String issueType) {
    return [
      'Provider No-Show',
      'Service Not Provided',
      'Billing Error',
    ].contains(issueType);
  }
  
  // Process immediate refund for eligible cases
  static Future<void> _processImmediateRefund(String disputeId, String bookingId, double amount) async {
    try {
      // Get booking details
      final booking = await _db.collection('bookings').doc(bookingId).get();
      final bookingData = booking.data()!;
      
      // Process refund through payment service
      final refundResult = await PaymentService.processRefund(
        originalTransactionId: bookingData['transactionId'],
        amount: amount,
        reason: 'Dispute auto-refund',
        disputeId: disputeId,
      );
      
      if (refundResult['success']) {
        // Update dispute status
        await _db.collection('disputes').doc(disputeId).update({
          'refundProcessed': true,
          'refundTransactionId': refundResult['refundTransactionId'],
          'refundProcessedAt': FieldValue.serverTimestamp(),
          'status': 'resolved',
          'resolution': 'Auto-refund processed due to ${disputeId}',
        });
        
        // Notify customer
        await NotificationService.sendDisputeNotification(
          disputeId: disputeId,
          type: 'refund_processed',
        );
      }
    } catch (e) {
      print('Error processing immediate refund: $e');
    }
  }
  
  // Add communication to dispute
  static Future<void> addCommunication({
    required String disputeId,
    required String senderId,
    required String senderType, // customer, provider, mediator, system
    required String message,
    List<String> attachments = const [],
  }) async {
    await _db.collection('disputes').doc(disputeId).update({
      'communicationLog': FieldValue.arrayUnion([{
        'senderId': senderId,
        'senderType': senderType,
        'message': message,
        'attachments': attachments,
        'timestamp': FieldValue.serverTimestamp(),
      }]),
      'lastActivity': FieldValue.serverTimestamp(),
    });
    
    // Notify relevant parties
    await NotificationService.sendDisputeNotification(
      disputeId: disputeId,
      type: 'new_message',
      message: message,
    );
  }
  
  // Update dispute status
  static Future<void> updateDisputeStatus({
    required String disputeId,
    required String newStatus,
    String? resolution,
    Map<String, dynamic>? additionalData,
  }) async {
    final updateData = {
      'status': newStatus,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    
    if (resolution != null) {
      updateData['resolution'] = resolution;
      updateData['resolvedAt'] = FieldValue.serverTimestamp();
    }
    
    if (additionalData != null) {
      updateData.addAll(additionalData.cast<String, Object>());
    }
    
    await _db.collection('disputes').doc(disputeId).update(updateData);
    
    // Send status update notification
    await NotificationService.sendDisputeNotification(
      disputeId: disputeId,
      type: 'status_update',
      message: 'Dispute status updated to: $newStatus',
    );
  }
  
  // Process refund
  static Future<Map<String, dynamic>> processRefund({
    required String disputeId,
    required String bookingId,
    required double refundAmount,
    required String refundMethod, // mobile_money, bank_transfer, credit
    Map<String, String>? accountDetails,
  }) async {
    try {
      // Get original payment details
      final booking = await _db.collection('bookings').doc(bookingId).get();
      final bookingData = booking.data()!;
      
      // Calculate refund (minus processing fees if applicable)
      double finalRefundAmount = refundAmount;
      if (refundMethod == 'mobile_money') {
        finalRefundAmount -= 2.0; // ₵2 processing fee
      }
      
      // Process refund through payment gateway
      final refundResult = await PaymentService.processRefund(
        originalTransactionId: bookingData['transactionId'],
        amount: finalRefundAmount,
        reason: 'Dispute resolution refund',
        disputeId: disputeId,
        refundMethod: refundMethod,
        accountDetails: accountDetails,
      );
      
      if (refundResult['success']) {
        // Update dispute
        await _db.collection('disputes').doc(disputeId).update({
          'refundProcessed': true,
          'refundAmount': finalRefundAmount,
          'refundMethod': refundMethod,
          'refundTransactionId': refundResult['refundTransactionId'],
          'refundProcessedAt': FieldValue.serverTimestamp(),
          'status': 'resolved',
        });
        
        // Update booking
        await _db.collection('bookings').doc(bookingId).update({
          'refundStatus': 'processed',
          'refundAmount': finalRefundAmount,
          'refundProcessedAt': FieldValue.serverTimestamp(),
        });
        
        // Record refund transaction
        await _recordRefundTransaction(disputeId, bookingId, finalRefundAmount, refundResult);
        
        // Notify customer
        await NotificationService.sendDisputeNotification(
          disputeId: disputeId,
          type: 'refund_processed',
          message: 'Your refund of ₵${finalRefundAmount.toStringAsFixed(2)} has been processed.',
        );
        
        return {
          'success': true,
          'refundAmount': finalRefundAmount,
          'transactionId': refundResult['refundTransactionId'],
          'processingTime': _getRefundProcessingTime(refundMethod),
        };
      } else {
        return {
          'success': false,
          'error': refundResult['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Record refund transaction
  static Future<void> _recordRefundTransaction(
    String disputeId,
    String bookingId,
    double amount,
    Map<String, dynamic> refundResult,
  ) async {
    await _db.collection('refund_transactions').add({
      'disputeId': disputeId,
      'bookingId': bookingId,
      'amount': amount,
      'transactionId': refundResult['refundTransactionId'],
      'method': refundResult['method'],
      'status': 'processed',
      'processedAt': FieldValue.serverTimestamp(),
      'gatewayResponse': refundResult,
    });
  }
  
  // Get refund processing time
  static String _getRefundProcessingTime(String method) {
    switch (method) {
      case 'mobile_money':
        return 'Instant';
      case 'bank_transfer':
        return '3-5 business days';
      case 'credit':
        return 'Instant';
      case 'international':
        return '5-7 business days';
      default:
        return '3-5 business days';
    }
  }
  
  // Schedule auto-escalation
  static Future<void> _scheduleEscalation(String disputeId, int hours) async {
    // In a real implementation, this would use a job scheduler
    // For now, we'll add a timestamp for manual checking
    await _db.collection('disputes').doc(disputeId).update({
      'escalationScheduledAt': Timestamp.fromDate(
        DateTime.now().add(Duration(hours: hours)),
      ),
      'autoEscalationEnabled': true,
    });
  }
  
  // Get dispute by ID
  static Future<DocumentSnapshot> getDispute(String disputeId) async {
    return await _db.collection('disputes').doc(disputeId).get();
  }
  
  // Get disputes for user
  static Stream<QuerySnapshot> getUserDisputes(String userId) {
    return _db
        .collection('disputes')
        .where('customerUserId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
  
  // Get disputes for provider
  static Stream<QuerySnapshot> getProviderDisputes(String providerId) {
    return _db
        .collection('disputes')
        .where('providerUserId', isEqualTo: providerId)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
  
  // Admin: Get all disputes
  static Stream<QuerySnapshot> getAllDisputes({String? status, String? priority}) {
    Query query = _db.collection('disputes');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (priority != null) {
      query = query.where('priority', isEqualTo: priority);
    }
    
    return query.orderBy('submittedAt', descending: true).snapshots();
  }
  
  // Calculate dispute resolution metrics
  static Future<Map<String, dynamic>> getDisputeMetrics() async {
    final disputes = await _db.collection('disputes').get();
    
    int totalDisputes = disputes.size;
    int resolvedDisputes = 0;
    int avgResolutionHours = 0;
    double customerSatisfaction = 0;
    
    for (var doc in disputes.docs) {
      final data = doc.data();
      if (data['status'] == 'resolved') {
        resolvedDisputes++;
        
        if (data['submittedAt'] != null && data['resolvedAt'] != null) {
          final submitted = (data['submittedAt'] as Timestamp).toDate();
          final resolved = (data['resolvedAt'] as Timestamp).toDate();
          avgResolutionHours += resolved.difference(submitted).inHours;
        }
      }
    }
    
    if (resolvedDisputes > 0) {
      avgResolutionHours = avgResolutionHours ~/ resolvedDisputes;
    }
    
    return {
      'totalDisputes': totalDisputes,
      'resolutionRate': resolvedDisputes / totalDisputes,
      'avgResolutionHours': avgResolutionHours,
      'customerSatisfaction': customerSatisfaction,
    };
  }
}