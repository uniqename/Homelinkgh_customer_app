import 'dart:convert';
import 'supabase_service.dart';

class DataExportService {
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      // For demonstration purposes, create sample user data
      // In a real app, this would query the actual Supabase tables
      final userData = {
        'profile': {
          'id': userId,
          'email': 'user@example.com',
          'name': 'User Name',
          'created_at': DateTime.now().toIso8601String(),
        },
        'bookings': [
          {
            'id': 'booking_1',
            'service': 'Home Cleaning',
            'date': DateTime.now().toIso8601String(),
            'status': 'completed',
          }
        ],
        'exportDate': DateTime.now().toIso8601String(),
      };
      
      return userData;
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }

  static Future<String> exportUserDataAsJson(String userId) async {
    final data = await exportUserData(userId);
    return jsonEncode(data);
  }

  static Future<void> deleteUserData(String userId) async {
    try {
      // In a real app, this would delete user data from Supabase
      // For now, we'll just simulate the deletion
      await Future.delayed(const Duration(seconds: 1));
      print('User data deleted for user: $userId');
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  static Future<Map<String, dynamic>> exportDataAsFile(String userId) async {
    try {
      final data = await exportUserData(userId);
      final jsonData = jsonEncode(data);
      final sizeInBytes = jsonData.length;
      final sizeMB = sizeInBytes / (1024 * 1024);
      
      return {
        'success': true,
        'size_mb': sizeMB,
        'data': jsonData,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to export data: $e',
      };
    }
  }

  static Stream<List<Map<String, dynamic>>> getExportHistory(String userId) {
    // Return a stream that emits sample export history
    return Stream.periodic(const Duration(seconds: 1), (count) {
      return [
        {
          'id': 'export_1',
          'userId': userId,
          'size_mb': 2.5,
          'exportDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'status': 'expired',
        }
      ];
    }).take(1);
  }

  static Future<Map<String, dynamic>> requestAccountDeletion(String userId, String reason) async {
    try {
      final deletionId = 'del_${DateTime.now().millisecondsSinceEpoch}';
      final deletionDate = DateTime.now().add(const Duration(days: 30));
      
      // In a real app, this would save to Supabase
      // For now, we'll just simulate the request
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'success': true,
        'deletionId': deletionId,
        'deletionDate': deletionDate.toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to request account deletion: $e',
      };
    }
  }
}