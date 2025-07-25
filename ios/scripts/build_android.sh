#\!/bin/bash

# HomeLinkGH Android Build Script
# This script ensures a clean AAB build for Google Play Store

set -e

echo "🤖 Starting HomeLinkGH Android Build Process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Check Android signing configuration
if [ \! -f "android/key.properties" ]; then
    echo "❌ Error: android/key.properties not found"
    echo "Please ensure your signing configuration is set up"
    exit 1
fi

echo "🔐 Android signing configuration verified"

# Build Android AAB
echo "🤖 Building Android App Bundle..."
flutter build appbundle --release

# Check if build was successful
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    # Get version from pubspec.yaml
    VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2 | tr -d ' ')
    
    # Copy AAB with version name
    cp build/app/outputs/bundle/release/app-release.aab "./homelinkgh-v${VERSION}.aab"
    
    echo "✅ Android AAB build completed successfully\!"
    echo "📱 Output: homelinkgh-v${VERSION}.aab"
    echo "🏪 Ready for Google Play Console upload"
    
    # Show file size
    ls -lh "homelinkgh-v${VERSION}.aab"
else
    echo "❌ Build failed - AAB file not found"
    exit 1
fi
EOF < /dev/null