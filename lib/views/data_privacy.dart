import 'package:flutter/material.dart';
import '../services/data_export_service.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isExporting = false;
  bool isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Privacy'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Privacy Header
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
                  Icons.security,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Data, Your Rights',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'GDPR & Ghana Data Protection Act Compliant',
                  style: TextStyle(
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
                    '🛡️ Your privacy is protected',
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
                Tab(text: 'Export Data'),
                Tab(text: 'Delete Account'),
                Tab(text: 'Privacy Rights'),
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
                _buildExportDataTab(),
                _buildDeleteAccountTab(),
                _buildPrivacyRightsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Your Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Get a complete copy of your personal data stored in HomeLinkGH. This includes:',
            style: TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Data categories
          _buildDataCategory('Profile Information', [
            'Personal details and contact information',
            'Account preferences and settings',
            'Profile photos and documents',
          ], Icons.person),
          
          _buildDataCategory('Booking History', [
            'All service bookings and transactions',
            'Payment history and receipts',
            'Service ratings and reviews',
          ], Icons.history),
          
          _buildDataCategory('Provider Data (if applicable)', [
            'Provider profile and certifications',
            'Earnings and payout history',
            'Customer ratings received',
          ], Icons.work),
          
          _buildDataCategory('Communication Data', [
            'Support conversations',
            'Dispute communications',
            'Notification preferences',
          ], Icons.message),
          
          const SizedBox(height: 24),
          
          // Export options
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
                  '📋 Export Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Data format: JSON (machine-readable)'),
                Text('• Delivery: Secure download link via email'),
                Text('• Availability: 7 days from export'),
                Text('• Processing time: Up to 24 hours'),
                Text('• Cost: Free (once per month)'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Export button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isExporting ? null : () => _exportData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isExporting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Exporting Data...'),
                      ],
                    )
                  : const Text(
                      'Request Data Export',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Export history
          const Text(
            'Recent Exports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 12),
          
          StreamBuilder(
            stream: DataExportService.getExportHistory('current_user_id'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final exports = snapshot.data!.docs;
              
              if (exports.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('No previous exports'),
                  ),
                );
              }
              
              return Column(
                children: exports.map((export) {
                  final data = export.data() as Map<String, dynamic>;
                  return _buildExportHistoryItem(data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delete Your Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Important Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text('Account deletion is permanent and cannot be undone.'),
                Text('You have a 30-day grace period to cancel the deletion.'),
                Text('All your data will be permanently removed after 30 days.'),
                Text('Active bookings must be completed or cancelled first.'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // What gets deleted
          const Text(
            'What Gets Deleted',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDeletionCategory('Personal Information', [
            'Profile and contact details',
            'Identity verification documents',
            'Photos and uploaded files',
          ], Icons.person_remove, Colors.red),
          
          _buildDeletionCategory('Activity Data', [
            'Booking history and transactions',
            'Messages and communications',
            'Ratings and reviews given',
          ], Icons.history, Colors.red),
          
          _buildDeletionCategory('Financial Data', [
            'Payment methods and history',
            'Earnings and payout records',
            'Refund transactions',
          ], Icons.money_off, Colors.red),
          
          const SizedBox(height: 24),
          
          // Deletion process
          const Text(
            'Deletion Process',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDeletionStep(1, 'Request Deletion', 'Submit account deletion request'),
          _buildDeletionStep(2, '30-Day Grace Period', 'You can cancel the deletion anytime'),
          _buildDeletionStep(3, 'Data Export', 'Automatic backup of your data'),
          _buildDeletionStep(4, 'Final Deletion', 'Permanent removal of all data'),
          
          const SizedBox(height: 24),
          
          // Deletion form
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reason for Deletion (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Help us improve by sharing why you\'re leaving...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                      activeColor: Colors.red,
                    ),
                    const Expanded(
                      child: Text(
                        'I understand that this action is permanent and cannot be undone',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Delete button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDeletingAccount ? null : () => _showDeleteConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isDeletingAccount
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Processing Deletion...'),
                      ],
                    )
                  : const Text(
                      'Delete My Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyRightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Privacy Rights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildPrivacyRight(
            'Right to Access',
            'You can request a copy of all personal data we hold about you',
            Icons.visibility,
            'Request Data Export',
            () => _tabController.animateTo(0),
          ),
          
          _buildPrivacyRight(
            'Right to Rectification',
            'You can request corrections to inaccurate or incomplete data',
            Icons.edit,
            'Update Profile',
            () => _updateProfile(),
          ),
          
          _buildPrivacyRight(
            'Right to Erasure',
            'You can request deletion of your personal data',
            Icons.delete_forever,
            'Delete Account',
            () => _tabController.animateTo(1),
          ),
          
          _buildPrivacyRight(
            'Right to Portability',
            'You can receive your data in a structured, machine-readable format',
            Icons.import_export,
            'Export Data',
            () => _exportData(),
          ),
          
          _buildPrivacyRight(
            'Right to Object',
            'You can object to processing of your data for marketing purposes',
            Icons.block,
            'Manage Preferences',
            () => _manageNotificationPreferences(),
          ),
          
          _buildPrivacyRight(
            'Right to Restriction',
            'You can request restriction of processing in certain circumstances',
            Icons.pause_circle,
            'Contact Support',
            () => _contactSupport(),
          ),
          
          const SizedBox(height: 24),
          
          // Data Protection Contact
          Container(
            width: double.infinity,
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
                  '📧 Data Protection Officer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B3C),
                  ),
                ),
                SizedBox(height: 8),
                Text('Email: privacy@homelink.gh'),
                Text('Phone: +233 (0) 30 123 4567'),
                Text('Response time: Within 30 days'),
                SizedBox(height: 8),
                Text(
                  'For privacy concerns or to exercise your rights, contact our Data Protection Officer.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legal compliance
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
                  '⚖️ Legal Compliance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Ghana Data Protection Act 2012'),
                Text('• EU General Data Protection Regulation (GDPR)'),
                Text('• International data transfer safeguards'),
                Text('• Regular compliance audits'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCategory(String title, List<String> items, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF006B3C)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Text('• $item'),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportHistoryItem(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.file_download, color: Color(0xFF006B3C)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Export',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Size: ${data['size_mb']?.toStringAsFixed(2) ?? '0'} MB',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Text(
              'Expired',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionCategory(String title, List<String> items, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Text('• $item'),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionStep(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  Widget _buildPrivacyRight(String title, String description, IconData icon, String actionText, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF006B3C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      isExporting = true;
    });

    try {
      final result = await DataExportService.exportDataAsFile('current_user_id');
      
      if (result['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Requested'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text('Your data export has been requested.'),
                const SizedBox(height: 8),
                Text('File size: ${result['size_mb'].toStringAsFixed(2)} MB'),
                const SizedBox(height: 8),
                const Text('You\'ll receive a download link via email within 24 hours.'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isExporting = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. You will have 30 days to cancel this request.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      isDeletingAccount = true;
    });

    try {
      final result = await DataExportService.requestAccountDeletion(
        'current_user_id',
        'User requested deletion',
      );
      
      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Account Deletion Scheduled'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, color: Colors.orange, size: 60),
                const SizedBox(height: 16),
                const Text('Your account will be deleted in 30 days.'),
                const SizedBox(height: 8),
                Text('Deletion ID: ${result['deletionId']}'),
                const SizedBox(height: 8),
                const Text('You can cancel this request anytime before the deletion date.'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deletion request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isDeletingAccount = false;
      });
    }
  }

  void _updateProfile() {
    // Navigate to profile update screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to profile update screen'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _manageNotificationPreferences() {
    // Navigate to notification preferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to notification preferences'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _contactSupport() {
    // Navigate to customer support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to customer support'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }
}