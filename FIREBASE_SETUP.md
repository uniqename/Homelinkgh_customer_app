# Firebase Production Setup for HomeLinkGH

## Overview
HomeLinkGH is now configured for production use with real Firebase integration. To use the app with real data instead of demo data, you need to set up your own Firebase project.

## Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it `homelink-ghana-production` (or your preferred name)
4. Enable Google Analytics (recommended)

### 2. Configure Authentication
1. Go to Authentication > Sign-in method
2. Enable:
   - Email/Password
   - Google Sign-In
   - Phone (optional)

### 3. Set up Firestore Database
1. Go to Firestore Database
2. Create database in production mode
3. Set up these collections:
   - `users` (user profiles)
   - `providers` (service providers)
   - `bookings` (service bookings)
   - `services` (service categories)
   - `chats` (messaging)

### 4. Configure Firebase for Flutter
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Run: `firebase login`
3. In your project root: `flutterfire configure`
4. Select your project and platforms (iOS/Android)
5. This will update `lib/firebase_options.dart` with real credentials

### 5. Replace Configuration
Update `lib/firebase_options.dart` with the generated values, or manually replace:
- `your-web-api-key-here` → Your actual web API key
- `your-android-api-key-here` → Your actual Android API key  
- `your-ios-api-key-here` → Your actual iOS API key
- `your-sender-id-here` → Your messaging sender ID
- `homelink-ghana-production` → Your project ID

### 6. Security Rules
Set up Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Providers can be read by authenticated users
    match /providers/{providerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == providerId;
    }
    
    // Bookings can be accessed by customer or provider
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.customerId || 
         request.auth.uid == resource.data.providerId);
    }
  }
}
```

## Features Enabled with Firebase

### With Real Firebase:
✅ User authentication and profiles
✅ Real service provider listings
✅ Actual booking system
✅ Real-time chat messaging
✅ Push notifications
✅ Payment processing integration
✅ GPS tracking for services
✅ Provider verification system

### Without Firebase (Fallback):
⚠️ Limited service categories shown
⚠️ No user authentication
⚠️ No real bookings
⚠️ Basic UI only

## Environment Variables (Optional)
For additional security, you can use environment variables:

```dart
// In lib/firebase_options.dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
  // ... other fields
);
```

## Testing
1. Build and run the app
2. Check console logs for "✅ Firebase initialized successfully"
3. Try signing up/signing in
4. Verify data appears in Firebase Console

## Support
For issues with Firebase setup, check:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- Flutter logs: `flutter logs`