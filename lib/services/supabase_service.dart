import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    // Load credentials from .env file for security
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
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

  // ============================================================================
  // ADMIN MANAGEMENT METHODS
  // ============================================================================

  /// Create admin user
  Future<String> createAdminUser({
    required String email,
    required String passwordHash,
    required String fullName,
    String role = 'admin',
    List<String>? permissions,
  }) async {
    try {
      final response = await supabase.from('admin_users').insert({
        'email': email,
        'password_hash': passwordHash,
        'full_name': fullName,
        'role': role,
        'permissions': permissions ?? [],
        'admin_secret_validated': true,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      await logAdminActivity(
        adminId: response['id'],
        action: 'create_admin',
        resourceType: 'admin_users',
        resourceId: response['id'],
      );

      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create admin user: $e');
    }
  }

  /// Get admin user by email
  Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
    try {
      final response = await supabase
          .from('admin_users')
          .select()
          .eq('email', email)
          .single();
      return response;
    } catch (e) {
      print('Error getting admin by email: $e');
      return null;
    }
  }

  /// Update admin last login
  Future<void> updateAdminLastLogin(String adminId) async {
    await supabase.from('admin_users').update({
      'last_login_at': DateTime.now().toIso8601String(),
    }).eq('id', adminId);
  }

  /// Get all admin users
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final response = await supabase
          .from('admin_users')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting admins: $e');
      return [];
    }
  }

  // ============================================================================
  // SERVICES CONFIGURATION METHODS
  // ============================================================================

  /// Create service
  Future<String> createService(Map<String, dynamic> serviceData) async {
    try {
      serviceData['created_at'] = DateTime.now().toIso8601String();
      serviceData['updated_at'] = DateTime.now().toIso8601String();
      serviceData['created_by'] = currentUser?.id;

      final response = await supabase.from('services').insert(serviceData).select().single();

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'create_service',
        resourceType: 'services',
        resourceId: response['id'],
        changes: serviceData,
      );

      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  /// Get all services
  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final response = await supabase
          .from('services')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting services: $e');
      return [];
    }
  }

  /// Update service
  Future<void> updateService(String serviceId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await supabase.from('services').update(updates).eq('id', serviceId);

    await logAdminActivity(
      adminId: currentUser!.id,
      action: 'update_service',
      resourceType: 'services',
      resourceId: serviceId,
      changes: updates,
    );
  }

  /// Delete service
  Future<void> deleteService(String serviceId) async {
    await supabase.from('services').delete().eq('id', serviceId);

    await logAdminActivity(
      adminId: currentUser!.id,
      action: 'delete_service',
      resourceType: 'services',
      resourceId: serviceId,
    );
  }

  // ============================================================================
  // LABOR RATES METHODS
  // ============================================================================

  /// Get all labor rates
  Future<List<Map<String, dynamic>>> getAllLaborRates() async {
    try {
      final response = await supabase
          .from('labor_rates')
          .select()
          .order('service_type');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting labor rates: $e');
      return [];
    }
  }

  /// Get labor rate by service type
  Future<double?> getLaborRate(String serviceType) async {
    try {
      final response = await supabase
          .from('labor_rates')
          .select('rate_per_hour')
          .eq('service_type', serviceType)
          .single();
      return double.tryParse(response['rate_per_hour'].toString());
    } catch (e) {
      print('Error getting labor rate: $e');
      return null;
    }
  }

  /// Set labor rate
  Future<void> setLaborRate(String serviceType, double rate, {String? description}) async {
    try {
      await supabase.from('labor_rates').upsert({
        'service_type': serviceType,
        'rate_per_hour': rate,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': currentUser?.id,
      });

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'update_labor_rate',
        resourceType: 'labor_rates',
        resourceId: serviceType,
        changes: {'rate_per_hour': rate},
      );
    } catch (e) {
      throw Exception('Failed to set labor rate: $e');
    }
  }

  // ============================================================================
  // PARTS CATALOG METHODS
  // ============================================================================

  /// Get all parts
  Future<List<Map<String, dynamic>>> getAllParts() async {
    try {
      final response = await supabase
          .from('parts')
          .select()
          .eq('is_active', true)
          .order('category');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting parts: $e');
      return [];
    }
  }

  /// Get part price
  Future<double?> getPartPrice(String category, String partName) async {
    try {
      final response = await supabase
          .from('parts')
          .select('base_price')
          .eq('category', category)
          .eq('part_name', partName)
          .single();
      return double.tryParse(response['base_price'].toString());
    } catch (e) {
      print('Error getting part price: $e');
      return null;
    }
  }

  /// Create or update part
  Future<void> upsertPart({
    required String category,
    required String partName,
    required double price,
    String? unit,
    String? description,
  }) async {
    try {
      await supabase.from('parts').upsert({
        'category': category,
        'part_name': partName,
        'base_price': price,
        'unit': unit,
        'description': description,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': currentUser?.id,
      });

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'upsert_part',
        resourceType: 'parts',
        resourceId: '$category:$partName',
        changes: {'base_price': price},
      );
    } catch (e) {
      throw Exception('Failed to upsert part: $e');
    }
  }

  // ============================================================================
  // PLATFORM SETTINGS METHODS
  // ============================================================================

  /// Get all platform settings
  Future<Map<String, dynamic>> getAllPlatformSettings() async {
    try {
      final response = await supabase.from('platform_settings').select();
      final settingsMap = <String, dynamic>{};
      for (var setting in response) {
        settingsMap[setting['key']] = setting['value'];
      }
      return settingsMap;
    } catch (e) {
      print('Error getting platform settings: $e');
      return {};
    }
  }

  /// Get platform setting
  Future<dynamic> getPlatformSetting(String key) async {
    try {
      final response = await supabase
          .from('platform_settings')
          .select('value')
          .eq('key', key)
          .single();
      return response['value'];
    } catch (e) {
      print('Error getting platform setting: $e');
      return null;
    }
  }

  /// Set platform setting
  Future<void> setPlatformSetting(
    String key,
    dynamic value, {
    String? description,
    String? settingType,
    bool isPublic = false,
  }) async {
    try {
      await supabase.from('platform_settings').upsert({
        'key': key,
        'value': value,
        'description': description,
        'setting_type': settingType,
        'is_public': isPublic,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': currentUser?.id,
      });

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'update_setting',
        resourceType: 'platform_settings',
        resourceId: key,
        changes: {'value': value},
      );
    } catch (e) {
      throw Exception('Failed to set platform setting: $e');
    }
  }

  // ============================================================================
  // COMMISSION RATES METHODS
  // ============================================================================

  /// Get all commission rates
  Future<Map<String, double>> getAllCommissionRates() async {
    try {
      final response = await supabase.from('commission_rates').select();
      final ratesMap = <String, double>{};
      for (var rate in response) {
        ratesMap[rate['service_type']] = double.parse(rate['rate_percentage'].toString());
      }
      return ratesMap;
    } catch (e) {
      print('Error getting commission rates: $e');
      return {};
    }
  }

  /// Set commission rate
  Future<void> setCommissionRate(String serviceType, double ratePercentage) async {
    try {
      await supabase.from('commission_rates').upsert({
        'service_type': serviceType,
        'rate_percentage': ratePercentage,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': currentUser?.id,
      });

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'update_commission',
        resourceType: 'commission_rates',
        resourceId: serviceType,
        changes: {'rate_percentage': ratePercentage},
      );
    } catch (e) {
      throw Exception('Failed to set commission rate: $e');
    }
  }

  // ============================================================================
  // SERVICE AREAS METHODS
  // ============================================================================

  /// Get all service areas
  Future<List<Map<String, dynamic>>> getAllServiceAreas() async {
    try {
      final response = await supabase
          .from('service_areas')
          .select()
          .eq('is_active', true)
          .order('region_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting service areas: $e');
      return [];
    }
  }

  /// Create service area
  Future<String> createServiceArea(Map<String, dynamic> areaData) async {
    try {
      areaData['created_at'] = DateTime.now().toIso8601String();
      areaData['updated_at'] = DateTime.now().toIso8601String();
      areaData['updated_by'] = currentUser?.id;

      final response = await supabase.from('service_areas').insert(areaData).select().single();

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'create_service_area',
        resourceType: 'service_areas',
        resourceId: response['id'],
      );

      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create service area: $e');
    }
  }

  /// Update service area
  Future<void> updateServiceArea(String areaId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    updates['updated_by'] = currentUser?.id;
    await supabase.from('service_areas').update(updates).eq('id', areaId);

    await logAdminActivity(
      adminId: currentUser!.id,
      action: 'update_service_area',
      resourceType: 'service_areas',
      resourceId: areaId,
      changes: updates,
    );
  }

  // ============================================================================
  // POLICIES METHODS
  // ============================================================================

  /// Get all policies
  Future<List<Map<String, dynamic>>> getAllPolicies() async {
    try {
      final response = await supabase
          .from('policies')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting policies: $e');
      return [];
    }
  }

  /// Get active policy by type
  Future<Map<String, dynamic>?> getActivePolicy(String policyType) async {
    try {
      final response = await supabase
          .from('policies')
          .select()
          .eq('policy_type', policyType)
          .eq('status', 'active')
          .single();
      return response;
    } catch (e) {
      print('Error getting active policy: $e');
      return null;
    }
  }

  /// Create policy
  Future<String> createPolicy(Map<String, dynamic> policyData) async {
    try {
      policyData['created_at'] = DateTime.now().toIso8601String();
      policyData['updated_at'] = DateTime.now().toIso8601String();
      policyData['updated_by'] = currentUser?.id;

      final response = await supabase.from('policies').insert(policyData).select().single();

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'create_policy',
        resourceType: 'policies',
        resourceId: response['id'],
      );

      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create policy: $e');
    }
  }

  /// Update policy
  Future<void> updatePolicy(String policyId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    updates['updated_by'] = currentUser?.id;
    await supabase.from('policies').update(updates).eq('id', policyId);

    await logAdminActivity(
      adminId: currentUser!.id,
      action: 'update_policy',
      resourceType: 'policies',
      resourceId: policyId,
      changes: updates,
    );
  }

  // ============================================================================
  // DISCOUNT CODES METHODS
  // ============================================================================

  /// Get all discount codes
  Future<List<Map<String, dynamic>>> getAllDiscountCodes() async {
    try {
      final response = await supabase
          .from('discount_codes')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting discount codes: $e');
      return [];
    }
  }

  /// Validate discount code
  Future<Map<String, dynamic>?> validateDiscountCode(String code) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabase
          .from('discount_codes')
          .select()
          .eq('code', code)
          .eq('is_active', true)
          .or('expiry_date.is.null,expiry_date.gte.$now')
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error validating discount code: $e');
      return null;
    }
  }

  /// Create discount code
  Future<String> createDiscountCode(Map<String, dynamic> discountData) async {
    try {
      discountData['created_at'] = DateTime.now().toIso8601String();
      discountData['updated_at'] = DateTime.now().toIso8601String();
      discountData['created_by'] = currentUser?.id;

      final response = await supabase.from('discount_codes').insert(discountData).select().single();

      await logAdminActivity(
        adminId: currentUser!.id,
        action: 'create_discount_code',
        resourceType: 'discount_codes',
        resourceId: response['id'],
      );

      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create discount code: $e');
    }
  }

  /// Update discount code
  Future<void> updateDiscountCode(String codeId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await supabase.from('discount_codes').update(updates).eq('id', codeId);

    await logAdminActivity(
      adminId: currentUser!.id,
      action: 'update_discount_code',
      resourceType: 'discount_codes',
      resourceId: codeId,
      changes: updates,
    );
  }

  // ============================================================================
  // ADMIN ACTIVITY LOG METHODS
  // ============================================================================

  /// Log admin activity
  Future<void> logAdminActivity({
    required String adminId,
    required String action,
    required String resourceType,
    String? resourceId,
    Map<String, dynamic>? changes,
  }) async {
    try {
      await supabase.from('admin_activity_log').insert({
        'admin_id': adminId,
        'action': action,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'changes': changes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to log admin activity: $e');
    }
  }

  /// Get admin activity logs
  Future<List<Map<String, dynamic>>> getAdminActivityLogs({
    String? adminId,
    int limit = 100,
  }) async {
    try {
      var query = supabase
          .from('admin_activity_log')
          .select();

      if (adminId != null) {
        query = query.eq('admin_id', adminId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting admin activity logs: $e');
      return [];
    }
  }
}