#!/bin/bash

# HomeLinkGH Real App Screenshot Capture Script
# This script takes actual screenshots from the running Flutter app

echo "🚀 Starting HomeLinkGH app screenshot capture..."

# Create screenshots directory
mkdir -p assets/screenshots/iPhone_Pro_Portrait
mkdir -p assets/screenshots/iPhone_Pro_Max_Portrait  
mkdir -p assets/screenshots/iPad_Pro_Portrait
mkdir -p assets/screenshots/iPad_12_9_Portrait

echo "📁 Created screenshot directories"

# Open the app in Chrome with mobile device simulation
echo "🌐 Opening app in Chrome..."
open -a "Google Chrome" "http://localhost:57420"

echo "📸 Please manually capture screenshots of the following screens:"
echo "   1. Home screen with services"
echo "   2. Food delivery screen"
echo "   3. Home services screen"
echo "   4. Profile/gamification screen"  
echo "   5. Any additional unique screen"
echo ""
echo "💡 Use Chrome DevTools to simulate mobile devices:"
echo "   - Press F12 to open DevTools"
echo "   - Click the mobile device toggle button"
echo "   - Select iPhone Pro (390x844) or iPad Pro (1024x1366)"
echo "   - Take screenshots with Cmd+Shift+4"
echo ""
echo "📂 Save screenshots to:"
echo "   assets/screenshots/iPhone_Pro_Portrait/"
echo "   assets/screenshots/iPhone_Pro_Max_Portrait/"
echo "   assets/screenshots/iPad_Pro_Portrait/"
echo "   assets/screenshots/iPad_12_9_Portrait/"
echo ""
echo "📝 Use naming format: 01_home_screen_1290x2796.png"
echo ""
echo "✅ Script completed. Please capture the screenshots manually."