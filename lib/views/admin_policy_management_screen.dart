import 'package:flutter/material.dart';

class AdminPolicyManagementScreen extends StatefulWidget {
  const AdminPolicyManagementScreen({super.key});

  @override
  State<AdminPolicyManagementScreen> createState() => _AdminPolicyManagementScreenState();
}

class _AdminPolicyManagementScreenState extends State<AdminPolicyManagementScreen> {
  final List<Map<String, dynamic>> _policies = [
    {
      'id': '1',
      'title': 'Privacy Policy',
      'description': 'How we collect, use, and protect user data',
      'lastUpdated': '2024-07-15',
      'status': 'Active',
      'version': '2.1',
      'category': 'Legal',
      'isRequired': true,
      'content': '''HomeLinkGH Privacy Policy

Last Updated: July 15, 2024

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, book services, or contact us for support.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Contact Us
If you have any questions about this Privacy Policy, please contact us at privacy@homelinkgh.com.''',
    },
    {
      'id': '2',
      'title': 'Terms of Service',
      'description': 'Platform usage rules and user agreements',
      'lastUpdated': '2024-07-10',
      'status': 'Active',
      'version': '3.0',
      'category': 'Legal',
      'isRequired': true,
      'content': '''HomeLinkGH Terms of Service

Last Updated: July 10, 2024

1. Acceptance of Terms
By accessing and using HomeLinkGH, you accept and agree to be bound by the terms and provision of this agreement.

2. Service Description
HomeLinkGH is a platform that connects customers with service providers for various home and lifestyle services.

3. User Responsibilities
Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.

4. Service Provider Requirements
Service providers must be verified, licensed (where applicable), and maintain professional standards when providing services.

5. Payment Terms
All payments are processed securely through our platform. Service fees and commissions are clearly outlined before booking.

6. Cancellation and Refund Policy
Cancellations and refunds are subject to the terms outlined in our cancellation policy.

7. Contact Information
For questions regarding these terms, contact us at legal@homelinkgh.com.''',
    },
    {
      'id': '3',
      'title': 'Service Provider Guidelines',
      'description': 'Standards and requirements for service providers',
      'lastUpdated': '2024-07-08',
      'status': 'Active',
      'version': '1.5',
      'category': 'Operations',
      'isRequired': false,
      'content': '''HomeLinkGH Service Provider Guidelines

1. Professional Standards
- Arrive on time for scheduled appointments
- Maintain professional appearance and demeanor
- Communicate clearly with customers
- Complete work to agreed specifications

2. Safety Requirements
- Follow all safety protocols
- Use appropriate safety equipment
- Report any safety incidents immediately
- Maintain insurance coverage

3. Quality Assurance
- Deliver high-quality services
- Use appropriate tools and materials
- Clean up work areas after completion
- Address customer concerns promptly

4. Platform Usage
- Keep profile information updated
- Respond to booking requests within 24 hours
- Update job status in real-time
- Maintain a minimum rating of 4.0 stars''',
    },
    {
      'id': '4',
      'title': 'Customer Code of Conduct',
      'description': 'Expected behavior and guidelines for customers',
      'lastUpdated': '2024-07-05',
      'status': 'Draft',
      'version': '1.0',
      'category': 'Operations',
      'isRequired': false,
      'content': '''HomeLinkGH Customer Code of Conduct

1. Respectful Communication
- Treat all service providers with respect and courtesy
- Communicate clearly about service requirements
- Provide feedback constructively

2. Property Access
- Ensure safe access to work areas
- Secure valuable items before service arrival
- Provide accurate location information

3. Payment Obligations
- Pay for services as agreed
- Report any payment issues promptly
- Follow platform payment procedures

4. Safety Considerations
- Ensure pets are secured during service visits
- Inform providers of any safety hazards
- Report safety concerns immediately''',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Management'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewPolicy,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _policies.length,
        itemBuilder: (context, index) {
          final policy = _policies[index];
          return _buildPolicyCard(policy, index);
        },
      ),
    );
  }

  Widget _buildPolicyCard(Map<String, dynamic> policy, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        policy['description'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(policy['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    policy['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Policy details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Category',
                    policy['category'],
                    _getCategoryIcon(policy['category']),
                    _getCategoryColor(policy['category']),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Version',
                    'v${policy['version']}',
                    Icons.numbers,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Updated',
                    policy['lastUpdated'],
                    Icons.calendar_today,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Required badge
            if (policy['isRequired'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.red, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Required for all users',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _previewPolicy(policy),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Preview'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _editPolicy(policy, index),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (policy['status'] == 'Draft')
                  ElevatedButton.icon(
                    onPressed: () => _publishPolicy(policy, index),
                    icon: const Icon(Icons.publish),
                    label: const Text('Publish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => _archivePolicy(policy, index),
                    icon: const Icon(Icons.archive),
                    color: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Draft':
        return Colors.orange;
      case 'Archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Legal':
        return Icons.gavel;
      case 'Operations':
        return Icons.business;
      case 'Safety':
        return Icons.security;
      default:
        return Icons.description;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Legal':
        return Colors.red;
      case 'Operations':
        return Colors.blue;
      case 'Safety':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _createNewPolicy() {
    _showPolicyEditor(isNew: true);
  }

  void _editPolicy(Map<String, dynamic> policy, int index) {
    _showPolicyEditor(policy: policy, index: index);
  }

  void _showPolicyEditor({Map<String, dynamic>? policy, int? index, bool isNew = false}) {
    final titleController = TextEditingController(text: policy?['title'] ?? '');
    final descController = TextEditingController(text: policy?['description'] ?? '');
    final contentController = TextEditingController(text: policy?['content'] ?? '');
    
    String selectedCategory = policy?['category'] ?? 'Operations';
    bool isRequired = policy?['isRequired'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isNew ? 'Create New Policy' : 'Edit Policy'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Policy Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Legal', 'Operations', 'Safety']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Required for all users'),
                    value: isRequired,
                    onChanged: (value) {
                      setDialogState(() {
                        isRequired = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Policy Content',
                      border: OutlineInputBorder(),
                      hintText: 'Enter the full policy text here...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPolicy = {
                  'id': policy?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text,
                  'description': descController.text,
                  'content': contentController.text,
                  'category': selectedCategory,
                  'isRequired': isRequired,
                  'status': 'Draft',
                  'version': policy?['version'] ?? '1.0',
                  'lastUpdated': DateTime.now().toString().substring(0, 10),
                };

                setState(() {
                  if (isNew) {
                    _policies.add(newPolicy);
                  } else if (index != null) {
                    _policies[index] = newPolicy;
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isNew ? 'Policy created successfully' : 'Policy updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
              child: Text(isNew ? 'Create' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _previewPolicy(Map<String, dynamic> policy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(policy['title']),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version: ${policy['version']} | Last Updated: ${policy['lastUpdated']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Divider(height: 20),
                Text(
                  policy['content'],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
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

  void _publishPolicy(Map<String, dynamic> policy, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Policy'),
        content: Text('Are you sure you want to publish "${policy['title']}"? This will make it active for all users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _policies[index]['status'] = 'Active';
                _policies[index]['lastUpdated'] = DateTime.now().toString().substring(0, 10);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${policy['title']} published successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Publish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _archivePolicy(Map<String, dynamic> policy, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Policy'),
        content: Text('Are you sure you want to archive "${policy['title']}"? Users will no longer see this policy.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _policies[index]['status'] = 'Archived';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${policy['title']} archived'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}