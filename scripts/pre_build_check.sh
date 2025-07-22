#!/bin/bash

# HomeLinkGH Pre-Build Check Script
# Automatically runs before builds to ensure everything is in sync

echo "🔍 HomeLinkGH Pre-Build Check..."

# Get the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT" || exit 1

# Check if this is an iOS build by looking for ios platform in args
if [[ "$*" == *"ios"* ]] || [[ -n "$IOS_BUILD" ]]; then
    echo "📱 iOS build detected, checking CocoaPods..."
    
    # Check if pods need syncing
    NEEDS_SYNC=false
    
    if [ ! -f "ios/Podfile.lock" ] || [ ! -d "ios/Pods/" ]; then
        echo "⚠️  Missing Podfile.lock or Pods directory"
        NEEDS_SYNC=true
    elif [ "pubspec.yaml" -nt "ios/Podfile.lock" ]; then
        echo "⚠️  Dependencies updated since last pod install"
        NEEDS_SYNC=true
    fi
    
    if [ "$NEEDS_SYNC" = true ]; then
        echo "🔧 Auto-syncing CocoaPods..."
        
        cd ios || exit 1
        rm -f Podfile.lock
        pod install --repo-update
        
        if [ $? -eq 0 ]; then
            echo "✅ CocoaPods synced successfully"
        else
            echo "❌ Failed to sync CocoaPods"
            echo "💡 Run manually: cd ios && pod install"
        fi
        
        cd .. || exit 1
    else
        echo "✅ CocoaPods already in sync"
    fi
fi

echo "✅ Pre-build check complete"