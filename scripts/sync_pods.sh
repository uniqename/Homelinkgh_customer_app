#!/bin/bash

# CocoaPods Auto-Sync Script
# This script ensures CocoaPods is always in sync before building

echo "🔄 Syncing CocoaPods for HomeLinkGH..."

# Navigate to iOS directory
cd "$(dirname "$0")/../ios"

# Check if Podfile.lock exists and compare with Podfile
if [ -f "Podfile.lock" ] && [ -f "Podfile" ]; then
    if [ "Podfile" -nt "Podfile.lock" ]; then
        echo "📦 Podfile is newer than Podfile.lock. Running pod install..."
        pod install
    else
        echo "✅ Podfile.lock is up to date"
    fi
else
    echo "📦 Running pod install..."
    pod install
fi

# Clean derived data if needed
if [ "$1" = "--clean" ]; then
    echo "🧹 Cleaning Xcode derived data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
fi

echo "✅ CocoaPods sync complete!"