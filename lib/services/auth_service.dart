// Using Supabase and SharedPreferences for authentication
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../constants/admin_config.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseService _supabase = SupabaseService();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // Initialize auth state from saved session
  Future<void> initialize() async {
    _currentUser = await _getSavedUserData();
  }

  // Get saved user data from SharedPreferences
  Future<AppUser?> _getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return AppUser.fromJson(userMap);
      }
    } catch (e) {
      print('Error loading saved user data: $e');
    }
    return null;
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(user.toJson()));
      _currentUser = user;
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Clear saved user data
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      _currentUser = null;
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Email/password registration
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
    String? phoneNumber,
    String? emergencyContact,
    String? emergencyContactPhone,
  }) async {
    try {
      final passwordHash = _hashPassword(password);

      final appUser = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: displayName,
        phoneNumber: phoneNumber,
        userType: userType,
        isAnonymous: false,
        createdAt: DateTime.now(),
        emergencyContact: emergencyContact,
        emergencyContactPhone: emergencyContactPhone,
      );

      // In production, save to Supabase
      // For now, save locally
      await _saveUserData(appUser);

      return appUser;
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  // Email/password sign in
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // In production, verify credentials against Supabase
      // For now, just check if user exists locally
      final savedUser = await _getSavedUserData();

      if (savedUser != null && savedUser.email == email) {
        _currentUser = savedUser;
        return savedUser;
      }

      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Get user data
  Future<AppUser?> getUserData(String uid) async {
    try {
      // In production, fetch from Supabase
      // For now, return current user if ID matches
      final savedUser = await _getSavedUserData();
      if (savedUser?.id == uid) {
        return savedUser;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<bool> updateUserData(AppUser user) async {
    try {
      await _saveUserData(user);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _clearUserData();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Password reset (placeholder - would use Supabase in production)
  Future<bool> resetPassword(String email) async {
    try {
      // In production, use Supabase password reset
      print('Password reset requested for: $email');
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      await _clearUserData();
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Check if user is anonymous
  Future<bool> isAnonymousUser() async {
    final user = await _getSavedUserData();
    return user?.isAnonymous ?? false;
  }

  // Password hashing methods for secure admin authentication
  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}homelink_salt_2025');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  // Admin-specific registration with secret code validation
  Future<AppUser?> registerAdmin({
    required String email,
    required String password,
    required String displayName,
    required String adminSecretCode,
  }) async {
    try {
      // Validate admin secret code
      if (!AdminConfig.validateSecretCode(adminSecretCode)) {
        throw Exception('Invalid admin secret code');
      }

      // Validate email domain
      if (!AdminConfig.validateEmailDomain(email)) {
        throw Exception('Email domain not authorized for admin access');
      }

      final passwordHash = _hashPassword(password);

      // Create admin user in Supabase
      final adminId = await _supabase.createAdminUser(
        email: email,
        passwordHash: passwordHash,
        fullName: displayName,
        role: 'admin',
      );

      // Create admin user in app
      final appUser = AppUser(
        id: adminId,
        email: email,
        displayName: displayName,
        userType: UserType.admin,
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      await _saveUserData(appUser);
      return appUser;
    } catch (e) {
      print('Error during admin registration: $e');
      rethrow;
    }
  }

  // Admin-specific sign in with password verification
  Future<AppUser?> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Get admin from Supabase
      final adminData = await _supabase.getAdminByEmail(email);

      if (adminData != null) {
        final storedHash = adminData['password_hash'] as String;

        // Verify password
        if (_verifyPassword(password, storedHash)) {
          // Update last login
          await _supabase.updateAdminLastLogin(adminData['id']);

          final appUser = AppUser(
            id: adminData['id'],
            email: email,
            displayName: adminData['full_name'],
            userType: UserType.admin,
            isAnonymous: false,
            createdAt: DateTime.parse(adminData['created_at']),
          );

          await _saveUserData(appUser);
          return appUser;
        } else {
          throw Exception('Invalid password');
        }
      } else {
        throw Exception('Admin account not found');
      }
    } catch (e) {
      print('Error during admin sign in: $e');
      rethrow;
    }
  }
}
