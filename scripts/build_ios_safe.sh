#!/bin/bash

# HomeLinkGH iOS Build Script with Auto-CocoaPods Sync
# This script ensures CocoaPods is always in sync before building

echo "🚀 HomeLinkGH iOS Build Script Starting..."

# Get the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT" || exit 1

# Function to check if pods need syncing
check_pods_sync() {
    if [ ! -f "ios/Podfile.lock" ] || [ ! -d "ios/Pods/" ]; then
        echo "⚠️  CocoaPods not properly installed"
        return 1
    fi
    
    # Check if pubspec.yaml is newer than Podfile.lock
    if [ "pubspec.yaml" -nt "ios/Podfile.lock" ]; then
        echo "⚠️  Dependencies may have changed since last pod install"
        return 1
    fi
    
    return 0
}

# Function to sync pods
sync_pods() {
    echo "🔧 Syncing CocoaPods..."
    cd ios || exit 1
    
    # Clean and reinstall
    rm -rf Pods/
    rm -f Podfile.lock
    
    pod install
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install CocoaPods"
        exit 1
    fi
    
    cd .. || exit 1
    echo "✅ CocoaPods synced successfully"
}

# Main build process
echo "🔍 Checking CocoaPods sync status..."

if ! check_pods_sync; then
    echo "🔧 CocoaPods out of sync, fixing..."
    sync_pods
else
    echo "✅ CocoaPods already in sync"
fi

echo "📦 Getting Flutter dependencies..."
flutter clean
flutter pub get

# Determine build type from argument
BUILD_TYPE=${1:-debug}

case "$BUILD_TYPE" in
    "debug")
        echo "🏗️  Building iOS Debug..."
        flutter build ios --debug
        ;;
    "release")
        echo "🏗️  Building iOS Release..."
        flutter build ios --release
        ;;
    "profile")
        echo "🏗️  Building iOS Profile..."
        flutter build ios --profile
        ;;
    *)
        echo "❌ Invalid build type: $BUILD_TYPE"
        echo "💡 Usage: $0 [debug|release|profile]"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo "✅ iOS build completed successfully!"
    echo "📱 Build type: $BUILD_TYPE"
else
    echo "❌ iOS build failed"
    echo "💡 Try running the CocoaPods sync script manually:"
    echo "   ./scripts/fix_pods_sync.sh"
    exit 1
fi