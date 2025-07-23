import 'dart:async';
import 'dart:math' as Math;
// Firestore dependency removed - using simplified services
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import '../models/service_request.dart';

/// Real Firebase service to replace all demo/mock data
class RealFirebaseService {
  static final RealFirebaseService _instance = RealFirebaseService._internal();
  factory RealFirebaseService() => _instance;
  RealFirebaseService._internal();

  final _firestore // FirebaseFirestore _firestore = _firestore // FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Create new user account
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phone,
    String? location,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      // Create user document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'userType': userType,
        'phone': phone ?? '',
        'location': location ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isVerified': false,
      });

      return credential;
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ============================================================================
  // PROVIDER METHODS
  // ============================================================================

  /// Get all verified providers
  Stream<List<Provider>> getAllProvidersStream() {
    return _firestore
        .collection('providers')
        .where('isVerified', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Provider.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Get providers by service type
  Stream<List<Provider>> getProvidersByServiceStream(String serviceType) {
    return _firestore
        .collection('providers')
        .where('services', arrayContains: serviceType)
        .where('isVerified', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Provider.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Get provider by ID
  Future<Provider?> getProviderById(String id) async {
    try {
      final doc = await _firestore.collection('providers').doc(id).get();
      if (doc.exists) {
        return Provider.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create provider profile
  Future<void> createProvider({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required List<String> services,
    required LatLng location,
    required String address,
    String? bio,
    String? profileImageUrl,
    List<String>? certifications,
    Map<String, dynamic>? availability,
  }) async {
    try {
      await _firestore.collection('providers').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'services': services,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'address': address,
        'bio': bio ?? '',
        'profileImageUrl': profileImageUrl ?? '',
        'certifications': certifications ?? [],
        'availability': availability ?? {},
        'rating': 0.0,
        'totalRatings': 0,
        'completedJobs': 0,
        'isVerified': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create provider profile: $e');
    }
  }

  /// Update provider availability
  Future<void> updateProviderAvailability(String providerId, bool isAvailable) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'isAvailable': isAvailable,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  // ============================================================================
  // BOOKING METHODS
  // ============================================================================

  /// Create new booking
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
      final bookingData = {
        'customerId': customerId,
        'providerId': providerId,
        'serviceType': serviceType,
        'description': description,
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'address': address,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'price': price,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'additionalDetails': additionalDetails ?? {},
      };

      final docRef = await _firestore.collection('bookings').add(bookingData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get user's bookings
  Stream<List<Booking>> getUserBookingsStream(String userId, {String? userType}) {
    Query query;
    
    if (userType == 'provider') {
      query = _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: userId);
    } else {
      query = _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: userId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final updateData = {
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (status == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('bookings').doc(bookingId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // ============================================================================
  // SERVICE CATEGORIES AND SEARCH
  // ============================================================================

  /// Get available service categories
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    try {
      final snapshot = await _firestore
          .collection('service_categories')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [
        {'id': 'house_cleaning', 'name': 'House Cleaning', 'icon': '🏠'},
        {'id': 'food_delivery', 'name': 'Food Delivery', 'icon': '🍽️'},
        {'id': 'transportation', 'name': 'Transportation', 'icon': '🚗'},
        {'id': 'beauty_services', 'name': 'Beauty Services', 'icon': '💄'},
        {'id': 'plumbing', 'name': 'Plumbing', 'icon': '🔧'},
        {'id': 'electrical', 'name': 'Electrical', 'icon': '⚡'},
        {'id': 'gardening', 'name': 'Gardening', 'icon': '🌱'},
        {'id': 'childcare', 'name': 'Childcare', 'icon': '👶'},
      ];
    }
  }

  /// Search providers
  Future<List<Provider>> searchProviders({
    String? query,
    String? serviceType,
    LatLng? location,
    double radiusKm = 10.0,
  }) async {
    try {
      Query baseQuery = _firestore
          .collection('providers')
          .where('isVerified', isEqualTo: true)
          .where('isActive', isEqualTo: true);

      // Filter by service type
      if (serviceType != null) {
        baseQuery = baseQuery.where('services', arrayContains: serviceType);
      }

      final snapshot = await baseQuery.get();
      
      List<Provider> results = snapshot.docs.map((doc) {
        return Provider.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Filter by text query
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        results = results.where((provider) {
          return provider.name.toLowerCase().contains(lowerQuery) ||
                 provider.services.any((service) => 
                   service.toLowerCase().contains(lowerQuery));
        }).toList();
      }

      // Filter by location (simplified distance calculation)
      if (location != null) {
        results = results.where((provider) {
          final distance = _calculateDistance(
            location.latitude,
            location.longitude,
            provider.location.latitude,
            provider.location.longitude,
          );
          return distance <= radiusKm;
        }).toList();
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search providers: $e');
    }
  }

  // ============================================================================
  // RATINGS AND REVIEWS
  // ============================================================================

  /// Submit rating and review
  Future<void> submitRating({
    required String bookingId,
    required String providerId,
    required String customerId,
    required double rating,
    String? review,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add review document
      final reviewRef = _firestore.collection('reviews').doc();
      batch.set(reviewRef, {
        'bookingId': bookingId,
        'providerId': providerId,
        'customerId': customerId,
        'rating': rating,
        'review': review ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update provider's average rating
      final providerRef = _firestore.collection('providers').doc(providerId);
      batch.update(providerRef, {
        'totalRatings': FieldValue.increment(1),
        'ratingSum': FieldValue.increment(rating),
      });

      // Update booking status
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      batch.update(bookingRef, {
        'rating': rating,
        'review': review ?? '',
        'ratedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  /// Get provider reviews
  Future<List<Map<String, dynamic>>> getProviderReviews(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Calculate distance between two coordinates (in kilometers)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_toRadians(lat1)) * Math.cos(_toRadians(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (Math.pi / 180);
  }

  /// Get Ghana cities for location selection
  List<String> getGhanaCities() {
    return [
      'Accra',
      'Kumasi',
      'Tamale',
      'Cape Coast',
      'Sekondi-Takoradi',
      'Sunyani',
      'Koforidua',
      'Ho',
      'Wa',
      'Bolgatanga',
    ];
  }

  /// Get popular services
  List<String> getPopularServices() {
    return [
      'House Cleaning',
      'Food Delivery',
      'Transportation',
      'Beauty Services',
      'Plumbing',
      'Electrical Work',
    ];
  }

  // ============================================================================
  // INITIALIZATION AND SETUP
  // ============================================================================

  /// Initialize Firebase collections with basic data structure
  Future<void> initializeCollections() async {
    try {
      // Create service categories if they don't exist
      final categoriesSnapshot = await _firestore.collection('service_categories').get();
      if (categoriesSnapshot.docs.isEmpty) {
        await _createDefaultServiceCategories();
      }

      // Create app settings if they don't exist
      final settingsDoc = await _firestore.collection('app_settings').doc('general').get();
      if (!settingsDoc.exists) {
        await _createDefaultSettings();
      }

    } catch (e) {
      print('Error initializing collections: $e');
    }
  }

  Future<void> _createDefaultServiceCategories() async {
    final categories = [
      {
        'name': 'House Cleaning',
        'description': 'Professional cleaning services',
        'icon': '🏠',
        'basePrice': 80,
        'currency': 'GHS',
        'isActive': true,
        'subcategories': ['Deep Cleaning', 'Regular Cleaning', 'Move-in/Move-out'],
      },
      {
        'name': 'Food Delivery',
        'description': 'Fast and reliable food delivery',
        'icon': '🍽️',
        'basePrice': 25,
        'currency': 'GHS',
        'isActive': true,
        'subcategories': ['Restaurant Delivery', 'Grocery Shopping', 'Meal Prep'],
      },
      {
        'name': 'Transportation',
        'description': 'Reliable transport services',
        'icon': '🚗',
        'basePrice': 15,
        'currency': 'GHS',
        'isActive': true,
        'subcategories': ['Airport Transfer', 'City Rides', 'Shopping Trips'],
      },
      {
        'name': 'Beauty Services',
        'description': 'Professional beauty and wellness',
        'icon': '💄',
        'basePrice': 150,
        'currency': 'GHS',
        'isActive': true,
        'subcategories': ['Hair Styling', 'Makeup', 'Nail Services', 'Spa'],
      },
    ];

    for (final category in categories) {
      await _firestore.collection('service_categories').add(category);
    }
  }

  Future<void> _createDefaultSettings() async {
    await _firestore.collection('app_settings').doc('general').set({
      'appName': 'HomeLinkGH',
      'version': '1.0.0',
      'supportEmail': 'support@homelinkgh.com',
      'emergencyNumber': '+233123456789',
      'defaultCurrency': 'GHS',
      'supportedRegions': ['Greater Accra', 'Ashanti', 'Northern'],
      'maintenanceMode': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}