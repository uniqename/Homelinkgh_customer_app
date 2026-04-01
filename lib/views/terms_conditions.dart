import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  final bool isSignup;
  final Function(bool)? onAccept;
  
  const TermsConditionsScreen({
    super.key, 
    this.isSignup = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HomeLinkGH Terms & Conditions',
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
                    '1. Acceptance of Terms',
                    'By accessing and using HomeLinkGH ("the Platform"), you accept and agree to be bound by the terms and provision of this agreement. HomeLinkGH is a platform connecting service providers with customers in Ghana and the diaspora community.',
                  ),
                  
                  _buildSection(
                    '2. Service Description',
                    'HomeLinkGH operates as an intermediary platform that:\n'
                    '• Connects customers with verified service providers\n'
                    '• Facilitates secure payments and transactions\n'
                    '• Provides customer support and dispute resolution\n'
                    '• Maintains quality standards through ratings and reviews\n'
                    '• Serves Ghana\'s diaspora community globally',
                  ),
                  
                  _buildSection(
                    '3. User Eligibility',
                    'To use HomeLinkGH, you must:\n'
                    '• Be at least 18 years old\n'
                    '• Provide accurate and truthful information\n'
                    '• Have legal capacity to enter into contracts\n'
                    '• Comply with all applicable laws in your jurisdiction\n'
                    '• For providers: Pass background checks and verification',
                  ),
                  
                  _buildSection(
                    '4. Provider Verification',
                    'All service providers must:\n'
                    '• Complete identity verification with valid ID\n'
                    '• Undergo background checks where applicable\n'
                    '• Provide proof of skills/certifications for specialized services\n'
                    '• Maintain current insurance coverage\n'
                    '• Complete diaspora cultural sensitivity training',
                  ),
                  
                  _buildSection(
                    '5. Payment Terms',
                    'Payment Structure:\n'
                    '• Platform commission: 15% of service fee\n'
                    '• Tax collection: 5% (remitted to Ghana Revenue Authority)\n'
                    '• Payment processing fees apply\n'
                    '• Refunds processed within 5-7 business days\n'
                    '• International payments subject to currency conversion',
                  ),
                  
                  _buildSection(
                    '6. Liability and Insurance',
                    'HomeLinkGH provides:\n'
                    '• Basic liability coverage up to ₵10,000 per incident\n'
                    '• Provider insurance verification\n'
                    '• Dispute resolution services\n'
                    '• Users are encouraged to maintain additional insurance\n'
                    '• Platform liability limited to service fees paid',
                  ),
                  
                  _buildSection(
                    '7. Prohibited Activities',
                    'Users may not:\n'
                    '• Engage in fraudulent or illegal activities\n'
                    '• Circumvent platform payment systems\n'
                    '• Discriminate based on race, religion, or nationality\n'
                    '• Share false or misleading information\n'
                    '• Use platform for purposes other than intended services',
                  ),
                  
                  _buildSection(
                    '8. Data Protection & Privacy',
                    'HomeLinkGH is committed to protecting your privacy:\n'
                    '• Data processed in accordance with Ghana Data Protection Act\n'
                    '• International transfers comply with GDPR where applicable\n'
                    '• Users can request data export or deletion\n'
                    '• See our Privacy Policy for detailed information',
                  ),
                  
                  _buildSection(
                    '9. Dispute Resolution',
                    'Disputes are resolved through:\n'
                    '• In-app mediation system\n'
                    '• Customer support intervention\n'
                    '• Third-party arbitration if necessary\n'
                    '• Escalation to Ghana courts as final resort\n'
                    '• Refund protection for qualifying disputes',
                  ),
                  
                  _buildSection(
                    '10. Platform Fees & Taxes',
                    'Fee Structure:\n'
                    '• Service commission: 15% of total booking\n'
                    '• Payment processing: 2.5% for cards, ₵5 for mobile money\n'
                    '• International transfer: ₵15 flat fee\n'
                    '• VAT: Applied according to Ghana tax laws\n'
                    '• Provider earnings subject to local tax obligations',
                  ),
                  
                  _buildSection(
                    '11. Service Standards',
                    'Quality Assurance:\n'
                    '• Minimum 4.0-star rating required for active providers\n'
                    '• Regular quality audits and mystery shopping\n'
                    '• Customer satisfaction guarantees\n'
                    '• Cultural sensitivity standards for diaspora services\n'
                    '• Timely service delivery requirements',
                  ),
                  
                  _buildSection(
                    '12. Intellectual Property',
                    'HomeLinkGH owns all platform intellectual property including:\n'
                    '• Trademarks, logos, and branding\n'
                    '• Software, algorithms, and technology\n'
                    '• Content, designs, and user interfaces\n'
                    '• Users grant license to use content they submit',
                  ),
                  
                  _buildSection(
                    '13. Governing Law',
                    'These terms are governed by:\n'
                    '• Laws of the Republic of Ghana\n'
                    '• Ghana Courts have exclusive jurisdiction\n'
                    '• International users subject to local consumer protection laws\n'
                    '• Disputes resolved per Ghana Alternative Dispute Resolution Act',
                  ),
                  
                  _buildSection(
                    '14. Changes to Terms',
                    'HomeLinkGH reserves the right to modify these terms:\n'
                    '• Users notified 30 days before changes take effect\n'
                    '• Continued use constitutes acceptance\n'
                    '• Material changes require explicit re-acceptance\n'
                    '• Users may terminate account if they disagree with changes',
                  ),
                  
                  _buildSection(
                    '15. Contact Information',
                    'For questions about these terms:\n'
                    '• Email: legal@homelink.gh\n'
                    '• Phone: +233 (0) 30 123 4567\n'
                    '• Address: Accra, Ghana\n'
                    '• Customer Support: Available 24/7 in-app',
                  ),
                  
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF006B3C)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ Important Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006B3C),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'By using HomeLinkGH, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use our platform.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Accept Terms Button (for signup flow)
          if (isSignup && onAccept != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        activeColor: const Color(0xFF006B3C),
                        onChanged: (value) => onAccept!(value ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'I have read and agree to the Terms & Conditions and Privacy Policy',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
        ],
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