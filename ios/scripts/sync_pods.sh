#\!/bin/bash

# HomeLinkGH iOS Dependency Sync Script
# This script ensures CocoaPods are always in sync before building

set -e

echo "🔄 Syncing iOS Dependencies for HomeLinkGH..."

# Navigate to iOS directory
cd "$(dirname "$0")/../ios"

# Check if Podfile.lock exists and is newer than Podfile
if [ -f "Podfile.lock" ] && [ -f "Podfile" ]; then
    if [ "Podfile" -nt "Podfile.lock" ]; then
        echo "⚠️  Podfile is newer than Podfile.lock - updating dependencies..."
        pod install --repo-update
    else
        echo "✅ Podfile.lock is up to date"
        pod install
    fi
else
    echo "📦 Installing CocoaPods dependencies..."
    pod install --repo-update
fi

echo "🎉 iOS Dependencies synced successfully\!"
EOF < /dev/null