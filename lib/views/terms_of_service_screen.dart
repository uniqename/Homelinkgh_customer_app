import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'privacy_policy_screen.dart';

/// Terms of Service Screen for HomeLinkGH
/// Displays comprehensive terms of service for the Ghana home services platform
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTermsOfService(),
            tooltip: 'Share Terms',
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
            _buildTermsContent(),
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
            'HomeLinkGH Terms of Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'These terms govern your use of HomeLinkGH services. By using our platform, you agree to these terms and conditions.',
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

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. Acceptance of Terms',
          '''By accessing or using HomeLinkGH ("the Service"), you agree to be bound by these Terms of Service ("Terms"). If you disagree with any part of these terms, you may not access the Service.

HomeLinkGH is a platform that connects customers with verified service providers in Ghana and serves the Ghanaian diaspora worldwide.''',
        ),

        _buildSection(
          '2. Description of Service',
          '''HomeLinkGH provides:

• A platform to book home services in Ghana
• Connection between customers and verified service providers
• Secure payment processing through PayStack
• Real-time tracking and communication tools
• Customer support and dispute resolution
• Services specifically designed for Ghana's diaspora community

We act as an intermediary platform and do not directly provide home services.''',
        ),

        _buildSection(
          '3. User Accounts and Registration',
          '''To use our Service, you must:

• Be at least 18 years old
• Provide accurate, current, and complete information
• Maintain the security of your account credentials
• Notify us immediately of any unauthorized use
• Comply with Ghana's laws and regulations

You are responsible for all activities under your account.''',
        ),

        _buildSection(
          '4. User Responsibilities',
          '''As a user, you agree to:

• Use the Service lawfully and respectfully
• Provide accurate information for bookings
• Pay for services as agreed
• Treat service providers with respect
• Not misuse or abuse the platform
• Comply with local laws and regulations
• Report any issues or concerns promptly''',
        ),

        _buildSection(
          '5. Service Provider Terms',
          '''Service providers agree to:

• Complete a verification process including Ghana Card validation
• Provide services professionally and on time
• Maintain appropriate licenses and insurance
• Follow safety protocols and best practices
• Communicate clearly with customers
• Honor confirmed bookings
• Maintain service quality standards
• Comply with HomeLinkGH's provider policies''',
        ),

        _buildSection(
          '6. Booking and Payment Terms',
          '''Booking Process:
• Bookings are confirmed when payment is processed
• Prices include service fees and applicable taxes
• Cancellation policies vary by service type
• Refunds are processed according to our refund policy

Payment:
• All payments are processed securely through PayStack
• We accept major payment methods available in Ghana
• Service fees are clearly displayed before booking
• You authorize us to charge your selected payment method''',
        ),

        _buildSection(
          '7. Cancellation and Refund Policy',
          '''Customer Cancellations:
• Free cancellation up to 24 hours before service
• 50% refund for cancellations 2-24 hours before service
• No refund for cancellations within 2 hours of service
• Emergency cancellations are handled case-by-case

Provider Cancellations:
• Full refund if provider cancels
• We will help find an alternative provider when possible
• Compensation may be provided for inconvenience''',
        ),

        _buildSection(
          '8. Quality Assurance and Disputes',
          '''We strive to ensure service quality through:

• Provider background checks and verification
• Customer feedback and rating systems
• Regular quality monitoring
• Responsive customer support

For disputes:
• Contact customer support within 48 hours
• We facilitate resolution between parties
• Refunds or credits may be issued for unsatisfactory service
• Serious issues may result in provider suspension''',
        ),

        _buildSection(
          '9. Location Services and Privacy',
          '''Our app uses location services to:

• Find nearby service providers
• Enable real-time service tracking
• Calculate accurate pricing and travel times
• Improve service recommendations

Location data is handled according to our Privacy Policy and Ghana's Data Protection Act.''',
        ),

        _buildSection(
          '10. Prohibited Activities',
          '''You may not:

• Use the Service for illegal activities
• Harass, threaten, or discriminate against others
• Provide false information or impersonate others
• Attempt to bypass security measures
• Use automated systems to access the Service
• Violate intellectual property rights
• Interfere with the Service's operation
• Engage in fraudulent activities''',
        ),

        _buildSection(
          '11. Intellectual Property',
          '''HomeLinkGH and its content are protected by:

• Trademark and copyright laws
• Trade secret protection
• Other intellectual property rights

You may not:
• Copy, modify, or distribute our content
• Use our trademarks without permission
• Reverse engineer our technology
• Create derivative works''',
        ),

        _buildSection(
          '12. Limitation of Liability',
          '''To the extent permitted by Ghanaian law:

• We provide the Service "as is" without warranties
• We are not liable for actions of service providers
• Our liability is limited to the amount paid for services
• We are not responsible for indirect or consequential damages
• Nothing limits liability for death, personal injury, or fraud''',
        ),

        _buildSection(
          '13. Indemnification',
          '''You agree to indemnify HomeLinkGH against:

• Claims arising from your use of the Service
• Violations of these Terms
• Infringement of third-party rights
• Your negligent or wrongful conduct

This includes legal fees and damages incurred.''',
        ),

        _buildSection(
          '14. Ghana-Specific Provisions',
          '''These Terms are governed by:

• The laws of the Republic of Ghana
• Ghana's Electronic Transactions Act, 2008
• Consumer protection laws in Ghana
• Data Protection Act, 2012

Disputes will be resolved in Ghana's courts or through arbitration as agreed.''',
        ),

        _buildSection(
          '15. Diaspora Services',
          '''For our diaspora community:

• Services can be booked from anywhere in the world
• Payment is processed in Ghana Cedis (GHS)
• International transaction fees may apply
• Communication may span different time zones
• We provide extra verification for overseas bookings''',
        ),

        _buildSection(
          '16. Termination',
          '''We may terminate or suspend your account for:

• Violation of these Terms
• Fraudulent or illegal activity
• Non-payment for services
• Abuse of the platform or other users

You may terminate your account at any time through the app settings.''',
        ),

        _buildSection(
          '17. Changes to Terms',
          '''We may update these Terms to reflect:

• Changes in our services
• Legal or regulatory requirements
• Industry best practices

We will notify you of significant changes and your continued use constitutes acceptance.''',
        ),

        _buildSection(
          '18. Contact Information',
          '''For questions about these Terms:

Email: info@homelinkgh.com
Phone: +233 XX XXX XXXX
Address: [Company Address], Accra, Ghana

Customer Support: support@homelinkgh.com
Business Hours: Monday-Friday, 8:00 AM - 6:00 PM GMT''',
        ),

        _buildSection(
          '19. Severability',
          '''If any provision of these Terms is found invalid or unenforceable, the remaining provisions will continue in full force and effect.''',
        ),

        _buildSection(
          '20. Entire Agreement',
          '''These Terms, together with our Privacy Policy, constitute the entire agreement between you and HomeLinkGH regarding the Service.''',
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
            'Welcome to HomeLinkGH',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'By using our platform, you join a community dedicated to connecting Ghana\'s diaspora with trusted home services. We appreciate your trust and look forward to serving you.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            '🇬🇭 Akwaba! Welcome to HomeLinkGH',
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

  void _shareTermsOfService() {
    const termsText = '''HomeLinkGH Terms of Service

These terms govern your use of HomeLinkGH services. By using our platform, you agree to these terms and conditions.

Key Points:
• Platform connects customers with verified service providers
• Secure payment processing through PayStack
• Quality assurance and dispute resolution
• Compliance with Ghana's laws and regulations

For complete terms, please visit our app or website.

Contact: info@homelinkgh.com''';

    Clipboard.setData(const ClipboardData(text: termsText));
  }
}

/// Widget for displaying terms of service summary in onboarding or forms
class TermsOfServiceSummaryWidget extends StatelessWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onViewFull;

  const TermsOfServiceSummaryWidget({
    super.key,
    this.onAccept,
    this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'By using HomeLinkGH, you agree to our terms. Key highlights:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Platform connects customers with verified providers\n'
            '• Secure payments processed through PayStack\n'
            '• Quality assurance and customer support included\n'
            '• Cancellation and refund policies apply\n'
            '• Governed by Ghana\'s laws and regulations',
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
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  );
                },
                child: const Text('View Full Terms'),
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

/// Combined widget for both privacy policy and terms of service acceptance
class LegalDocumentsAcceptanceWidget extends StatefulWidget {
  final VoidCallback? onAcceptAll;

  const LegalDocumentsAcceptanceWidget({
    super.key,
    this.onAcceptAll,
  });

  @override
  State<LegalDocumentsAcceptanceWidget> createState() => _LegalDocumentsAcceptanceWidgetState();
}

class _LegalDocumentsAcceptanceWidgetState extends State<LegalDocumentsAcceptanceWidget> {
  bool _acceptedPrivacy = false;
  bool _acceptedTerms = false;

  bool get _allAccepted => _acceptedPrivacy && _acceptedTerms;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review and accept our legal documents to continue:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('I have read and accept the Privacy Policy'),
            value: _acceptedPrivacy,
            activeColor: const Color(0xFF006B3C),
            onChanged: (value) {
              setState(() => _acceptedPrivacy = value ?? false);
            },
            secondary: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
              child: const Text('Read'),
            ),
          ),
          
          CheckboxListTile(
            title: const Text('Terms of Service'),
            subtitle: const Text('I have read and accept the Terms of Service'),
            value: _acceptedTerms,
            activeColor: const Color(0xFF006B3C),
            onChanged: (value) {
              setState(() => _acceptedTerms = value ?? false);
            },
            secondary: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
              child: const Text('Read'),
            ),
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _allAccepted ? widget.onAcceptAll : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _allAccepted ? 'Continue' : 'Please accept both documents',
              ),
            ),
          ),
        ],
      ),
    );
  }
}