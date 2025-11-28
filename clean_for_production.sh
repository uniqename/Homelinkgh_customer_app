#!/bin/bash

echo "🚀 HomeLinkGH Production Cleanup Script"
echo "======================================="
echo ""
echo "⚠️  WARNING: This will remove demo/test content for production!"
echo "📱 Only run this AFTER Apple App Store approval"
echo ""

# Ask for confirmation
read -p "Are you sure you want to clean demo content for production? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

echo "🧹 Starting production cleanup..."
echo ""

# Create backup first
echo "📦 Creating backup of demo files..."
mkdir -p backups/demo_files_$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/demo_files_$(date +%Y%m%d_%H%M%S)"

# Backup demo files before deletion
cp lib/services/demo_auth_service.dart "$BACKUP_DIR/" 2>/dev/null || echo "   ⚠️  demo_auth_service.dart not found"
cp lib/services/supabase_staging_service.dart "$BACKUP_DIR/" 2>/dev/null || echo "   ⚠️  supabase_staging_service.dart not found"
cp lib/main_test.dart "$BACKUP_DIR/" 2>/dev/null || echo "   ⚠️  main_test.dart not found"

echo "✅ Backup created in $BACKUP_DIR"
echo ""

# 1. Remove demo service files
echo "🗑️  Removing demo service files..."
rm -f lib/services/demo_auth_service.dart
rm -f lib/services/supabase_staging_service.dart
rm -f lib/main_test.dart
echo "✅ Demo service files removed"

# 2. Clean demo references from main files
echo "🧽 Cleaning demo references from main files..."

# Remove demo imports and references
if [ -f "lib/main_ios.dart" ]; then
    # Remove demo auth import
    sed -i '' '/import.*demo_auth_service/d' lib/main_ios.dart
    # Remove DemoAuthService provider
    sed -i '' '/ChangeNotifierProvider.*DemoAuthService/d' lib/main_ios.dart
    # Remove demo print statements
    sed -i '' '/print.*Demo/d' lib/main_ios.dart
    echo "   ✅ Cleaned lib/main_ios.dart"
fi

# 3. Update Firebase config (warn user about production keys)
echo "🔑 Firebase configuration needs manual update..."
echo "   ⚠️  MANUAL ACTION REQUIRED:"
echo "   📝 Update lib/firebase_options.dart with production keys"
echo "   📝 Replace 'beacon-new-beginnings-demo' with production project ID"
echo "   📝 Update all API keys to production values"
echo ""

# 4. Clean up user role demo accounts
echo "👥 Cleaning demo accounts from user models..."
if [ -f "lib/models/user_role.dart" ]; then
    # Create a temporary file without demo accounts section
    sed -i '' '/\/\/ Demo accounts for testing/,/^}/d' lib/models/user_role.dart
    echo "   ✅ Removed demo accounts from user_role.dart"
fi

# 5. Clean sample data generators
echo "📊 Removing sample data generators..."
if [ -f "lib/widgets/revenue_chart.dart" ]; then
    sed -i '' '/\/\/ Sample data generators for testing/,$d' lib/widgets/revenue_chart.dart
    echo "   ✅ Cleaned revenue_chart.dart"
fi

if [ -f "lib/services/resource_service.dart" ]; then
    # Remove addSampleResources method
    sed -i '' '/addSampleResources/,/^  }/d' lib/services/resource_service.dart
    echo "   ✅ Removed sample resources from resource_service.dart"
fi

# 6. Clean document placeholders
echo "📄 Cleaning document placeholders..."
if [ -f "lib/widgets/document_viewer.dart" ]; then
    sed -i '' 's/SAMPLE DOCUMENT/Document/g' lib/widgets/document_viewer.dart
    sed -i '' 's/Sample Business Ltd/Business Name/g' lib/widgets/document_viewer.dart
    echo "   ✅ Cleaned document_viewer.dart"
fi

# 7. Search for remaining test/demo references
echo "🔍 Searching for remaining demo/test references..."
echo ""

DEMO_REFS=$(grep -r -i "demo\|test\|sample" lib/ --exclude-dir=test 2>/dev/null | grep -v "// Test\|/* Test\|Test.*:" | head -10)
if [ ! -z "$DEMO_REFS" ]; then
    echo "⚠️  Found potential demo/test references to review manually:"
    echo "$DEMO_REFS"
    echo ""
    echo "📝 Please review these files manually"
else
    echo "✅ No obvious demo/test references found"
fi

# 8. Update app constants to production values
echo "⚙️  Updating app constants..."
if [ -f "lib/constants/app_constants.dart" ]; then
    # These should already be updated from previous fixes
    echo "   ✅ App constants should already be updated to homelinkgh.com"
fi

# 9. Clean Flutter and rebuild
echo "🔄 Cleaning Flutter cache..."
flutter clean
flutter pub get

echo ""
echo "✅ Production cleanup completed!"
echo ""
echo "📋 MANUAL STEPS REMAINING:"
echo "========================="
echo "1. 🔑 Update lib/firebase_options.dart with production Firebase keys"
echo "2. 🗄️  Switch Supabase URLs to production database"  
echo "3. 💳 Update payment gateway keys to live/production mode"
echo "4. 📧 Verify email service uses production SMTP settings"
echo "5. 🌐 Test all features with production backend"
echo "6. 🚀 Remove demo account from app store metadata (keep for Apple review only)"
echo ""
echo "💡 TIP: Run the app and test core flows to ensure everything works!"
echo "📱 Test: Registration → Login → Service Booking → Payment"
echo ""
echo "⚠️  CRITICAL: Before launch, set IS_PRODUCTION = true in your constants!"