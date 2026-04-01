import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/dispute_service.dart';

class DisputeResolutionScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingDetails;
  
  const DisputeResolutionScreen({
    super.key,
    required this.bookingId,
    required this.bookingDetails,
  });

  @override
  State<DisputeResolutionScreen> createState() => _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends State<DisputeResolutionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _issueController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String selectedIssueType = 'Service Quality';
  List<String> evidencePhotos = [];
  bool requestRefund = false;
  double? refundAmount;
  
  final List<String> issueTypes = [
    'Service Quality',
    'Provider No-Show',
    'Incomplete Service',
    'Property Damage',
    'Safety Concern',
    'Billing Error',
    'Communication Issue',
    'Late Arrival',
    'Unprofessional Behavior',
    'Other',
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
        title: const Text('Dispute Resolution'),
        backgroundColor: const Color(0xFFCE1126), // Ghana Red for disputes
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showDisputeHelp(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dispute Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCE1126), Color(0xFFE53E3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.report_problem, color: Colors.white, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Dispute Resolution',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking ID: ${widget.bookingId}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Service: ${widget.bookingDetails['service'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⚡ We aim to resolve disputes within 24 hours',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                Tab(text: 'Report Issue'),
                Tab(text: 'Mediation'),
                Tab(text: 'Refund'),
              ],
              labelColor: const Color(0xFFCE1126),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFCE1126),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportIssueTab(),
                _buildMediationTab(),
                _buildRefundTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportIssueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What went wrong?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
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
                value: selectedIssueType,
                isExpanded: true,
                items: issueTypes.map((issue) {
                  return DropdownMenuItem(
                    value: issue,
                    child: Row(
                      children: [
                        _getIssueIcon(issue),
                        const SizedBox(width: 8),
                        Text(issue),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIssueType = value!;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Issue Description
          const Text(
            'Describe the Issue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _issueController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Please provide detailed information about what happened...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Evidence Photos
          const Text(
            'Evidence Photos (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add Photo Button
                GestureDetector(
                  onTap: () => _addEvidencePhoto(),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                        SizedBox(height: 4),
                        Text('Add Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                
                // Evidence Photos
                ...evidencePhotos.map((photo) => Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.photo, size: 40, color: Colors.green),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(photo),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Refund Request Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: requestRefund,
                      activeColor: const Color(0xFF006B3C),
                      onChanged: (value) {
                        setState(() {
                          requestRefund = value ?? false;
                          if (requestRefund) {
                            refundAmount = double.tryParse(widget.bookingDetails['amount']?.toString() ?? '0');
                          }
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I am requesting a refund for this service',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (requestRefund) ...[
                  const SizedBox(height: 8),
                  const Text('Refund Amount:'),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: refundAmount?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '₵ ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      refundAmount = double.tryParse(value);
                    },
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitDispute(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE1126),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit Dispute',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Process Info
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
                  '📋 What Happens Next?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text('1. Your dispute is reviewed within 2 hours'),
                Text('2. Provider is contacted for their response'),
                Text('3. Mediation begins if needed (24-48 hours)'),
                Text('4. Resolution decision within 72 hours'),
                Text('5. Refunds processed within 3-5 business days'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mediation Process',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          // Mediation Steps
          _buildMediationStep(
            1,
            'Initial Review',
            'HomeLinkGH reviews your dispute and evidence',
            true,
            Icons.assignment,
          ),
          _buildMediationStep(
            2,
            'Provider Response',
            'Provider has 24 hours to respond with their side',
            false,
            Icons.reply,
          ),
          _buildMediationStep(
            3,
            'Investigation',
            'We investigate with additional evidence if needed',
            false,
            Icons.search,
          ),
          _buildMediationStep(
            4,
            'Resolution',
            'Final decision and any refunds processed',
            false,
            Icons.gavel,
          ),
          
          const SizedBox(height: 24),
          
          // Current Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⏱️ Current Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text('Your dispute is being reviewed by our mediation team.'),
                SizedBox(height: 8),
                Text('Expected response: Within 2 hours'),
                Text('Case ID: DIS-2024-001234'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Communication Log
          const Text(
            'Communication History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCommunicationItem(
            'You',
            'Dispute submitted with evidence photos',
            '2 hours ago',
            Colors.blue,
          ),
          _buildCommunicationItem(
            'HomeLinkGH',
            'Dispute received and under review',
            '2 hours ago',
            const Color(0xFF006B3C),
          ),
          _buildCommunicationItem(
            'System',
            'Provider has been notified',
            '1 hour ago',
            Colors.grey,
          ),
          
          const SizedBox(height: 24),
          
          // Add Message
          const Text(
            'Add Additional Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any additional details...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _addMessage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Refund Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          // Refund Eligibility
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Refund Eligible',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Original Amount: ₵${widget.bookingDetails['amount'] ?? '0'}'),
                const Text('Platform Fee: ₵5.00'),
                Text('Refund Amount: ₵${(double.tryParse(widget.bookingDetails['amount']?.toString() ?? '0') ?? 0) - 5}'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Refund Policies
          const Text(
            'Refund Policies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 12),
          _buildRefundPolicy('Service Quality Issues', 'Full refund available', Icons.star),
          _buildRefundPolicy('Provider No-Show', 'Full refund + ₵20 credit', Icons.person_off),
          _buildRefundPolicy('Cancellation (2+ hours)', 'Full refund', Icons.cancel),
          _buildRefundPolicy('Cancellation (<2 hours)', '50% refund', Icons.access_time),
          _buildRefundPolicy('Property Damage', 'Full refund + insurance claim', Icons.warning),
          
          const SizedBox(height: 20),
          
          // Refund Methods
          const Text(
            'Refund Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 12),
          _buildRefundMethod('Mobile Money', '₵2 fee • Instant', Icons.phone_android, Colors.green),
          _buildRefundMethod('Bank Account', 'Free • 3-5 business days', Icons.account_balance, Colors.blue),
          _buildRefundMethod('HomeLinkGH Credit', 'Free • Instant', Icons.account_balance_wallet, const Color(0xFF006B3C)),
          
          const SizedBox(height: 24),
          
          // Processing Times
          Container(
            width: double.infinity,
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
                  '⏰ Refund Processing Times',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Approved disputes: Refund within 24 hours'),
                Text('• Mobile Money: Instant after approval'),
                Text('• Bank transfer: 3-5 business days'),
                Text('• International refunds: 5-7 business days'),
                Text('• Credit to HomeLinkGH wallet: Instant'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIssueIcon(String issueType) {
    switch (issueType) {
      case 'Service Quality':
        return const Icon(Icons.star_border, color: Colors.orange);
      case 'Provider No-Show':
        return const Icon(Icons.person_off, color: Colors.red);
      case 'Property Damage':
        return const Icon(Icons.warning, color: Colors.red);
      case 'Safety Concern':
        return const Icon(Icons.security, color: Colors.red);
      case 'Late Arrival':
        return const Icon(Icons.access_time, color: Colors.orange);
      default:
        return const Icon(Icons.report_problem, color: Colors.grey);
    }
  }

  Widget _buildMediationStep(int step, String title, String description, bool isActive, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF006B3C) : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$step. $title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF006B3C) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationItem(String sender, String message, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundPolicy(String policy, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006B3C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundMethod(String method, String details, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  details,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addEvidencePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        evidencePhotos.add(image.path);
      });
    }
  }

  void _removePhoto(String photo) {
    setState(() {
      evidencePhotos.remove(photo);
    });
  }

  void _submitDispute() async {
    if (_issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the issue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit dispute
    final dispute = await DisputeService.submitDispute(
      bookingId: widget.bookingId,
      issueType: selectedIssueType,
      description: _issueController.text,
      evidencePhotos: evidencePhotos,
      requestRefund: requestRefund,
      refundAmount: refundAmount,
    );

    if (dispute['success']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dispute Submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text('Your dispute has been submitted successfully.'),
              const SizedBox(height: 8),
              Text('Case ID: ${dispute['caseId']}'),
              const SizedBox(height: 8),
              const Text('We\'ll review and respond within 2 hours.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _tabController.animateTo(1); // Switch to mediation tab
              },
              child: const Text('Track Progress'),
            ),
          ],
        ),
      );
    }
  }

  void _addMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent to mediation team'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _showDisputeHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Dispute Resolution Help',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    Text(
                      'How Dispute Resolution Works',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Submit your dispute with evidence'),
                    Text('2. Provider responds within 24 hours'),
                    Text('3. HomeLinkGH mediates fairly'),
                    Text('4. Resolution within 72 hours'),
                    Text('5. Refunds processed quickly'),
                    SizedBox(height: 16),
                    Text(
                      'Tips for Better Resolution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Provide clear photos as evidence'),
                    Text('• Be specific about what went wrong'),
                    Text('• Include timestamps if relevant'),
                    Text('• Remain professional in communication'),
                    Text('• Respond promptly to requests for info'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}