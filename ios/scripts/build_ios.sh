#\!/bin/bash

# HomeLinkGH iOS Build Script
# This script ensures all dependencies are synced before building

set -e

echo "🏗️  Starting HomeLinkGH iOS Build Process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Sync iOS dependencies
echo "🔄 Syncing iOS dependencies..."
./scripts/sync_pods.sh

# Build iOS
echo "🍎 Building iOS app..."
flutter build ios --release

echo "✅ iOS build completed successfully\!"
echo "📱 You can now archive in Xcode for distribution"
EOF < /dev/null