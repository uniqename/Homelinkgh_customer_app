import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import '../models/service_request.dart';

/// Complete Supabase service replacing Firebase with all functionality
/// Provides authentication, real-time database, and cloud functions
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client
  SupabaseClient get supabase => Supabase.instance.client;
  
  // Current user
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize Supabase (call this in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      // For demo purposes - in production, use your Supabase project URL and key
      url: 'https://homelinkgh.supabase.co', // Your project URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Your anon key
      // In production, get these from environment variables or secure config
    );
  }

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phone,
    String? location,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'user_type': userType,
          'phone': phone,
          'location': location,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Create user profile in database
      if (response.user != null) {
        await _createUserProfile(response.user!, name, userType, phone, location);
      }

      return response;
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // ============================================================================
  // USER PROFILE METHODS
  // ============================================================================

  /// Create user profile in database
  Future<void> _createUserProfile(
    User user,
    String name,
    String userType,
    String? phone,
    String? location,
  ) async {
    await supabase.from('user_profiles').insert({
      'id': user.id,
      'email': user.email,
      'name': name,
      'user_type': userType,
      'phone': phone,
      'location': location,
      'is_verified': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await supabase.from('user_profiles').update(updates).eq('id', userId);
  }

  // ============================================================================
  // PROVIDER METHODS
  // ============================================================================

  /// Create new provider
  Future<String> createProvider(Map<String, dynamic> providerData) async {
    try {
      providerData['created_at'] = DateTime.now().toIso8601String();
      providerData['updated_at'] = DateTime.now().toIso8601String();
      providerData['is_verified'] = false;
      providerData['status'] = 'pending';

      final response = await supabase.from('providers').insert(providerData).select().single();
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create provider: $e');
    }
  }

  /// Get all providers
  Stream<List<Map<String, dynamic>>> getAllProvidersStream() {
    return supabase
        .from('providers')
        .stream(primaryKey: ['id'])
        .eq('status', 'verified')
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Get providers by service type
  Future<List<Map<String, dynamic>>> getProvidersByService(String serviceType) async {
    try {
      final response = await supabase
          .from('providers')
          .select()
          .contains('services', [serviceType])
          .eq('status', 'verified');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting providers by service: $e');
      return [];
    }
  }

  /// Update provider
  Future<void> updateProvider(String providerId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await supabase.from('providers').update(updates).eq('id', providerId);
  }

  // ============================================================================
  // BOOKING METHODS
  // ============================================================================

  /// Create new booking
  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    try {
      bookingData['created_at'] = DateTime.now().toIso8601String();
      bookingData['updated_at'] = DateTime.now().toIso8601String();
      bookingData['status'] = 'pending';

      final response = await supabase.from('bookings').insert(bookingData).select().single();
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get user bookings
  Stream<List<Map<String, dynamic>>> getUserBookingsStream(String userId) {
    return supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Get provider bookings
  Stream<List<Map<String, dynamic>>> getProviderBookingsStream(String providerId) {
    return supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('provider_id', providerId)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await supabase.from('bookings').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  // ============================================================================
  // SERVICE REQUEST METHODS
  // ============================================================================

  /// Create service request
  Future<String> createServiceRequest(Map<String, dynamic> requestData) async {
    try {
      requestData['created_at'] = DateTime.now().toIso8601String();
      requestData['updated_at'] = DateTime.now().toIso8601String();
      requestData['status'] = 'open';

      final response = await supabase.from('service_requests').insert(requestData).select().single();
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create service request: $e');
    }
  }

  /// Get service requests
  Stream<List<Map<String, dynamic>>> getServiceRequestsStream() {
    return supabase
        .from('service_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'open')
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ============================================================================
  // REAL-TIME NOTIFICATIONS
  // ============================================================================

  /// Subscribe to user notifications
  RealtimeChannel subscribeToUserNotifications(String userId, Function(Map<String, dynamic>) onNotification) {
    return supabase
        .channel('user-notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (payload) => onNotification(payload.newRecord),
        )
        .subscribe();
  }

  /// Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================================
  // CHAT/MESSAGING
  // ============================================================================

  /// Send message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    String? type = 'text',
  }) async {
    await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message': message,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribe to conversation messages
  RealtimeChannel subscribeToMessages(String conversationId, Function(Map<String, dynamic>) onMessage) {
    return supabase
        .channel('conversation-$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'conversation_id', value: conversationId),
          callback: (payload) => onMessage(payload.newRecord),
        )
        .subscribe();
  }

  // ============================================================================
  // FILE STORAGE
  // ============================================================================

  /// Upload file
  Future<String> uploadFile(String bucket, String filePath, Uint8List fileBytes) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      await supabase.storage.from(bucket).uploadBinary(fileName, fileBytes);
      return supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // ============================================================================
  // ANALYTICS & REPORTING
  // ============================================================================

  /// Get platform statistics
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      final users = await supabase.from('user_profiles').select('id').count();
      final providers = await supabase.from('providers').select('id').eq('status', 'verified').count();
      final bookings = await supabase.from('bookings').select('id').count();
      final revenue = await supabase.rpc('get_total_revenue');

      return {
        'total_users': users.count,
        'active_providers': providers.count,
        'total_bookings': bookings.count,
        'total_revenue': revenue ?? 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting platform stats: $e');
      return {
        'total_users': 0,
        'active_providers': 0,
        'total_bookings': 0,
        'total_revenue': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  // ============================================================================
  // ERROR HANDLING & LOGGING
  // ============================================================================

  /// Log error to Supabase
  Future<void> logError(String error, String context, [Map<String, dynamic>? metadata]) async {
    try {
      await supabase.from('error_logs').insert({
        'error': error,
        'context': context,
        'metadata': metadata,
        'user_id': currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to log error: $e');
    }
  }
}