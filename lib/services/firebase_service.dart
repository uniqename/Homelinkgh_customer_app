import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import '../models/service_request.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase project configuration
  static const String _projectId = 'homelinkgh-production';
  static const String _apiKey = 'AIzaSyC_your_api_key_here'; // To be configured
  static const String _baseUrl = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';
  
  // Authentication token (for server-side operations)
  String? _authToken;
  
  // Headers for Firebase REST API
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Initialize Firebase service
  Future<void> initialize() async {
    try {
      // Initialize Firebase configuration
      print('Initializing Firebase service for HomeLinkGH...');
      // In production, this would include Firebase Auth setup
    } catch (e) {
      print('Error initializing Firebase: $e');
      throw Exception('Failed to initialize Firebase service');
    }
  }

  /// Set authentication token for server operations
  void setAuthToken(String token) {
    _authToken = token;
  }

  // PROVIDERS COLLECTION
  
  /// Create a new provider in Firebase
  Future<String> createProvider(Provider provider) async {
    try {
      final providerData = {
        'fields': {
          'id': {'stringValue': provider.id},
          'name': {'stringValue': provider.name},
          'services': {
            'arrayValue': {
              'values': provider.services.map((service) => {'stringValue': service}).toList()
            }
          },
          'rating': {'doubleValue': provider.rating},
          'totalRatings': {'integerValue': provider.totalRatings.toString()},
          'completedJobs': {'integerValue': provider.completedJobs.toString()},
          'location': {
            'mapValue': {
              'fields': {
                'latitude': {'doubleValue': provider.location.latitude},
                'longitude': {'doubleValue': provider.location.longitude},
              }
            }
          },
          'isActive': {'booleanValue': provider.isActive},
          'isVerified': {'booleanValue': provider.isVerified},
          'profileImageUrl': {'stringValue': provider.profileImageUrl},
          'phone': {'stringValue': provider.phone},
          'email': {'stringValue': provider.email},
          'bio': {'stringValue': provider.bio},
          'address': {'stringValue': provider.address},
          'certifications': {
            'arrayValue': {
              'values': provider.certifications.map((cert) => {'stringValue': cert}).toList()
            }
          },
          'availability': {
            'mapValue': {
              'fields': {}
            }
          },
          'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'verificationStatus': {'stringValue': 'pending'}, // pending, verified, rejected
          'totalEarnings': {'doubleValue': 0.0},
          'monthlyEarnings': {'doubleValue': 0.0},
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/providers'),
        headers: _headers,
        body: json.encode(providerData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['name'].split('/').last; // Extract document ID
      } else {
        throw Exception('Failed to create provider: ${response.body}');
      }
    } catch (e) {
      print('Error creating provider: $e');
      throw Exception('Failed to create provider in Firebase');
    }
  }

  /// Get providers by service type
  Future<List<Provider>> getProvidersByService(String serviceType) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl:runQuery'),
        headers: _headers,
        body: json.encode({
          'structuredQuery': {
            'from': [{'collectionId': 'providers'}],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'services'},
                'op': 'ARRAY_CONTAINS',
                'value': {'stringValue': serviceType}
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Provider> providers = [];
        
        if (responseData.containsKey('result')) {
          for (final doc in responseData['result']) {
            if (doc.containsKey('document')) {
              providers.add(_parseProviderFromFirestore(doc['document']));
            }
          }
        }
        
        return providers;
      } else {
        throw Exception('Failed to fetch providers: ${response.body}');
      }
    } catch (e) {
      print('Error fetching providers: $e');
      return []; // Return empty list on error
    }
  }

  /// Update provider availability
  Future<void> updateProviderAvailability(String providerId, bool isAvailable) async {
    try {
      final updateData = {
        'fields': {
          'isAvailable': {'booleanValue': isAvailable},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final response = await http.patch(
        Uri.parse('$_baseUrl/providers/$providerId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update provider availability: ${response.body}');
      }
    } catch (e) {
      print('Error updating provider availability: $e');
      throw Exception('Failed to update provider availability');
    }
  }

  // BOOKINGS COLLECTION
  
  /// Create a new booking
  Future<String> createBooking(Booking booking) async {
    try {
      final bookingData = {
        'fields': {
          'id': {'stringValue': booking.id},
          'customerId': {'stringValue': booking.customerId},
          'providerId': {'stringValue': booking.providerId},
          'serviceType': {'stringValue': booking.serviceType},
          'description': {'stringValue': booking.description},
          'scheduledDate': {'timestampValue': booking.scheduledDate.toUtc().toIso8601String()},
          'address': {'stringValue': booking.address},
          'price': {'doubleValue': booking.price},
          'status': {'stringValue': booking.status},
          'createdAt': {'timestampValue': booking.createdAt?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String()},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'completedAt': booking.completedAt != null 
              ? {'timestampValue': booking.completedAt!.toUtc().toIso8601String()}
              : {'nullValue': null},
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/bookings'),
        headers: _headers,
        body: json.encode(bookingData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['name'].split('/').last;
      } else {
        throw Exception('Failed to create booking: ${response.body}');
      }
    } catch (e) {
      print('Error creating booking: $e');
      throw Exception('Failed to create booking in Firebase');
    }
  }

  /// Get bookings for a customer
  Future<List<Booking>> getCustomerBookings(String customerId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl:runQuery'),
        headers: _headers,
        body: json.encode({
          'structuredQuery': {
            'from': [{'collectionId': 'bookings'}],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'customerId'},
                'op': 'EQUAL',
                'value': {'stringValue': customerId}
              }
            },
            'orderBy': [
              {
                'field': {'fieldPath': 'createdAt'},
                'direction': 'DESCENDING'
              }
            ]
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Booking> bookings = [];
        
        if (responseData.containsKey('result')) {
          for (final doc in responseData['result']) {
            if (doc.containsKey('document')) {
              bookings.add(_parseBookingFromFirestore(doc['document']));
            }
          }
        }
        
        return bookings;
      } else {
        throw Exception('Failed to fetch customer bookings: ${response.body}');
      }
    } catch (e) {
      print('Error fetching customer bookings: $e');
      return [];
    }
  }

  /// Get bookings for a provider
  Future<List<Booking>> getProviderBookings(String providerId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl:runQuery'),
        headers: _headers,
        body: json.encode({
          'structuredQuery': {
            'from': [{'collectionId': 'bookings'}],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'providerId'},
                'op': 'EQUAL',
                'value': {'stringValue': providerId}
              }
            },
            'orderBy': [
              {
                'field': {'fieldPath': 'createdAt'},
                'direction': 'DESCENDING'
              }
            ]
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Booking> bookings = [];
        
        if (responseData.containsKey('result')) {
          for (final doc in responseData['result']) {
            if (doc.containsKey('document')) {
              bookings.add(_parseBookingFromFirestore(doc['document']));
            }
          }
        }
        
        return bookings;
      } else {
        throw Exception('Failed to fetch provider bookings: ${response.body}');
      }
    } catch (e) {
      print('Error fetching provider bookings: $e');
      return [];
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final updateData = {
        'fields': {
          'status': {'stringValue': status},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          if (status == 'completed')
            'completedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final response = await http.patch(
        Uri.parse('$_baseUrl/bookings/$bookingId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update booking status: ${response.body}');
      }
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status');
    }
  }

  // USER MANAGEMENT
  
  /// Create user profile
  Future<String> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String role, // customer, provider, admin, diaspora
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userData = {
        'fields': {
          'id': {'stringValue': userId},
          'name': {'stringValue': name},
          'email': {'stringValue': email},
          'phoneNumber': {'stringValue': phoneNumber},
          'role': {'stringValue': role},
          'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'isActive': {'booleanValue': true},
          'profileComplete': {'booleanValue': false},
          'lastLoginAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          ...?additionalData?.map((key, value) => MapEntry(key, {'stringValue': value.toString()})),
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: _headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['name'].split('/').last;
      } else {
        throw Exception('Failed to create user profile: ${response.body}');
      }
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile in Firebase');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return _parseUserFromFirestore(responseData);
      } else if (response.statusCode == 404) {
        return null; // User not found
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // ANALYTICS AND REPORTING
  
  /// Record user analytics event
  Future<void> recordAnalyticsEvent({
    required String eventName,
    required String userId,
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final analyticsData = {
        'fields': {
          'eventName': {'stringValue': eventName},
          'userId': {'stringValue': userId},
          'eventData': {
            'mapValue': {
              'fields': eventData.map(
                (key, value) => MapEntry(key, {'stringValue': value.toString()}),
              )
            }
          },
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'sessionId': {'stringValue': DateTime.now().millisecondsSinceEpoch.toString()},
        }
      };

      await http.post(
        Uri.parse('$_baseUrl/analytics'),
        headers: _headers,
        body: json.encode(analyticsData),
      );
    } catch (e) {
      print('Error recording analytics event: $e');
      // Don't throw exception for analytics failures
    }
  }

  // HELPER METHODS

  /// Parse Provider from Firestore document
  Provider _parseProviderFromFirestore(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>;
    
    return Provider(
      id: fields['id']['stringValue'] ?? '',
      name: fields['name']['stringValue'] ?? '',
      services: _parseArrayValue(fields['services']),
      rating: _parseDoubleValue(fields['rating']) ?? 0.0,
      completedJobs: _parseIntValue(fields['completedJobs']) ?? 0,
      location: LatLng(
        _parseDoubleValue(fields['location']['mapValue']['fields']['latitude']) ?? 0.0,
        _parseDoubleValue(fields['location']['mapValue']['fields']['longitude']) ?? 0.0,
      ),
      phone: fields['phone']['stringValue'] ?? '',
      email: fields['email']['stringValue'] ?? '',
      bio: fields['bio']['stringValue'] ?? '',
      address: fields['address']['stringValue'] ?? '',
      isActive: fields['isActive']['booleanValue'] ?? false,
      isVerified: fields['isVerified']['booleanValue'] ?? false,
      profileImageUrl: fields['profileImageUrl']['stringValue'] ?? '',
      certifications: _parseArrayValue(fields['certifications']),
      availability: {},
      totalRatings: _parseIntValue(fields['totalRatings']) ?? 0,
    );
  }

  /// Parse Booking from Firestore document
  Booking _parseBookingFromFirestore(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>;
    
    return Booking(
      id: fields['id']['stringValue'] ?? '',
      customerId: fields['customerId']['stringValue'] ?? '',
      providerId: fields['providerId']['stringValue'] ?? '',
      serviceType: fields['serviceType']['stringValue'] ?? '',
      description: fields['description']['stringValue'] ?? '',
      scheduledDate: DateTime.parse(fields['scheduledDate']['timestampValue'] ?? DateTime.now().toIso8601String()),
      address: fields['address']['stringValue'] ?? '',
      price: _parseDoubleValue(fields['price']) ?? 0.0,
      status: fields['status']['stringValue'] ?? 'pending',
      createdAt: fields['createdAt']?['timestampValue'] != null 
          ? DateTime.parse(fields['createdAt']['timestampValue'])
          : null,
      completedAt: fields['completedAt']?['timestampValue'] != null 
          ? DateTime.parse(fields['completedAt']['timestampValue'])
          : null,
    );
  }

  /// Parse User from Firestore document
  Map<String, dynamic> _parseUserFromFirestore(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>;
    
    return {
      'id': fields['id']['stringValue'] ?? '',
      'name': fields['name']['stringValue'] ?? '',
      'email': fields['email']['stringValue'] ?? '',
      'phoneNumber': fields['phoneNumber']['stringValue'] ?? '',
      'role': fields['role']['stringValue'] ?? '',
      'isActive': fields['isActive']['booleanValue'] ?? true,
      'profileComplete': fields['profileComplete']['booleanValue'] ?? false,
      'createdAt': fields['createdAt']['timestampValue'],
      'updatedAt': fields['updatedAt']['timestampValue'],
      'lastLoginAt': fields['lastLoginAt']['timestampValue'],
    };
  }

  /// Parse array value from Firestore
  List<String> _parseArrayValue(Map<String, dynamic>? arrayField) {
    if (arrayField == null || !arrayField.containsKey('arrayValue')) return [];
    
    final values = arrayField['arrayValue']['values'] as List<dynamic>? ?? [];
    return values.map((v) => v['stringValue'] as String? ?? '').toList();
  }

  /// Parse double value from Firestore
  double? _parseDoubleValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    
    if (field.containsKey('doubleValue')) {
      return field['doubleValue'] as double?;
    } else if (field.containsKey('integerValue')) {
      return double.tryParse(field['integerValue'].toString());
    }
    
    return null;
  }

  /// Parse integer value from Firestore
  int? _parseIntValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    
    if (field.containsKey('integerValue')) {
      return int.tryParse(field['integerValue'].toString());
    } else if (field.containsKey('doubleValue')) {
      return (field['doubleValue'] as double?)?.round();
    }
    
    return null;
  }

  // LOCATION TRACKING METHODS

  /// Update user location in Firebase
  Future<void> updateUserLocation(String userId, Map<String, dynamic> locationData) async {
    try {
      final locationRecord = {
        'fields': {
          'userId': {'stringValue': userId},
          'latitude': {'doubleValue': locationData['latitude']},
          'longitude': {'doubleValue': locationData['longitude']},
          'accuracy': {'doubleValue': locationData['accuracy']},
          'address': {'stringValue': locationData['address'] ?? ''},
          'timestamp': {'timestampValue': locationData['timestamp']},
          'userRole': {'stringValue': locationData['user_role'] ?? 'customer'},
        }
      };

      // Update current location
      await http.patch(
        Uri.parse('$_baseUrl/user_locations/$userId'),
        headers: _headers,
        body: json.encode(locationRecord),
      );

      // Add to location history
      await http.post(
        Uri.parse('$_baseUrl/location_history'),
        headers: _headers,
        body: json.encode({
          'fields': {
            ...(locationRecord['fields'] as Map<String, dynamic>? ?? {}),
            'id': {'stringValue': 'loc_${DateTime.now().millisecondsSinceEpoch}'},
          }
        }),
      );
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  /// Get nearby providers based on location
  Future<List<Provider>> getNearbyProviders({
    required double latitude,
    required double longitude,
    required String serviceType,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // Query providers with location data
      final response = await http.get(
        Uri.parse('$_baseUrl/providers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final providers = <Provider>[];

        if (responseData['documents'] != null) {
          for (var doc in responseData['documents']) {
            final provider = _parseProviderFromFirestore(doc);
            
            // Check if provider offers the service
            if (provider.services.contains(serviceType)) {
              // Check if provider has location data
              double distance = _calculateDistance(
                latitude, longitude,
                provider.location.latitude, provider.location.longitude,
              );
                
              // Check if within radius
              if (distance <= radiusKm * 1000) { // Convert to meters
                providers.add(provider);
              }
            }
          }
        }

        // Limit results
        return providers.take(limit).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting nearby providers: $e');
      return [];
    }
  }

  /// Get user location history
  Future<List<Map<String, dynamic>>> getUserLocationHistory({
    required String userId,
    int limitDays = 7,
  }) async {
    try {
      // Calculate date range
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: limitDays));

      final response = await http.get(
        Uri.parse('$_baseUrl/location_history?'
          'structuredQuery=${json.encode({
            'where': {
              'compositeFilter': {
                'op': 'AND',
                'filters': [
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'userId'},
                      'op': 'EQUAL',
                      'value': {'stringValue': userId}
                    }
                  },
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'timestamp'},
                      'op': 'GREATER_THAN_OR_EQUAL',
                      'value': {'timestampValue': startDate.toIso8601String()}
                    }
                  }
                ]
              }
            },
            'orderBy': [
              {
                'field': {'fieldPath': 'timestamp'},
                'direction': 'DESCENDING'
              }
            ]
          })}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final history = <Map<String, dynamic>>[];

        if (responseData['documents'] != null) {
          for (var doc in responseData['documents']) {
            final fields = doc['fields'];
            history.add({
              'latitude': _parseDoubleValue(fields['latitude']),
              'longitude': _parseDoubleValue(fields['longitude']),
              'accuracy': _parseDoubleValue(fields['accuracy']),
              'address': fields['address']['stringValue'],
              'timestamp': fields['timestamp']['timestampValue'],
            });
          }
        }

        return history;
      }
      
      return [];
    } catch (e) {
      print('Error getting location history: $e');
      return [];
    }
  }

  /// Create service tracking record
  Future<void> createServiceTracking(String trackingId, Map<String, dynamic> trackingData) async {
    try {
      final trackingRecord = {
        'fields': {
          'trackingId': {'stringValue': trackingId},
          'bookingId': {'stringValue': trackingData['booking_id']},
          'providerId': {'stringValue': trackingData['provider_id']},
          'customerId': {'stringValue': trackingData['customer_id']},
          'status': {'stringValue': trackingData['status']},
          'startTime': {'timestampValue': trackingData['start_time']},
          'startLocation': {
            'mapValue': {
              'fields': {
                'latitude': {'doubleValue': trackingData['start_location']['latitude']},
                'longitude': {'doubleValue': trackingData['start_location']['longitude']},
                'address': {'stringValue': trackingData['start_location']['address'] ?? ''},
              }
            }
          },
          'updates': {'arrayValue': {'values': []}},
          'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      await http.patch(
        Uri.parse('$_baseUrl/service_tracking/$trackingId'),
        headers: _headers,
        body: json.encode(trackingRecord),
      );
    } catch (e) {
      print('Error creating service tracking: $e');
    }
  }

  /// Update service tracking record
  Future<void> updateServiceTracking(String trackingId, Map<String, dynamic> updateData) async {
    try {
      final updateFields = <String, dynamic>{};
      
      if (updateData['status'] != null) {
        updateFields['status'] = {'stringValue': updateData['status']};
      }
      
      if (updateData['end_time'] != null) {
        updateFields['endTime'] = {'timestampValue': updateData['end_time']};
      }
      
      if (updateData['end_location'] != null) {
        updateFields['endLocation'] = {
          'mapValue': {
            'fields': {
              'latitude': {'doubleValue': updateData['end_location']['latitude']},
              'longitude': {'doubleValue': updateData['end_location']['longitude']},
              'address': {'stringValue': updateData['end_location']['address'] ?? ''},
            }
          }
        };
      }

      updateFields['updatedAt'] = {'timestampValue': DateTime.now().toUtc().toIso8601String()};

      await http.patch(
        Uri.parse('$_baseUrl/service_tracking/$trackingId'),
        headers: _headers,
        body: json.encode({
          'fields': updateFields,
        }),
      );
    } catch (e) {
      print('Error updating service tracking: $e');
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // PUSH NOTIFICATION METHODS

  /// Register device for push notifications
  Future<void> registerDeviceForNotifications(Map<String, dynamic> deviceData) async {
    try {
      final deviceRecord = {
        'fields': {
          'fcmToken': {'stringValue': deviceData['fcm_token']},
          'userId': {'stringValue': deviceData['user_id']},
          'userRole': {'stringValue': deviceData['user_role']},
          'platform': {'stringValue': deviceData['platform']},
          'appVersion': {'stringValue': deviceData['app_version']},
          'registeredAt': {'timestampValue': deviceData['registered_at']},
          'notificationPreferences': {
            'mapValue': {
              'fields': deviceData['notification_preferences'].map(
                (key, value) => MapEntry(key, {'booleanValue': value}),
              )
            }
          },
          'isActive': {'booleanValue': true},
        }
      };

      await http.patch(
        Uri.parse('$_baseUrl/notification_devices/${deviceData['user_id']}'),
        headers: _headers,
        body: json.encode(deviceRecord),
      );
    } catch (e) {
      print('Error registering device for notifications: $e');
    }
  }

  /// Get user notification data
  Future<Map<String, dynamic>?> getUserNotificationData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notification_devices/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final fields = responseData['fields'];
        
        return {
          'fcm_token': fields['fcmToken']['stringValue'],
          'user_role': fields['userRole']['stringValue'],
          'platform': fields['platform']['stringValue'],
          'notification_preferences': _parseNotificationPreferences(fields['notificationPreferences']),
          'is_active': fields['isActive']['booleanValue'],
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting user notification data: $e');
      return null;
    }
  }

  /// Save notification record
  Future<void> saveNotificationRecord(Map<String, dynamic> notificationData) async {
    try {
      final notificationRecord = {
        'fields': {
          'id': {'stringValue': notificationData['id']},
          'userId': {'stringValue': notificationData['user_id']},
          'title': {'stringValue': notificationData['title']},
          'body': {'stringValue': notificationData['body']},
          'category': {'stringValue': notificationData['category']},
          'data': {
            'mapValue': {
              'fields': notificationData['data'].map(
                (key, value) => MapEntry(key, {'stringValue': value.toString()}),
              )
            }
          },
          'sentAt': {'timestampValue': notificationData['sent_at']},
          'read': {'booleanValue': notificationData['read']},
          'delivered': {'booleanValue': notificationData['delivered']},
        }
      };

      await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: _headers,
        body: json.encode(notificationRecord),
      );
    } catch (e) {
      print('Error saving notification record: $e');
    }
  }

  /// Get upcoming bookings for reminder notifications
  Future<List<Map<String, dynamic>>> getUpcomingBookings(String userId) async {
    try {
      final now = DateTime.now();
      final next48Hours = now.add(const Duration(hours: 48));

      final response = await http.get(
        Uri.parse('$_baseUrl/bookings?'
          'structuredQuery=${json.encode({
            'where': {
              'compositeFilter': {
                'op': 'AND',
                'filters': [
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'customerId'},
                      'op': 'EQUAL',
                      'value': {'stringValue': userId}
                    }
                  },
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'scheduledDate'},
                      'op': 'GREATER_THAN',
                      'value': {'timestampValue': now.toIso8601String()}
                    }
                  },
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'scheduledDate'},
                      'op': 'LESS_THAN',
                      'value': {'timestampValue': next48Hours.toIso8601String()}
                    }
                  }
                ]
              }
            },
            'orderBy': [
              {
                'field': {'fieldPath': 'scheduledDate'},
                'direction': 'ASCENDING'
              }
            ]
          })}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bookings = <Map<String, dynamic>>[];

        if (responseData['documents'] != null) {
          for (var doc in responseData['documents']) {
            final booking = _parseBookingFromFirestore(doc);
            bookings.add(booking.toMap());
          }
        }

        return bookings;
      }
      
      return [];
    } catch (e) {
      print('Error getting upcoming bookings: $e');
      return [];
    }
  }

  /// Get pending promotional notifications
  Future<List<Map<String, dynamic>>> getPendingPromotions(String userId) async {
    try {
      final now = DateTime.now();

      final response = await http.get(
        Uri.parse('$_baseUrl/promotions?'
          'structuredQuery=${json.encode({
            'where': {
              'compositeFilter': {
                'op': 'AND',
                'filters': [
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'targetUserId'},
                      'op': 'EQUAL',
                      'value': {'stringValue': userId}
                    }
                  },
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'sent'},
                      'op': 'EQUAL',
                      'value': {'booleanValue': false}
                    }
                  },
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'scheduledFor'},
                      'op': 'LESS_THAN_OR_EQUAL',
                      'value': {'timestampValue': now.toIso8601String()}
                    }
                  }
                ]
              }
            }
          })}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final promotions = <Map<String, dynamic>>[];

        if (responseData['documents'] != null) {
          for (var doc in responseData['documents']) {
            final fields = doc['fields'];
            promotions.add({
              'id': doc['name'].split('/').last,
              'title': fields['title']['stringValue'],
              'body': fields['body']['stringValue'],
              'image_url': fields['imageUrl']['stringValue'],
              'promo_code': fields['promoCode']['stringValue'],
              'expiry_date': fields['expiryDate']['timestampValue'],
            });
          }
        }

        return promotions;
      }
      
      return [];
    } catch (e) {
      print('Error getting pending promotions: $e');
      return [];
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(String userId, Map<String, bool> preferences) async {
    try {
      final updateData = {
        'fields': {
          'notificationPreferences': {
            'mapValue': {
              'fields': preferences.map(
                (key, value) => MapEntry(key, {'booleanValue': value}),
              )
            }
          },
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      await http.patch(
        Uri.parse('$_baseUrl/notification_devices/$userId'),
        headers: _headers,
        body: json.encode(updateData),
      );
    } catch (e) {
      print('Error updating notification preferences: $e');
    }
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory(String userId, int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications?'
          'structuredQuery=${json.encode({
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'userId'},
                'op': 'EQUAL',
                'value': {'stringValue': userId}
              }
            },
            'orderBy': [
              {
                'field': {'fieldPath': 'sentAt'},
                'direction': 'DESCENDING'
              }
            ],
            'limit': limit
          })}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final notifications = <Map<String, dynamic>>[];

        if (responseData['documents'] != null) {
          for (var doc in responseData['documents']) {
            final fields = doc['fields'];
            notifications.add({
              'id': fields['id']['stringValue'],
              'title': fields['title']['stringValue'],
              'body': fields['body']['stringValue'],
              'category': fields['category']['stringValue'],
              'data': _parseNotificationData(fields['data']),
              'sent_at': fields['sentAt']['timestampValue'],
              'read': fields['read']['booleanValue'],
              'delivered': fields['delivered']['booleanValue'],
            });
          }
        }

        return notifications;
      }
      
      return [];
    } catch (e) {
      print('Error getting notification history: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final updateData = {
        'fields': {
          'read': {'booleanValue': true},
          'readAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      await http.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: _headers,
        body: json.encode(updateData),
      );
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Parse notification preferences from Firestore
  Map<String, bool> _parseNotificationPreferences(Map<String, dynamic>? prefsField) {
    if (prefsField == null || !prefsField.containsKey('mapValue')) return {};
    
    final fields = prefsField['mapValue']['fields'] as Map<String, dynamic>? ?? {};
    return fields.map((key, value) => MapEntry(key, value['booleanValue'] as bool? ?? true));
  }

  /// Parse notification data from Firestore
  Map<String, String> _parseNotificationData(Map<String, dynamic>? dataField) {
    if (dataField == null || !dataField.containsKey('mapValue')) return {};
    
    final fields = dataField['mapValue']['fields'] as Map<String, dynamic>? ?? {};
    return fields.map((key, value) => MapEntry(key, value['stringValue'] as String? ?? ''));
  }
}

