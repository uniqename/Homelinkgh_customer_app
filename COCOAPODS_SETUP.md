# CocoaPods Setup Guide for HomeLinkGH

## ✅ Permanent Fix Applied

The CocoaPods sync issue has been permanently resolved with the following changes:

### 1. Fixed Configuration Files
- **Debug.xcconfig**: Updated to properly include CocoaPods configuration
- **Release.xcconfig**: Updated to properly include CocoaPods configuration  
- **Profile.xcconfig**: Created new file for profile builds

### 2. Auto-Sync Scripts Created
- **scripts/sync_pods.sh**: Manual sync script you can run anytime
- **ios/Runner/Scripts/RunScript.sh**: Auto-sync before builds

### 3. How to Use

#### For Manual Sync (when needed):
```bash
cd /path/to/customer_app
./scripts/sync_pods.sh
```

#### For Clean Sync (if issues persist):
```bash
cd /path/to/customer_app
./scripts/sync_pods.sh --clean
```

#### The Warning You'll See (This is NORMAL):
```
[!] CocoaPods did not set the base configuration of your project because your project already has a custom config set.
```

**This warning is NORMAL and does NOT break anything.** It appears because Flutter uses custom Xcode configurations.

### 4. What's Fixed

✅ **Podfile.lock sync issues**  
✅ **Build configuration includes**  
✅ **Missing Profile.xcconfig**  
✅ **Auto-sync capabilities**  

### 5. If You Still See Issues

1. **Delete derived data:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
   ```

2. **Clean and reinstall:**
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   ```

3. **Flutter clean:**
   ```bash
   flutter clean
   flutter pub get
   ```

### 6. For Future Development

The sync should now be automatic, but if you add new dependencies:

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Run `./scripts/sync_pods.sh` if needed
4. iOS builds should work without manual intervention

## 🎯 Result

You should no longer see the "sandbox is not in sync" error when building for iOS. The configuration is now robust and handles dependency changes automatically.