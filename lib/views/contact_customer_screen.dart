import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactCustomerScreen extends StatelessWidget {
  final Map<String, dynamic> customerData;
  
  const ContactCustomerScreen({
    super.key,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact ${customerData['customer']}'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF006B3C),
                          child: Text(
                            customerData['customer'][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerData['customer'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.8 rating',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Service', customerData['service']),
                    _buildInfoRow('Date & Time', '${customerData['date']} at ${customerData['time']}'),
                    _buildInfoRow('Location', customerData['location']),
                    _buildInfoRow('Status', customerData['status']),
                    
                    // Service-specific details
                    if (_isLaundryService(customerData['service'])) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Laundry Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Pickup Location', customerData['pickupLocation'] ?? 'Main building entrance'),
                      _buildInfoRow('Dropoff Location', customerData['dropoffLocation'] ?? 'Same as pickup'),
                      _buildInfoRow('Laundry Type', customerData['laundryType'] ?? 'Mixed clothes'),
                      _buildInfoRow('Special Instructions', customerData['specialInstructions'] ?? 'Handle with care'),
                      _buildInfoRow('Estimated Items', customerData['itemCount'] ?? '15-20 pieces'),
                    ] else if (_isBeautyService(customerData['service'])) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Beauty Service Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Service Location', customerData['serviceLocation'] ?? 'Customer\'s home'),
                      _buildInfoRow('Number of People', customerData['numberOfPeople'] ?? '1 person'),
                      _buildInfoRow('Occasion', customerData['occasion'] ?? 'Regular styling'),
                      _buildInfoRow('Duration', customerData['estimatedDuration'] ?? '1-2 hours'),
                      _buildInfoRow('Special Requests', customerData['beautyRequests'] ?? 'None specified'),
                    ] else if (_isPlumbingOrElectrical(customerData['service'])) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Technical Service Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Room/Area', customerData['room'] ?? 'Kitchen'),
                      _buildInfoRow('Problem Description', customerData['problemDescription'] ?? 'Repair needed'),
                      _buildInfoRow('Urgency Level', customerData['urgency'] ?? 'Normal'),
                      _buildInfoRow('House Type', customerData['houseType'] ?? 'Residential'),
                      _buildInfoRow('Access Requirements', customerData['accessRequirements'] ?? 'Standard access'),
                    ] else if (_isCleaningService(customerData['service'])) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Cleaning Service Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('House Size', customerData['houseSize'] ?? '3 bedrooms'),
                      _buildInfoRow('Areas to Clean', customerData['areasToClean'] ?? 'All rooms'),
                      _buildInfoRow('Cleaning Type', customerData['cleaningType'] ?? 'Deep cleaning'),
                      _buildInfoRow('Supplies Provided', customerData['suppliesProvided'] ?? 'Customer provides'),
                      _buildInfoRow('Special Focus', customerData['specialFocus'] ?? 'Kitchen & bathrooms'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contact Options
            const Text(
              'Contact Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Call Button
            _buildContactButton(
              context,
              'Call Customer',
              Icons.phone,
              Colors.green,
              () => _makePhoneCall('+233541234567'), // Mock phone number
            ),
            
            const SizedBox(height: 12),
            
            // SMS Button
            _buildContactButton(
              context,
              'Send SMS',
              Icons.sms,
              Colors.blue,
              () => _sendSMS('+233541234567'),
            ),
            
            const SizedBox(height: 12),
            
            // WhatsApp Button
            _buildContactButton(
              context,
              'WhatsApp Message',
              Icons.message,
              const Color(0xFF25D366),
              () => _sendWhatsApp('+233541234567'),
            ),
            
            const SizedBox(height: 12),
            
            // In-App Chat Button
            _buildContactButton(
              context,
              'In-App Chat',
              Icons.chat,
              const Color(0xFF006B3C),
              () => _openInAppChat(context),
            ),
            
            const SizedBox(height: 20),
            
            // Quick Templates
            const Text(
              'Quick Message Templates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: ListView(
                children: [
                  _buildTemplateCard(
                    'Running Late',
                    'Hi ${customerData['customer']}, I\'m running about 15 minutes late due to traffic. I\'ll be there soon. Thank you for your patience!',
                    context,
                  ),
                  _buildTemplateCard(
                    'Arrival Confirmation',
                    'Hello ${customerData['customer']}, I\'ve arrived at your location for the ${customerData['service']} service. Please let me know when you\'re ready.',
                    context,
                  ),
                  _buildTemplateCard(
                    'Service Completion',
                    'Hi ${customerData['customer']}, I\'ve completed the ${customerData['service']} service. Please check and let me know if you need anything else. Thank you!',
                    context,
                  ),
                  _buildTemplateCard(
                    'Additional Requirements',
                    'Hello ${customerData['customer']}, I noticed some additional work might be needed. Can we discuss this? I want to ensure you get the best service.',
                    context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTemplateCard(String title, String message, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message copied to clipboard')),
                        );
                      },
                      child: const Text('Copy'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendTemplate(message),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Send'),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    await launchUrl(launchUri);
  }

  void _openInAppChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _InAppChatScreen(
          customerName: customerData['customer'],
        ),
      ),
    );
  }

  void _sendTemplate(String message) {
    // This would send the template message via the selected method
    debugPrint('Sending template: $message');
  }

  // Helper methods to detect service types
  bool _isLaundryService(String service) {
    return service.toLowerCase().contains('laundry');
  }

  bool _isBeautyService(String service) {
    return service.toLowerCase().contains('beauty') ||
           service.toLowerCase().contains('makeup') ||
           service.toLowerCase().contains('nail') ||
           service.toLowerCase().contains('hair');
  }

  bool _isPlumbingOrElectrical(String service) {
    return service.toLowerCase().contains('plumbing') ||
           service.toLowerCase().contains('electrical') ||
           service.toLowerCase().contains('hvac') ||
           service.toLowerCase().contains('ac repair') ||
           service.toLowerCase().contains('generator');
  }

  bool _isCleaningService(String service) {
    return service.toLowerCase().contains('cleaning');
  }
}

class _InAppChatScreen extends StatefulWidget {
  final String customerName;
  
  const _InAppChatScreen({required this.customerName});

  @override
  State<_InAppChatScreen> createState() => __InAppChatScreenState();
}

class __InAppChatScreenState extends State<_InAppChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'message': 'Hello! I\'m your service provider for today\'s appointment.',
      'isProvider': true,
      'timestamp': '10:30 AM',
    },
    {
      'message': 'Great! I\'ll be ready. What time should I expect you?',
      'isProvider': false,
      'timestamp': '10:32 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.customerName}'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _makePhoneCall('+233541234567'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF006B3C),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isProvider = message['isProvider'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isProvider ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isProvider ? const Color(0xFF006B3C) : Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message['message'],
                  style: TextStyle(
                    color: isProvider ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['timestamp'],
                  style: TextStyle(
                    color: isProvider ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'message': _messageController.text.trim(),
          'isProvider': true,
          'timestamp': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
      });
      _messageController.clear();
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}