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

  // Firestore collections
  static CollectionReference get users => _firestore.collection('users');
  static CollectionReference get providers => _firestore.collection('providers');
  static CollectionReference get bookings => _firestore.collection('bookings');
  static CollectionReference get services => _firestore.collection('services');
  static CollectionReference get jobs => _firestore.collection('jobs');
  static CollectionReference get jobApplications => _firestore.collection('job_applications');
  static CollectionReference get notifications => _firestore.collection('notifications');
  static CollectionReference get earnings => _firestore.collection('earnings');
  static CollectionReference get reviews => _firestore.collection('reviews');
  
  // User profile operations
  static Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String role,
    String? phone,
    String? address,
  }) async {
    await users.doc(uid).set({
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
      'bookings': [],
      'family': [],
    });
  }
  
  // Get user profile
  static Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await users.doc(uid).get();
  }
  
  // Booking operations
  static Future<String> createBooking({
    required String customerId,
    required String serviceType,
    required String description,
    required String address,
    required double priceGHS,
    required DateTime scheduledDate,
    String? providerId,
  }) async {
    final docRef = await bookings.add({
      'customerId': customerId,
      'providerId': providerId,
      'serviceType': serviceType,
      'description': description,
      'address': address,
      'priceGHS': priceGHS,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'paymentMethod': null,
      'paymentStatus': 'pending',
    });
    return docRef.id;
  }
  
  // Get user bookings
  static Stream<QuerySnapshot> getUserBookings(String userId) {
    return bookings
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Service operations
  static Future<void> initializeServices() async {
    final servicesData = [
      {
        'id': 'cleaning',
        'name': 'House Cleaning',
        'description': 'Professional house cleaning service including deep cleaning, regular maintenance, and specialized cleaning for all areas of your home.',
        'basePrice': 80.0,
        'currency': 'GHS',
        'category': 'Home Services',
        'duration': '2-4 hours',
      },
      {
        'id': 'plumbing',
        'name': 'Plumbing Services',
        'description': 'Expert plumbing services including pipe repairs, fixture installation, drain cleaning, and emergency plumbing solutions.',
        'basePrice': 120.0,
        'currency': 'GHS',
        'category': 'Home Services',
        'duration': '1-3 hours',
      },
      {
        'id': 'electrical',
        'name': 'Electrical Services',
        'description': 'Licensed electrical work including wiring, fixture installation, electrical repairs, and safety inspections.',
        'basePrice': 150.0,
        'currency': 'GHS',
        'category': 'Home Services',
        'duration': '1-4 hours',
      },
      {
        'id': 'gardening',
        'name': 'Gardening & Landscaping',
        'description': 'Complete garden care including lawn maintenance, tree trimming, planting, and landscape design services.',
        'basePrice': 100.0,
        'currency': 'GHS',
        'category': 'Outdoor Services',
        'duration': '2-6 hours',
      },
      {
        'id': 'delivery',
        'name': 'Delivery Services',
        'description': 'Fast and reliable delivery service for packages, documents, food, and other items across Ghana.',
        'basePrice': 25.0,
        'currency': 'GHS',
        'category': 'Logistics',
        'duration': '30 minutes - 2 hours',
      },
    ];
    
    for (final serviceData in servicesData) {
      await services.doc(serviceData['id'] as String).set(serviceData);
    }
  }
  
  // Get all services
  static Stream<QuerySnapshot> getServices() {
    return services.snapshots();
  }

  // Get FCM token for push notifications
  static Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }
}