import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Send emergency alert with location
  Future<bool> sendEmergencyAlert({
    required String userId,
    required Position location,
    String? message,
  }) async {
    try {
      // Create emergency alert document
      final alertData = {
        'userId': userId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'timestamp': FieldValue.serverTimestamp(),
        'message': message ?? 'Emergency alert triggered',
        'status': 'active',
        'type': 'location_alert',
      };

      // Save to emergency_alerts collection
      final alertRef = await _firestore
          .collection('emergency_alerts')
          .add(alertData);

      // Get user data to find emergency contacts
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = AppUser.fromFirestore(userDoc);
        
        // Notify emergency contacts if available
        if (userData.emergencyContact != null && 
            userData.emergencyContactPhone != null) {
          
          await _notifyEmergencyContacts(
            alertId: alertRef.id,
            userName: userData.displayName ?? 'Someone',
            emergencyContact: userData.emergencyContact!,
            emergencyPhone: userData.emergencyContactPhone!,
            location: location,
          );
        }

        // Notify NGO staff
        await _notifyNGOStaff(
          alertId: alertRef.id,
          userId: userId,
          userName: userData.displayName ?? 'Anonymous',
          location: location,
          isAnonymous: userData.isAnonymous,
        );
      }

      return true;
    } catch (e) {
      print('Error sending emergency alert: $e');
      return false;
    }
  }

  // Create emergency case
  Future<String?> createEmergencyCase({
    required String survivorId,
    required String description,
    Position? location,
    String? contactInfo,
  }) async {
    try {
      final caseData = {
        'survivorId': survivorId,
        'type': 'emergency',
        'priority': 'critical',
        'status': 'pending',
        'title': 'Emergency Support Request',
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': true,
        'contactInfo': contactInfo,
        'location': location != null ? {
          'latitude': location.latitude,
          'longitude': location.longitude,
        } : null,
        'notes': [],
        'attachments': [],
      };

      final caseRef = await _firestore
          .collection('cases')
          .add(caseData);

      // Assign to available counselor
      await _assignEmergencyCase(caseRef.id);

      return caseRef.id;
    } catch (e) {
      print('Error creating emergency case: $e');
      return null;
    }
  }

  // Get nearby emergency resources
  Future<List<Map<String, dynamic>>> getNearbyEmergencyResources({
    required Position userLocation,
    double radiusKm = 10.0,
  }) async {
    try {
      // Get all emergency resources
      final resourcesQuery = await _firestore
          .collection('resources')
          .where('type', whereIn: ['shelter', 'medical', 'emergency', 'hotline'])
          .where('status', isEqualTo: 'available')
          .get();

      List<Map<String, dynamic>> nearbyResources = [];

      for (final doc in resourcesQuery.docs) {
        final data = doc.data();
        
        if (data['latitude'] != null && data['longitude'] != null) {
          final distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            data['latitude'],
            data['longitude'],
          ) / 1000; // Convert to km

          if (distance <= radiusKm) {
            nearbyResources.add({
              'id': doc.id,
              'distance': distance,
              ...data,
            });
          }
        } else {
          // Include resources without location (like hotlines)
          if (data['type'] == 'hotline' || data['type'] == 'emergency') {
            nearbyResources.add({
              'id': doc.id,
              'distance': 0.0,
              ...data,
            });
          }
        }
      }

      // Sort by distance
      nearbyResources.sort((a, b) => a['distance'].compareTo(b['distance']));

      return nearbyResources;
    } catch (e) {
      print('Error getting nearby emergency resources: $e');
      return [];
    }
  }

  // Get emergency hotlines
  Future<List<Map<String, dynamic>>> getEmergencyHotlines() async {
    try {
      final hotlinesQuery = await _firestore
          .collection('resources')
          .where('type', isEqualTo: 'hotline')
          .where('is24Hours', isEqualTo: true)
          .orderBy('name')
          .get();

      return hotlinesQuery.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting emergency hotlines: $e');
      return [];
    }
  }

  // Private helper methods
  Future<void> _notifyEmergencyContacts({
    required String alertId,
    required String userName,
    required String emergencyContact,
    required String emergencyPhone,
    required Position location,
  }) async {
    try {
      // In a real implementation, this would send SMS/call to emergency contact
      // For now, we'll log the emergency alert
      await _firestore.collection('emergency_notifications').add({
        'alertId': alertId,
        'type': 'emergency_contact',
        'contactName': emergencyContact,
        'contactPhone': emergencyPhone,
        'userName': userName,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
    } catch (e) {
      print('Error notifying emergency contacts: $e');
    }
  }

  Future<void> _notifyNGOStaff({
    required String alertId,
    required String userId,
    required String userName,
    required Position location,
    required bool isAnonymous,
  }) async {
    try {
      // Get available counselors and admin users
      final staffQuery = await _firestore
          .collection('users')
          .where('userType', whereIn: ['counselor', 'admin'])
          .where('isAvailable', isEqualTo: true)
          .get();

      // Send notification to all available staff
      for (final staffDoc in staffQuery.docs) {
        await _firestore.collection('notifications').add({
          'userId': staffDoc.id,
          'type': 'emergency_alert',
          'title': 'Emergency Alert Received',
          'message': isAnonymous 
              ? 'Anonymous user needs immediate assistance'
              : '$userName needs immediate assistance',
          'data': {
            'alertId': alertId,
            'survivorId': userId,
            'location': {
              'latitude': location.latitude,
              'longitude': location.longitude,
            },
            'isAnonymous': isAnonymous,
          },
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      print('Error notifying NGO staff: $e');
    }
  }

  Future<void> _assignEmergencyCase(String caseId) async {
    try {
      // Find available counselor with shortest queue
      final counselorsQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'counselor')
          .where('isAvailable', isEqualTo: true)
          .get();

      if (counselorsQuery.docs.isNotEmpty) {
        // For now, assign to first available counselor
        // In a real implementation, you might implement load balancing
        final counselorId = counselorsQuery.docs.first.id;

        await _firestore
            .collection('cases')
            .doc(caseId)
            .update({
          'assignedCounselorId': counselorId,
          'status': 'active',
          'assignedAt': FieldValue.serverTimestamp(),
        });

        // Notify the assigned counselor
        await _firestore.collection('notifications').add({
          'userId': counselorId,
          'type': 'case_assigned',
          'title': 'Emergency Case Assigned',
          'message': 'You have been assigned a critical emergency case',
          'data': {'caseId': caseId},
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      print('Error assigning emergency case: $e');
    }
  }
}