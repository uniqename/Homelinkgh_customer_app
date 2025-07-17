# HomeLinkGH - Deployment Guide

## 📱 App Store & Play Console Deployment

### 🍎 iOS App Store Deployment

#### Prerequisites
- **Xcode 15+** installed
- **iOS Developer Account** (Apple Developer Program)
- **Development Team ID**: `U5JG38RBYM` (already configured)

#### Current Configuration
- **Bundle ID**: `com.homelink.provider.app`
- **App Name**: `HomeLinkGH - Unified Platform`
- **Deployment Target**: iOS 17.0+ (iOS 26 compatible)
- **Code Signing**: Automatic (configured)

#### Build Commands
```bash
# Navigate to project
cd /Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app

# Clean previous builds
flutter clean
flutter pub get

# Build for iOS release
flutter build ios --release

# Or build for archive (recommended for App Store)
flutter build ipa --release
```

#### Archive Location
After building, the IPA file will be located at:
```
build/ios/ipa/homelink_ghana.ipa
```

#### App Store Upload Steps
1. Open **Xcode**
2. Go to **Window > Organizer**
3. Click **Distribute App**
4. Select **App Store Connect**
5. Follow the upload wizard

#### App Store Connect Configuration
- **App Information**:
  - Name: `HomeLinkGH`
  - Subtitle: `Ghana's Unified Service Platform`
  - Category: `Lifestyle` / `Business`
  - Content Rating: `4+`

- **App Privacy**:
  - Location: Required for service provider matching
  - Camera: Required for service documentation
  - Photos: Required for profile and service images

### 🤖 Google Play Console Deployment

#### Prerequisites
- **Android Studio** or **Java JDK 17+**
- **Google Play Developer Account**
- **App Signing Key** (already generated)

#### Current Configuration
- **Package Name**: `com.homelink.provider.app`
- **App Name**: `HomeLinkGH - Unified Platform`
- **Min SDK**: 24 (Android 7.0)
- **Target SDK**: 35 (Android 15)
- **NDK Version**: 27.0.12077973

#### Keystore Information
```
Location: android/homelinkgh-keystore.jks
Alias: homelinkgh
Store Password: homelinkgh2024!
Key Password: homelinkgh2024!
```

#### Build Commands
```bash
# Navigate to project
cd /Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app

# Clean previous builds
flutter clean
flutter pub get

# Build Android App Bundle (AAB) - Recommended for Play Store
flutter build appbundle --release

# Or build APK for testing
flutter build apk --release
```

#### Build Artifacts
- **AAB (App Bundle)**: `build/app/outputs/bundle/release/app-release.aab`
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`

#### Play Console Upload Steps
1. Open **Google Play Console**
2. Go to your app dashboard
3. Navigate to **Production** > **Create new release**
4. Upload the AAB file: `app-release.aab`
5. Fill out release notes and submit

#### Play Console Configuration
- **App Category**: `Lifestyle`
- **Target Age**: `Everyone`
- **Content Rating**: Apply for rating questionnaire
- **Data Safety**: Configure based on app permissions

## 🔧 Pre-Deployment Checklist

### ✅ iOS Checklist
- [ ] App icons generated (all sizes, no alpha channel)
- [ ] Info.plist permissions configured
- [ ] Firebase configuration updated
- [ ] Code signing certificates valid
- [ ] iOS 17.0+ deployment target set
- [ ] Privacy manifest created (if required)

### ✅ Android Checklist
- [ ] App icons generated (all densities)
- [ ] AndroidManifest.xml permissions configured
- [ ] Firebase configuration updated
- [ ] App signing key created and secure
- [ ] Target SDK 35 configured
- [ ] App bundle optimizations enabled

### ✅ General Checklist
- [ ] App version updated in pubspec.yaml
- [ ] Release notes prepared
- [ ] Firebase project configured for production
- [ ] Analytics and crash reporting configured
- [ ] App Store/Play Store listings prepared
- [ ] Screenshots and marketing materials ready

## 🚀 Build Commands Summary

### iOS Production Build
```bash
# For direct device installation
flutter build ios --release

# For App Store submission (recommended)
flutter build ipa --release
```

### Android Production Build
```bash
# For Play Store submission (recommended)
flutter build appbundle --release

# For direct installation/testing
flutter build apk --release
```

## 📋 Store Listing Information

### App Description
**HomeLinkGH** is Ghana's premier unified platform connecting customers, service providers, and administrators. Whether you're a diaspora member planning a visit home, a local customer needing services, or a provider offering expertise, HomeLinkGH brings trusted Ghanaian services to your fingertips.

### Key Features
- **Diaspora Mode**: Pre-arrival service booking for Ghana visitors
- **Local Services**: Comprehensive home and business services
- **Provider Network**: Vetted and verified service professionals
- **Admin Dashboard**: Platform management and analytics
- **Multi-User Support**: Customers, providers, admins, and staff

### Keywords
Ghana, Home Services, Diaspora, Service Provider, Cleaning, Plumbing, Food Delivery, Ghana Services, African Diaspora, Home Maintenance

### Support Information
- **Website**: https://homelinkgh.com
- **Support Email**: support@homelinkgh.com
- **Privacy Policy**: https://homelinkgh.com/privacy
- **Terms of Service**: https://homelinkgh.com/terms

## 🔐 Security Notes

- **Keystore File**: Keep `homelinkgh-keystore.jks` secure and backed up
- **Passwords**: Store keystore passwords securely
- **Firebase Keys**: Ensure production Firebase config is used
- **API Keys**: Verify all API keys are production-ready
- **Encryption**: App uses AES-256 encryption for sensitive data

## 📱 Version Information

- **Current Version**: 3.0.0+10
- **Flutter Version**: 3.24+
- **iOS Target**: 17.0+
- **Android Target**: API 35

---

**Last Updated**: December 2024  
**Platform**: Universal (iOS & Android)  
**Status**: Production Ready