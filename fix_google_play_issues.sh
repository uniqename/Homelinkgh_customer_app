#!/bin/bash

echo "🚨 Fixing Google Play Store Issues for Beacon NGO App"
echo "=================================================="
echo ""

# Issue 1: Remove SMS and Call Log Permissions
echo "📱 Issue 1: Removing SMS and Call Log Permissions"
echo "------------------------------------------------"

# Create custom Android manifest to exclude unwanted permissions
echo "📝 Adding permission exclusions to AndroidManifest.xml..."

# Backup original manifest
cp android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml.backup

# Add permission exclusions to the manifest
cat >> android/app/src/main/AndroidManifest.xml << 'EOF'

    <!-- Explicitly remove permissions that url_launcher might add -->
    <uses-permission android:name="android.permission.CALL_PHONE" tools:node="remove" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" tools:node="remove" />
    <uses-permission android:name="android.permission.SEND_SMS" tools:node="remove" />
    <uses-permission android:name="android.permission.READ_SMS" tools:node="remove" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" tools:node="remove" />
    <uses-permission android:name="android.permission.READ_CALL_LOG" tools:node="remove" />
    <uses-permission android:name="android.permission.WRITE_CALL_LOG" tools:node="remove" />
EOF

# Fix the manifest opening tag to include tools namespace
sed -i '' 's/<manifest xmlns:android="http:\/\/schemas.android.com\/apk\/res\/android">/<manifest xmlns:android="http:\/\/schemas.android.com\/apk\/res\/android" xmlns:tools="http:\/\/schemas.android.com\/apk\/res\/tools">/g' android/app/src/main/AndroidManifest.xml

echo "✅ Permission exclusions added to AndroidManifest.xml"

# Issue 2: Create Privacy Policy
echo ""
echo "🔒 Issue 2: Creating Privacy Policy"
echo "------------------------------------"

# Create privacy policy HTML file
mkdir -p assets/legal
cat > assets/legal/privacy_policy.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beacon of New Beginnings - Privacy Policy</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        h1, h2 { color: #006B3C; }
        .contact { background: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Privacy Policy for Beacon of New Beginnings</h1>
    <p><strong>Effective Date:</strong> January 2025</p>
    
    <h2>1. Information We Collect</h2>
    <p>We collect information to provide better services to our users:</p>
    <ul>
        <li><strong>Personal Information:</strong> Name, email address, phone number when you register</li>
        <li><strong>Location Data:</strong> GPS coordinates to connect you with nearby resources (only when granted)</li>
        <li><strong>Usage Data:</strong> How you use our app to improve our services</li>
        <li><strong>Device Information:</strong> Device type, operating system for compatibility</li>
    </ul>

    <h2>2. How We Use Your Information</h2>
    <ul>
        <li>Connect you with appropriate support resources</li>
        <li>Provide emergency assistance and safety features</li>
        <li>Send important safety notifications (with your consent)</li>
        <li>Improve our app and services</li>
        <li>Comply with legal obligations</li>
    </ul>

    <h2>3. Information Sharing</h2>
    <p>We do not sell or rent your personal information. We may share information only:</p>
    <ul>
        <li>With your explicit consent</li>
        <li>With emergency services when you use emergency features</li>
        <li>With verified support organizations you choose to contact</li>
        <li>When required by law or to protect safety</li>
    </ul>

    <h2>4. Data Security</h2>
    <p>We implement appropriate security measures to protect your personal information:</p>
    <ul>
        <li>Encrypted data transmission and storage</li>
        <li>Regular security audits and updates</li>
        <li>Limited access to personal information by staff</li>
        <li>Secure servers with backup and recovery systems</li>
    </ul>

    <h2>5. Your Rights</h2>
    <p>You have the right to:</p>
    <ul>
        <li>Access your personal information</li>
        <li>Correct or update your information</li>
        <li>Delete your account and data</li>
        <li>Opt-out of non-essential communications</li>
        <li>Request data portability</li>
    </ul>

    <h2>6. Data Retention</h2>
    <p>We retain your personal information only as long as necessary for the purposes outlined in this policy or as required by law. You may request deletion of your data at any time.</p>

    <h2>7. Children's Privacy</h2>
    <p>Our app is designed for users 17 years and older. We do not knowingly collect personal information from children under 17. If we become aware of such collection, we will delete the information immediately.</p>

    <h2>8. Third-Party Services</h2>
    <p>Our app may contain links to third-party websites or services. This privacy policy does not apply to those services. Please review their respective privacy policies.</p>

    <h2>9. Changes to This Policy</h2>
    <p>We may update this privacy policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the effective date.</p>

    <div class="contact">
        <h2>10. Contact Us</h2>
        <p>If you have questions about this privacy policy or our data practices, please contact us:</p>
        <ul>
            <li><strong>Email:</strong> privacy@beaconnewbeginnings.org</li>
            <li><strong>Phone:</strong> Available through the app</li>
            <li><strong>Address:</strong> Ghana</li>
        </ul>
    </div>

    <p><em>This privacy policy complies with Ghana Data Protection Act and international privacy standards.</em></p>
</body>
</html>
EOF

echo "✅ Privacy policy created at assets/legal/privacy_policy.html"

# Update pubspec.yaml to include the legal assets
echo ""
echo "📦 Updating pubspec.yaml to include legal assets..."
if ! grep -q "assets/legal/" pubspec.yaml; then
    sed -i '' '/assets:/{
a\
    - assets/legal/
}' pubspec.yaml
fi

echo "✅ Updated pubspec.yaml"

# Create a simple function to replace direct phone calls with intent-based approach
echo ""
echo "📞 Issue 3: Updating Phone Call Implementation"
echo "----------------------------------------------"

# Create a safer phone call implementation
cat > lib/services/safe_phone_service.dart << 'EOF'
import 'package:url_launcher/url_launcher.dart';

/// Safe phone service that launches phone dialer without requiring CALL_PHONE permission
class SafePhoneService {
  
  /// Launch phone dialer with pre-filled number (doesn't auto-dial)
  static Future<void> openDialer(String phoneNumber) async {
    // Clean phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        // This opens the dialer app with the number pre-filled
        // User must manually tap call button - no CALL_PHONE permission needed
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open phone dialer';
      }
    } catch (e) {
      print('Error opening dialer: $e');
      rethrow;
    }
  }
  
  /// Show emergency numbers in a dialog for manual dialing
  static void showEmergencyDialog(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Numbers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmergencyNumber('Police', '191'),
            _buildEmergencyNumber('Fire Service', '192'),
            _buildEmergencyNumber('Ambulance', '193'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildEmergencyNumber(String service, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(number, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
EOF

echo "✅ Created safe phone service"

# Clean and rebuild
echo ""
echo "🧹 Cleaning and rebuilding..."
flutter clean
flutter pub get

echo ""
echo "✅ Google Play Store Issues Fixed!"
echo "================================="
echo ""
echo "📋 What was fixed:"
echo "1. ✅ Added permission exclusions to remove SMS/Call log permissions"
echo "2. ✅ Created comprehensive privacy policy"
echo "3. ✅ Implemented safer phone dialing approach"
echo ""
echo "📱 Next steps:"
echo "1. Build new APK/AAB: flutter build appbundle --release"
echo "2. Upload to Google Play Console"
echo "3. Update privacy policy declaration in Play Console"
echo "4. Submit for review"
echo ""
echo "🔒 Privacy Policy URL for Play Console:"
echo "   Use: https://yourwebsite.com/privacy-policy"
echo "   (Host the HTML file on your website)"
echo ""
echo "⚠️  Remember to:"
echo "   - Host privacy policy on your website"
echo "   - Update Play Console privacy policy URL"
echo "   - Complete policy declarations in Play Console"
EOF