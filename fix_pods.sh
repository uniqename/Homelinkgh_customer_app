#!/bin/bash

echo "🔧 Fixing CocoaPods sync issues..."

# Navigate to iOS directory
cd ios

# Clean existing pods
echo "📦 Cleaning existing pods..."
rm -rf Pods/
rm -rf Podfile.lock

# Clean Xcode build files
echo "🧹 Cleaning Xcode build files..."
rm -rf build/
rm -rf DerivedData/

# Reinstall pods
echo "⬇️  Reinstalling CocoaPods..."
pod deintegrate 2>/dev/null || true
pod install

# Clean Flutter
echo "🔄 Cleaning Flutter..."
cd ..
flutter clean
flutter pub get

# Optional: Clean iOS build in Flutter
echo "🍎 Cleaning iOS build cache..."
flutter clean --verbose
rm -rf ios/build/
rm -rf build/

echo "✅ CocoaPods sync fixed! This should prevent future sync issues."
echo ""
echo "💡 To prevent this error in the future:"
echo "   - Run this script (./fix_pods.sh) whenever you get CocoaPods errors"
echo "   - Or run 'cd ios && pod install' after making changes"
echo "   - Always run 'flutter clean && flutter pub get' after major changes"