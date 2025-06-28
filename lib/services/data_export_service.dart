import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class DataExportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final orders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      return {
        'user': userDoc.data(),
        'orders': orders.docs.map((doc) => doc.data()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };
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
      final batch = _firestore.batch();
      
      // Delete user document
      batch.delete(_firestore.collection('users').doc(userId));
      
      // Delete user orders
      final orders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in orders.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }
}