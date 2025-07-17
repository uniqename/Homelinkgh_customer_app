import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

/// Persistent Authentication Service for HomeLinkGH
/// Securely remembers user sign-in details until cache is cleared
class PersistentAuthService {
  static const String _encryptionKey = 'HomeLinkGH2024SecureKey32BytesLong';
  static const String _userDataKey = 'persistent_user_data';
  static const String _credentialsKey = 'encrypted_credentials';
  static const String _sessionKey = 'user_session_data';
  static const String _autoLoginKey = 'auto_login_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginKey = 'last_login_timestamp';
  
  static final _encrypter = Encrypter(AES(Key.fromBase64(base64.encode(_encryptionKey.codeUnits))));
  static final _iv = IV.fromLength(16);
  
  /// Save user credentials securely for auto-login
  static Future<bool> saveUserCredentials({
    required String email,
    required String password,
    required String userId,
    required String userType,
    required Map<String, dynamic> userProfile,
    bool enableAutoLogin = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Encrypt sensitive data
      Map<String, dynamic> credentials = {
        'email': email,
        'password': password, // In production, use hashed password
        'user_id': userId,
        'user_type': userType,
        'save_timestamp': DateTime.now().toIso8601String(),
      };
      
      String encryptedCredentials = _encrypter.encrypt(
        json.encode(credentials), 
        iv: _iv
      ).base64;
      
      // Save encrypted credentials
      await prefs.setString(_credentialsKey, encryptedCredentials);
      
      // Save user profile data (non-sensitive)
      await prefs.setString(_userDataKey, json.encode(userProfile));
      
      // Save session data
      Map<String, dynamic> sessionData = {
        'user_id': userId,
        'user_type': userType,
        'email': email,
        'login_timestamp': DateTime.now().toIso8601String(),
        'is_logged_in': true,
        'session_expires': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };
      
      await prefs.setString(_sessionKey, json.encode(sessionData));
      await prefs.setBool(_autoLoginKey, enableAutoLogin);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      print('Error saving user credentials: $e');
      return false;
    }
  }
  
  /// Check if user has saved credentials and auto-login is enabled
  static Future<bool> hasValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if auto-login is enabled
      bool autoLoginEnabled = prefs.getBool(_autoLoginKey) ?? false;
      if (!autoLoginEnabled) return false;
      
      // Check if credentials exist
      String? encryptedCredentials = prefs.getString(_credentialsKey);
      if (encryptedCredentials == null) return false;
      
      // Check session data
      String? sessionJson = prefs.getString(_sessionKey);
      if (sessionJson == null) return false;
      
      Map<String, dynamic> sessionData = json.decode(sessionJson);
      
      // Check if session is not expired
      String? expiryDateStr = sessionData['session_expires'];
      if (expiryDateStr != null) {
        DateTime expiryDate = DateTime.parse(expiryDateStr);
        if (DateTime.now().isAfter(expiryDate)) {
          await clearUserSession();
          return false;
        }
      }
      
      return sessionData['is_logged_in'] == true;
    } catch (e) {
      print('Error checking session validity: $e');
      return false;
    }
  }
  
  /// Retrieve saved user credentials
  static Future<Map<String, dynamic>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      String? encryptedCredentials = prefs.getString(_credentialsKey);
      if (encryptedCredentials == null) return null;
      
      // Decrypt credentials
      String decryptedJson = _encrypter.decrypt64(encryptedCredentials, iv: _iv);
      Map<String, dynamic> credentials = json.decode(decryptedJson);
      
      return credentials;
    } catch (e) {
      print('Error retrieving saved credentials: $e');
      return null;
    }
  }
  
  /// Get current user session data
  static Future<Map<String, dynamic>?> getCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        return json.decode(sessionJson);
      }
    } catch (e) {
      print('Error getting current session: $e');
    }
    return null;
  }
  
  /// Get saved user profile data
  static Future<Map<String, dynamic>?> getSavedUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString(_userDataKey);
      
      if (userDataJson != null) {
        return json.decode(userDataJson);
      }
    } catch (e) {
      print('Error getting saved user profile: $e');
    }
    return null;
  }
  
  /// Update session timestamp (extend session)
  static Future<void> updateSessionTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        Map<String, dynamic> sessionData = json.decode(sessionJson);
        sessionData['last_activity'] = DateTime.now().toIso8601String();
        sessionData['session_expires'] = DateTime.now().add(const Duration(days: 30)).toIso8601String();
        
        await prefs.setString(_sessionKey, json.encode(sessionData));
      }
    } catch (e) {
      print('Error updating session timestamp: $e');
    }
  }
  
  /// Auto-login with saved credentials
  static Future<Map<String, dynamic>> attemptAutoLogin() async {
    try {
      // Check if valid session exists
      if (!await hasValidSession()) {
        return {
          'success': false,
          'message': 'No valid session found',
          'requires_login': true,
        };
      }
      
      // Get saved credentials
      Map<String, dynamic>? credentials = await getSavedCredentials();
      if (credentials == null) {
        return {
          'success': false,
          'message': 'No saved credentials found',
          'requires_login': true,
        };
      }
      
      // Get user profile
      Map<String, dynamic>? userProfile = await getSavedUserProfile();
      
      // Update session
      await updateSessionTimestamp();
      
      return {
        'success': true,
        'message': 'Auto-login successful',
        'user_data': {
          'user_id': credentials['user_id'],
          'email': credentials['email'],
          'user_type': credentials['user_type'],
          'profile': userProfile,
        },
        'session_data': await getCurrentSession(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Auto-login failed: $e',
        'requires_login': true,
      };
    }
  }
  
  /// Enable/disable auto-login
  static Future<void> setAutoLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, enabled);
    
    if (!enabled) {
      // Clear credentials if auto-login is disabled
      await clearUserCredentials();
    }
  }
  
  /// Check if auto-login is enabled
  static Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? false;
  }
  
  /// Enable/disable biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
  
  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  /// Update user profile data
  static Future<void> updateUserProfile(Map<String, dynamic> userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, json.encode(userProfile));
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }
  
  /// Clear user credentials only (keep session for current login)
  static Future<void> clearUserCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_credentialsKey);
      await prefs.setBool(_autoLoginKey, false);
    } catch (e) {
      print('Error clearing user credentials: $e');
    }
  }
  
  /// Clear entire user session (logout)
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_credentialsKey);
      await prefs.remove(_sessionKey);
      await prefs.remove(_userDataKey);
      await prefs.setBool(_autoLoginKey, false);
      await prefs.setBool(_biometricEnabledKey, false);
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }
  
  /// Get last login information
  static Future<Map<String, dynamic>> getLastLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? lastLoginStr = prefs.getString(_lastLoginKey);
      
      if (lastLoginStr != null) {
        DateTime lastLogin = DateTime.parse(lastLoginStr);
        Duration timeSinceLogin = DateTime.now().difference(lastLogin);
        
        return {
          'last_login': lastLogin.toIso8601String(),
          'days_since_login': timeSinceLogin.inDays,
          'hours_since_login': timeSinceLogin.inHours,
          'formatted_time': _formatTimeSince(timeSinceLogin),
        };
      }
    } catch (e) {
      print('Error getting last login info: $e');
    }
    
    return {
      'last_login': null,
      'days_since_login': 0,
      'hours_since_login': 0,
      'formatted_time': 'Never',
    };
  }
  
  /// Check if session needs renewal
  static Future<bool> needsSessionRenewal() async {
    try {
      Map<String, dynamic>? sessionData = await getCurrentSession();
      if (sessionData == null) return true;
      
      String? expiryDateStr = sessionData['session_expires'];
      if (expiryDateStr != null) {
        DateTime expiryDate = DateTime.parse(expiryDateStr);
        DateTime renewalDate = expiryDate.subtract(const Duration(days: 7)); // Renew 7 days before expiry
        
        return DateTime.now().isAfter(renewalDate);
      }
    } catch (e) {
      print('Error checking session renewal: $e');
    }
    return true;
  }
  
  /// Renew session with current credentials
  static Future<bool> renewSession() async {
    try {
      Map<String, dynamic>? credentials = await getSavedCredentials();
      Map<String, dynamic>? userProfile = await getSavedUserProfile();
      
      if (credentials != null && userProfile != null) {
        return await saveUserCredentials(
          email: credentials['email'],
          password: credentials['password'],
          userId: credentials['user_id'],
          userType: credentials['user_type'],
          userProfile: userProfile,
          enableAutoLogin: await isAutoLoginEnabled(),
        );
      }
    } catch (e) {
      print('Error renewing session: $e');
    }
    return false;
  }
  
  /// Get authentication statistics
  static Future<Map<String, dynamic>> getAuthStats() async {
    try {
      Map<String, dynamic> lastLoginInfo = await getLastLoginInfo();
      bool autoLoginEnabled = await isAutoLoginEnabled();
      bool biometricEnabled = await isBiometricEnabled();
      bool needsRenewal = await needsSessionRenewal();
      bool validSession = await hasValidSession();
      
      return {
        'has_valid_session': validSession,
        'auto_login_enabled': autoLoginEnabled,
        'biometric_enabled': biometricEnabled,
        'needs_session_renewal': needsRenewal,
        'last_login_info': lastLoginInfo,
        'session_data': await getCurrentSession(),
      };
    } catch (e) {
      return {
        'error': 'Failed to get auth stats: $e',
      };
    }
  }
  
  /// Format time since last activity
  static String _formatTimeSince(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Security check - validate session integrity
  static Future<bool> validateSessionIntegrity() async {
    try {
      Map<String, dynamic>? sessionData = await getCurrentSession();
      Map<String, dynamic>? credentials = await getSavedCredentials();
      
      if (sessionData == null || credentials == null) return false;
      
      // Check if user IDs match
      if (sessionData['user_id'] != credentials['user_id']) return false;
      
      // Check if emails match
      if (sessionData['email'] != credentials['email']) return false;
      
      // Check session expiry
      String? expiryDateStr = sessionData['session_expires'];
      if (expiryDateStr != null) {
        DateTime expiryDate = DateTime.parse(expiryDateStr);
        if (DateTime.now().isAfter(expiryDate)) return false;
      }
      
      return true;
    } catch (e) {
      print('Error validating session integrity: $e');
      return false;
    }
  }
}