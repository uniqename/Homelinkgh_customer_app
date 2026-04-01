import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HomeLinkGH Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: December 20, 2024',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              '1. Information We Collect',
              'Personal Information:\n'
              '• Name, email address, phone number\n'
              '• Government-issued ID for verification\n'
              '• Location data for service delivery\n'
              '• Payment information (securely processed)\n'
              '• Profile photos and service images\n'
              '• Communication records with providers/customers',
            ),
            
            _buildSection(
              '2. How We Use Your Information',
              'We use your data to:\n'
              '• Facilitate service bookings and payments\n'
              '• Verify provider identities and backgrounds\n'
              '• Provide customer support and resolve disputes\n'
              '• Improve our platform and services\n'
              '• Send important updates and notifications\n'
              '• Comply with legal and regulatory requirements',
            ),
            
            _buildSection(
              '3. Data Sharing & Disclosure',
              'We share information only when:\n'
              '• Necessary to complete service bookings\n'
              '• Required by law or legal process\n'
              '• With trusted service providers (payment processors)\n'
              '• With user consent for specific purposes\n'
              '• To protect safety and prevent fraud\n'
              '• During business transfers (with notice)',
            ),
            
            _buildSection(
              '4. International Data Transfers',
              'Diaspora Data Protection:\n'
              '• Data may be transferred between Ghana and diaspora countries\n'
              '• GDPR compliance for EU users\n'
              '• Adequate protection measures in place\n'
              '• User consent for international transfers\n'
              '• Local data protection laws respected',
            ),
            
            _buildSection(
              '5. Data Security',
              'Security Measures:\n'
              '• End-to-end encryption for sensitive data\n'
              '• Secure cloud storage with regular backups\n'
              '• Two-factor authentication options\n'
              '• Regular security audits and monitoring\n'
              '• PCI DSS compliance for payments\n'
              '• Staff training on data protection',
            ),
            
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n'
              '• Access your personal data\n'
              '• Correct inaccurate information\n'
              '• Delete your account and data\n'
              '• Export your data in portable format\n'
              '• Restrict processing in certain circumstances\n'
              '• Object to automated decision-making',
            ),
            
            _buildSection(
              '7. Data Retention',
              'We keep your data for:\n'
              '• Active accounts: As long as account exists\n'
              '• Transaction records: 7 years for tax compliance\n'
              '• Verification documents: 5 years after account closure\n'
              '• Communication logs: 2 years\n'
              '• Marketing data: Until you opt out\n'
              '• Legal holds: As required by law',
            ),
            
            _buildSection(
              '8. Cookies & Tracking',
              'We use:\n'
              '• Essential cookies for platform functionality\n'
              '• Analytics cookies to improve user experience\n'
              '• Preference cookies to remember your settings\n'
              '• You can control cookies in your browser\n'
              '• Third-party analytics (Google Analytics)\n'
              '• Location tracking for service delivery',
            ),
            
            _buildSection(
              '9. Children\'s Privacy',
              'Platform Restrictions:\n'
              '• HomeLinkGH is not intended for users under 18\n'
              '• We do not knowingly collect data from minors\n'
              '• Parents/guardians must supervise any use\n'
              '• Special protection for sensitive services\n'
              '• Age verification required for all users',
            ),
            
            _buildSection(
              '10. Ghana Data Protection Compliance',
              'Local Law Compliance:\n'
              '• Ghana Data Protection Act 2012 compliance\n'
              '• Data Protection Commission registration\n'
              '• Local data subject rights respected\n'
              '• Cross-border transfer safeguards\n'
              '• Breach notification procedures\n'
              '• Regular compliance audits',
            ),
            
            _buildSection(
              '11. Contact for Privacy Matters',
              'Data Protection Officer:\n'
              '• Email: privacy@homelink.gh\n'
              '• Phone: +233 (0) 30 123 4567\n'
              '• Address: HomeLinkGH, Accra, Ghana\n'
              '• Response time: 30 days maximum\n'
              '• Escalation to Data Protection Commission available',
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛡️ Your Privacy Matters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'HomeLinkGH is committed to protecting your privacy and giving you control over your personal information. Contact us anytime with questions or concerns.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}