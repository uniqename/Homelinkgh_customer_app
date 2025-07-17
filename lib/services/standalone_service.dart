import 'dart:async';
import 'dart:math' as Math;
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import '../models/service_request.dart';

/// Standalone service that works without Firebase
class StandaloneService {
  static final StandaloneService _instance = StandaloneService._internal();
  factory StandaloneService() => _instance;
  StandaloneService._internal() {
    _initializeData();
  }

  // In-memory data storage
  final List<Provider> _providers = [];
  final List<Map<String, dynamic>> _serviceCategories = [];
  final List<Booking> _bookings = [];
  final Map<String, Map<String, dynamic>> _users = {};
  String? _currentUserId;

  // Stream controllers for real-time updates
  final StreamController<List<Provider>> _providersController = StreamController<List<Provider>>.broadcast();
  final StreamController<List<Booking>> _bookingsController = StreamController<List<Booking>>.broadcast();

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  void _initializeData() {
    _createDefaultServiceCategories();
    // Removed sample providers and users for production
  }

  void _createDefaultServiceCategories() {
    _serviceCategories.addAll([
      {
        'id': 'house_cleaning',
        'name': 'House Cleaning',
        'description': 'Professional home cleaning services',
        'icon': '🏠',
        'basePrice': 80,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'food_delivery',
        'name': 'Food Delivery',
        'description': 'Fast and reliable food delivery',
        'icon': '🍽️',
        'basePrice': 25,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'transportation',
        'name': 'Transportation',
        'description': 'Reliable transport services',
        'icon': '🚗',
        'basePrice': 15,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'beauty_services',
        'name': 'Beauty Services',
        'description': 'Professional beauty and wellness',
        'icon': '💄',
        'basePrice': 150,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'plumbing',
        'name': 'Plumbing',
        'description': 'Pipes, fixtures, and water system repairs',
        'icon': '🔧',
        'basePrice': 120,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'electrical',
        'name': 'Electrical',
        'description': 'Wiring, outlets, and electrical installations',
        'icon': '⚡',
        'basePrice': 100,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'gardening',
        'name': 'Gardening',
        'description': 'Garden design, lawn care, and outdoor spaces',
        'icon': '🌱',
        'basePrice': 90,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
      {
        'id': 'childcare',
        'name': 'Childcare',
        'description': 'Trusted childcare and babysitting services',
        'icon': '👶',
        'basePrice': 60,
        'currency': 'GHS',
        'isActive': true,
        'providers': 0,
      },
    ]);
  }

  void _createSampleProviders() {
    final sampleProviders = [
      // House Cleaning Providers
      Provider(
        id: 'provider_1',
        name: 'Akosua Cleaning Services',
        email: 'akosua@cleaning.gh',
        phone: '+233244123456',
        services: ['House Cleaning'],
        location: const LatLng(5.6037, -0.1870), // East Legon
        address: 'East Legon, Accra',
        bio: 'Professional cleaning with 5+ years experience',
        rating: 4.8,
        totalRatings: 156,
        completedJobs: 234,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Professional Cleaning Certificate'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),
      Provider(
        id: 'provider_2',
        name: 'Pristine Home Care',
        email: 'pristine@homecare.gh',
        phone: '+233244234567',
        services: ['House Cleaning'],
        location: const LatLng(5.5557, -0.1963), // Osu
        address: 'Osu, Accra',
        bio: 'Eco-friendly cleaning solutions',
        rating: 4.9,
        totalRatings: 89,
        completedJobs: 145,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Eco-Cleaning Specialist'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),

      // Food Delivery Providers
      Provider(
        id: 'provider_3',
        name: 'Quick Bites Delivery',
        email: 'quick@bites.gh',
        phone: '+233244345678',
        services: ['Food Delivery'],
        location: const LatLng(5.6020, -0.1875), // Cantonments
        address: 'Cantonments, Accra',
        bio: 'Fast and reliable food delivery service',
        rating: 4.7,
        totalRatings: 312,
        completedJobs: 567,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Food Safety Certificate'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),
      Provider(
        id: 'provider_4',
        name: 'Speedy Meals GH',
        email: 'speedy@meals.gh',
        phone: '+233244456789',
        services: ['Food Delivery'],
        location: const LatLng(5.5502, -0.2174), // Accra Mall Area
        address: 'Tetteh Quarshie, Accra',
        bio: 'Hot meals delivered fresh to your door',
        rating: 4.6,
        totalRatings: 278,
        completedJobs: 445,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Safe Food Handling'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),

      // Transportation Providers
      Provider(
        id: 'provider_5',
        name: 'Reliable Rides Ghana',
        email: 'reliable@rides.gh',
        phone: '+233244567890',
        services: ['Transportation'],
        location: const LatLng(5.6045, -0.1865), // Airport Residential
        address: 'Airport Residential, Accra',
        bio: 'Safe and comfortable rides across Accra',
        rating: 4.8,
        totalRatings: 445,
        completedJobs: 823,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Professional Driver License'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),

      // Beauty Services Providers
      Provider(
        id: 'provider_6',
        name: 'Glamour Touch Beauty',
        email: 'glamour@beauty.gh',
        phone: '+233244678901',
        services: ['Beauty Services'],
        location: const LatLng(5.5557, -0.1963), // Osu
        address: 'Osu, Accra',
        bio: 'Professional makeup and hair styling',
        rating: 4.9,
        totalRatings: 134,
        completedJobs: 198,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Certified Makeup Artist', 'Hair Styling Certificate'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),

      // Plumbing Providers
      Provider(
        id: 'provider_7',
        name: 'Fix-It Plumbing Services',
        email: 'fixit@plumbing.gh',
        phone: '+233244789012',
        services: ['Plumbing'],
        location: const LatLng(5.6050, -0.1880), // Labone
        address: 'Labone, Accra',
        bio: 'Expert plumbing repairs and installations',
        rating: 4.7,
        totalRatings: 98,
        completedJobs: 156,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Licensed Plumber'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),

      // Electrical Providers
      Provider(
        id: 'provider_8',
        name: 'PowerUp Electrical',
        email: 'powerup@electrical.gh',
        phone: '+233244890123',
        services: ['Electrical'],
        location: const LatLng(5.6037, -0.1870), // East Legon
        address: 'East Legon, Accra',
        bio: 'Licensed electrician for all your electrical needs',
        rating: 4.8,
        totalRatings: 76,
        completedJobs: 123,
        isVerified: true,
        isActive: true,
        profileImageUrl: '',
        certifications: ['Licensed Electrician'],
        availability: {'monday': true, 'tuesday': true, 'wednesday': true},
      ),
    ];

    _providers.addAll(sampleProviders);
    _providersController.add(_providers);
  }

  void _createSampleUsers() {
    _users['user_1'] = {
      'id': 'user_1',
      'email': 'customer@test.com',
      'name': 'Test Customer',
      'userType': 'customer',
      'phone': '+233244123456',
      'location': 'East Legon, Accra',
      'isActive': true,
      'isVerified': true,
    };

    _users['user_2'] = {
      'id': 'user_2',
      'email': 'provider@test.com',
      'name': 'Test Provider',
      'userType': 'provider',
      'phone': '+233244234567',
      'location': 'Osu, Accra',
      'isActive': true,
      'isVerified': true,
    };
  }

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Sign in with email and password
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    final user = _users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      _currentUserId = user['id'];
      return user;
    }
    
    throw Exception('Invalid email or password');
  }

  /// Create new user account
  Future<Map<String, dynamic>> createAccount({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phone,
    String? location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    // Check if email already exists
    final existingUser = _users.values.any((user) => user['email'] == email);
    if (existingUser) {
      throw Exception('An account already exists with this email address');
    }

    final userId = 'user_${_users.length + 1}';
    final userData = {
      'id': userId,
      'email': email,
      'name': name,
      'userType': userType,
      'phone': phone ?? '',
      'location': location ?? '',
      'isActive': true,
      'isVerified': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _users[userId] = userData;
    _currentUserId = userId;
    return userData;
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUserId = null;
  }

  /// Get current user data
  Map<String, dynamic>? getCurrentUserData() {
    return _currentUserId != null ? _users[_currentUserId] : null;
  }

  String? get currentUserId => _currentUserId;

  // ============================================================================
  // PROVIDER METHODS
  // ============================================================================

  /// Get all verified providers
  Stream<List<Provider>> getAllProvidersStream() {
    return _providersController.stream;
  }

  /// Get providers by service type
  Stream<List<Provider>> getProvidersByServiceStream(String serviceType) {
    return _providersController.stream.map((providers) {
      return providers.where((provider) => 
        provider.services.contains(serviceType) && 
        provider.isVerified && 
        provider.isActive
      ).toList();
    });
  }

  /// Get provider by ID
  Future<Provider?> getProviderById(String id) async {
    try {
      return _providers.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search providers
  Future<List<Provider>> searchProviders({
    String? query,
    String? serviceType,
    LatLng? location,
    double radiusKm = 10.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    List<Provider> results = List.from(_providers);

    // Filter by verification and active status
    results = results.where((provider) => 
      provider.isVerified && provider.isActive
    ).toList();

    // Filter by service type
    if (serviceType != null) {
      results = results.where((provider) => 
        provider.services.contains(serviceType)
      ).toList();
    }

    // Filter by text query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((provider) {
        return provider.name.toLowerCase().contains(lowerQuery) ||
               provider.services.any((service) => 
                 service.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    // Filter by location
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
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    final bookingId = 'booking_${_bookings.length + 1}';
    final booking = Booking(
      id: bookingId,
      customerId: customerId,
      providerId: providerId,
      serviceType: serviceType,
      description: description,
      scheduledDate: scheduledDate,
      address: address,
      price: price,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);
    _bookingsController.add(_bookings);
    return bookingId;
  }

  /// Get user's bookings
  Stream<List<Booking>> getUserBookingsStream(String userId, {String? userType}) {
    return _bookingsController.stream.map((bookings) {
      if (userType == 'provider') {
        return bookings.where((booking) => booking.providerId == userId).toList();
      } else {
        return bookings.where((booking) => booking.customerId == userId).toList();
      }
    });
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    final bookingIndex = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (bookingIndex != -1) {
      final booking = _bookings[bookingIndex];
      final updatedBooking = Booking(
        id: booking.id,
        customerId: booking.customerId,
        providerId: booking.providerId,
        serviceType: booking.serviceType,
        description: booking.description,
        scheduledDate: booking.scheduledDate,
        address: booking.address,
        price: booking.price,
        status: status,
        createdAt: booking.createdAt,
        completedAt: status == 'completed' ? DateTime.now() : booking.completedAt,
      );

      _bookings[bookingIndex] = updatedBooking;
      _bookingsController.add(_bookings);
    }
  }

  // ============================================================================
  // SERVICE CATEGORIES
  // ============================================================================

  /// Get available service categories
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network delay
    return List.from(_serviceCategories);
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

  /// Get Ghana cities
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

  /// Dispose of stream controllers
  void dispose() {
    _providersController.close();
    _bookingsController.close();
  }
}