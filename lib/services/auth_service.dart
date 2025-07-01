import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'demo_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DemoAuthService _demoAuth = DemoAuthService();
  
  bool _useDemo = false;

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Check if Firebase is available
  Future<bool> _checkFirebaseAvailability() async {
    try {
      await _auth.currentUser; // Simple check
      return true;
    } catch (e) {
      print('Firebase not available, switching to demo mode: $e');
      _useDemo = true;
      return false;
    }
  }

  // Anonymous sign in for survivors who want privacy
  Future<AppUser?> signInAnonymously() async {
    // Check if Firebase is available first
    if (!await _checkFirebaseAvailability() || _useDemo) {
      print('Using demo authentication for anonymous sign in');
      return await _demoAuth.signInAnonymously();
    }
    
    try {
      print('Attempting Firebase anonymous sign in...');
      final UserCredential result = await _auth.signInAnonymously();
      final User? user = result.user;
      
      if (user != null) {
        print('Anonymous sign in successful: ${user.uid}');
        final appUser = AppUser(
          id: user.uid,
          email: 'anonymous@survivor.local',
          displayName: 'Anonymous Survivor',
          userType: UserType.survivor,
          isAnonymous: true,
          createdAt: DateTime.now(),
        );
        
        try {
          await _createUserDocument(appUser);
          print('User document created successfully');
        } catch (firestoreError) {
          print('Firestore error (continuing anyway): $firestoreError');
          // Continue even if Firestore fails, for demo purposes
        }
        
        await _saveAnonymousStatus(true);
        return appUser;
      }
      return null;
    } catch (e) {
      print('Firebase anonymous sign in failed, falling back to demo: $e');
      _useDemo = true;
      return await _demoAuth.signInAnonymously();
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
    // Check if Firebase is available first
    if (!await _checkFirebaseAvailability() || _useDemo) {
      print('Using demo authentication for registration');
      return await _demoAuth.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        userType: userType,
        phoneNumber: phoneNumber,
        emergencyContact: emergencyContact,
        emergencyContactPhone: emergencyContactPhone,
      );
    }
    
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        
        final appUser = AppUser(
          id: user.uid,
          email: email,
          displayName: displayName,
          phoneNumber: phoneNumber,
          userType: userType,
          isAnonymous: false,
          createdAt: DateTime.now(),
          emergencyContact: emergencyContact,
          emergencyContactPhone: emergencyContactPhone,
        );
        
        try {
          await _createUserDocument(appUser);
        } catch (firestoreError) {
          print('Firestore error (continuing anyway): $firestoreError');
        }
        
        await _saveAnonymousStatus(false);
        return appUser;
      }
      return null;
    } catch (e) {
      print('Firebase registration failed, falling back to demo: $e');
      _useDemo = true;
      return await _demoAuth.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        userType: userType,
        phoneNumber: phoneNumber,
        emergencyContact: emergencyContact,
        emergencyContactPhone: emergencyContactPhone,
      );
    }
  }

  // Email/password sign in
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user != null) {
        await _updateLastLogin(user.uid);
        final appUser = await getUserData(user.uid);
        await _saveAnonymousStatus(appUser?.isAnonymous ?? false);
        return appUser;
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
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
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _clearAnonymousStatus();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Delete account (for anonymous users)
  Future<bool> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete cases associated with this user
        final casesQuery = await _firestore
            .collection('cases')
            .where('survivorId', isEqualTo: user.uid)
            .get();
        
        for (final doc in casesQuery.docs) {
          await doc.reference.delete();
        }
        
        // Delete Firebase Auth account
        await user.delete();
        await _clearAnonymousStatus();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Check if user is anonymous
  Future<bool> isAnonymousUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_anonymous') ?? false;
  }

  // Private helper methods
  Future<void> _createUserDocument(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'lastLoginAt': FieldValue.serverTimestamp()});
  }

  Future<void> _saveAnonymousStatus(bool isAnonymous) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_anonymous', isAnonymous);
  }

  Future<void> _clearAnonymousStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_anonymous');
  }
}