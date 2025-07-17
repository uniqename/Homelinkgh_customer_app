import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Privacy Policy Screen for HomeLinkGH
/// Displays comprehensive privacy policy compliant with Ghana's data protection laws
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePrivacyPolicy(),
            tooltip: 'Share Privacy Policy',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildPrivacyPolicyContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF006B3C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF006B3C).withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HomeLinkGH Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your privacy is important to us. This policy explains how we collect, use, and protect your personal information when you use HomeLinkGH services.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.update, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Text(
            'Last Updated: December 2024',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. Information We Collect',
          '''We collect information you provide directly to us, such as when you:

• Create an account or update your profile
• Book services through our platform
• Communicate with service providers
• Contact our customer support
• Participate in surveys or promotions

Types of information collected include:
• Name, email address, and phone number
• Ghana Card or other identification details (for providers)
• Location data (with your permission)
• Payment information (processed securely through PayStack)
• Service preferences and booking history
• Device information and app usage analytics''',
        ),
        
        _buildSection(
          '2. How We Use Your Information',
          '''We use your information to:

• Provide and improve our home services platform
• Connect you with verified service providers
• Process payments and bookings
• Send important notifications about your services
• Ensure safety and security of all users
• Comply with legal obligations in Ghana
• Provide customer support
• Analyze usage patterns to improve our app

We do not sell your personal information to third parties.''',
        ),

        _buildSection(
          '3. Information Sharing',
          '''We may share your information with:

• Service providers you book (limited to necessary contact information)
• PayStack for payment processing (encrypted and secure)
• Our trusted service partners for app functionality
• Law enforcement when required by Ghanaian law
• With your explicit consent for specific purposes

We require all third parties to maintain the confidentiality and security of your information.''',
        ),

        _buildSection(
          '4. Location Information',
          '''We collect location data to:

• Find nearby service providers
• Enable real-time service tracking
• Calculate accurate pricing and delivery times
• Improve service recommendations

You can control location sharing through your device settings. Disabling location services may limit some app functionality.''',
        ),

        _buildSection(
          '5. Data Security',
          '''We implement industry-standard security measures including:

• End-to-end encryption for sensitive data
• Secure servers with regular security updates
• Limited access to personal information by employees
• Regular security audits and monitoring
• Compliance with Ghana's Data Protection Act, 2012

While we strive to protect your information, no system is 100% secure. We encourage you to use strong passwords and keep your account information confidential.''',
        ),

        _buildSection(
          '6. Your Rights',
          '''Under Ghana's Data Protection Act, you have the right to:

• Access your personal information
• Correct inaccurate information
• Delete your account and associated data
• Object to certain data processing
• Withdraw consent for data collection
• Receive a copy of your data

To exercise these rights, contact us at privacy@homelinkgh.com''',
        ),

        _buildSection(
          '7. Data Retention',
          '''We retain your information for as long as:

• Your account is active
• Required for providing services
• Necessary for legal compliance
• Needed for resolving disputes

When you delete your account, we will delete or anonymize your personal information within 30 days, except where retention is required by law.''',
        ),

        _buildSection(
          '8. Children\'s Privacy',
          '''HomeLinkGH is not intended for children under 18. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.''',
        ),

        _buildSection(
          '9. International Data Transfers',
          '''Your information may be transferred to and processed in countries outside Ghana for:

• Cloud storage and processing
• Payment processing through PayStack
• App analytics and improvement

We ensure appropriate safeguards are in place for international transfers.''',
        ),

        _buildSection(
          '10. Push Notifications',
          '''We send push notifications for:

• Booking confirmations and updates
• Payment notifications
• Service reminders
• Important app announcements

You can manage notification preferences in the app settings or disable them entirely through your device settings.''',
        ),

        _buildSection(
          '11. Cookies and Analytics',
          '''We use cookies and similar technologies to:

• Remember your preferences
• Analyze app usage and performance
• Improve user experience
• Provide personalized recommendations

You can control cookie settings through your device or browser settings.''',
        ),

        _buildSection(
          '12. Changes to This Policy',
          '''We may update this privacy policy to reflect:

• Changes in our practices
• Legal or regulatory requirements
• New features or services

We will notify you of significant changes through the app or email. Your continued use constitutes acceptance of the updated policy.''',
        ),

        _buildSection(
          '13. Contact Information',
          '''For privacy-related questions or concerns, contact us:

Email: privacy@homelinkgh.com
Phone: +233 XX XXX XXXX
Address: [Company Address], Accra, Ghana

Data Protection Officer: [Name]
Email: dpo@homelinkgh.com

You may also contact the Data Protection Commission of Ghana if you have concerns about our data practices.''',
        ),

        _buildSection(
          '14. Ghana-Specific Provisions',
          '''This policy complies with:

• Ghana's Data Protection Act, 2012 (Act 843)
• National Information Technology Agency (NITA) guidelines
• Bank of Ghana regulations for payment services
• Ghana Standards Authority requirements

For disputes, Ghanaian law applies and courts in Ghana have jurisdiction.''',
        ),

        const SizedBox(height: 32),
        _buildFooter(),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3C),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thank you for trusting HomeLinkGH',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We are committed to protecting your privacy and providing excellent home services to Ghana\'s diaspora and local communities.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            '🇬🇭 Made in Ghana, Connecting the World',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006B3C),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePrivacyPolicy() {
    const privacyText = '''HomeLinkGH Privacy Policy

Your privacy is important to us. This policy explains how we collect, use, and protect your personal information when you use HomeLinkGH services.

For the complete privacy policy, please visit our app or website.

Contact us: privacy@homelinkgh.com''';

    Clipboard.setData(const ClipboardData(text: privacyText));
  }
}

/// Widget for displaying privacy policy summary in onboarding or forms
class PrivacyPolicySummaryWidget extends StatelessWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onViewFull;

  const PrivacyPolicySummaryWidget({
    super.key,
    this.onAccept,
    this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Privacy & Data Protection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'We protect your personal information and comply with Ghana\'s Data Protection Act. Key points:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '• We only collect information necessary for our services\n'
            '• Your location data is used to find nearby providers\n'
            '• Payment information is processed securely by PayStack\n'
            '• You can delete your account and data at any time\n'
            '• We do not sell your information to third parties',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: onViewFull ?? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                child: const Text('View Full Policy'),
              ),
              const Spacer(),
              if (onAccept != null)
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept & Continue'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}