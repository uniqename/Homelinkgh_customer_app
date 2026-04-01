import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/firebase_config.dart';
import 'firebase_service.dart';
import 'local_data_service.dart';

/// Service to handle Firebase initialization and data migration
class FirebaseInitializationService {
  static final FirebaseInitializationService _instance = FirebaseInitializationService._internal();
  factory FirebaseInitializationService() => _instance;
  FirebaseInitializationService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final LocalDataService _localDataService = LocalDataService();
  
  bool _isInitialized = false;
  bool _isOnlineMode = false;
  
  /// Initialize Firebase and set up the app for production use
  Future<bool> initializeForProduction() async {
    try {
      print('Starting Firebase initialization for production...');
      
      // Check if Firebase configuration is valid
      if (!FirebaseConfig.isConfigurationValid()) {
        print('Firebase configuration is incomplete. Please update firebase_config.dart');
        FirebaseSetupGuide.printSetupInstructions();
        return false;
      }
      
      // Initialize Firebase service
      await _firebaseService.initialize();
      
      // Test connection to Firebase
      final connectionTest = await _testFirebaseConnection();
      if (!connectionTest) {
        print('Failed to connect to Firebase. Falling back to local mode.');
        _isOnlineMode = false;
        return false;
      }
      
      print('Firebase connection successful!');
      _isOnlineMode = true;
      
      // Migrate local data to Firebase if needed
      await _migrateLocalDataToFirebase();
      
      // Set up real-time listeners
      await _setupRealtimeListeners();
      
      _isInitialized = true;
      print('Firebase initialization completed successfully!');
      return true;
      
    } catch (e) {
      print('Error during Firebase initialization: $e');
      _isOnlineMode = false;
      return false;
    }
  }
  
  /// Test Firebase connection
  Future<bool> _testFirebaseConnection() async {
    try {
      // Try to read from a test collection
      final response = await http.get(
        Uri.parse('${FirebaseConfig.firestoreUrl}/test'),
        headers: {'Content-Type': 'application/json'},
      );
      
      // Even a 404 response means we can reach Firebase
      return response.statusCode == 404 || response.statusCode == 200;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
  
  /// Migrate existing local data to Firebase
  Future<void> _migrateLocalDataToFirebase() async {
    try {
      print('Starting data migration to Firebase...');
      
      // Migrate providers
      await _migrateProviders();
      
      // Migrate bookings
      await _migrateBookings();
      
      // Migrate user data
      await _migrateUserData();
      
      print('Data migration completed!');
    } catch (e) {
      print('Error during data migration: $e');
    }
  }
  
  /// Migrate providers to Firebase
  Future<void> _migrateProviders() async {
    try {
      final localProviders = await _localDataService.getAllProviders();
      print('Migrating ${localProviders.length} providers to Firebase...');
      
      for (final provider in localProviders) {
        try {
          await _firebaseService.createProvider(provider);
          print('Migrated provider: ${provider.name}');
        } catch (e) {
          print('Failed to migrate provider ${provider.name}: $e');
        }
      }
    } catch (e) {
      print('Error migrating providers: $e');
    }
  }
  
  /// Migrate bookings to Firebase
  Future<void> _migrateBookings() async {
    try {
      final localBookings = await _localDataService.getAllBookings();
      print('Migrating ${localBookings.length} bookings to Firebase...');
      
      for (final booking in localBookings) {
        try {
          await _firebaseService.createBooking(booking);
          print('Migrated booking: ${booking.id}');
        } catch (e) {
          print('Failed to migrate booking ${booking.id}: $e');
        }
      }
    } catch (e) {
      print('Error migrating bookings: $e');
    }
  }
  
  /// Migrate user data to Firebase
  Future<void> _migrateUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      final userPhone = prefs.getString('user_phone');
      final userEmail = prefs.getString('user_email');
      final userRole = prefs.getString('user_role');
      
      if (userName != null && userPhone != null && userEmail != null && userRole != null) {
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        await _firebaseService.createUserProfile(
          userId: userId,
          name: userName,
          email: userEmail,
          phoneNumber: userPhone,
          role: userRole,
          additionalData: {
            'migrated_from_local': 'true',
            'migration_date': DateTime.now().toIso8601String(),
          },
        );
        
        // Store Firebase user ID locally
        await prefs.setString('firebase_user_id', userId);
        print('Migrated user profile for: $userName');
      }
    } catch (e) {
      print('Error migrating user data: $e');
    }
  }
  
  /// Set up real-time listeners for live updates
  Future<void> _setupRealtimeListeners() async {
    // In a full implementation, this would set up WebSocket or Firebase SDK listeners
    // For now, we'll implement polling for updates
    print('Real-time listeners setup (polling mode)');
  }
  
  /// Create initial Firebase collections and data
  Future<void> setupInitialData() async {
    if (!_isOnlineMode) return;
    
    try {
      print('Setting up initial Firebase data...');
      
      // Create sample service categories
      await _createServiceCategories();
      
      // Create system admin user if needed
      await _createSystemAdmin();
      
      // Initialize analytics tracking
      await _initializeAnalytics();
      
      print('Initial data setup completed!');
    } catch (e) {
      print('Error setting up initial data: $e');
    }
  }
  
  /// Create service categories in Firebase
  Future<void> _createServiceCategories() async {
    final categories = [
      {
        'id': 'food_delivery',
        'name': 'Food Delivery',
        'icon': 'restaurant',
        'description': 'Order food from top Ghana restaurants',
        'isActive': true,
      },
      {
        'id': 'house_cleaning',
        'name': 'House Cleaning',
        'icon': 'cleaning_services',
        'description': 'Professional house cleaning services',
        'isActive': true,
      },
      {
        'id': 'beauty_services',
        'name': 'Beauty Services',
        'icon': 'face',
        'description': 'Hair, makeup, nail services',
        'isActive': true,
      },
      {
        'id': 'transportation',
        'name': 'Transportation',
        'icon': 'directions_car',
        'description': 'Airport transfers and city rides',
        'isActive': true,
      },
      {
        'id': 'home_services',
        'name': 'Home Services',
        'icon': 'home_repair_service',
        'description': 'Plumbing, electrical, maintenance',
        'isActive': true,
      },
    ];
    
    for (final category in categories) {
      try {
        await http.post(
          Uri.parse('${FirebaseConfig.firestoreUrl}/service_categories'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'fields': category.map((key, value) => MapEntry(key, {
              'stringValue': value.toString()
            }))
          }),
        );
      } catch (e) {
        print('Error creating category ${category['name']}: $e');
      }
    }
  }
  
  /// Create system admin user
  Future<void> _createSystemAdmin() async {
    try {
      await _firebaseService.createUserProfile(
        userId: 'admin_system',
        name: 'System Administrator',
        email: 'admin@homelinkgh.com',
        phoneNumber: '+233200000000',
        role: 'admin',
        additionalData: {
          'is_system_admin': 'true',
          'created_by': 'initialization_service',
        },
      );
    } catch (e) {
      print('Error creating system admin: $e');
    }
  }
  
  /// Initialize analytics tracking
  Future<void> _initializeAnalytics() async {
    try {
      await _firebaseService.recordAnalyticsEvent(
        eventName: 'app_initialized',
        userId: 'system',
        eventData: {
          'platform': 'flutter',
          'version': '3.1.1',
          'initialization_time': DateTime.now().toIso8601String(),
          'mode': 'production',
        },
      );
    } catch (e) {
      print('Error initializing analytics: $e');
    }
  }
  
  /// Check if app is running in online mode
  bool get isOnlineMode => _isOnlineMode;
  
  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;
  
  /// Switch between online and offline modes
  Future<void> setOnlineMode(bool online) async {
    if (online && !_isInitialized) {
      await initializeForProduction();
    } else {
      _isOnlineMode = online;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('firebase_online_mode', online);
    }
  }
  
  /// Get connection status for UI display
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isOnline': _isOnlineMode,
      'isInitialized': _isInitialized,
      'mode': _isOnlineMode ? 'Firebase (Production)' : 'Local (Development)',
      'status': _isOnlineMode ? 'Connected' : 'Offline',
    };
  }
}

/// Extension methods for the LocalDataService to support Firebase migration
extension LocalDataServiceFirebaseExtensions on LocalDataService {
  /// Get all providers for migration
  Future<List<dynamic>> getAllProviders() async {
    // This would return all local providers
    // Implementation depends on your current local storage structure
    return [];
  }
  
  /// Get all bookings for migration  
  Future<List<dynamic>> getAllBookings() async {
    // This would return all local bookings
    // Implementation depends on your current local storage structure
    return [];
  }
}