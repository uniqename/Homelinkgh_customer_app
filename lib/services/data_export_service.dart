import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class DataExportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Export user data (GDPR compliance)
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final userData = <String, dynamic>{};
      
      // Basic user profile
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        userData['profile'] = _sanitizeData(userDoc.data()!);
      }
      
      // Booking history
      final bookings = await _db
          .collection('bookings')
          .where('customerId', isEqualTo: userId)
          .get();
      
      userData['bookings'] = bookings.docs
          .map((doc) => {
                'id': doc.id,
                'data': _sanitizeData(doc.data()),
              })
          .toList();
      
      // Provider data (if user is a provider)
      final providerDoc = await _db.collection('providers').doc(userId).get();
      if (providerDoc.exists) {
        userData['provider_profile'] = _sanitizeData(providerDoc.data()!);
        
        // Provider earnings
        final earnings = await _db
            .collection('earnings')
            .where('providerId', isEqualTo: userId)
            .get();
        
        userData['earnings'] = earnings.docs
            .map((doc) => {
                  'id': doc.id,
                  'data': _sanitizeData(doc.data()),
                })
            .toList();
        
        // Payouts
        final payouts = await _db
            .collection('payouts')
            .where('providerId', isEqualTo: userId)
            .get();
        
        userData['payouts'] = payouts.docs
            .map((doc) => {
                  'id': doc.id,
                  'data': _sanitizeData(doc.data()),
                })
            .toList();
      }
      
      // Referrals
      final referrals = await _db
          .collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .get();
      
      userData['referrals'] = referrals.docs
          .map((doc) => {
                'id': doc.id,
                'data': _sanitizeData(doc.data()),
              })
          .toList();
      
      // Disputes
      final disputes = await _db
          .collection('disputes')
          .where('customerUserId', isEqualTo: userId)
          .get();
      
      userData['disputes'] = disputes.docs
          .map((doc) => {
                'id': doc.id,
                'data': _sanitizeData(doc.data()),
              })
          .toList();
      
      // Ratings and reviews
      final ratings = await _db
          .collection('service_ratings')
          .where('customerId', isEqualTo: userId)
          .get();
      
      userData['ratings_given'] = ratings.docs
          .map((doc) => {
                'id': doc.id,
                'data': _sanitizeData(doc.data()),
              })
          .toList();
      
      // Notification logs
      final notifications = await _db
          .collection('notification_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(100)
          .get();
      
      userData['notifications'] = notifications.docs
          .map((doc) => {
                'id': doc.id,
                'data': _sanitizeData(doc.data()),
              })
          .toList();
      
      // App usage data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      userData['app_preferences'] = _getAppPreferences(prefs);
      
      // Export metadata
      userData['export_metadata'] = {
        'exported_at': DateTime.now().toIso8601String(),
        'export_version': '1.0',
        'app_version': '1.0.0',
        'total_records': _countRecords(userData),
        'data_retention_policy': 'Data retained for 7 years or until account deletion',
        'export_format': 'JSON',
      };
      
      return {
        'success': true,
        'data': userData,
        'size_mb': _calculateDataSize(userData),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Export data as downloadable file
  static Future<Map<String, dynamic>> exportDataAsFile(String userId) async {
    try {
      final exportResult = await exportUserData(userId);
      
      if (!exportResult['success']) {
        return exportResult;
      }
      
      final userData = exportResult['data'];
      final jsonString = json.encode(userData);
      
      // Create export record
      await _createExportRecord(userId, exportResult['size_mb']);
      
      return {
        'success': true,
        'filename': 'homelink_gh_data_export_$userId.json',
        'content': jsonString,
        'size_mb': exportResult['size_mb'],
        'download_expires': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Request account deletion
  static Future<Map<String, dynamic>> requestAccountDeletion(String userId, String reason) async {
    try {
      // Create deletion request
      final deletionId = _db.collection('deletion_requests').doc().id;
      
      await _db.collection('deletion_requests').doc(deletionId).set({
        'deletionId': deletionId,
        'userId': userId,
        'reason': reason,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, approved, processing, completed
        'scheduledDeletionAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)), // 30-day grace period
        ),
        'dataExported': false,
        'notificationsSent': false,
      });
      
      // Mark user account for deletion
      await _db.collection('users').doc(userId).update({
        'accountStatus': 'deletion_requested',
        'deletionRequestId': deletionId,
        'deletionRequestedAt': FieldValue.serverTimestamp(),
      });
      
      // Send confirmation notification
      await _sendDeletionConfirmationNotification(userId, deletionId);
      
      return {
        'success': true,
        'deletionId': deletionId,
        'gracePeriodDays': 30,
        'scheduledDeletionDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Cancel account deletion
  static Future<Map<String, dynamic>> cancelAccountDeletion(String userId) async {
    try {
      // Get deletion request
      final userDoc = await _db.collection('users').doc(userId).get();
      final deletionRequestId = userDoc.data()?['deletionRequestId'];
      
      if (deletionRequestId == null) {
        return {
          'success': false,
          'error': 'No deletion request found',
        };
      }
      
      // Cancel deletion request
      await _db.collection('deletion_requests').doc(deletionRequestId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      // Restore user account
      await _db.collection('users').doc(userId).update({
        'accountStatus': 'active',
        'deletionRequestId': FieldValue.delete(),
        'deletionRequestedAt': FieldValue.delete(),
        'deletionCancelledAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'Account deletion cancelled successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Backup user data to cloud storage
  static Future<Map<String, dynamic>> backupUserData(String userId) async {
    try {
      final exportResult = await exportUserData(userId);
      
      if (!exportResult['success']) {
        return exportResult;
      }
      
      final userData = exportResult['data'];
      
      // Store backup in Firestore
      final backupId = _db.collection('user_backups').doc().id;
      
      await _db.collection('user_backups').doc(backupId).set({
        'backupId': backupId,
        'userId': userId,
        'data': userData,
        'createdAt': FieldValue.serverTimestamp(),
        'size_mb': exportResult['size_mb'],
        'version': '1.0',
        'type': 'user_data_backup',
      });
      
      // Update user's last backup timestamp
      await _db.collection('users').doc(userId).update({
        'lastBackupAt': FieldValue.serverTimestamp(),
        'lastBackupId': backupId,
      });
      
      return {
        'success': true,
        'backupId': backupId,
        'size_mb': exportResult['size_mb'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Get data export history
  static Stream<QuerySnapshot> getExportHistory(String userId) {
    return _db
        .collection('export_records')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Get backup history
  static Stream<QuerySnapshot> getBackupHistory(String userId) {
    return _db
        .collection('user_backups')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Data retention policy
  static Future<void> enforceDataRetention() async {
    try {
      // Delete old exports (older than 30 days)
      final oldExports = await _db
          .collection('export_records')
          .where('createdAt', isLessThan: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 30)),
          ))
          .get();
      
      for (final doc in oldExports.docs) {
        await doc.reference.delete();
      }
      
      // Delete old backups (keep only last 5 per user)
      final users = await _db.collection('users').get();
      
      for (final userDoc in users.docs) {
        final backups = await _db
            .collection('user_backups')
            .where('userId', isEqualTo: userDoc.id)
            .orderBy('createdAt', descending: true)
            .get();
        
        // Keep only the 5 most recent backups
        if (backups.docs.length > 5) {
          for (int i = 5; i < backups.docs.length; i++) {
            await backups.docs[i].reference.delete();
          }
        }
      }
      
      // Process scheduled deletions
      await _processScheduledDeletions();
      
    } catch (e) {
      print('Error enforcing data retention: $e');
    }
  }
  
  // Process scheduled account deletions
  static Future<void> _processScheduledDeletions() async {
    final scheduledDeletions = await _db
        .collection('deletion_requests')
        .where('status', isEqualTo: 'pending')
        .where('scheduledDeletionAt', isLessThan: Timestamp.now())
        .get();
    
    for (final deletionDoc in scheduledDeletions.docs) {
      final deletionData = deletionDoc.data();
      final userId = deletionData['userId'];
      
      try {
        // Export data before deletion (if not already done)
        if (!deletionData['dataExported']) {
          await exportDataAsFile(userId);
          await deletionDoc.reference.update({
            'dataExported': true,
            'dataExportedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Delete all user data
        await _deleteUserData(userId);
        
        // Mark deletion as completed
        await deletionDoc.reference.update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
        
      } catch (e) {
        print('Error processing deletion for user $userId: $e');
        await deletionDoc.reference.update({
          'status': 'failed',
          'error': e.toString(),
          'failedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
  
  // Delete all user data
  static Future<void> _deleteUserData(String userId) async {
    final batch = _db.batch();
    
    // Collections to delete from
    final collections = [
      'users',
      'providers',
      'bookings',
      'earnings',
      'payouts',
      'referrals',
      'disputes',
      'service_ratings',
      'notification_logs',
      'user_backups',
      'export_records',
    ];
    
    for (final collection in collections) {
      final docs = await _db
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      
      // Also check for providerId, customerId, etc.
      final providerDocs = await _db
          .collection(collection)
          .where('providerId', isEqualTo: userId)
          .get();
      
      for (final doc in providerDocs.docs) {
        batch.delete(doc.reference);
      }
      
      final customerDocs = await _db
          .collection(collection)
          .where('customerId', isEqualTo: userId)
          .get();
      
      for (final doc in customerDocs.docs) {
        batch.delete(doc.reference);
      }
    }
    
    await batch.commit();
  }
  
  // Helper methods
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    // Remove sensitive fields that shouldn't be exported
    final sensitiveFields = [
      'fcmToken',
      'deviceInfo',
      'ipAddress',
      'internalNotes',
      'moderatorFlags',
    ];
    
    final sanitized = Map<String, dynamic>.from(data);
    for (final field in sensitiveFields) {
      sanitized.remove(field);
    }
    
    // Convert Timestamps to ISO strings
    for (final key in sanitized.keys) {
      if (sanitized[key] is Timestamp) {
        sanitized[key] = (sanitized[key] as Timestamp).toDate().toIso8601String();
      }
    }
    
    return sanitized;
  }
  
  static Map<String, dynamic> _getAppPreferences(SharedPreferences prefs) {
    final keys = prefs.getKeys();
    final preferences = <String, dynamic>{};
    
    for (final key in keys) {
      try {
        preferences[key] = prefs.get(key);
      } catch (e) {
        // Skip problematic keys
      }
    }
    
    return preferences;
  }
  
  static int _countRecords(Map<String, dynamic> userData) {
    int count = 0;
    for (final value in userData.values) {
      if (value is List) {
        count += value.length;
      } else if (value is Map) {
        count += 1;
      }
    }
    return count;
  }
  
  static double _calculateDataSize(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    final bytes = utf8.encode(jsonString).length;
    return bytes / (1024 * 1024); // Convert to MB
  }
  
  static Future<void> _createExportRecord(String userId, double sizeMb) async {
    await _db.collection('export_records').add({
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'size_mb': sizeMb,
      'type': 'user_data_export',
      'downloadCount': 0,
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
    });
  }
  
  static Future<void> _sendDeletionConfirmationNotification(String userId, String deletionId) async {
    // This would integrate with the notification service
    print('Sending deletion confirmation to user: $userId, deletion ID: $deletionId');
  }
}