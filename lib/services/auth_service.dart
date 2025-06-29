import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Real authentication service for HomeLinkGH
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ============================================================================
  // AUTHENTICATION STATE
  // ============================================================================

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // ============================================================================
  // SIGN UP METHODS
  // ============================================================================

  /// Create customer account
  Future<UserCredential> createCustomerAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? location,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'location': location ?? '',
        'userType': 'customer',
        'isActive': true,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'preferences': {
          'language': 'en',
          'currency': 'GHS',
          'notifications': true,
        },
      });

      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create provider account
  Future<UserCredential> createProviderAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String businessName,
    required List<String> services,
    required String location,
    String? ghanaCardNumber,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'businessName': businessName,
        'location': location,
        'userType': 'provider',
        'isActive': true,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
      });

      // Create provider profile document
      await _firestore.collection('providers').doc(credential.user!.uid).set({
        'name': businessName,
        'ownerName': name,
        'email': email,
        'phone': phone,
        'services': services,
        'location': location,
        'ghanaCardNumber': ghanaCardNumber ?? '',
        'rating': 0.0,
        'totalRatings': 0,
        'completedJobs': 0,
        'isVerified': false,
        'isActive': false, // Inactive until verified
        'verificationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'documents': {
          'ghanaCard': null,
          'businessRegistration': null,
          'certifications': [],
        },
      });

      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create diaspora customer account
  Future<UserCredential> createDiasporaAccount({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String currentLocation,
    required String ghanaLocation,
    String? ghanaContact,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'currentLocation': currentLocation,
        'ghanaLocation': ghanaLocation,
        'ghanaContact': ghanaContact ?? '',
        'userType': 'diaspora_customer',
        'isActive': true,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'diasporaDetails': {
          'visitPlans': [],
          'familyContacts': [],
          'preferredPaymentMethod': 'card',
          'timeZone': _getTimeZoneFromLocation(currentLocation),
        },
      });

      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============================================================================
  // SIGN IN METHODS
  // ============================================================================

  /// Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last sign in
      await _updateLastSignIn(credential.user!.uid);

      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out from previous Google session
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Create user document for new Google users
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'User',
          'phone': userCredential.user!.phoneNumber ?? '',
          'location': '',
          'userType': 'customer',
          'isActive': true,
          'isVerified': true, // Google accounts are pre-verified
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
          'signInMethod': 'google',
        });
      } else {
        await _updateLastSignIn(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============================================================================
  // PASSWORD RESET
  // ============================================================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============================================================================
  // ACCOUNT MANAGEMENT
  // ============================================================================

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? location,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      // Update Firebase Auth profile
      if (name != null) {
        await user.updateDisplayName(name);
      }

      // Update Firestore document
      final updateData = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (location != null) updateData['location'] = location;

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete account
  Future<void> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _deleteUserData(user.uid);

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============================================================================
  // SIGN OUT
  // ============================================================================

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ============================================================================
  // USER DATA METHODS
  // ============================================================================

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  /// Get user data stream
  Stream<Map<String, dynamic>?> getCurrentUserDataStream() {
    final user = currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      return doc.exists ? doc.data() : null;
    });
  }

  /// Check if user is provider
  Future<bool> isProvider() async {
    final userData = await getCurrentUserData();
    return userData?['userType'] == 'provider';
  }

  /// Check if user is verified
  Future<bool> isVerified() async {
    final userData = await getCurrentUserData();
    return userData?['isVerified'] == true;
  }

  // ============================================================================
  // VERIFICATION METHODS
  // ============================================================================

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Reload user to get latest verification status
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Update last sign in timestamp
  Future<void> _updateLastSignIn(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-critical error, don't throw
      print('Warning: Failed to update last sign in: $e');
    }
  }

  /// Delete user data from Firestore
  Future<void> _deleteUserData(String uid) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));

      // Delete provider document if exists
      batch.delete(_firestore.collection('providers').doc(uid));

      // Cancel active bookings
      final activeBookings = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: uid)
          .where('status', whereIn: ['pending', 'accepted', 'confirmed'])
          .get();

      for (final doc in activeBookings.docs) {
        batch.update(doc.reference, {
          'status': 'cancelled',
          'cancellationReason': 'Account deleted',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Warning: Failed to delete user data: $e');
    }
  }

  /// Get timezone from location
  String _getTimeZoneFromLocation(String location) {
    // Simplified timezone mapping
    final locationLower = location.toLowerCase();
    
    if (locationLower.contains('usa') || locationLower.contains('america')) {
      return 'America/New_York';
    } else if (locationLower.contains('uk') || locationLower.contains('london')) {
      return 'Europe/London';
    } else if (locationLower.contains('canada')) {
      return 'America/Toronto';
    } else {
      return 'GMT';
    }
  }

  /// Handle authentication exceptions
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return Exception('Password is too weak. Please choose a stronger password.');
        case 'email-already-in-use':
          return Exception('An account already exists with this email address.');
        case 'invalid-email':
          return Exception('Please enter a valid email address.');
        case 'user-not-found':
          return Exception('No account found with this email address.');
        case 'wrong-password':
          return Exception('Incorrect password. Please try again.');
        case 'user-disabled':
          return Exception('This account has been disabled. Please contact support.');
        case 'too-many-requests':
          return Exception('Too many sign-in attempts. Please try again later.');
        case 'requires-recent-login':
          return Exception('Please sign in again to complete this action.');
        default:
          return Exception('Authentication failed: ${e.message}');
      }
    }
    return Exception('An unexpected error occurred: $e');
  }
}