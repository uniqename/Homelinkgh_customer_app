import 'package:flutter/material.dart';
import '../services/ghana_card_verification_service.dart';

/// User Verification Status Screen
/// Allows users to check their Ghana Card verification status and resubmit if needed
class UserVerificationStatusScreen extends StatefulWidget {
  final String userId;
  final String userType;
  
  const UserVerificationStatusScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  State<UserVerificationStatusScreen> createState() => _UserVerificationStatusScreenState();
}

class _UserVerificationStatusScreenState extends State<UserVerificationStatusScreen> {
  Map<String, dynamic>? _verificationData;
  bool _isLoading = false;
  bool _canAccessFeatures = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVerificationStatus,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _verificationData == null 
              ? _buildUnverifiedState()
              : _buildVerificationStatus(),
    );
  }

  Widget _buildUnverifiedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Not Verified',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You haven\'t submitted your Ghana Card for verification yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToVerification,
              icon: const Icon(Icons.credit_card),
              label: const Text('Start Verification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    final status = _verificationData!['status'];
    final trustLevel = _verificationData!['trust_level'];
    final personalInfo = _verificationData!['personal_info'] ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 48,
                        color: _getStatusColor(status),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Status',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status?.toString().toUpperCase() ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusMessage(status),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Trust Level Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.military_tech,
                        color: _getTrustLevelColor(trustLevel),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Trust Level',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getTrustLevelColor(trustLevel),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          trustLevel?.toString().toUpperCase() ?? 'NONE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getTrustLevelDescription(trustLevel),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Personal Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Full Name', personalInfo['full_name']),
                  _buildInfoRow('Ghana Card Number', personalInfo['ghana_card_number']),
                  _buildInfoRow('Phone Number', personalInfo['phone_number']),
                  _buildInfoRow('Date of Birth', personalInfo['date_of_birth']),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Verification Timeline
          if (_verificationData!['verification_history'] != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildVerificationTimeline(),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Feature Access Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Feature Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureAccessList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          if (status == 'rejected' || status == 'expired')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToVerification,
                icon: const Icon(Icons.refresh),
                label: const Text('Resubmit Verification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVerificationTimeline() {
    final history = _verificationData!['verification_history'] as List<dynamic>;
    
    return history.map((entry) {
      final action = entry['action'] ?? 'unknown';
      final timestamp = entry['timestamp'] ?? '';
      final details = entry['details'] ?? entry['notes'] ?? '';
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getActionColor(action),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    action.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDate(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(details),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFeatureAccessList() {
    final features = [
      {'name': 'Booking Services', 'key': 'booking_services'},
      {'name': 'Providing Services', 'key': 'providing_services'},
      {'name': 'High Value Transactions', 'key': 'high_value_transactions'},
      {'name': 'Premium Features', 'key': 'premium_features'},
      {'name': 'Admin Features', 'key': 'admin_features'},
    ];
    
    return Column(
      children: features.map((feature) {
        final hasAccess = _canAccessFeatures; // This will be updated based on verification
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                hasAccess ? Icons.check_circle : Icons.cancel,
                color: hasAccess ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(feature['name']!),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _loadVerificationStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final verificationData = await GhanaCardVerificationService.getUserVerificationData(widget.userId);
      
      // Check feature access
      final canAccess = await GhanaCardVerificationService.canAccessFeature(widget.userId, 'booking_services');
      
      setState(() {
        _verificationData = verificationData;
        _canAccessFeatures = canAccess;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading verification status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToVerification() {
    // Navigate to verification screen
    // This would typically navigate to a verification submission screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification process will be implemented here')),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'suspended':
        return Colors.red.shade800;
      case 'under_review':
        return Colors.blue;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'verified':
        return Icons.verified_user;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      case 'suspended':
        return Icons.block;
      case 'under_review':
        return Icons.visibility;
      case 'expired':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  String _getStatusMessage(String? status) {
    switch (status) {
      case 'verified':
        return 'Your Ghana Card has been verified successfully. You have full access to all features.';
      case 'pending':
        return 'Your Ghana Card verification is being processed. This typically takes 24-48 hours.';
      case 'rejected':
        return 'Your Ghana Card verification was rejected. Please check the details and resubmit with correct information.';
      case 'suspended':
        return 'Your verification has been suspended. Please contact support for assistance.';
      case 'under_review':
        return 'Your Ghana Card is under manual review. We may contact you for additional information.';
      case 'expired':
        return 'Your verification has expired. Please resubmit your Ghana Card for verification.';
      default:
        return 'Your verification status is unknown. Please contact support.';
    }
  }

  Color _getTrustLevelColor(String? trustLevel) {
    switch (trustLevel) {
      case 'basic':
        return Colors.blue;
      case 'standard':
        return Colors.green;
      case 'premium':
        return Colors.orange;
      case 'elite':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTrustLevelDescription(String? trustLevel) {
    switch (trustLevel) {
      case 'basic':
        return 'Basic verification with standard features';
      case 'standard':
        return 'Standard verification with extended features';
      case 'premium':
        return 'Premium verification with priority support';
      case 'elite':
        return 'Elite verification with all features';
      default:
        return 'No trust level assigned';
    }
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'approved':
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'submitted':
      case 'pending':
        return Colors.blue;
      case 'promoted':
        return Colors.purple;
      case 'suspended':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}