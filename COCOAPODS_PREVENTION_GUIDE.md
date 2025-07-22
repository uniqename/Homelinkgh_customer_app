# CocoaPods Sync Prevention Guide

## 🚨 Issue Fixed: "The sandbox is not in sync with the Podfile.lock"

This guide ensures the CocoaPods sync error never happens again in the HomeLinkGH project.

## ✅ Preventive Measures Implemented

### 1. **Automated Sync Scripts**
- `scripts/sync_pods.sh` - Smart dependency sync
- `scripts/build_ios.sh` - Complete iOS build pipeline
- `scripts/build_android.sh` - Complete Android AAB pipeline

### 2. **Pre-commit Hook**
- Automatically syncs dependencies when Podfile or pubspec.yaml changes
- Ensures Podfile.lock is always committed with changes

### 3. **Build Process Integration**
- All build scripts now include dependency sync as first step
- Prevents builds with outdated dependencies

## 🔄 Usage Instructions

### Quick Build Commands

```bash
# iOS Build (includes dependency sync)
./scripts/build_ios.sh

# Android AAB Build (includes dependency sync)
./scripts/build_android.sh

# Manual dependency sync only
./scripts/sync_pods.sh
```

### Manual Steps (if needed)

```bash
# 1. Clean and get Flutter dependencies
flutter clean
flutter pub get

# 2. Sync iOS dependencies
cd ios && pod install && cd ..

# 3. Build as needed
flutter build ios --release
# OR
flutter build appbundle --release
```

## 🛡️ Prevention Strategies

### When Working on the Project:

1. **Always use build scripts** instead of manual commands
2. **Run sync_pods.sh** after pulling changes that affect Podfile
3. **Commit Podfile.lock** whenever Podfile changes
4. **Use clean builds** for production releases

### When Adding New Plugins:

```bash
# 1. Add plugin to pubspec.yaml
# 2. Run flutter pub get
# 3. Run sync script
./scripts/sync_pods.sh
# 4. Commit both pubspec.lock AND Podfile.lock
git add pubspec.lock ios/Podfile.lock
git commit -m "Add new plugin with synced dependencies"
```

## 🔧 Troubleshooting

### If Sync Error Still Occurs:

```bash
# Nuclear option - complete clean rebuild
rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### For Team Development:

1. **Always pull before building**:
   ```bash
   git pull origin main
   ./scripts/sync_pods.sh
   ```

2. **Share dependency updates**:
   ```bash
   # After adding plugins
   git add pubspec.lock ios/Podfile.lock
   git commit -m "Update dependencies"
   git push origin main
   ```

## 📋 Checklist for New Team Members

- [ ] Run `./scripts/sync_pods.sh` after first clone
- [ ] Use build scripts instead of manual flutter build commands  
- [ ] Always commit Podfile.lock with Podfile changes
- [ ] Run dependency sync after pulling updates

## 🎯 Key Files to Monitor

- `pubspec.yaml` - Flutter dependencies
- `ios/Podfile` - iOS native dependencies  
- `pubspec.lock` - Flutter dependency versions (commit this)
- `ios/Podfile.lock` - iOS dependency versions (commit this)

## 🚀 Production Build Process

### iOS App Store:
```bash
./scripts/build_ios.sh
# Then use Xcode to archive and upload
```

### Google Play Store:
```bash
./scripts/build_android.sh
# Upload the generated homelinkgh-v*.aab file
```

---

**✅ This setup ensures the CocoaPods sync issue will never occur again!**