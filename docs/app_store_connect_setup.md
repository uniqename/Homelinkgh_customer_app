# App Store Connect Setup Guide for HomeLinkGH

## Prerequisites Checklist

### Apple Developer Account
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] Two-factor authentication enabled
- [ ] App Store Connect access configured
- [ ] Team member roles assigned appropriately

### Technical Requirements
- [ ] Bundle ID registered: `com.homelinkgh.customerapp`
- [ ] App signing certificates generated
- [ ] Provisioning profiles created
- [ ] iOS deployment target: 17.0+
- [ ] Xcode 15+ installed

### Business Information
- [ ] Legal entity information ready
- [ ] Tax and banking information prepared
- [ ] App privacy details documented
- [ ] Content rating questionnaire answers ready

---

## Step-by-Step Setup Process

### 1. Create App Record

1. **Login to App Store Connect**
   - Visit: https://appstoreconnect.apple.com
   - Sign in with Apple ID and two-factor authentication

2. **Create New App**
   - Click "My Apps" → "+" → "New App"
   - Fill in app information:
     - **Platform:** iOS
     - **Name:** HomeLinkGH
     - **Primary Language:** English (U.S.)
     - **Bundle ID:** com.homelinkgh.customerapp
     - **SKU:** HOMELINKGH-001
     - **User Access:** Limited Access (recommended)

### 2. App Information Section

#### Basic Information
- **Name:** HomeLinkGH
- **Subtitle:** Ghana's Premier Home Services Platform
- **Category:** 
  - Primary: Lifestyle
  - Secondary: Business

#### Localizable Information
- **Description:** (Use content from app_store_metadata.md)
- **Keywords:** Ghana,home services,diaspora,cleaning,delivery,PayStack,verified providers,GPS tracking,Accra
- **Support URL:** https://homelinkgh.com/support
- **Marketing URL:** https://homelinkgh.com

#### General Information
- **Bundle ID:** com.homelinkgh.customerapp
- **Apple ID:** (Auto-generated)
- **SKU:** HOMELINKGH-001
- **Content Rights:** Does not contain, show, or access third-party content

### 3. Pricing and Availability

#### Pricing
- **Price:** Free
- **Make this app available on the App Store:** Yes

#### Availability
- **All Countries and Regions:** Initially select key markets:
  - Ghana (Primary market)
  - United States (Diaspora)
  - United Kingdom (Diaspora)
  - Canada (Diaspora)
  - Germany (Diaspora)
  - Add other countries based on demand

### 4. App Privacy Configuration

#### Data Collection Practices

**Contact Info**
- Email Address: Yes (Account creation, Customer support)
- Name: Yes (Account creation, Service booking)
- Phone Number: Yes (Account creation, Service communication)

**Location**
- Precise Location: Yes (Service provider matching, GPS tracking)
- Coarse Location: Yes (Regional service availability)

**Identifiers**
- Device ID: Yes (Analytics, App functionality)

**Usage Data**
- Product Interaction: Yes (App improvement, Analytics)
- Advertising Data: No

**Diagnostics**
- Crash Data: Yes (App improvement)
- Performance Data: Yes (App optimization)

**Financial Info**
- Payment Info: Yes (Service payments via PayStack)

#### Data Use Purposes
- **Third-Party Advertising:** No
- **Developer's Advertising:** No
- **Analytics:** Yes
- **Product Personalization:** Yes
- **App Functionality:** Yes
- **Customer Support:** Yes

#### Data Sharing
- **Data Shared with Third Parties:** Yes
  - PayStack (Payment processing)
  - Firebase (Backend services)
  - Service providers (Contact information for bookings)

### 5. Age Rating Configuration

Answer the age rating questionnaire:

**4+ Rating Justification:**
- No inappropriate content
- Family-friendly service platform
- Safe for all ages

**Questionnaire Answers:**
- Cartoon or Fantasy Violence: None
- Realistic Violence: None
- Sexual Content or Nudity: None
- Profanity or Crude Humor: None
- Alcohol, Tobacco, or Drug Use or References: None
- Mature/Suggestive Themes: None
- Horror/Fear Themes: None
- Medical/Treatment Information: None
- Gambling and Contests: None
- Unrestricted Web Access: No
- Social Networking: No

### 6. Version Information

#### Version 3.1.1 Details
- **Version Number:** 3.1.1
- **Build Number:** 13
- **What's New:** (Use content from app_store_metadata.md)

#### Copyright
- **Copyright:** 2024 HomeLinkGH Limited

#### Review Information
- **First Name:** [Developer First Name]
- **Last Name:** [Developer Last Name]
- **Phone Number:** +233 XX XXX XXXX
- **Email:** developer@homelinkgh.com
- **Demo Account:** 
  - Username: demo@homelinkgh.com
  - Password: Demo123!
- **Notes:** 
  ```
  HomeLinkGH is a home services platform for Ghana's diaspora community.
  
  Test Account Details:
  - Customer: demo@homelinkgh.com / Demo123!
  - Provider: provider@homelinkgh.com / Provider123!
  
  Key Features to Test:
  1. Service booking flow
  2. Payment integration (test mode)
  3. GPS tracking simulation
  4. Push notifications
  5. Provider onboarding
  
  Note: App includes PayStack payment integration in test mode for review.
  Location services used for provider discovery and service tracking.
  ```

### 7. Build Upload Process

#### Prepare Build for Upload

1. **Update Info.plist**
   ```xml
   <key>CFBundleDisplayName</key>
   <string>HomeLinkGH</string>
   <key>CFBundleShortVersionString</key>
   <string>3.1.1</string>
   <key>CFBundleVersion</key>
   <string>13</string>
   ```

2. **Build Configuration**
   ```bash
   # Clean and build for release
   flutter clean
   flutter pub get
   flutter build ios --release --no-codesign
   ```

3. **Xcode Archive**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device" as target
   - Product → Archive
   - Upload to App Store Connect via Organizer

#### Upload Checklist
- [ ] Build successfully archived
- [ ] No validation errors
- [ ] Build uploaded to App Store Connect
- [ ] Build shows in TestFlight

### 8. Screenshot Requirements

#### Required Screenshots

**iPhone 6.9" (iPhone 15 Pro Max)**
- Resolution: 1320 x 2868 pixels
- Format: PNG or JPEG
- No alpha channel
- RGB color space

**Content for Screenshots:**
1. **Welcome/Hero Screen** - App logo with Ghana flag elements
2. **Service Selection** - Grid of service categories with icons
3. **Provider List** - Verified providers with ratings and distance
4. **Booking Details** - Service booking form with pricing
5. **Payment Screen** - PayStack integration interface
6. **GPS Tracking** - Real-time service tracking map
7. **Diaspora Features** - International booking capabilities
8. **Notifications** - Push notification examples
9. **Profile/Account** - User settings and preferences
10. **Success/Confirmation** - Completed booking screen

#### Screenshot Best Practices
- Use actual app screens (no mockups)
- Include relevant text and content
- Show app's key value propositions
- Ensure high quality and clarity
- Follow iOS Human Interface Guidelines

### 9. App Review Preparation

#### Common Rejection Reasons & Prevention

**Metadata Issues**
- ✅ Ensure description accurately reflects app functionality
- ✅ Keywords relevant to app purpose
- ✅ Screenshots show actual app screens

**App Functionality**
- ✅ All features work as described
- ✅ No crashes or critical bugs
- ✅ Proper error handling

**Legal Requirements**
- ✅ Privacy policy linked and accessible
- ✅ Terms of service clearly stated
- ✅ Age rating appropriate for content

**Payment Processing**
- ✅ PayStack integration properly implemented
- ✅ Clear pricing and fee structure
- ✅ Refund policy accessible

**Location Services**
- ✅ Clear explanation of location usage
- ✅ User permission properly requested
- ✅ Functionality degrades gracefully if denied

#### Pre-Submission Testing

**Functional Testing**
- [ ] Complete user registration flow
- [ ] Service booking end-to-end
- [ ] Payment processing (test mode)
- [ ] GPS tracking functionality
- [ ] Push notifications delivery
- [ ] Provider onboarding process

**Device Testing**
- [ ] iPhone 15 Pro Max
- [ ] iPhone 14 Pro
- [ ] iPhone 13
- [ ] iPhone 12
- [ ] iPad (if supported)

**Network Testing**
- [ ] WiFi connectivity
- [ ] Cellular data (3G/4G/5G)
- [ ] Poor network conditions
- [ ] Offline mode functionality

### 10. Submission Checklist

#### Final Pre-Submission Review
- [ ] App Store metadata complete and accurate
- [ ] Screenshots uploaded and properly formatted
- [ ] App privacy information configured
- [ ] Age rating questionnaire completed
- [ ] Pricing and availability set
- [ ] Build uploaded and processed
- [ ] Review information provided
- [ ] Demo accounts working
- [ ] Legal documents accessible in app

#### Submit for Review
1. **Select Build**
   - Choose latest build (3.1.1, Build 13)
   - Verify build details are correct

2. **Final Review**
   - Check all sections are complete
   - Verify no validation errors
   - Review submission summary

3. **Submit**
   - Click "Submit for Review"
   - Monitor App Store Connect for updates
   - Respond promptly to any reviewer questions

### 11. Post-Submission Process

#### Review Timeline
- **Standard Review:** 1-7 days
- **Expedited Review:** 2-4 days (if requested and approved)

#### Possible Review Outcomes

**Approved**
- App becomes available on App Store
- Monitor downloads and reviews
- Prepare for ongoing updates

**Rejected**
- Review rejection reasons carefully
- Address all issues mentioned
- Resubmit with fixes

**Waiting for Review**
- Monitor status in App Store Connect
- Prepare response for potential questions
- Ensure demo accounts remain functional

#### Launch Day Preparation
- [ ] Press release ready
- [ ] Social media posts scheduled
- [ ] Website updated with App Store links
- [ ] Customer support prepared for increased volume
- [ ] Analytics tracking configured
- [ ] Marketing campaigns ready to activate

### 12. Ongoing Maintenance

#### Regular Tasks
- Monitor app performance and crashes
- Respond to user reviews
- Update content and fix bugs
- Maintain App Store metadata
- Update screenshots for new features
- Keep legal documents current

#### Version Updates
- Plan regular updates every 2-3 months
- Address user feedback
- Add new features based on usage data
- Maintain compatibility with latest iOS versions

---

## Contact Information for Support

**Technical Issues:**
- Apple Developer Support
- App Store Connect Help

**Business Questions:**
- App Store Review Board
- Developer Relations

**Emergency Contact:**
- Expedited Review Request (if critical issues)

This comprehensive setup guide ensures a smooth App Store Connect configuration and submission process for HomeLinkGH.