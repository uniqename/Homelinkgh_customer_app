# HomeLinkGH Testing Guide

## 🚀 Quick Start Testing

### 1. Access Testing Dashboard
- **Open the app** and go to the Role Selection screen
- **Long press** on "HomeLinkGH" title to access the hidden Testing Dashboard
- This gives you full control over test data and user creation

### 2. Initialize Test Data
1. In Testing Dashboard, tap **"Initialize Full Test Data"**
2. This creates comprehensive Ghana-specific test data:
   - Test users (customers, diaspora, job seekers, providers)
   - Real Ghana locations (Accra, Tema, Kumasi, etc.)
   - Services with GHS pricing
   - Sample bookings and jobs
   - Provider networks

### 3. Create Test Users
Use the Testing Dashboard to create users instantly:
- **Customer Test User**: `customer@test.com` / `test123456`
- **Diaspora Test User**: `diaspora@test.com` / `test123456` 
- **Job Seeker Test User**: `jobseeker@test.com` / `test123456`
- **Provider Test User**: `provider@test.com` / `test123456`

## 🧪 Testing Workflows

### "I Want to Work" Workflow (FIXED)
1. Select **"I Want to Work"** from role selection
2. Login/Register as job seeker
3. Complete **Job Seeker Onboarding**:
   - Personal information
   - Service interests (Food Delivery, Cleaning, etc.)
   - Experience level and availability
   - Transportation options
4. Access **Job Portal** with real Ghana opportunities

### Testing Real Data Scenarios

#### 🏠 **Diaspora Customer Testing**
- Book services for family in Ghana
- Test East Legon, Airport Residential locations
- Pre-arrival house preparation services

#### 🚗 **Food Delivery Testing**  
- Order from KFC, Papaye, local restaurants
- Test Accra Mall, Osu, Spintex areas
- Real-time tracking simulation

#### 🧹 **House Cleaning Testing**
- Book deep cleaning services
- Test Tema, East Legon service areas
- Provider verification workflow

#### 💼 **Job Opportunities Testing**
- Browse delivery rider positions
- Apply for cleaning specialist roles
- Salary ranges in GHS (800-2000/month)

## 📍 Real Ghana Test Locations

### Greater Accra Region
- **East Legon**: Premium residential area
- **Tema**: Industrial/residential hub  
- **Osu**: Commercial/tourist area
- **Spintex**: Mixed residential
- **Airport Residential**: Expat community
- **Accra Central**: Business district

### Ashanti Region  
- **Kumasi Central**: Regional capital
- **Bantama**: Residential area
- **Asokwa**: Mixed development

## 💰 Real Pricing (Ghana Cedis)

### Services
- **House Cleaning**: 50-200 GHS
- **Food Delivery**: 15-80 GHS
- **Plumbing**: 120+ GHS
- **Makeup Artist**: 80-350 GHS

### Jobs
- **Delivery Rider**: 800-1500 GHS/month
- **Cleaning Specialist**: 1200-2000 GHS/month
- **Part-time opportunities available**

## 🔧 Technical Testing

### Firebase Collections Created
- `users` - All user types with Ghana data
- `providers` - Verified service providers
- `services` - Service catalog with GHS pricing
- `bookings` - Sample transactions
- `jobs` - Real Ghana job opportunities
- `locations` - Ghana regions and coordinates

### Security Rules
- User data protected by authentication
- Provider verification required
- Admin-only access for sensitive data
- Firestore rules configured for Ghana use case

## 🔄 Reset Testing Environment

### Clear Test Data
1. Go to Testing Dashboard
2. Tap **"Clear Test Data"**
3. Confirm deletion
4. Re-initialize when needed

### User Management
- Test users can be recreated instantly
- Real Ghana phone numbers supported
- Multi-language testing (English, Twi, Ga)

## 📱 Production Ready Features

✅ **Fixed "I Want to Work" workflow**  
✅ **Real Ghana location data**  
✅ **GHS currency pricing**  
✅ **Diaspora-friendly services**  
✅ **Job seeker onboarding**  
✅ **Provider verification**  
✅ **Firebase security rules**  
✅ **Testing infrastructure**

## 🎯 Next Steps

1. **Connect Firebase Project**: Add your Firebase config files
2. **Test All Workflows**: Use the testing dashboard
3. **Verify Real Data**: Ensure Ghana locations work
4. **Production Deploy**: Ready for TestFlight/Play Store

---

**Pro Tip**: Long press "HomeLinkGH" title anywhere in the app to access testing tools during development!