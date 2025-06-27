#!/bin/bash

echo "🚀 HomeLinkGH iOS Build Script"
echo "=============================="

# Navigate to project directory
cd "$(dirname "$0")"

echo "📱 Step 1: Clean previous builds..."
flutter clean
rm -rf ios/build/
rm -rf build/ios/

echo "📦 Step 2: Get dependencies..."
flutter pub get

echo "🔧 Step 3: Install iOS pods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo "🏗️ Step 4: Build iOS for release..."
flutter build ios --release --no-codesign

if [ $? -eq 0 ]; then
    echo "✅ iOS build completed successfully!"
    echo "📍 Next steps:"
    echo "   1. Open ios/Runner.xcworkspace in Xcode"
    echo "   2. Select 'Any iOS Device (arm64)' as target"
    echo "   3. Product → Archive"
    echo "   4. Distribute to App Store Connect"
else
    echo "❌ iOS build failed. Check the error messages above."
    echo "📋 Troubleshooting:"
    echo "   1. Ensure all import statements are correct"
    echo "   2. Check for missing Dart files"
    echo "   3. Verify iOS deployment target is set to 17.0"
    exit 1
fi

echo ""
echo "🎯 Bundle ID: com.homelink.provider.app"
echo "📱 iOS Target: 17.0+ (iOS 26 compatible)"
echo "🚀 Ready for App Store Connect!"