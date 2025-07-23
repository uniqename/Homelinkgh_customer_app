/// Simplified Auth Service that doesn't depend on Firestore
/// In production, this would integrate with Supabase Auth
class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUserId;
  static String? _currentUserType;

  /// Check if user is logged in
  static bool get isLoggedIn => _isLoggedIn;
  
  /// Get current user ID
  static String? get currentUserId => _currentUserId;
  
  /// Get current user type
  static String? get currentUserType => _currentUserType;

  /// Sign in user
  static Future<bool> signIn(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoggedIn = true;
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserType = 'customer';
    
    return true;
  }

  /// Sign out user
  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserType = null;
  }

  /// Register new user
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));
    
    _isLoggedIn = true;
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserType = userType;
    
    return true;
  }
}