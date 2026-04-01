import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Biometric Authentication Service
///
/// Provides Face ID, Touch ID, and Fingerprint authentication
/// for iOS and Android devices. Handles secure credential storage
/// and fallback to password authentication.
///
/// Usage:
/// ```dart
/// final bioAuth = BiometricAuthService();
/// bool canUse = await bioAuth.canUseBiometrics();
/// if (canUse) {
///   bool authenticated = await bioAuth.authenticate(reason: 'Login to app');
/// }
/// ```
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Check if device supports biometric authentication
  Future<bool> canUseBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics ||
                                    await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('Error checking biometric support: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  /// Returns: [BiometricType.face, BiometricType.fingerprint, etc.]
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Get user-friendly name for biometric type
  /// Returns: "Face ID", "Touch ID", "Fingerprint", etc.
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return 'Biometric';

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      // iOS Touch ID or Android Fingerprint
      return 'Touch ID';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris Scanner';
    } else {
      return 'Biometric';
    }
  }

  /// Authenticate user with biometrics
  ///
  /// [reason] - User-facing reason for authentication (required by iOS)
  /// [useErrorDialogs] - Show system error dialogs on failure
  /// [stickyAuth] - Stay on lock screen until success or cancel
  ///
  /// Returns true if authentication successful
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/password fallback
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  /// Check if biometric login is enabled for this app
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final enabled = await _storage.read(key: 'biometric_enabled');
      return enabled == 'true';
    } catch (e) {
      print('Error checking biometric login status: $e');
      return false;
    }
  }

  /// Enable biometric login
  /// Call this after user successfully logs in with password
  Future<void> enableBiometricLogin() async {
    try {
      await _storage.write(key: 'biometric_enabled', value: 'true');
    } catch (e) {
      print('Error enabling biometric login: $e');
      rethrow;
    }
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.delete(key: 'biometric_enabled');
      await clearStoredCredentials();
    } catch (e) {
      print('Error disabling biometric login: $e');
      rethrow;
    }
  }

  /// Store user credentials securely (encrypted in Keychain/KeyStore)
  ///
  /// [email] - User email/username
  /// [userId] - User ID for session restoration
  /// [authToken] - Optional authentication token
  Future<void> storeCredentials({
    required String email,
    required String userId,
    String? authToken,
  }) async {
    try {
      await _storage.write(key: 'stored_email', value: email);
      await _storage.write(key: 'stored_user_id', value: userId);
      if (authToken != null) {
        await _storage.write(key: 'stored_auth_token', value: authToken);
      }
    } catch (e) {
      print('Error storing credentials: $e');
      rethrow;
    }
  }

  /// Retrieve stored email
  Future<String?> getStoredEmail() async {
    try {
      return await _storage.read(key: 'stored_email');
    } catch (e) {
      print('Error retrieving stored email: $e');
      return null;
    }
  }

  /// Retrieve stored user ID
  Future<String?> getStoredUserId() async {
    try {
      return await _storage.read(key: 'stored_user_id');
    } catch (e) {
      print('Error retrieving stored user ID: $e');
      return null;
    }
  }

  /// Retrieve stored auth token
  Future<String?> getStoredAuthToken() async {
    try {
      return await _storage.read(key: 'stored_auth_token');
    } catch (e) {
      print('Error retrieving stored auth token: $e');
      return null;
    }
  }

  /// Clear all stored credentials
  Future<void> clearStoredCredentials() async {
    try {
      await _storage.delete(key: 'stored_email');
      await _storage.delete(key: 'stored_user_id');
      await _storage.delete(key: 'stored_auth_token');
    } catch (e) {
      print('Error clearing stored credentials: $e');
      rethrow;
    }
  }

  /// Complete biometric setup flow
  ///
  /// Call this after successful password login to set up biometrics.
  ///
  /// Returns true if biometric setup successful
  Future<bool> setupBiometricLogin({
    required String email,
    required String userId,
    String? authToken,
    String? customReason,
  }) async {
    try {
      // Check if device supports biometrics
      if (!await canUseBiometrics()) {
        throw Exception('Biometric authentication not available on this device');
      }

      // Authenticate to confirm user intent
      final bioTypeName = await getBiometricTypeName();
      final authenticated = await authenticate(
        reason: customReason ?? 'Confirm $bioTypeName to enable quick login',
      );

      if (!authenticated) {
        return false;
      }

      // Store credentials securely
      await storeCredentials(
        email: email,
        userId: userId,
        authToken: authToken,
      );

      // Enable biometric login
      await enableBiometricLogin();

      return true;
    } catch (e) {
      print('Error setting up biometric login: $e');
      return false;
    }
  }

  /// Attempt biometric login
  ///
  /// Returns stored credentials if authentication successful
  /// Returns null if authentication failed
  Future<Map<String, String>?> biometricLogin({
    String? customReason,
  }) async {
    try {
      // Check if biometric login is enabled
      if (!await isBiometricLoginEnabled()) {
        return null;
      }

      // Authenticate
      final bioTypeName = await getBiometricTypeName();
      final authenticated = await authenticate(
        reason: customReason ?? 'Use $bioTypeName to login',
      );

      if (!authenticated) {
        return null;
      }

      // Retrieve stored credentials
      final email = await getStoredEmail();
      final userId = await getStoredUserId();
      final authToken = await getStoredAuthToken();

      if (email == null || userId == null) {
        return null;
      }

      return {
        'email': email,
        'userId': userId,
        if (authToken != null) 'authToken': authToken,
      };
    } catch (e) {
      print('Error during biometric login: $e');
      return null;
    }
  }
}
