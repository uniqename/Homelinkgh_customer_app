import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Request permission for notifications
    await _messaging.requestPermission();
  }

  // Authentication
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Register with email and password
  static Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore operations
  static CollectionReference get providers => _firestore.collection('providers');
  static CollectionReference get jobs => _firestore.collection('jobs');
  static CollectionReference get jobApplications => _firestore.collection('job_applications');
  static CollectionReference get notifications => _firestore.collection('notifications');
  static CollectionReference get earnings => _firestore.collection('earnings');

  // Get FCM token for push notifications
  static Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }
}