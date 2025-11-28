# 🚀 Production Cleanup Checklist

## ⚠️ CRITICAL: Remove Before Production Launch

After Apple App Store approval, you MUST clean up demo/test content before launching to real users.

## 📋 Demo Content to Remove

### 1. Demo Authentication & Test Users
- [ ] `lib/services/demo_auth_service.dart` - Remove entire file
- [ ] `lib/models/user_role.dart` - Remove `DemoAccounts` class (lines 288-545)
- [ ] `lib/services/supabase_staging_service.dart` - Remove entire file or disable staging
- [ ] Demo credentials in app store metadata (keep for Apple review only)

### 2. Test Entry Points
- [ ] `lib/main_test.dart` - Remove or disable
- [ ] `lib/main_minimal.dart` - Review for demo mode references
- [ ] `lib/main_ios.dart` - Remove demo mode references
- [ ] `lib/main_simple_working.dart` - Review and clean

### 3. Firebase Test Configuration
- [ ] `lib/firebase_options.dart` - Replace demo keys with production keys
- [ ] Update project ID from `beacon-new-beginnings-demo` to production
- [ ] Replace API keys with production values

### 4. Sample/Test Data
- [ ] `lib/services/resource_service.dart` - Remove `addSampleResources()` method
- [ ] `lib/widgets/revenue_chart.dart` - Remove sample data generators
- [ ] `lib/widgets/document_viewer.dart` - Remove placeholder "SAMPLE DOCUMENT" text

### 5. Test File Cleanup
- [ ] Remove all files with "test" in the name (except in test/ directory)
- [ ] Clean up any hardcoded test emails/usernames in code

## 🔧 Production Configuration Updates

### Database & Backend
- [ ] **Switch to production Supabase project**
- [ ] **Update all database URLs to production**
- [ ] **Verify all API keys are production keys**
- [ ] **Remove staging/test database references**

### Authentication
- [ ] **Replace DemoAuthService with real AuthService**
- [ ] **Remove test user credentials**
- [ ] **Verify real Firebase Auth is working**

### Payment Processing
- [ ] **Switch payment gateways to production mode**
- [ ] **Update PayStack keys to live keys**
- [ ] **Remove test payment credentials**

### App Store Metadata
- [ ] **Remove demo account info from production builds**
- [ ] **Keep demo account only for Apple review process**

## 📝 Automated Cleanup Script

Run the provided script to automate most cleanup:

```bash
./clean_for_production.sh
```

## ⚠️ Manual Verification Required

After running cleanup script, manually verify:

1. **No "demo", "test", "sample" text in user-facing areas**
2. **All API keys are production keys**
3. **Database connections point to production**
4. **Payment systems use live credentials**
5. **No hardcoded test data appears in app**

## 🚨 Critical Production Switches

### Before First Real User:
```dart
// In main.dart - ensure using production config
const bool IS_PRODUCTION = true;  // Set to true!

// In constants/app_constants.dart - verify all URLs
static const String websiteUrl = 'https://homelinkgh.com';  // Production URL
static const String supportEmail = 'support@homelinkgh.com';  // Production email
```

### Environment Variables to Set:
- `FLUTTER_ENV=production`  
- `SUPABASE_URL=production_url`
- `SUPABASE_ANON_KEY=production_key`

## 📊 Production Readiness Tests

Before going live:
- [ ] Test real user registration flow
- [ ] Verify real payments work
- [ ] Check all email notifications send properly  
- [ ] Confirm database writes to production
- [ ] Test with real service providers
- [ ] Verify location services work
- [ ] Check push notifications

## 🛡️ Security Checklist
- [ ] No hardcoded API keys in code
- [ ] All sensitive configs in environment variables
- [ ] Production database has proper access controls
- [ ] Payment processing uses secure, live credentials
- [ ] User data properly encrypted and secured

---

**🚨 IMPORTANT**: Demo content is useful for Apple App Store review but must be removed for real users to prevent confusion and security issues.