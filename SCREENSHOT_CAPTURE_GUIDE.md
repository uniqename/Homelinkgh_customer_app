# HomeLinkGH App Screenshots Capture Guide

## 📱 Overview
This guide helps you capture real screenshots from the HomeLinkGH app for App Store and Google Play Store submissions. You need to capture screenshots from the actual running app, not mockups.

## 📐 Required Screenshot Dimensions

### iPhone Screenshots
- **iPhone Pro Max (6.7")**: 1320 × 2868px or 2868 × 1320px
- **iPhone Pro (6.1")**: 1290 × 2796px or 2796 × 1290px

### iPad Screenshots  
- **iPad 12.9" or 13"**: 2064 × 2752px, 2752 × 2064px, 2048 × 2732px, or 2732 × 2048px

### Android Screenshots
- **Phone**: 320dp × 569dp minimum (scales to device)
- **Tablet**: 600dp × 960dp minimum (scales to device)

## 🎯 Required Screenshots (5 per platform)

### Screenshot 1: Home Screen with AI Features
**Content to capture:**
- App logo and branding
- Main navigation
- AI personalization features highlighted
- Ghana Card priority banner/indicator
- Quick access buttons (Food, Services, etc.)

**How to capture:**
1. Open the HomeLinkGH app
2. Ensure you're on the main home screen
3. Make sure all AI features are visible
4. Take screenshot using device screenshot function

### Screenshot 2: Food Delivery Screen
**Content to capture:**
- Restaurant listings with AI recommendations
- Smart filtering options
- Ghana Card verified restaurants badge
- Location-based results
- AI-powered "Recommended for You" section

**How to capture:**
1. Navigate to Food Delivery section
2. Ensure restaurants are loaded
3. Show AI recommendations if available
4. Capture screen with diverse restaurant options

### Screenshot 3: Home Services Screen
**Content to capture:**
- Service provider profiles
- Trust scores and verification badges
- Ghana Card verified providers
- Service categories (Cleaning, Plumbing, etc.)
- Dynamic provider cards

**How to capture:**
1. Navigate to Home Services
2. Show different service categories
3. Ensure provider profiles are visible
4. Highlight verification badges

### Screenshot 4: User Profile & Gamification
**Content to capture:**
- User profile with gamification elements
- Points, levels, achievements
- Progress indicators
- Reward badges
- Ghana Card verification status

**How to capture:**
1. Navigate to Profile/Account section
2. Show gamification dashboard
3. Display achievement badges
4. Highlight level progression

### Screenshot 5: Ghana Card Verification Screen
**Content to capture:**
- Ghana Card verification interface
- Priority benefits explanation
- Diaspora connection features
- Enhanced trust score display
- Verification process steps

**How to capture:**
1. Navigate to Verification section
2. Show Ghana Card priority features
3. Display verification benefits
4. Capture verification interface

## 📱 iOS Screenshot Capture Process

### Using iOS Simulator
1. Open Xcode and run the app in iOS Simulator
2. Choose device type (iPhone Pro Max, iPhone Pro, iPad Pro)
3. Navigate to each screen as outlined above
4. Use `Device → Screenshot` menu or `Cmd+S`
5. Screenshots saved to Desktop by default

### Using Physical Device
1. Install app on iPhone/iPad
2. Navigate to each screen
3. Use physical buttons: `Power + Volume Up` (iPhone X+) or `Power + Home` (older)
4. Transfer screenshots to Mac via AirDrop or Photos

### iOS Simulator Device Selection
- **iPhone 15 Pro Max** (for 1320×2868 screenshots)
- **iPhone 15 Pro** (for 1290×2796 screenshots)  
- **iPad Pro 12.9-inch** (for 2064×2752 screenshots)
- **iPad Pro 11-inch** (for 2048×2732 screenshots)

## 🤖 Android Screenshot Capture Process

### Using Android Emulator
1. Open Android Studio
2. Create emulator with required screen size
3. Run HomeLinkGH app
4. Navigate to each screen
5. Use emulator screenshot button or `Ctrl+S`

### Using Physical Device
1. Install app on Android device
2. Navigate to each screen
3. Use `Power + Volume Down` buttons
4. Transfer screenshots via USB or Google Photos

### Android Emulator Configuration
- **Phone**: Pixel 7 Pro or similar (high resolution)
- **Tablet**: Pixel Tablet or similar (tablet layout)

## 📊 Screenshot Organization

### File Naming Convention
```
homelink_[platform]_[device]_[screen_number]_[description].png

Examples:
- homelink_ios_iphone_pro_max_01_home_screen.png
- homelink_ios_ipad_pro_02_food_delivery.png
- homelink_android_phone_03_home_services.png
```

### Folder Structure
```
HomeLinkGH-App-Screenshots/
├── iOS/
│   ├── iPhone_Pro_Max/
│   │   ├── 01_home_screen.png
│   │   ├── 02_food_delivery.png
│   │   ├── 03_home_services.png
│   │   ├── 04_profile_gamification.png
│   │   └── 05_ghana_card_verification.png
│   ├── iPhone_Pro/
│   └── iPad_Pro/
└── Android/
    ├── Phone/
    └── Tablet/
```

## 🎨 Screenshot Quality Guidelines

### Technical Requirements
- **Resolution**: Use highest available device resolution
- **Format**: PNG format (lossless compression)
- **Color**: Full color, not grayscale
- **Orientation**: Match device orientation (portrait/landscape)

### Content Requirements
- **Real Data**: Use actual app content, not placeholder text
- **UI Elements**: Ensure all buttons and text are visible
- **Branding**: Show HomeLinkGH logo and Ghana-themed elements
- **Features**: Highlight key app features in each screen

### Visual Quality
- **Clarity**: Screenshots should be sharp and clear
- **Lighting**: Use good lighting if photographing screen
- **Alignment**: Ensure UI elements are properly aligned
- **Completeness**: Show full screen without cropping

## 🔧 Screenshot Automation Script

### Quick Screenshot Organizer
```bash
#!/bin/bash
# organize_screenshots.sh

# Create directory structure
mkdir -p "HomeLinkGH-App-Screenshots/iOS/iPhone_Pro_Max"
mkdir -p "HomeLinkGH-App-Screenshots/iOS/iPhone_Pro"
mkdir -p "HomeLinkGH-App-Screenshots/iOS/iPad_Pro"
mkdir -p "HomeLinkGH-App-Screenshots/Android/Phone"
mkdir -p "HomeLinkGH-App-Screenshots/Android/Tablet"

echo "📁 Screenshot directories created!"
echo "📱 Ready to organize your HomeLinkGH screenshots"
```

### Screenshot Validator Script
```python
#!/usr/bin/env python3
# validate_screenshots.py

import os
from PIL import Image

def validate_screenshots(directory):
    """Validate screenshot dimensions and quality"""
    
    required_dimensions = {
        'iPhone_Pro_Max': [(1320, 2868), (2868, 1320)],
        'iPhone_Pro': [(1290, 2796), (2796, 1290)],
        'iPad_Pro': [(2064, 2752), (2752, 2064), (2048, 2732), (2732, 2048)]
    }
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.png'):
                img_path = os.path.join(root, file)
                try:
                    img = Image.open(img_path)
                    width, height = img.size
                    
                    print(f"📸 {file}: {width}x{height}px")
                    
                    # Check if dimensions match requirements
                    for device, dims in required_dimensions.items():
                        if device in root:
                            if (width, height) in dims:
                                print(f"   ✅ Correct dimensions for {device}")
                            else:
                                print(f"   ❌ Incorrect dimensions for {device}")
                                print(f"   Expected: {dims}")
                
                except Exception as e:
                    print(f"   ❌ Error processing {file}: {e}")

if __name__ == "__main__":
    validate_screenshots("HomeLinkGH-App-Screenshots")
```

## 📋 Pre-Submission Checklist

### Before Capturing Screenshots
- [ ] App is fully functional and tested
- [ ] All screens load properly with real data
- [ ] Ghana Card features are implemented
- [ ] Gamification elements are visible
- [ ] AI features are working and displayed

### During Screenshot Capture
- [ ] Use correct device sizes and orientations
- [ ] Capture all 5 required screens per platform
- [ ] Ensure UI elements are fully visible
- [ ] Check for proper Ghana branding
- [ ] Verify text is readable

### After Screenshot Capture
- [ ] Validate screenshot dimensions
- [ ] Check image quality and clarity
- [ ] Organize files with proper naming
- [ ] Backup screenshots to cloud storage
- [ ] Test upload to App Store Connect/Play Console

## 🚀 Upload to App Stores

### App Store Connect (iOS)
1. Login to App Store Connect
2. Navigate to your app
3. Go to "App Store" tab
4. Select device type (iPhone/iPad)
5. Upload screenshots in order
6. Add descriptions for each screenshot

### Google Play Console (Android)
1. Login to Google Play Console
2. Navigate to your app
3. Go to "Store presence" → "Main store listing"
4. Upload screenshots in "Screenshots" section
5. Add phone and tablet screenshots
6. Add descriptions

## 🎯 Screenshot Descriptions

### Screenshot 1: Home Screen
"HomeLinkGH's AI-powered home screen featuring personalized recommendations, Ghana Card priority access, and smart service suggestions tailored to your preferences."

### Screenshot 2: Food Delivery
"Discover Ghana's best restaurants with AI-powered recommendations, real-time tracking, and Ghana Card verified establishments for trusted dining experiences."

### Screenshot 3: Home Services
"Book verified home service providers with trust scores, Ghana Card verification badges, and AI-matched professionals for cleaning, plumbing, and electrical services."

### Screenshot 4: Profile & Gamification
"Earn points, unlock achievements, and level up with HomeLinkGH's gamification system while tracking your Ghana Card verification status and service history."

### Screenshot 5: Ghana Card Verification
"Priority verification system for Ghana Card holders with enhanced trust scores, diaspora connection benefits, and seamless identity verification process."

## 🔍 Common Issues and Solutions

### Issue: Screenshot dimensions don't match
**Solution**: Use exact device simulators/emulators specified in requirements

### Issue: Screenshots appear blurry
**Solution**: Ensure device is set to highest resolution, avoid compression

### Issue: UI elements cut off
**Solution**: Check device orientation, ensure full screen capture

### Issue: App crashes during screenshot
**Solution**: Test app thoroughly before capture, use stable build

### Issue: Screenshots rejected by app store
**Solution**: Verify dimensions, check content guidelines, ensure real app content

## 📞 Support

If you encounter issues during screenshot capture:
- Check device compatibility
- Verify app functionality
- Review Apple/Google screenshot guidelines
- Test on multiple devices if needed

---

**Ready to capture professional App Store screenshots for HomeLinkGH!**

© 2024 HomeLinkGH. All rights reserved.
Ghana's smartest AI-powered services platform.