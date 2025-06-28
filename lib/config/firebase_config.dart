/// Firebase Configuration for HomeLinkGH Production
/// 
/// This file contains the Firebase project configuration.
/// Replace these values with your actual Firebase project credentials.

class FirebaseConfig {
  // Firebase Project Settings
  static const String projectId = 'homelinkgh-production';
  static const String apiKey = 'AIzaSyC_your_api_key_here'; // Replace with actual API key
  static const String authDomain = 'homelinkgh-production.firebaseapp.com';
  static const String storageBucket = 'homelinkgh-production.appspot.com';
  static const String messagingSenderId = '123456789012'; // Replace with actual sender ID
  static const String appId = '1:123456789012:web:abcdef123456'; // Replace with actual app ID
  
  // Firestore Database URL
  static const String firestoreUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
  
  // Firebase Storage
  static const String storageUrl = 'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o';
  
  // Firebase Cloud Functions (optional)
  static const String functionsUrl = 'https://us-central1-$projectId.cloudfunctions.net';
  
  // Environment-specific settings
  static const bool isProduction = true; // Set to false for development
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // Security Rules and Permissions
  static const Map<String, List<String>> collectionPermissions = {
    'users': ['read', 'write'], // Users can read/write their own data
    'providers': ['read'], // All users can read provider data
    'bookings': ['read', 'write'], // Users can manage their bookings
    'analytics': ['write'], // Write-only for analytics events
    'reviews': ['read', 'write'], // Reviews are public read, authenticated write
  };
  
  // Ghana-specific configuration
  static const String countryCode = 'GH';
  static const String currency = 'GHS'; // Ghana Cedis
  static const String timeZone = 'Africa/Accra';
  static const String phonePrefix = '+233';
  
  // App-specific settings
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoUploadSize = 50 * 1024 * 1024; // 50MB
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  
  /// Get the configuration as a map for easy serialization
  static Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'apiKey': apiKey,
      'authDomain': authDomain,
      'storageBucket': storageBucket,
      'messagingSenderId': messagingSenderId,
      'appId': appId,
      'firestoreUrl': firestoreUrl,
      'storageUrl': storageUrl,
      'functionsUrl': functionsUrl,
      'isProduction': isProduction,
      'enableAnalytics': enableAnalytics,
      'enableCrashlytics': enableCrashlytics,
      'countryCode': countryCode,
      'currency': currency,
      'timeZone': timeZone,
      'phonePrefix': phonePrefix,
    };
  }
  
  /// Validate that all required configuration is present
  static bool isConfigurationValid() {
    return projectId.isNotEmpty &&
           apiKey != 'AIzaSyC_your_api_key_here' &&
           authDomain.isNotEmpty &&
           storageBucket.isNotEmpty &&
           messagingSenderId != '123456789012' &&
           appId != '1:123456789012:web:abcdef123456';
  }
  
  /// Get environment-specific database name
  static String getDatabaseName() {
    return isProduction ? 'production' : 'development';
  }
  
  /// Get collection name with environment prefix if needed
  static String getCollectionName(String collection) {
    if (isProduction) {
      return collection;
    } else {
      return 'dev_$collection';
    }
  }
}

/// Firebase initialization instructions and setup guide
class FirebaseSetupGuide {
  static const String setupInstructions = '''
FIREBASE SETUP INSTRUCTIONS FOR HOMELINKGH:

1. CREATE FIREBASE PROJECT:
   - Go to https://console.firebase.google.com/
   - Click "Create a project"
   - Name: "homelinkgh-production"
   - Enable Google Analytics (recommended)

2. ENABLE REQUIRED SERVICES:
   - Authentication (Email/Password, Phone)
   - Firestore Database
   - Cloud Storage
   - Cloud Functions (optional)
   - Analytics
   - Crashlytics

3. CONFIGURE AUTHENTICATION:
   - Enable Email/Password sign-in
   - Enable Phone authentication for Ghana (+233)
   - Set up OAuth providers if needed (Google, Facebook)

4. SET UP FIRESTORE SECURITY RULES:
   Copy the security rules from firebase_security_rules.txt

5. CONFIGURE PROJECT SETTINGS:
   - Update firebase_config.dart with your actual:
     * Project ID
     * API Key  
     * Auth Domain
     * Storage Bucket
     * Messaging Sender ID
     * App ID

6. ADD PLATFORM CONFIGURATIONS:
   - Android: Download google-services.json
   - iOS: Download GoogleService-Info.plist
   - Web: Copy Firebase config object

7. INITIALIZE COLLECTIONS:
   Create these collections in Firestore:
   - users
   - providers  
   - bookings
   - analytics
   - reviews
   - notifications

8. SET UP INDEXES:
   Create composite indexes for:
   - providers: (services, isAvailable, rating)
   - bookings: (customerId, status, createdAt)
   - bookings: (providerId, status, createdAt)

9. CONFIGURE STORAGE RULES:
   Set up storage rules for user uploads (profiles, portfolios)

10. TEST CONNECTION:
    Run firebase_test.dart to verify all services work
''';

  static void printSetupInstructions() {
    print(setupInstructions);
  }
}