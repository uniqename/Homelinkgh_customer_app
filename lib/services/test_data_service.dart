import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize the app with comprehensive test data for Ghana
  static Future<void> initializeTestData() async {
    try {
      print('🚀 Initializing HomeLinkGH test data...');
      
      await _createTestUsers();
      await _createTestProviders();
      await _createTestServices();
      await _createTestBookings();
      await _createTestJobs();
      await _createTestLocations();
      
      print('✅ Test data initialization complete!');
    } catch (e) {
      print('❌ Error initializing test data: $e');
      rethrow;
    }
  }

  /// Create test users across different types
  static Future<void> _createTestUsers() async {
    final users = [
      {
        'id': 'test_customer_1',
        'email': 'customer@test.com',
        'name': 'Kwame Asante',
        'userType': 'customer',
        'phone': '+233244123456',
        'location': 'Accra, Greater Accra',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'preferences': {
          'language': 'en',
          'currency': 'GHS',
          'notifications': true,
        }
      },
      {
        'id': 'test_diaspora_1',
        'email': 'diaspora@test.com',
        'name': 'Ama Osei',
        'userType': 'diaspora_customer',
        'phone': '+1234567890',
        'location': 'New York, USA',
        'ghanaLocation': 'East Legon, Accra',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'visitPlans': {
          'nextVisit': '2024-12-20',
          'duration': '2 weeks',
          'preparations': ['house cleaning', 'grocery shopping']
        }
      },
      {
        'id': 'test_job_seeker_1',
        'email': 'jobseeker@test.com',
        'name': 'Kofi Mensah',
        'userType': 'job_seeker',
        'phone': '+233201234567',
        'location': 'Kumasi, Ashanti',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'experience': 'beginner',
        'interests': ['food_delivery', 'house_cleaning'],
        'availability': 'full_time',
        'hasTransport': false,
      },
      {
        'id': 'test_provider_1',
        'email': 'provider@test.com',
        'name': 'Akosua Boateng',
        'userType': 'provider',
        'phone': '+233208765432',
        'location': 'Tema, Greater Accra',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isVerified': true,
        'services': ['house_cleaning', 'laundry'],
        'rating': 4.8,
        'completedJobs': 156,
      }
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user['id'] as String).set(user);
    }
    print('✅ Created test users');
  }

  /// Create test service providers with Ghana-specific details
  static Future<void> _createTestProviders() async {
    final providers = [
      {
        'id': 'provider_001',
        'name': 'Akosua\'s Cleaning Services',
        'ownerName': 'Akosua Boateng',
        'email': 'akosua@cleaning.gh',
        'phone': '+233208765432',
        'services': ['house_cleaning', 'laundry', 'organization'],
        'location': {
          'address': 'Tema, Greater Accra',
          'coordinates': {'lat': 5.6037, 'lng': -0.0487},
          'serviceAreas': ['Tema', 'Ashaiman', 'Sakumono', 'Lekki']
        },
        'rating': 4.8,
        'totalJobs': 156,
        'priceRange': {'min': 50, 'max': 200, 'currency': 'GHS'},
        'availability': {
          'monday': {'start': '08:00', 'end': '17:00'},
          'tuesday': {'start': '08:00', 'end': '17:00'},
          'wednesday': {'start': '08:00', 'end': '17:00'},
          'thursday': {'start': '08:00', 'end': '17:00'},
          'friday': {'start': '08:00', 'end': '17:00'},
          'saturday': {'start': '09:00', 'end': '15:00'},
          'sunday': null
        },
        'isVerified': true,
        'diasporaFriendly': true,
        'languages': ['English', 'Twi', 'Ga'],
        'experience': '3+ years',
        'certifications': ['Ghana Cleaning Association'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'provider_002',
        'name': 'Kwame\'s Quick Delivery',
        'ownerName': 'Kwame Nkrumah Jr.',
        'email': 'kwame@delivery.gh',
        'phone': '+233244987654',
        'services': ['food_delivery', 'grocery_shopping', 'package_delivery'],
        'location': {
          'address': 'Osu, Accra',
          'coordinates': {'lat': 5.5563, 'lng': -0.1969},
          'serviceAreas': ['Osu', 'Labone', 'Airport Residential', 'East Legon']
        },
        'rating': 4.6,
        'totalJobs': 89,
        'priceRange': {'min': 15, 'max': 80, 'currency': 'GHS'},
        'hasVehicle': true,
        'vehicleType': 'motorcycle',
        'isVerified': true,
        'diasporaFriendly': true,
        'languages': ['English', 'Twi'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'provider_003',
        'name': 'Ama\'s Beauty & Care',
        'ownerName': 'Ama Serwaa',
        'email': 'ama@beauty.gh',
        'phone': '+233201111222',
        'services': ['makeup_artist', 'nail_tech', 'hair_styling'],
        'location': {
          'address': 'Spintex, Accra',
          'coordinates': {'lat': 5.5894, 'lng': -0.0974},
          'serviceAreas': ['Spintex', 'Baatsona', 'Lakeside Estate']
        },
        'rating': 4.9,
        'totalJobs': 67,
        'priceRange': {'min': 80, 'max': 350, 'currency': 'GHS'},
        'services': ['Bridal makeup', 'Traditional styling', 'Gel nails'],
        'isVerified': true,
        'portfolio': ['image1.jpg', 'image2.jpg', 'image3.jpg'],
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final provider in providers) {
      await _firestore.collection('providers').doc(provider['id'] as String).set(provider);
    }
    print('✅ Created test providers');
  }

  /// Create service categories with Ghana-specific pricing
  static Future<void> _createTestServices() async {
    final services = [
      {
        'id': 'house_cleaning',
        'name': 'House Cleaning',
        'category': 'home_services',
        'description': 'Professional house cleaning services',
        'basePrice': 80,
        'currency': 'GHS',
        'duration': '2-4 hours',
        'popular': true,
        'diasporaFriendly': true,
        'subcategories': ['deep_cleaning', 'regular_cleaning', 'move_in_out']
      },
      {
        'id': 'food_delivery',
        'name': 'Food Delivery',
        'category': 'delivery',
        'description': 'Fast and reliable food delivery',
        'basePrice': 25,
        'currency': 'GHS',
        'duration': '30-60 minutes',
        'popular': true,
        'diasporaFriendly': true,
        'restaurants': ['KFC', 'Papaye', 'Chicken Republic', 'Local restaurants']
      },
      {
        'id': 'plumbing',
        'name': 'Plumbing Services',
        'category': 'maintenance',
        'description': 'Professional plumbing repairs and installations',
        'basePrice': 120,
        'currency': 'GHS',
        'duration': '1-3 hours',
        'emergency': true,
        'certificationRequired': true
      },
      {
        'id': 'makeup_artist',
        'name': 'Makeup Artist',
        'category': 'beauty',
        'description': 'Professional makeup services for events',
        'basePrice': 200,
        'currency': 'GHS',
        'duration': '1-2 hours',
        'occasions': ['wedding', 'party', 'photoshoot', 'traditional']
      }
    ];

    for (final service in services) {
      await _firestore.collection('services').doc(service['id'] as String).set(service);
    }
    print('✅ Created test services');
  }

  /// Create test bookings with realistic Ghana scenarios
  static Future<void> _createTestBookings() async {
    final bookings = [
      {
        'id': 'booking_001',
        'customerId': 'test_diaspora_1',
        'providerId': 'provider_001',
        'serviceId': 'house_cleaning',
        'status': 'completed',
        'scheduledDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'location': {
          'address': 'East Legon, Accra',
          'coordinates': {'lat': 5.6037, 'lng': -0.0487}
        },
        'price': 150,
        'currency': 'GHS',
        'notes': 'Deep cleaning before family visit from USA',
        'rating': 5,
        'review': 'Excellent service! House was spotless for my family\'s arrival.',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'booking_002',
        'customerId': 'test_customer_1',
        'providerId': 'provider_002',
        'serviceId': 'food_delivery',
        'status': 'in_progress',
        'scheduledDate': Timestamp.now(),
        'location': {
          'address': 'Accra Mall, Tetteh Quarshie',
          'coordinates': {'lat': 5.6112, 'lng': -0.2019}
        },
        'price': 45,
        'currency': 'GHS',
        'restaurant': 'KFC Accra Mall',
        'items': ['2pc Chicken', 'Large Fries', 'Coke'],
        'estimatedArrival': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 25))),
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final booking in bookings) {
      await _firestore.collection('bookings').doc(booking['id'] as String).set(booking);
    }
    print('✅ Created test bookings');
  }

  /// Create job opportunities for job seekers
  static Future<void> _createTestJobs() async {
    final jobs = [
      {
        'id': 'job_001',
        'title': 'Food Delivery Rider - Accra',
        'company': 'HomeLinkGH',
        'category': 'delivery',
        'type': 'part_time',
        'location': 'Accra, Greater Accra',
        'salary': {'min': 800, 'max': 1500, 'currency': 'GHS', 'period': 'monthly'},
        'requirements': [
          'Own motorcycle or bicycle',
          'Valid Ghana Card',
          'Good knowledge of Accra roads',
          'Smartphone with internet'
        ],
        'benefits': [
          'Flexible working hours',
          'Weekly payments',
          'Training provided',
          'Insurance coverage'
        ],
        'description': 'Join our delivery team and earn while serving your community. Perfect for students and part-time workers.',
        'isActive': true,
        'applicants': 23,
        'postedDate': FieldValue.serverTimestamp(),
      },
      {
        'id': 'job_002',
        'title': 'House Cleaning Specialist - Tema',
        'company': 'CleanPro Ghana',
        'category': 'cleaning',
        'type': 'full_time',
        'location': 'Tema, Greater Accra',
        'salary': {'min': 1200, 'max': 2000, 'currency': 'GHS', 'period': 'monthly'},
        'requirements': [
          'Previous cleaning experience',
          'Attention to detail',
          'Reliable and punctual',
          'Good communication skills'
        ],
        'benefits': [
          'Health insurance',
          'Paid training',
          'Performance bonuses',
          'Career advancement'
        ],
        'description': 'Opportunity to work with high-end residential and commercial clients. Training and certification provided.',
        'isActive': true,
        'applicants': 15,
        'postedDate': FieldValue.serverTimestamp(),
      }
    ];

    for (final job in jobs) {
      await _firestore.collection('jobs').doc(job['id'] as String).set(job);
    }
    print('✅ Created test jobs');
  }

  /// Create Ghana-specific locations and service areas
  static Future<void> _createTestLocations() async {
    final locations = [
      {
        'id': 'greater_accra',
        'name': 'Greater Accra Region',
        'type': 'region',
        'areas': [
          {'name': 'Accra Central', 'coordinates': {'lat': 5.5600, 'lng': -0.2057}},
          {'name': 'East Legon', 'coordinates': {'lat': 5.6205, 'lng': -0.1419}},
          {'name': 'Tema', 'coordinates': {'lat': 5.6037, 'lng': -0.0487}},
          {'name': 'Osu', 'coordinates': {'lat': 5.5563, 'lng': -0.1969}},
          {'name': 'Spintex', 'coordinates': {'lat': 5.5894, 'lng': -0.0974}},
          {'name': 'Airport Residential', 'coordinates': {'lat': 5.6052, 'lng': -0.1716}},
          {'name': 'Labone', 'coordinates': {'lat': 5.5563, 'lng': -0.1969}},
          {'name': 'Dzorwulu', 'coordinates': {'lat': 5.5936, 'lng': -0.1882}},
        ],
        'serviceProviders': 45,
        'activeUsers': 234,
        'popularServices': ['food_delivery', 'house_cleaning', 'plumbing']
      },
      {
        'id': 'ashanti',
        'name': 'Ashanti Region',
        'type': 'region',
        'areas': [
          {'name': 'Kumasi Central', 'coordinates': {'lat': 6.6885, 'lng': -1.6244}},
          {'name': 'Bantama', 'coordinates': {'lat': 6.7140, 'lng': -1.6532}},
          {'name': 'Asokwa', 'coordinates': {'lat': 6.6667, 'lng': -1.6500}},
          {'name': 'Suame', 'coordinates': {'lat': 6.7167, 'lng': -1.6333}},
        ],
        'serviceProviders': 28,
        'activeUsers': 156,
        'popularServices': ['house_cleaning', 'plumbing', 'electrical']
      }
    ];

    for (final location in locations) {
      await _firestore.collection('locations').doc(location['id'] as String).set(location);
    }
    print('✅ Created test locations');
  }

  /// Quick test user creation for immediate testing
  static Future<UserCredential> createTestUser({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phone,
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
        'userType': userType,
        'phone': phone ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      print('✅ Created test user: $email ($userType)');
      return credential;
    } catch (e) {
      print('❌ Error creating test user: $e');
      rethrow;
    }
  }

  /// Delete all test data (for cleanup)
  static Future<void> clearTestData() async {
    try {
      final collections = ['users', 'providers', 'services', 'bookings', 'jobs', 'locations'];
      
      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          if (doc.id.startsWith('test_') || doc.id.startsWith('provider_') || 
              doc.id.startsWith('booking_') || doc.id.startsWith('job_')) {
            await doc.reference.delete();
          }
        }
      }
      
      print('✅ Test data cleared');
    } catch (e) {
      print('❌ Error clearing test data: $e');
    }
  }
}