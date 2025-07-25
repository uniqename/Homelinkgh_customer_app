# 🔍 Google Play Reviewer Access Instructions
## Home Services Ghana App Testing Guide

**App Package:** `com.homeservicesghana.app`  
**Version:** 4.1.0 (Build 30)  
**Last Updated:** January 25, 2025

---

## 📱 **Demo Account Access**

### **Primary Test Account**
- **Email:** `reviewer@homelinkgh.com`
- **Password:** `ReviewTest2025!`
- **Account Type:** Customer account with full features enabled
- **Pre-loaded:** Sample booking history, saved addresses

### **Alternative Guest Access**
- **Method:** App supports guest browsing without registration
- **Access:** Tap "Browse as Guest" on welcome screen
- **Limitations:** Cannot book services, but can view all features

---

## 🏠 **Testing Core Features**

### **1. Service Booking Flow**
**How to Test:**
1. Open app → Login with demo account
2. Tap "Home Services" 
3. Select "Plumbing" or "Cleaning"
4. Choose any available provider
5. Select "Book Now"
6. Choose date/time → Confirm booking

**Expected Result:** Booking confirmation screen appears

### **2. Food Delivery**
**How to Test:**
1. From home screen → Tap "Food Delivery"
2. Browse restaurants (sample data pre-loaded)
3. Select any restaurant
4. Add items to cart
5. Proceed to checkout

**Expected Result:** Order summary with payment options

### **3. Location Services**
**How to Test:**
1. Allow location permission when prompted
2. App will show "Accra, Ghana" or use simulator location
3. Service providers will show based on location
4. Map view displays nearby options

**Important:** Location is used ONLY for service matching, not tracking

---

## 🚨 **Emergency Features Testing**

### **Ghana Emergency Integration**
**How to Test:**
1. Tap profile icon → "Emergency Contacts"
2. View Ghana emergency numbers (999, 191, 192, 193)
3. Test "Call Emergency" button (will show dialer with 999)

**⚠️ Important:** 
- DO NOT actually call emergency numbers during testing
- Feature shows proper dialer integration
- Clear disclaimers about supplementary nature

### **Emergency Contacts**
**Pre-loaded Contacts:**
- Ghana Police: 191
- Fire Service: 192  
- Ambulance: 193
- General Emergency: 999

---

## 💳 **Payment Testing**

### **Payment Methods**
The app integrates with third-party payment processors:
- **Mobile Money:** Simulated (MTN, Vodafone Ghana)
- **Card Payments:** Test mode enabled
- **Cash:** Available option for on-site payment

### **Test Payment Flow**
1. Complete service booking to payment screen
2. Select "Test Card Payment"
3. Use any test card number (processed in sandbox mode)
4. Payment confirmation will appear

**Note:** No real transactions occur during testing

---

## 🔐 **Privacy & Data Testing**

### **Account Deletion Testing**
**Method 1 - In-App:**
1. Profile → Settings → Account Management
2. Tap "Delete Account"
3. Confirm deletion request
4. Account marked for deletion (24-hour process)

**Method 2 - Website:**
1. Visit: https://homelinkgh.com/account/delete
2. Click "Delete My Account" button
3. Email form opens with pre-filled request

### **Data Access Testing**
1. Profile → Settings → Privacy & Data
2. View "My Data" section
3. Request data export (generates sample report)
4. All features work without requiring real personal data

---

## 🌍 **Ghana-Specific Features**

### **Ghana Card Integration**
**How to Test:**
1. Profile → Verification → Ghana Card
2. Feature shows verification interface
3. Uses demo data for testing (no real Ghana Card needed)
4. Shows verification status

### **Local Services Context**
- **Currency:** Ghana Cedis (GH¢) displayed throughout
- **Languages:** English primary, local greetings included
- **Locations:** Accra, Kumasi, Takoradi pre-loaded
- **Business Hours:** Ghana timezone (GMT)

---

## 📞 **Customer Support Testing**

### **In-App Support**
1. Profile → Help & Support
2. Browse FAQ sections
3. Test "Contact Support" → opens email client
4. Support email: support@homelinkgh.com

### **Live Chat (Simulated)**
1. Tap chat icon on any screen
2. Demo conversation appears
3. Shows typical customer service interactions
4. No real agents during testing

---

## 🔧 **Technical Testing Notes**

### **Permissions Usage**
- **Location:** Only when booking services or browsing nearby providers
- **Network:** Required for all app functionality
- **Storage:** Minimal, for user preferences only
- **No sensitive permissions:** SMS, Call logs removed per policy compliance

### **Offline Functionality**
- **Limited offline mode:** Recently viewed services cached
- **Emergency contacts:** Available offline
- **Booking requires internet:** Clear error messages when offline

### **Performance Testing**
- **Load time:** App launches in <3 seconds
- **Navigation:** Smooth transitions between screens
- **Memory usage:** Optimized for mid-range Android devices

---

## 🌟 **Key Testing Scenarios**

### **Scenario 1: First-Time User**
1. Install app → Welcome screen appears
2. Choose "Sign Up" or "Browse as Guest"
3. Complete onboarding (location permission, notifications)
4. Explore main features without commitment

### **Scenario 2: Service Booking**
1. Login → Search for "house cleaning"
2. View provider profiles and ratings
3. Book service for future date
4. Receive booking confirmation

### **Scenario 3: Emergency Situation**
1. Access emergency features quickly
2. View Ghana emergency numbers
3. Test dialer integration (don't complete call)
4. Verify clear disclaimers

---

## 📋 **Policy Compliance Verification**

### **Data Collection**
- **What we collect:** Name, email, phone (for booking only)
- **Location data:** Used for service matching, not stored
- **No tracking:** No advertising or behavioral tracking
- **Clear consent:** Users explicitly agree to data usage

### **Content Appropriateness**
- **Age rating:** Everyone 3+ appropriate
- **No gambling:** No gambling or betting features
- **No violence:** Family-friendly service platform
- **Local compliance:** Adheres to Ghana business regulations

---

## 🚨 **Important Reviewer Notes**

### **Geographic Context**
- **Built for Ghana:** All features designed for Ghanaian market
- **Local emergency services:** Integrates with Ghana's 999 system
- **Cultural relevance:** Ghana Card, local languages, business practices

### **Safety Features**
- **Provider verification:** Background check system (demo data)
- **User safety:** Real-time tracking, secure messaging
- **Emergency integration:** Direct connection to Ghana emergency services

### **Business Model**
- **Free app:** No upfront costs to users
- **Commission-based:** Platform takes small percentage from service transactions
- **Transparent pricing:** All fees clearly disclosed

---

## 📞 **Support During Review**

### **Contact Information**
- **Review Support:** reviewer-support@homelinkgh.com
- **Response Time:** Within 2 hours during Ghana business hours (GMT)
- **Available:** Monday-Friday, 8:00 AM - 6:00 PM GMT

### **Additional Resources**
- **Privacy Policy:** https://homelinkgh.com/privacy
- **Terms of Service:** https://homelinkgh.com/terms
- **Account Deletion:** https://homelinkgh.com/account/delete
- **Support Center:** https://homelinkgh.com/support

---

## ✅ **Testing Checklist for Reviewers**

**Core Functionality:**
- [ ] App launches successfully
- [ ] Demo account login works
- [ ] Service browsing functional
- [ ] Booking flow completes
- [ ] Food delivery interface works
- [ ] Emergency contacts accessible

**Privacy & Compliance:**
- [ ] Privacy policy accessible
- [ ] Account deletion process works
- [ ] Data collection clearly explained
- [ ] Location permission properly requested
- [ ] No inappropriate content detected

**Ghana-Specific Features:**
- [ ] Emergency services integration appropriate
- [ ] Local currency and context correct
- [ ] Cultural elements respectful and accurate
- [ ] Business model transparent

---

## 🎯 **Expected Review Outcome**

This app is designed to provide essential services to Ghanaians while maintaining strict compliance with Google Play policies. All sensitive permissions have been removed, privacy controls are robust, and emergency features supplement (not replace) official services.

**The app should pass review based on:**
- Complete policy compliance
- Clear value proposition for Ghana market  
- Appropriate use of location services
- Transparent business model
- Robust privacy protections

**Thank you for reviewing Home Services Ghana! 🇬🇭**