import 'package:flutter/material.dart';
import '../services/ghana_card_verification_service.dart';

/// Admin Verification Management Screen
/// Allows admins to view and manage Ghana Card verification requests
class AdminVerificationManagementScreen extends StatefulWidget {
  final String adminId;
  
  const AdminVerificationManagementScreen({
    super.key,
    required this.adminId,
  });

  @override
  State<AdminVerificationManagementScreen> createState() => _AdminVerificationManagementScreenState();
}

class _AdminVerificationManagementScreenState extends State<AdminVerificationManagementScreen> {
  List<Map<String, dynamic>> _pendingVerifications = [];
  Map<String, dynamic>? _selectedVerification;
  bool _isLoading = false;
  bool _isProcessing = false;
  String _selectedFilter = 'all';
  
  final _adminNotesController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  TrustLevel _selectedTrustLevel = TrustLevel.basic;

  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }

  @override
  void dispose() {
    _adminNotesController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Management'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingVerifications,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showVerificationStatistics,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left Panel - Verification List
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildFilterBar(),
                      Expanded(child: _buildVerificationsList()),
                    ],
                  ),
                ),
                // Right Panel - Verification Details
                Expanded(
                  flex: 2,
                  child: _selectedVerification != null
                      ? _buildVerificationDetails()
                      : _buildEmptyState(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
              _filterVerifications();
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'under_review', child: Text('Under Review')),
              DropdownMenuItem(value: 'verified', child: Text('Verified')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
          const Spacer(),
          Text(
            '${_pendingVerifications.length} verifications',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationsList() {
    final filteredVerifications = _filterVerifications();
    
    if (filteredVerifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No verifications found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredVerifications.length,
      itemBuilder: (context, index) {
        final verification = filteredVerifications[index];
        final isSelected = _selectedVerification?['verification_id'] == verification['verification_id'];
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E8B57).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: const Color(0xFF2E8B57)) : null,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(verification['status']),
              child: Icon(
                _getStatusIcon(verification['status']),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              verification['personal_info']['full_name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${verification['user_type']?.toString().toUpperCase() ?? 'USER'}'),
                Text(
                  'Submitted: ${_formatDate(verification['submission_date'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(verification['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    verification['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trust: ${verification['trust_level']?.toString().toUpperCase() ?? 'NONE'}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedVerification = verification;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildVerificationDetails() {
    final verification = _selectedVerification!;
    final personalInfo = verification['personal_info'] ?? {};
    
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(verification['status']),
                  child: Icon(
                    _getStatusIcon(verification['status']),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personalInfo['full_name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Verification ID: ${verification['verification_id']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('Personal Information', [
                    _buildInfoRow('Full Name', personalInfo['full_name']),
                    _buildInfoRow('Ghana Card Number', personalInfo['ghana_card_number']),
                    _buildInfoRow('Date of Birth', personalInfo['date_of_birth']),
                    _buildInfoRow('Phone Number', personalInfo['phone_number']),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoCard('Verification Status', [
                    _buildInfoRow('Status', verification['status']?.toString().toUpperCase()),
                    _buildInfoRow('Trust Level', verification['trust_level']?.toString().toUpperCase()),
                    _buildInfoRow('Submitted', _formatDate(verification['submission_date'])),
                    _buildInfoRow('Last Updated', _formatDate(verification['last_updated'])),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoCard('Documents', [
                    _buildDocumentRow('Ghana Card Front', verification['documents']?['front_image_path']),
                    _buildDocumentRow('Ghana Card Back', verification['documents']?['back_image_path']),
                    _buildDocumentRow('Selfie', verification['documents']?['selfie_image_path']),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  if (verification['additional_data'] != null)
                    _buildInfoCard('Additional Information', [
                      _buildInfoRow('User Type', verification['user_type']),
                      _buildInfoRow('Email', verification['additional_data']?['email']),
                      _buildInfoRow('Services', verification['additional_data']?['services']?.join(', ')),
                      _buildInfoRow('Hourly Rate', 'GHS ${verification['additional_data']?['hourly_rate']}'),
                    ]),
                  
                  const SizedBox(height: 16),
                  
                  if (verification['verification_history'] != null && verification['verification_history'].isNotEmpty)
                    _buildVerificationHistory(verification['verification_history']),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (verification['status'] == 'pending' || verification['status'] == 'under_review')
                    _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Select a verification to view details',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
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

  Widget _buildDocumentRow(String label, String? imagePath) {
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
            child: imagePath != null 
                ? TextButton(
                    onPressed: () => _showImageDialog(imagePath),
                    child: const Text('View Image'),
                  )
                : const Text('Not uploaded'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationHistory(List<dynamic> history) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...history.map((entry) => Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry['action']?.toString().toUpperCase() ?? 'UNKNOWN',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(entry['timestamp']),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (entry['notes'] != null)
                    Text(entry['notes']),
                  if (entry['admin_id'] != null)
                    Text(
                      'By: ${entry['admin_id']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _showApprovalDialog,
            icon: const Icon(Icons.check_circle),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _showRejectionDialog,
            icon: const Icon(Icons.cancel),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filterVerifications() {
    if (_selectedFilter == 'all') {
      return _pendingVerifications;
    }
    return _pendingVerifications.where((v) => v['status'] == _selectedFilter).toList();
  }

  void _loadPendingVerifications() async {
    setState(() => _isLoading = true);
    try {
      final verifications = await GhanaCardVerificationService.getPendingVerifications();
      setState(() {
        _pendingVerifications = verifications;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading verifications: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Assign trust level for this provider:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<TrustLevel>(
              value: _selectedTrustLevel,
              decoration: const InputDecoration(
                labelText: 'Trust Level',
                border: OutlineInputBorder(),
              ),
              items: TrustLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTrustLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminNotesController,
              decoration: const InputDecoration(
                labelText: 'Admin Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _approveVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminNotesController,
              decoration: const InputDecoration(
                labelText: 'Admin Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _rejectVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _approveVerification() async {
    if (_selectedVerification == null) return;
    
    Navigator.pop(context);
    setState(() => _isProcessing = true);
    
    try {
      final result = await GhanaCardVerificationService.approveVerification(
        verificationId: _selectedVerification!['verification_id'],
        adminId: widget.adminId,
        assignedTrustLevel: _selectedTrustLevel,
        adminNotes: _adminNotesController.text,
      );
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification approved successfully')),
        );
        _loadPendingVerifications();
        setState(() => _selectedVerification = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving verification: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
      _adminNotesController.clear();
    }
  }

  void _rejectVerification() async {
    if (_selectedVerification == null || _rejectionReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rejection reason')),
      );
      return;
    }
    
    Navigator.pop(context);
    setState(() => _isProcessing = true);
    
    try {
      final result = await GhanaCardVerificationService.rejectVerification(
        verificationId: _selectedVerification!['verification_id'],
        adminId: widget.adminId,
        rejectionReason: _rejectionReasonController.text,
        adminNotes: _adminNotesController.text,
      );
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification rejected')),
        );
        _loadPendingVerifications();
        setState(() => _selectedVerification = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting verification: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
      _rejectionReasonController.clear();
      _adminNotesController.clear();
    }
  }

  void _showVerificationStatistics() async {
    final stats = await GhanaCardVerificationService.getVerificationStatistics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total Pending', stats['total_pending']),
              _buildStatRow('Total Verified', stats['total_verified']),
              _buildStatRow('Total Rejected', stats['total_rejected']),
              _buildStatRow('Total Suspended', stats['total_suspended']),
              _buildStatRow('Verification Rate', '${stats['verification_rate'].toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              const Text('Trust Level Distribution:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...stats['trust_level_distribution'].entries.map((entry) => 
                _buildStatRow(entry.key.toUpperCase(), entry.value)),
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

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Image'),
        content: Container(
          width: 300,
          height: 400,
          child: Image.network(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Error loading image'),
                  ],
                ),
              );
            },
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
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      case 'suspended':
        return Icons.block;
      case 'under_review':
        return Icons.visibility;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}