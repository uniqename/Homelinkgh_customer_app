import 'package:flutter/material.dart';

class AdminPendingApprovalsScreen extends StatefulWidget {
  const AdminPendingApprovalsScreen({super.key});

  @override
  State<AdminPendingApprovalsScreen> createState() => _AdminPendingApprovalsScreenState();
}

class _AdminPendingApprovalsScreenState extends State<AdminPendingApprovalsScreen> {
  final List<Map<String, dynamic>> _pendingApprovals = [
    {
      'id': '1',
      'type': 'Provider Application',
      'name': 'Samuel Adjei',
      'businessName': 'Adjei Electrical Services',
      'service': 'Electrical Services',
      'location': 'Tema, Greater Accra',
      'submittedDate': '2024-07-20',
      'status': 'pending',
      'documents': ['Business License', 'ID Card', 'Certificate'],
      'experience': '5 years',
      'description': 'Professional electrician with 5 years of experience in residential and commercial electrical work.',
    },
    {
      'id': '2',
      'type': 'Provider Application',
      'name': 'Grace Owusu',
      'businessName': 'Grace Beauty Studio',
      'service': 'Beauty Services',
      'location': 'East Legon, Accra',
      'submittedDate': '2024-07-19',
      'status': 'pending',
      'documents': ['Business License', 'ID Card', 'Training Certificate'],
      'experience': '3 years',
      'description': 'Certified makeup artist and hair stylist specializing in bridal makeup and special events.',
    },
    {
      'id': '3',
      'type': 'User Verification',
      'name': 'Michael Asante',
      'businessName': null,
      'service': null,
      'location': 'Kumasi, Ashanti',
      'submittedDate': '2024-07-21',
      'status': 'pending',
      'documents': ['Ghana Card', 'Utility Bill'],
      'experience': null,
      'description': 'Customer account verification for enhanced services.',
    },
    {
      'id': '4',
      'type': 'Provider Application',
      'name': 'Joseph Nkrumah',
      'businessName': 'Clean Pro Services',
      'service': 'Cleaning Services',
      'location': 'Spintex, Accra',
      'submittedDate': '2024-07-18',
      'status': 'pending',
      'documents': ['Business License', 'ID Card'],
      'experience': '2 years',
      'description': 'Professional cleaning service with focus on residential and office cleaning.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Approvals refreshed')),
              );
            },
          ),
        ],
      ),
      body: _pendingApprovals.isEmpty 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Pending Approvals',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'All applications have been processed',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pendingApprovals.length,
            itemBuilder: (context, index) {
              final approval = _pendingApprovals[index];
              return _buildApprovalCard(approval, index);
            },
          ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> approval, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(approval['type']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    approval['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  approval['submittedDate'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Applicant information
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF006B3C),
                  child: Text(
                    approval['name'][0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        approval['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (approval['businessName'] != null)
                        Text(
                          approval['businessName'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            approval['location'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Service and experience (for providers)
            if (approval['service'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.work, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(approval['service']),
                  if (approval['experience'] != null) ...[
                    const Spacer(),
                    Text(
                      '${approval['experience']} experience',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Description
            Text(
              approval['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Documents
            Wrap(
              spacing: 8,
              children: (approval['documents'] as List<String>).map((doc) => 
                Chip(
                  label: Text(
                    doc,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  side: const BorderSide(color: Colors.blue, width: 0.5),
                ),
              ).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewDetails(approval),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _rejectApplication(approval, index),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _approveApplication(approval, index),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Provider Application':
        return Colors.green;
      case 'User Verification':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _viewDetails(Map<String, dynamic> approval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${approval['name']} - Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', approval['type']),
              _buildDetailRow('Name', approval['name']),
              if (approval['businessName'] != null)
                _buildDetailRow('Business', approval['businessName']),
              if (approval['service'] != null)
                _buildDetailRow('Service', approval['service']),
              _buildDetailRow('Location', approval['location']),
              if (approval['experience'] != null)
                _buildDetailRow('Experience', approval['experience']),
              _buildDetailRow('Submitted', approval['submittedDate']),
              const SizedBox(height: 8),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(approval['description']),
              const SizedBox(height: 8),
              const Text(
                'Documents:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text((approval['documents'] as List<String>).join(', ')),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _approveApplication(Map<String, dynamic> approval, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: Text('Are you sure you want to approve ${approval['name']}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingApprovals.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${approval['name']} approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectApplication(Map<String, dynamic> approval, int index) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject ${approval['name']}\'s application?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingApprovals.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${approval['name']} application rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}