#!/bin/bash

echo "🧹 Complete Flutter Clean & Build Setup"
echo "======================================"

# Clean everything
echo "1️⃣ Cleaning Flutter cache..."
flutter clean

echo "2️⃣ Getting Flutter packages..."
flutter pub get

# iOS specific cleanup
echo "3️⃣ Cleaning iOS dependencies..."
cd ios
rm -rf Pods/
rm -rf Podfile.lock
rm -rf build/
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

echo "4️⃣ Reinstalling CocoaPods..."
pod install

cd ..

echo "5️⃣ Final Flutter clean..."
flutter clean
flutter pub get

echo "✅ Complete cleanup finished!"
echo ""
echo "📝 Next steps:"
echo "   • Run: flutter run"
echo "   • Or: flutter build ios"
echo "   • For release: flutter build ios --release"
echo ""
echo "🚨 If you still get CocoaPods errors:"
echo "   • Check Xcode version compatibility"
echo "   • Try: sudo gem install cocoapods"
echo "   • Try: pod repo update"