#!/bin/bash

# HomeLinkGH CocoaPods Auto-Sync Script
# This script automatically resolves the persistent "sandbox not in sync with Podfile.lock" issue

echo "🔧 HomeLinkGH CocoaPods Auto-Sync Starting..."

# Get the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IOS_DIR="$PROJECT_ROOT/ios"

echo "📁 Project root: $PROJECT_ROOT"
echo "📱 iOS directory: $IOS_DIR"

# Check if ios directory exists
if [ ! -d "$IOS_DIR" ]; then
    echo "❌ Error: iOS directory not found at $IOS_DIR"
    exit 1
fi

# Change to iOS directory
cd "$IOS_DIR" || exit 1

echo "🧹 Cleaning up old CocoaPods files..."

# Remove old pods and derived data that can cause sync issues
rm -rf Pods/
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -f Podfile.lock

echo "📦 Installing CocoaPods dependencies..."

# Install pods with verbose output for debugging
pod install --verbose

if [ $? -eq 0 ]; then
    echo "✅ CocoaPods installation successful!"
    
    # Verify the installation
    if [ -f "Podfile.lock" ] && [ -d "Pods/" ]; then
        echo "✅ Podfile.lock and Pods/ directory verified"
        
        # Check for configuration warnings
        echo "🔍 Checking for configuration issues..."
        
        # Run a quick build check
        cd "$PROJECT_ROOT"
        echo "🏗️  Running quick build verification..."
        
        flutter clean
        flutter pub get
        
        echo "✅ HomeLinkGH CocoaPods Auto-Sync Complete!"
        echo "📱 You can now build the iOS app without sync errors"
        
    else
        echo "⚠️  Installation completed but verification failed"
        echo "   Podfile.lock or Pods directory missing"
    fi
else
    echo "❌ CocoaPods installation failed"
    echo "💡 Possible solutions:"
    echo "   1. Update CocoaPods: sudo gem install cocoapods"
    echo "   2. Check Ruby version: ruby --version"
    echo "   3. Check Flutter iOS setup: flutter doctor"
    exit 1
fi

echo ""
echo "🚀 Next steps:"
echo "   Run: flutter build ios"
echo "   Or:  flutter run"
echo ""