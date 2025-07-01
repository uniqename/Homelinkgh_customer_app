#!/bin/bash

# Create screenshots directory on desktop
SCREENSHOT_DIR="/Users/enamegyir/Desktop/HomeLinkGH_Screenshots"
mkdir -p "$SCREENSHOT_DIR"

echo "📱 Taking HomeLinkGH App Screenshots..."
echo "Make sure the app is running on the Android emulator!"

# Function to take screenshot
take_screenshot() {
    local name=$1
    local delay=${2:-2}
    
    echo "📸 Taking screenshot: $name"
    echo "⏳ Waiting $delay seconds for you to navigate to the screen..."
    sleep $delay
    
    /Users/enamegyir/Library/Android/sdk/platform-tools/adb exec-out screencap -p > "$SCREENSHOT_DIR/$name.png"
    echo "✅ Saved: $name.png"
}

echo "
🎯 Screenshot Instructions:
1. Make sure HomeLinkGH app is running on Android emulator
2. Navigate to each screen when prompted
3. Screenshots will be saved to Desktop/HomeLinkGH_Screenshots/

Press ENTER to start taking screenshots..."
read

# Welcome/Home Screen
echo "📍 Navigate to: Welcome/Home screen"
take_screenshot "01_welcome_home" 5

# Role Selection Screen  
echo "📍 Navigate to: Role Selection screen (click 'Get Started' or similar)"
take_screenshot "02_role_selection" 5

# Customer/Diaspora Home
echo "📍 Navigate to: Customer/Diaspora Home (select 'I am visiting Ghana' or 'Customer')"
take_screenshot "03_customer_home" 5

# Services Menu
echo "📍 Navigate to: Services menu (show available services)"
take_screenshot "04_services_menu" 5

# Food Delivery
echo "📍 Navigate to: Food Delivery section"
take_screenshot "05_food_delivery" 5

# Provider Dashboard
echo "📍 Navigate to: Provider Dashboard (go back and select 'Service Provider')"
take_screenshot "06_provider_dashboard" 5

# Job Applications
echo "📍 Navigate to: Available Jobs/Applications screen"
take_screenshot "07_available_jobs" 5

# Admin Dashboard
echo "📍 Navigate to: Admin Dashboard (go back and select 'Admin')"
take_screenshot "08_admin_dashboard" 5

# Staff Dashboard
echo "📍 Navigate to: Staff Dashboard (go back and select 'Staff')"
take_screenshot "09_staff_dashboard" 5

# Notifications
echo "📍 Navigate to: Notifications screen (tap notification icon)"
take_screenshot "10_notifications" 5

echo "
🎉 Screenshots completed!
📁 Check Desktop/HomeLinkGH_Screenshots/ folder
📱 You now have 10 app store ready screenshots!

Next steps:
1. Review screenshots for quality
2. Resize for different device requirements:
   - iPhone 6.5\": 1284x2778
   - iPhone 5.5\": 1242x2208  
   - iPad Pro: 2048x2732
   - Android Phone: 1080x1920
   - Android Tablet: 1200x1920
"