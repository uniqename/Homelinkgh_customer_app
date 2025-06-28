import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/provider.dart';
import '../models/service_request.dart';
import '../models/booking.dart';

class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  // Mock Ghana providers with realistic data
  final List<Provider> _providers = [
    Provider(
      id: '1',
      name: 'Kwame Asante',
      email: 'kwame.asante@homelink.gh',
      phoneNumber: '+233 24 123 4567',
      rating: 4.8,
      completedJobs: 145,
      services: ['Food Delivery', 'Grocery Shopping'],
      location: const LatLng(5.6037, -0.1870), // East Legon, Accra
      isAvailable: true,
      averageResponseTime: 15,
      profileImageUrl: 'https://via.placeholder.com/150',
      bio: 'Experienced food delivery specialist in Greater Accra. Fast, reliable service.',
    ),
    Provider(
      id: '2', 
      name: 'Ama Serwaa',
      email: 'ama.serwaa@homelink.gh',
      phoneNumber: '+233 20 987 6543',
      rating: 4.9,
      completedJobs: 203,
      services: ['House Cleaning', 'Laundry Service'],
      location: const LatLng(5.5502, -0.2174), // Osu, Accra
      isAvailable: true,
      averageResponseTime: 12,
      profileImageUrl: 'https://via.placeholder.com/150',
      bio: 'Professional house cleaning with eco-friendly products. Trusted by families.',
    ),
    Provider(
      id: '3',
      name: 'Kofi Mensah', 
      email: 'kofi.mensah@homelink.gh',
      phoneNumber: '+233 26 555 7890',
      rating: 4.7,
      completedJobs: 89,
      services: ['Food Delivery', 'Transportation'],
      location: const LatLng(5.6205, -0.1731), // Airport Residential, Accra
      isAvailable: true,
      averageResponseTime: 8,
      profileImageUrl: 'https://via.placeholder.com/150',
      bio: 'Quick food delivery and ride services. Available 24/7 in Accra.',
    ),
    Provider(
      id: '4',
      name: 'Akosua Boateng',
      email: 'akosua.boateng@homelink.gh',
      phoneNumber: '+233 23 456 7890',
      rating: 4.9,
      completedJobs: 167,
      services: ['Nail Tech', 'Makeup Artist'],
      location: const LatLng(5.5557, -0.1963), // Cantonments, Accra
      isAvailable: true,
      averageResponseTime: 20,
      profileImageUrl: 'https://via.placeholder.com/150',
      bio: 'Professional beauty services. Specializing in bridal and event makeup.',
    ),
    Provider(
      id: '5',
      name: 'Yaw Opoku',
      email: 'yaw.opoku@homelink.gh',
      phoneNumber: '+233 27 123 9876',
      rating: 4.6,
      completedJobs: 134,
      services: ['Plumbing', 'Electrical Work'],
      location: const LatLng(5.6434, -0.1776), // Dzorwulu, Accra
      isAvailable: true,
      averageResponseTime: 25,
      profileImageUrl: 'https://via.placeholder.com/150',
      bio: 'Licensed electrician and plumber. Emergency services available.',
    ),
  ];

  final List<Booking> _bookings = [];

  // Service categories with Ghana-specific options
  final Map<String, List<String>> _serviceCategories = {
    'Food Delivery': [
      'Jollof Rice & Chicken',
      'Banku & Tilapia', 
      'Waakye',
      'Kelewele',
      'Fast Food',
      'Local Dishes',
      'International Cuisine',
    ],
    'House Cleaning': [
      'Deep Cleaning',
      'Regular Cleaning',
      'Move-in/Move-out',
      'Office Cleaning',
      'Carpet Cleaning',
    ],
    'Transportation': [
      'Airport Transfer',
      'City Rides',
      'Shopping Trips',
      'Event Transport',
    ],
    'Beauty Services': [
      'Hair Styling',
      'Makeup',
      'Nail Services',
      'Spa Services',
    ],
    'Home Services': [
      'Plumbing',
      'Electrical',
      'Gardening',
      'Painting',
      'Repairs',
    ],
  };

  // Get all providers
  Future<List<Provider>> getAllProviders() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return List.from(_providers);
  }

  // Get providers by service type
  Future<List<Provider>> getProvidersByService(String serviceType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Create service mapping to match different naming conventions
    final serviceMapping = {
      'Food Delivery': ['Food Delivery', 'Restaurant', 'Delivery'],
      'House Cleaning': ['House Cleaning', 'Cleaning', 'Laundry Service'],
      'Transportation': ['Transportation', 'Driver', 'Ride'],
      'Beauty Services': ['Nail Tech', 'Makeup Artist', 'Beauty', 'Hair'],
      'Jollof Delivery': ['Food Delivery', 'Restaurant'],
      'Banku & Fish': ['Food Delivery', 'Restaurant'],
      'Airport Transfer': ['Transportation', 'Driver'],
      'Braiding Hair': ['Nail Tech', 'Makeup Artist', 'Beauty'],
      'House Help': ['House Cleaning', 'Cleaning'],
    };
    
    // Get matching service types for the requested service
    final matchingServices = serviceMapping[serviceType] ?? [serviceType];
    
    // Find providers that have any of the matching services
    return _providers.where((provider) => 
      provider.services.any((service) => 
        matchingServices.any((matchingService) => 
          service.toLowerCase().contains(matchingService.toLowerCase()) ||
          matchingService.toLowerCase().contains(service.toLowerCase())
        )
      )
    ).toList();
  }

  // Get provider by ID
  Future<Provider?> getProviderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _providers.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create booking
  Future<String> createBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate processing
    
    final newBooking = booking.copyWith(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      status: 'confirmed',
      createdAt: DateTime.now(),
    );
    
    _bookings.add(newBooking);
    return newBooking.id!;
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _bookings.where((booking) => booking.customerId == userId).toList();
  }

  // Get service categories
  Map<String, List<String>> getServiceCategories() {
    return Map.from(_serviceCategories);
  }

  // Search providers
  Future<List<Provider>> searchProviders({
    String? query,
    String? serviceType,
    LatLng? location,
    double radiusKm = 10.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    var results = List<Provider>.from(_providers);
    
    // Filter by service type
    if (serviceType != null) {
      results = results.where((provider) => 
        provider.services.contains(serviceType)
      ).toList();
    }
    
    // Filter by search query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((provider) => 
        provider.name.toLowerCase().contains(lowerQuery) ||
        provider.services.any((service) => 
          service.toLowerCase().contains(lowerQuery)
        )
      ).toList();
    }
    
    // Filter by location (simplified)
    if (location != null) {
      // In a real app, you'd calculate actual distance
      // For demo, we'll just return all results
    }
    
    return results;
  }

  // Get popular services for Ghana
  List<String> getPopularServices() {
    return [
      'Food Delivery',
      'House Cleaning', 
      'Transportation',
      'Beauty Services',
      'Home Services',
    ];
  }

  // Get Ghana cities
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
    ];
  }

  // Simulate real-time updates
  Stream<List<Provider>> getAvailableProvidersStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      // Randomly update provider availability
      for (var provider in _providers) {
        if (DateTime.now().millisecond % 10 == 0) {
          provider.isAvailable = !provider.isAvailable;
        }
      }
      yield List.from(_providers);
    }
  }
}