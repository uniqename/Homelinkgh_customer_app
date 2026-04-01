import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

/// Comprehensive GPS Tracking Service for HomeLinkGH
/// Handles real-time location tracking for users and providers
class GPSTrackingService {
  static final GPSTrackingService _instance = GPSTrackingService._internal();
  factory GPSTrackingService() => _instance;
  GPSTrackingService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isTracking = false;
  
  // Stream controllers for real-time updates
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  final StreamController<String> _addressController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _locationUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<Position> get positionStream => _positionController.stream;
  Stream<String> get addressStream => _addressController.stream;
  Stream<Map<String, dynamic>> get locationUpdateStream => _locationUpdateController.stream;

  // Getters for current data
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;

  /// Initialize GPS tracking service
  Future<bool> initialize() async {
    try {
      print('Initializing GPS tracking service...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return false;
      }

      // Get initial position
      await _updateCurrentPosition();
      
      print('GPS tracking service initialized successfully!');
      return true;
    } catch (e) {
      print('Error initializing GPS tracking: $e');
      return false;
    }
  }

  /// Start real-time GPS tracking
  Future<bool> startTracking({
    int updateIntervalSeconds = 10,
    double distanceFilterMeters = 10.0,
  }) async {
    try {
      if (_isTracking) {
        print('GPS tracking is already active');
        return true;
      }

      bool initialized = await initialize();
      if (!initialized) {
        throw Exception('Failed to initialize GPS tracking');
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _handlePositionUpdate(position);
        },
        onError: (error) {
          print('GPS tracking error: $error');
          _locationUpdateController.add({
            'type': 'error',
            'message': error.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          });
        },
      );

      _isTracking = true;
      
      // Save tracking preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('gps_tracking_enabled', true);
      
      print('GPS tracking started successfully');
      return true;
    } catch (e) {
      print('Error starting GPS tracking: $e');
      return false;
    }
  }

  /// Stop GPS tracking
  Future<void> stopTracking() async {
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _isTracking = false;
      
      // Save tracking preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('gps_tracking_enabled', false);
      
      _locationUpdateController.add({
        'type': 'tracking_stopped',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      print('GPS tracking stopped');
    } catch (e) {
      print('Error stopping GPS tracking: $e');
    }
  }

  /// Handle position updates
  Future<void> _handlePositionUpdate(Position position) async {
    try {
      _currentPosition = position;
      _positionController.add(position);

      // Get address for the new position
      await _updateAddressFromPosition(position);

      // Create location update data
      final locationUpdate = {
        'type': 'position_update',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'timestamp': position.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'address': _currentAddress,
      };

      _locationUpdateController.add(locationUpdate);

      // Update location in Firebase if user is logged in
      await _updateLocationInFirebase(locationUpdate);
      
      print('Position updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error handling position update: $e');
    }
  }

  /// Update current position (one-time)
  Future<Position?> _updateCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      await _updateAddressFromPosition(position);
      
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get current position (public method)
  Future<Position?> getCurrentPosition() async {
    try {
      bool initialized = await initialize();
      if (!initialized) {
        return null;
      }

      return await _updateCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Update address from position
  Future<void> _updateAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = _formatAddress(place);
        _addressController.add(_currentAddress!);
      }
    } catch (e) {
      print('Error getting address: $e');
      _currentAddress = 'Unknown location';
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street?.isNotEmpty == true) addressParts.add(place.street!);
    if (place.subLocality?.isNotEmpty == true) addressParts.add(place.subLocality!);
    if (place.locality?.isNotEmpty == true) addressParts.add(place.locality!);
    if (place.administrativeArea?.isNotEmpty == true) addressParts.add(place.administrativeArea!);
    
    return addressParts.take(3).join(', '); // Take first 3 parts for brevity
  }

  /// Update location in Firebase
  Future<void> _updateLocationInFirebase(Map<String, dynamic> locationData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userRole = prefs.getString('user_role');
      
      if (userId == null || userRole == null) return;

      // Add user info to location data
      locationData['user_id'] = userId;
      locationData['user_role'] = userRole;
      
      // Update user location in Firebase
      await _firebaseService.updateUserLocation(userId, locationData);
    } catch (e) {
      print('Error updating location in Firebase: $e');
    }
  }

  /// Calculate distance between two positions
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two positions
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Find nearby providers within radius
  Future<List<Map<String, dynamic>>> findNearbyProviders({
    required String serviceType,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      if (_currentPosition == null) {
        await getCurrentPosition();
        if (_currentPosition == null) {
          throw Exception('Unable to get current position');
        }
      }

      // Get providers from Firebase with location data
      final providers = await _firebaseService.getNearbyProviders(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        serviceType: serviceType,
        radiusKm: radiusKm,
        limit: limit,
      );

      // Calculate distances and add to provider data
      for (var provider in providers) {
        if (provider['latitude'] != null && provider['longitude'] != null) {
          double distance = calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            provider['latitude'],
            provider['longitude'],
          );
          
          provider['distance_meters'] = distance;
          provider['distance_km'] = distance / 1000;
          provider['estimated_travel_time'] = _estimateTravelTime(distance);
        }
      }

      // Sort by distance
      providers.sort((a, b) {
        double distanceA = a['distance_meters'] ?? double.infinity;
        double distanceB = b['distance_meters'] ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      return providers;
    } catch (e) {
      print('Error finding nearby providers: $e');
      return [];
    }
  }

  /// Estimate travel time based on distance
  String _estimateTravelTime(double distanceMeters) {
    // Assume average speed of 30 km/h in Accra traffic
    double distanceKm = distanceMeters / 1000;
    double timeHours = distanceKm / 30;
    int timeMinutes = (timeHours * 60).round();
    
    if (timeMinutes < 5) return '5 min';
    if (timeMinutes > 60) return '${(timeMinutes / 60).round()}h ${timeMinutes % 60}min';
    return '${timeMinutes} min';
  }

  /// Get location permission status
  Future<LocationPermission> getLocationPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      print('Error requesting location permissions: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> areLocationServicesEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get location tracking history
  Future<List<Map<String, dynamic>>> getLocationHistory({
    int limitDays = 7,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null) return [];
      
      return await _firebaseService.getUserLocationHistory(
        userId: userId,
        limitDays: limitDays,
      );
    } catch (e) {
      print('Error getting location history: $e');
      return [];
    }
  }

  /// Track service delivery
  Future<String> startServiceDeliveryTracking({
    required String bookingId,
    required String providerId,
    required String customerId,
  }) async {
    try {
      final trackingId = 'tracking_${DateTime.now().millisecondsSinceEpoch}';
      
      if (_currentPosition == null) {
        await getCurrentPosition();
      }

      final trackingData = {
        'tracking_id': trackingId,
        'booking_id': bookingId,
        'provider_id': providerId,
        'customer_id': customerId,
        'status': 'started',
        'start_time': DateTime.now().toIso8601String(),
        'start_location': {
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'address': _currentAddress,
        },
        'updates': [],
      };

      await _firebaseService.createServiceTracking(trackingId, trackingData);
      
      // Start enhanced tracking for service delivery
      await startTracking(updateIntervalSeconds: 5, distanceFilterMeters: 5.0);
      
      return trackingId;
    } catch (e) {
      print('Error starting service delivery tracking: $e');
      throw Exception('Failed to start delivery tracking');
    }
  }

  /// Stop service delivery tracking
  Future<void> stopServiceDeliveryTracking(String trackingId) async {
    try {
      if (_currentPosition == null) {
        await getCurrentPosition();
      }

      final endData = {
        'status': 'completed',
        'end_time': DateTime.now().toIso8601String(),
        'end_location': {
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'address': _currentAddress,
        },
      };

      await _firebaseService.updateServiceTracking(trackingId, endData);
      
      // Return to normal tracking interval
      await stopTracking();
      await startTracking(); // Restart with normal intervals
      
    } catch (e) {
      print('Error stopping service delivery tracking: $e');
    }
  }

  /// Get Ghana-specific location insights
  Map<String, dynamic> getGhanaLocationInsights() {
    if (_currentPosition == null) {
      return {'error': 'Location not available'};
    }

    // Ghana-specific location insights
    final insights = <String, dynamic>{
      'coordinates': {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      },
      'address': _currentAddress ?? 'Unknown',
      'region': _determineGhanaRegion(_currentPosition!.latitude, _currentPosition!.longitude),
      'urban_classification': _getUrbanClassification(_currentPosition!.latitude, _currentPosition!.longitude),
      'service_availability': _assessServiceAvailability(_currentPosition!.latitude, _currentPosition!.longitude),
      'peak_hours': _getPeakHours(),
      'weather_suitability': _getWeatherSuitability(),
    };

    return insights;
  }

  /// Determine Ghana region from coordinates
  String _determineGhanaRegion(double latitude, double longitude) {
    // Simplified region determination for Ghana
    if (latitude >= 5.5 && latitude <= 6.0 && longitude >= -0.5 && longitude <= 0.0) {
      return 'Greater Accra';
    } else if (latitude >= 6.5 && latitude <= 7.5 && longitude >= -2.5 && longitude <= -1.5) {
      return 'Ashanti';
    } else if (latitude >= 4.8 && latitude <= 5.5 && longitude >= -3.5 && longitude <= -1.0) {
      return 'Western';
    } else if (latitude >= 6.0 && latitude <= 7.0 && longitude >= -1.0 && longitude <= 0.5) {
      return 'Eastern';
    } else if (latitude >= 7.0 && latitude <= 8.5 && longitude >= -2.5 && longitude <= -0.5) {
      return 'Brong Ahafo';
    }
    return 'Other Region';
  }

  /// Get urban classification
  String _getUrbanClassification(double latitude, double longitude) {
    // Major cities coordinates (simplified)
    final majorCities = [
      {'name': 'Accra', 'lat': 5.6037, 'lng': -0.1870, 'radius': 0.3},
      {'name': 'Kumasi', 'lat': 6.6885, 'lng': -1.6244, 'radius': 0.2},
      {'name': 'Tamale', 'lat': 9.4034, 'lng': -0.8424, 'radius': 0.15},
    ];

    for (var city in majorCities) {
      double distance = calculateDistance(
        latitude, longitude,
        city['lat'] as double, city['lng'] as double,
      );
      if (distance < (city['radius'] as double) * 111000) { // Convert degrees to meters
        return 'Urban - ${city['name']} Metropolitan';
      }
    }

    return 'Rural/Suburban';
  }

  /// Assess service availability in area
  String _assessServiceAvailability(double latitude, double longitude) {
    String region = _determineGhanaRegion(latitude, longitude);
    String classification = _getUrbanClassification(latitude, longitude);
    
    if (region == 'Greater Accra' && classification.contains('Urban')) {
      return 'Excellent';
    } else if (region == 'Ashanti' && classification.contains('Urban')) {
      return 'Very Good';
    } else if (classification.contains('Urban')) {
      return 'Good';
    } else {
      return 'Limited';
    }
  }

  /// Get peak hours for current location
  List<String> _getPeakHours() {
    return ['7:00-9:00 AM', '12:00-2:00 PM', '6:00-8:00 PM'];
  }

  /// Get weather suitability assessment
  String _getWeatherSuitability() {
    // This would integrate with weather API in production
    return 'Good for outdoor services';
  }

  /// Cleanup resources
  void dispose() {
    _positionStreamSubscription?.cancel();
    _positionController.close();
    _addressController.close();
    _locationUpdateController.close();
  }
}

/// Location tracking event types
enum LocationTrackingEvent {
  started,
  updated,
  stopped,
  error,
  permissionDenied,
  serviceDisabled,
}

/// Location update data class
class LocationUpdate {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;
  final String? address;

  LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    required this.timestamp,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      altitude: json['altitude'],
      heading: json['heading'],
      speed: json['speed'],
      timestamp: DateTime.parse(json['timestamp']),
      address: json['address'],
    );
  }
}