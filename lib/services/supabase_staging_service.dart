import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import '../models/service_request.dart';

/// Staging Supabase service for testing HomeLinkGH features
/// Uses separate staging database with test data
class SupabaseStagingService {
  static final SupabaseStagingService _instance = SupabaseStagingService._internal();
  factory SupabaseStagingService() => _instance;
  SupabaseStagingService._internal();

  // Staging Supabase client
  SupabaseClient get supabase => Supabase.instance.client;
  
  // Current user
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // ============================================================================
  // INITIALIZATION FOR STAGING
  // ============================================================================

  /// Initialize Supabase for staging environment
  static Future<void> initializeStaging() async {
    await Supabase.initialize(
      // Staging environment URLs
      url: 'https://homelinkgh-staging.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvbWVsaW5rZ2gtc3RhZ2luZyIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzM2MjQ2NDAwLCJleHAiOjIwNTE4MjI0MDB9.staging_key_for_testing',
      debug: true, // Enable debug mode for staging
    );
    
    // Set up staging data if needed
    await _setupStagingData();
  }

  /// Set up test data for staging environment
  static Future<void> _setupStagingData() async {
    try {
      final service = SupabaseStagingService();
      
      // Create test providers
      await service._createTestProviders();
      
      // Create test users
      await service._createTestUsers();
      
      print('Staging data setup completed');
    } catch (e) {
      print('Error setting up staging data: $e');
    }
  }

  // ============================================================================
  // TEST DATA SETUP
  // ============================================================================

  /// Create test providers for staging
  Future<void> _createTestProviders() async {
    final testProviders = [
      {
        'name': 'Test Cleaning Service',
        'email': 'cleaning@test.com',
        'phone': '+233501234567',
        'services': ['cleaning', 'deep_cleaning'],
        'location': 'Accra Central',
        'rating': 4.5,
        'status': 'verified',
        'is_available': true,
        'price_range': 'GHS 50-200',
      },
      {
        'name': 'Test Plumbing Service',
        'email': 'plumbing@test.com',
        'phone': '+233501234568',
        'services': ['plumbing', 'repairs'],
        'location': 'East Legon',
        'rating': 4.8,
        'status': 'verified',
        'is_available': true,
        'price_range': 'GHS 100-500',
      },
      {
        'name': 'Test Food Delivery',
        'email': 'food@test.com',
        'phone': '+233501234569',
        'services': ['food_delivery', 'catering'],
        'location': 'Osu',
        'rating': 4.3,
        'status': 'verified',
        'is_available': true,
        'price_range': 'GHS 20-100',
      },
    ];

    for (var provider in testProviders) {
      try {
        await supabase.from('providers').upsert(provider);
      } catch (e) {
        print('Error creating test provider: $e');
      }
    }
  }

  /// Create test users for staging
  Future<void> _createTestUsers() async {
    final testUsers = [
      {
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'test.customer@homelinkgh.com',
        'name': 'Test Customer',
        'user_type': 'customer',
        'phone': '+233501111111',
        'location': 'Accra',
        'is_verified': true,
      },
      {
        'id': '22222222-2222-2222-2222-222222222222',
        'email': 'test.provider@homelinkgh.com',
        'name': 'Test Provider',
        'user_type': 'provider',
        'phone': '+233502222222',
        'location': 'Kumasi',
        'is_verified': true,
      },
    ];

    for (var user in testUsers) {
      try {
        await supabase.from('user_profiles').upsert(user);
      } catch (e) {
        print('Error creating test user: $e');
      }
    }
  }

  // ============================================================================
  // STAGING-SPECIFIC METHODS
  // ============================================================================

  /// Get staging environment info
  Map<String, dynamic> getStagingInfo() {
    return {
      'environment': 'staging',
      'database_url': 'https://homelinkgh-staging.supabase.co',
      'features_enabled': [
        'authentication',
        'real_time_updates',
        'file_storage',
        'notifications',
        'test_payments',
      ],
      'test_users': [
        {
          'email': 'test.customer@homelinkgh.com',
          'password': 'TestPass123!',
          'role': 'customer',
        },
        {
          'email': 'test.provider@homelinkgh.com',
          'password': 'TestPass123!',
          'role': 'provider',
        },
      ],
      'test_data': {
        'providers': 'Available',
        'services': 'Available',
        'bookings': 'Available',
      },
    };
  }

  /// Reset staging data
  Future<void> resetStagingData() async {
    try {
      // Clear existing data
      await supabase.from('bookings').delete().neq('id', '');
      await supabase.from('providers').delete().neq('id', '');
      await supabase.from('user_profiles').delete().neq('id', '');
      
      // Recreate test data
      await _setupStagingData();
      
      print('Staging data reset completed');
    } catch (e) {
      print('Error resetting staging data: $e');
    }
  }

  // ============================================================================
  // AUTHENTICATION METHODS (STAGING)
  // ============================================================================

  /// Quick sign in for testing
  Future<AuthResponse> quickSignIn(String testUserType) async {
    final credentials = testUserType == 'customer' 
        ? {'email': 'test.customer@homelinkgh.com', 'password': 'TestPass123!'}
        : {'email': 'test.provider@homelinkgh.com', 'password': 'TestPass123!'};
    
    return await supabase.auth.signInWithPassword(
      email: credentials['email']!,
      password: credentials['password']!,
    );
  }

  /// Create test booking
  Future<String> createTestBooking() async {
    final testBooking = {
      'user_id': '11111111-1111-1111-1111-111111111111',
      'provider_id': '1',
      'service_type': 'cleaning',
      'description': 'Test cleaning service booking',
      'scheduled_date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'location': 'Test Location, Accra',
      'price': 100.0,
      'status': 'confirmed',
      'payment_status': 'pending',
    };

    final response = await supabase.from('bookings').insert(testBooking).select().single();
    return response['id'].toString();
  }

  // All other methods from the original service can be inherited
  // by importing and extending the original SupabaseService
}