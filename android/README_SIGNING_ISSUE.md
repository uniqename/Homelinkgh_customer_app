# Android App Bundle Signing Issue - URGENT

## Problem
Google Play Store is rejecting the AAB because it's signed with the wrong certificate:

**Expected fingerprint:** `A3:B7:D6:58:EA:F4:71:7A:B3:1F:D3:23:6C:10:65:7C:76:0C:45:13`
**Current fingerprint:** `FC:81:74:CA:0B:4E:9E:DA:7B:E2:F8:07:5A:1F:12:1A:7D:17:72:58`

## Root Cause
The app was previously uploaded with a different keystore, and Google Play Store now expects all updates to be signed with the same certificate.

## Solutions

### Option 1: Use App Signing by Google Play (Recommended)
1. **Create Upload Key**: Generate a new upload key for future uploads
2. **Let Google Handle Signing**: Google will re-sign with the correct certificate
3. **Update key.properties**: Use the upload key instead of release key

### Option 2: Recover Original Keystore
1. **Locate Original Keystore**: Find the keystore used for the first upload
2. **Update Configuration**: Use the original keystore for signing
3. **Rebuild AAB**: Generate new AAB with correct certificate

### Option 3: Reset App Signing (Last Resort)
1. **Contact Google Play Support**: Request to reset app signing
2. **Provide New Certificate**: Upload new certificate fingerprint
3. **Wait for Approval**: Google will approve the new certificate

## Immediate Action Required

### Step 1: Create Upload Key
```bash
keytool -genkeypair -v -keystore homelinkgh-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias homelinkgh-upload
```

### Step 2: Update key.properties
```properties
storePassword=HomeLinkGH2025!
keyPassword=HomeLinkGH2025!
keyAlias=homelinkgh-upload
storeFile=homelinkgh-upload-key.jks
```

### Step 3: Build with Upload Key
```bash
flutter build appbundle --release
```

### Step 4: Configure Google Play App Signing
1. Go to Google Play Console
2. Navigate to Release management > App signing
3. Enable "App signing by Google Play"
4. Upload the new AAB signed with upload key

## Files to Update
- `/android/key.properties` - Update to use upload key
- `/android/homelinkgh-upload-key.jks` - New upload keystore
- `/android/app/build.gradle.kts` - Ensure signing config is correct

## Expected Outcome
Google Play will:
1. Accept the AAB signed with upload key
2. Re-sign it with the correct certificate (A3:B7:D6:58...)
3. Distribute the properly signed app

## Timeline
- **Critical**: Must be resolved before next upload
- **Recommended**: Test upload key with internal testing first
- **Deadline**: Complete within 24 hours

## Backup Plan
If upload key doesn't work:
1. Contact Google Play Support
2. Provide both certificate fingerprints
3. Request certificate reset or assistance
4. Consider creating new app listing (last resort)

---

**Generated**: July 18, 2025
**Priority**: CRITICAL
**Status**: Needs immediate resolution