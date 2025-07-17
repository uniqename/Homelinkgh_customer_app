import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  String selectedIssue = 'Payment Issue';

  final List<String> issueTypes = [
    'Payment Issue',
    'Service Quality',
    'Provider No-Show',
    'Billing Dispute',
    'Account Problem',
    'Technical Issue',
    'Safety Concern',
    'Refund Request',
    'Other',
  ];

  final List<Map<String, dynamic>> faqs = [
    {
      'question': 'How do I get a refund for a cancelled service?',
      'answer': 'Refunds are processed automatically for cancellations made 2+ hours before service time. For other cases, contact support within 24 hours. Refunds typically take 3-5 business days.',
    },
    {
      'question': 'What if my provider doesn\'t show up?',
      'answer': 'You\'ll receive automatic compensation if a provider is more than 30 minutes late without notice. We\'ll also help rebook your service with another provider at no extra cost.',
    },
    {
      'question': 'How are providers verified?',
      'answer': 'All providers undergo ID verification, background checks, skill assessment, and diaspora cultural sensitivity training. They must maintain a 4.0+ star rating.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept Mobile Money (MTN, Vodafone, AirtelTigo), bank cards, international transfers, and digital wallets. Payment is secure and processed only after service completion.',
    },
    {
      'question': 'Can I book services from abroad?',
      'answer': 'Yes! Our "Book Before You Land" feature allows diaspora users to schedule services for their arrival in Ghana. We accept international payments in USD, GBP, EUR, and CAD.',
    },
    {
      'question': 'What\'s covered by insurance?',
      'answer': 'Basic liability coverage up to ₵10,000 per incident. This covers property damage and injuries during service provision. Additional insurance recommended for high-value items.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _showEmergencyContact(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Support Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006B3C), Color(0xFF228B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.support_agent,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'We\'re Here to Help! 🇬🇭',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '24/7 Support for Ghana\'s Diaspora',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction('WhatsApp', Icons.message, () => _openWhatsApp()),
                    _buildQuickAction('Call Us', Icons.phone, () => _makeCall()),
                    _buildQuickAction('Live Chat', Icons.chat, () => _openLiveChat()),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Contact Us'),
                Tab(text: 'FAQ'),
                Tab(text: 'Live Chat'),
              ],
              labelColor: const Color(0xFF006B3C),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF006B3C),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContactTab(),
                _buildFAQTab(),
                _buildLiveChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submit a Support Request',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 20),
          
          // Issue Type Selector
          const Text(
            'Issue Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedIssue,
                isExpanded: true,
                items: issueTypes.map((issue) {
                  return DropdownMenuItem(
                    value: issue,
                    child: Text(issue),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIssue = value!;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Message Input
          const Text(
            'Describe Your Issue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Please provide details about your issue...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Priority and Response Time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Column(
              children: [
                Text(
                  '⚡ Expected Response Times',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Emergency/Safety: Immediate (< 5 mins)'),
                Text('• Payment Issues: Within 30 minutes'),
                Text('• Service Problems: Within 2 hours'),
                Text('• General Questions: Within 24 hours'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitSupportRequest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Emergency Contact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 Emergency Support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('For urgent safety or security issues:'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _makeEmergencyCall(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Call Emergency Line'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              faq['question'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  faq['answer'],
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveChatTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Color(0xFF006B3C),
          ),
          const SizedBox(height: 24),
          const Text(
            'Live Chat Coming Soon!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We\'re working on real-time chat support. For now, use WhatsApp or submit a support request.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _openWhatsApp(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.message),
                SizedBox(width: 8),
                Text('Chat on WhatsApp'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitSupportRequest() {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your issue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit to support system
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Submitted'),
        content: const Text(
          'Your support request has been submitted. You\'ll receive a response within the expected timeframe based on your issue priority.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.clear();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp() {
    // Open WhatsApp with pre-filled message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp...'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  void _makeCall() {
    // Make phone call to support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling support line...'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _openLiveChat() {
    _tabController.animateTo(2);
  }

  void _makeEmergencyCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: const Text('This will connect you to our emergency support line immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Make emergency call
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContact() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🚨 Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            _buildEmergencyContact('Police', '199', Icons.local_police),
            _buildEmergencyContact('Fire Service', '192', Icons.local_fire_department),
            _buildEmergencyContact('Ambulance', '193', Icons.local_hospital),
            _buildEmergencyContact('HomeLinkGH Emergency', '+233 30 123 4567', Icons.support_agent),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String title, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
        ],
      ),
    );
  }
}