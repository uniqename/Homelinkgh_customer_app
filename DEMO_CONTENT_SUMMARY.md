# 📋 Demo Content Summary - HomeLinkGH

## 🟢 Safe to Keep (For Apple Review)

These items should STAY during Apple App Store review:

✅ **App Store Demo Account**:
- Username: `reviewer@homelinkgh.com`
- Password: `ReviewDemo2025!`
- Location: `assets/app_store_metadata.json` lines 52-55
- **Action**: Keep for Apple review, remove from production app

## 🔴 Must Remove After Approval

### Critical Demo Files (Remove completely):
1. **`lib/services/demo_auth_service.dart`** - Fake authentication system
2. **`lib/services/supabase_staging_service.dart`** - Test database with fake data
3. **`lib/main_test.dart`** - Test app entry point  
4. **`lib/models/user_role.dart`** - Contains `DemoAccounts` class (lines 288-545)

### Demo References in Code:
1. **`lib/main_ios.dart`** - References `DemoAuthService` (lines 3, 22, 52)
2. **`lib/main_minimal.dart`** - Demo mode prints (lines 9-10)
3. **`lib/firebase_options.dart`** - Demo Firebase keys (lines 44-48)

### Sample/Test Data:
1. **`lib/services/resource_service.dart`** - `addSampleResources()` method
2. **`lib/widgets/revenue_chart.dart`** - Sample data generators  
3. **`lib/widgets/document_viewer.dart`** - "SAMPLE DOCUMENT" placeholders

## 🟡 Configuration Updates Needed

### Production Environment:
- [ ] Firebase project ID: `beacon-new-beginnings-demo` → `homelinkgh-production`
- [ ] Supabase URLs: staging → production database
- [ ] PayStack keys: test → live keys
- [ ] Email service: demo SMTP → production SMTP

### Constants Updates:
- [ ] Set `IS_PRODUCTION = true`
- [ ] Verify all URLs point to `homelinkgh.com` (✅ already done)
- [ ] Update API endpoints to production servers

## 🚨 Critical Security Items

**Before going live with real users:**

1. **Remove all demo authentication** - Real users shouldn't access demo accounts
2. **Switch to production database** - Demo data should not mix with real user data
3. **Update payment processing** - Use live payment credentials only
4. **Verify API keys** - All keys should be production keys, not demo/test keys

## 📱 Testing After Cleanup

**Must test these flows with production backend:**
- ✅ User registration with real email
- ✅ Login with real credentials  
- ✅ Service provider booking
- ✅ Payment processing (small test amount)
- ✅ Location services
- ✅ Push notifications

## 🎯 Timeline

**During Apple Review**: Keep demo content for reviewer access
**After Apple Approval**: Run `./clean_for_production.sh` script  
**Before Public Launch**: Complete manual production configuration
**Go Live**: Test all critical flows with real data

---

**💡 Quick Command**: `./clean_for_production.sh` - Automated cleanup after approval