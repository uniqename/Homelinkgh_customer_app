import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/resource.dart';

class ResourceService {
  static final ResourceService _instance = ResourceService._internal();
  factory ResourceService() => _instance;
  ResourceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all resources by type
  Future<List<Resource>> getResourcesByType(ResourceType type) async {
    try {
      final query = await _firestore
          .collection('resources')
          .where('type', isEqualTo: type.toString().split('.').last)
          .where('status', isEqualTo: 'available')
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => Resource.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting resources by type: $e');
      return [];
    }
  }

  // Get nearby resources based on user location
  Future<List<Resource>> getNearbyResources({
    required Position userLocation,
    ResourceType? type,
    double radiusKm = 20.0,
  }) async {
    try {
      Query query = _firestore
          .collection('resources')
          .where('status', isEqualTo: 'available');

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      final querySnapshot = await query.get();
      List<Resource> nearbyResources = [];

      for (final doc in querySnapshot.docs) {
        final resource = Resource.fromFirestore(doc);
        
        if (resource.latitude != null && resource.longitude != null) {
          final distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            resource.latitude!,
            resource.longitude!,
          ) / 1000; // Convert to km

          if (distance <= radiusKm) {
            nearbyResources.add(resource);
          }
        } else {
          // Include resources without location (like hotlines)
          if (resource.type == ResourceType.hotline || 
              resource.type == ResourceType.emergency) {
            nearbyResources.add(resource);
          }
        }
      }

      // Sort by distance (resources without location come first)
      nearbyResources.sort((a, b) {
        if (a.latitude == null || a.longitude == null) return -1;
        if (b.latitude == null || b.longitude == null) return 1;

        final distanceA = Geolocator.distanceBetween(
          userLocation.latitude, userLocation.longitude,
          a.latitude!, a.longitude!,
        );
        final distanceB = Geolocator.distanceBetween(
          userLocation.latitude, userLocation.longitude,
          b.latitude!, b.longitude!,
        );

        return distanceA.compareTo(distanceB);
      });

      return nearbyResources;
    } catch (e) {
      print('Error getting nearby resources: $e');
      return [];
    }
  }

  // Get available shelters with capacity
  Future<List<Resource>> getAvailableShelters() async {
    try {
      final query = await _firestore
          .collection('resources')
          .where('type', isEqualTo: 'shelter')
          .where('status', isEqualTo: 'available')
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => Resource.fromFirestore(doc))
          .where((resource) => resource.hasAvailableSpace)
          .toList();
    } catch (e) {
      print('Error getting available shelters: $e');
      return [];
    }
  }

  // Search resources by name or services
  Future<List<Resource>> searchResources(String searchTerm) async {
    try {
      final searchLower = searchTerm.toLowerCase();
      
      // Get all resources and filter locally (Firestore doesn't support full-text search)
      final allResourcesQuery = await _firestore
          .collection('resources')
          .where('status', isEqualTo: 'available')
          .get();

      final allResources = allResourcesQuery.docs
          .map((doc) => Resource.fromFirestore(doc))
          .toList();

      return allResources.where((resource) {
        return resource.name.toLowerCase().contains(searchLower) ||
               resource.description.toLowerCase().contains(searchLower) ||
               resource.services.any((service) => 
                   service.toLowerCase().contains(searchLower));
      }).toList();
    } catch (e) {
      print('Error searching resources: $e');
      return [];
    }
  }

  // Get emergency hotlines (24/7 available)
  Future<List<Resource>> getEmergencyHotlines() async {
    try {
      final query = await _firestore
          .collection('resources')
          .where('type', isEqualTo: 'hotline')
          .where('is24Hours', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => Resource.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting emergency hotlines: $e');
      return [];
    }
  }

  // Book/request a resource
  Future<bool> requestResource({
    required String resourceId,
    required String userId,
    String? notes,
    DateTime? preferredDate,
  }) async {
    try {
      final requestData = {
        'resourceId': resourceId,
        'userId': userId,
        'status': 'pending',
        'notes': notes,
        'preferredDate': preferredDate != null 
            ? Timestamp.fromDate(preferredDate) 
            : null,
        'requestedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('resource_requests').add(requestData);

      // Create a case for follow-up if needed
      await _createResourceCase(
        resourceId: resourceId,
        userId: userId,
        notes: notes,
      );

      return true;
    } catch (e) {
      print('Error requesting resource: $e');
      return false;
    }
  }

  // Get user's resource requests
  Future<List<Map<String, dynamic>>> getUserResourceRequests(String userId) async {
    try {
      final query = await _firestore
          .collection('resource_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      List<Map<String, dynamic>> requests = [];

      for (final doc in query.docs) {
        final requestData = doc.data();
        
        // Get resource details
        final resourceDoc = await _firestore
            .collection('resources')
            .doc(requestData['resourceId'])
            .get();

        if (resourceDoc.exists) {
          final resource = Resource.fromFirestore(resourceDoc);
          requests.add({
            'id': doc.id,
            'resource': resource,
            'status': requestData['status'],
            'notes': requestData['notes'],
            'preferredDate': requestData['preferredDate']?.toDate(),
            'requestedAt': requestData['requestedAt']?.toDate(),
          });
        }
      }

      return requests;
    } catch (e) {
      print('Error getting user resource requests: $e');
      return [];
    }
  }

  // Add sample resources for testing
  Future<void> addSampleResources() async {
    try {
      final sampleResources = [
        {
          'name': 'Beacon of New Beginnings Emergency Shelter',
          'description': 'Secure emergency accommodation for women and children escaping domestic violence',
          'type': 'shelter',
          'status': 'available',
          'address': 'Accra, Ghana',
          'phone': '+233-XXX-XXXX',
          'email': 'shelter@beaconnewbeginnings.org',
          'services': ['Emergency accommodation', 'Meals', 'Childcare', 'Security'],
          'operatingHours': {
            'monday': '24 hours',
            'tuesday': '24 hours',
            'wednesday': '24 hours',
            'thursday': '24 hours',
            'friday': '24 hours',
            'saturday': '24 hours',
            'sunday': '24 hours',
          },
          'requiresAppointment': false,
          'is24Hours': true,
          'latitude': 5.6037,
          'longitude': -0.1870,
          'capacity': 50,
          'currentOccupancy': 32,
          'eligibilityCriteria': ['Women and children', 'Domestic violence survivors'],
          'contactPerson': 'Sarah Mensah',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Legal Aid Ghana - Domestic Violence Unit',
          'description': 'Free legal support for domestic violence cases',
          'type': 'legal',
          'status': 'available',
          'address': 'Ring Road, Accra',
          'phone': '+233-XXX-XXXX',
          'email': 'legal@legalaidgh.org',
          'services': ['Legal consultation', 'Court representation', 'Restraining orders'],
          'operatingHours': {
            'monday': '8:00 AM - 5:00 PM',
            'tuesday': '8:00 AM - 5:00 PM',
            'wednesday': '8:00 AM - 5:00 PM',
            'thursday': '8:00 AM - 5:00 PM',
            'friday': '8:00 AM - 5:00 PM',
          },
          'requiresAppointment': true,
          'is24Hours': false,
          'latitude': 5.5502,
          'longitude': -0.2174,
          'eligibilityCriteria': ['Low income', 'Domestic violence cases'],
          'contactPerson': 'Kwame Asante',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Domestic Violence Hotline Ghana',
          'description': '24/7 crisis support and counseling for domestic violence survivors',
          'type': 'hotline',
          'status': 'available',
          'phone': '+233-XXX-XXXX',
          'services': ['Crisis counseling', 'Safety planning', 'Resource referrals'],
          'is24Hours': true,
          'contactPerson': 'Crisis Team',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Korle-Bu Teaching Hospital - Trauma Unit',
          'description': 'Emergency medical care and trauma treatment',
          'type': 'medical',
          'status': 'available',
          'address': 'Korle-Bu, Accra',
          'phone': '+233-XXX-XXXX',
          'services': ['Emergency care', 'Trauma treatment', 'Mental health support'],
          'is24Hours': true,
          'latitude': 5.5385,
          'longitude': -0.2317,
          'contactPerson': 'Emergency Department',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final resourceData in sampleResources) {
        await _firestore.collection('resources').add(resourceData);
      }

      print('Sample resources added successfully');
    } catch (e) {
      print('Error adding sample resources: $e');
    }
  }

  // Private helper methods
  Future<void> _createResourceCase({
    required String resourceId,
    required String userId,
    String? notes,
  }) async {
    try {
      final caseData = {
        'survivorId': userId,
        'type': 'resource_request',
        'priority': 'medium',
        'status': 'pending',
        'title': 'Resource Request Follow-up',
        'description': 'Follow-up for resource request: $resourceId',
        'metadata': {
          'resourceId': resourceId,
          'notes': notes,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': true,
      };

      await _firestore.collection('cases').add(caseData);
    } catch (e) {
      print('Error creating resource case: $e');
    }
  }
}