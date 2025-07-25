#!/bin/bash

# Auto-sync CocoaPods before build
echo "🔄 Auto-syncing CocoaPods..."

# Check if pods are out of sync
if [ -f "$SRCROOT/Podfile" ] && [ -f "$SRCROOT/Podfile.lock" ]; then
    if [ "$SRCROOT/Podfile" -nt "$SRCROOT/Podfile.lock" ]; then
        echo "📦 Running pod install..."
        cd "$SRCROOT"
        pod install
    fi
fi

echo "✅ CocoaPods check complete"