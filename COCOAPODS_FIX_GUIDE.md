# CocoaPods Sync Fix Guide

## The Problem
"The sandbox is not in sync with the Podfile.lock" error occurs when iOS dependencies are out of sync.

## Permanent Solution

### Quick Fix (Run this first)
```bash
cd ios && pod install
```

### Complete Reset (If quick fix doesn't work)
```bash
# Use the provided script
./fix_pods.sh

# Or manually:
cd ios
rm -rf Pods/ Podfile.lock build/
pod install
cd ..
flutter clean && flutter pub get
```

## Prevention Strategies

### 1. Always run after changes:
- **After modifying pubspec.yaml**: `flutter pub get && cd ios && pod install`
- **After git pull**: `flutter clean && flutter pub get && cd ios && pod install`
- **Before building**: `cd ios && pod install`

### 2. Use the provided scripts:
- **Quick CocoaPods fix**: `./fix_pods.sh`
- **Complete clean build**: `./flutter_clean_build.sh`

### 3. Add to your workflow:
```bash
# Before every build
cd ios && pod install && cd ..
flutter build ios
```

## Troubleshooting

### If you still get errors:

1. **Update CocoaPods**:
   ```bash
   sudo gem install cocoapods
   pod repo update
   ```

2. **Check Xcode version**:
   - Ensure Xcode is updated
   - Check Flutter/iOS compatibility

3. **Nuclear option** (last resort):
   ```bash
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock ios/.symlinks
   rm -rf ~/.pub-cache
   flutter pub get
   cd ios && pod install
   ```

## Files That Prevent Issues

The following files are properly configured to prevent sync issues:
- `ios/Flutter/Debug.xcconfig` - Includes CocoaPods debug config
- `ios/Flutter/Release.xcconfig` - Includes CocoaPods release config  
- `ios/Flutter/Profile.xcconfig` - Includes CocoaPods profile config

## Quick Commands Cheat Sheet

| Problem | Solution |
|---------|----------|
| Podfile.lock sync error | `cd ios && pod install` |
| Major dependency changes | `./fix_pods.sh` |
| Complete clean build | `./flutter_clean_build.sh` |
| Before App Store build | `cd ios && pod install && flutter build ios --release` |

---

**💡 Pro Tip**: Always run `cd ios && pod install` before building for App Store submission!