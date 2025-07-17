import 'package:flutter/material.dart';
import '../services/ghana_card_verification_service.dart';

/// Provider Promotion Management Screen
/// Allows admins to promote or demote providers' trust levels
class ProviderPromotionManagementScreen extends StatefulWidget {
  final String adminId;
  
  const ProviderPromotionManagementScreen({
    super.key,
    required this.adminId,
  });

  @override
  State<ProviderPromotionManagementScreen> createState() => _ProviderPromotionManagementScreenState();
}

class _ProviderPromotionManagementScreenState extends State<ProviderPromotionManagementScreen> {
  List<Map<String, dynamic>> _verifiedProviders = [];
  Map<String, dynamic>? _selectedProvider;
  bool _isLoading = false;
  bool _isProcessing = false;
  
  final _reasonController = TextEditingController();
  TrustLevel _newTrustLevel = TrustLevel.basic;

  @override
  void initState() {
    super.initState();
    _loadVerifiedProviders();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Promotion Management'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVerifiedProviders,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left Panel - Provider List
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildProviderListHeader(),
                      Expanded(child: _buildProvidersList()),
                    ],
                  ),
                ),
                // Right Panel - Provider Details
                Expanded(
                  flex: 2,
                  child: _selectedProvider != null
                      ? _buildProviderDetails()
                      : _buildEmptyState(),
                ),
              ],
            ),
    );
  }

  Widget _buildProviderListHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Text(
            'Verified Providers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${_verifiedProviders.length} providers',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList() {
    if (_verifiedProviders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No verified providers found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _verifiedProviders.length,
      itemBuilder: (context, index) {
        final provider = _verifiedProviders[index];
        final isSelected = _selectedProvider?['user_id'] == provider['user_id'];
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E8B57).withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: const Color(0xFF2E8B57)) : null,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTrustLevelColor(provider['trust_level']),
              child: Text(
                provider['trust_level']?.toString().substring(0, 1).toUpperCase() ?? 'N',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              provider['personal_info']?['full_name'] ?? 'Unknown Provider',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trust Level: ${provider['trust_level']?.toString().toUpperCase() ?? 'NONE'}'),
                Text(
                  'Verified: ${_formatDate(provider['approved_date'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
            onTap: () {
              setState(() {
                _selectedProvider = provider;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildProviderDetails() {
    final provider = _selectedProvider!;
    final personalInfo = provider['personal_info'] ?? {};
    final currentTrustLevel = TrustLevel.values.firstWhere(
      (level) => level.name == provider['trust_level'],
      orElse: () => TrustLevel.none,
    );
    
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
                  backgroundColor: _getTrustLevelColor(provider['trust_level']),
                  radius: 24,
                  child: Text(
                    provider['trust_level']?.toString().substring(0, 1).toUpperCase() ?? 'N',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personalInfo['full_name'] ?? 'Unknown Provider',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'User ID: ${provider['user_id']}',
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
                  // Current Trust Level
                  _buildInfoCard('Current Trust Level', [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getTrustLevelColor(provider['trust_level']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            provider['trust_level']?.toString().toUpperCase() ?? 'NONE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _getTrustLevelDescription(provider['trust_level']),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTrustLevelBenefits(currentTrustLevel),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Provider Information
                  _buildInfoCard('Provider Information', [
                    _buildInfoRow('Full Name', personalInfo['full_name']),
                    _buildInfoRow('Email', provider['additional_data']?['email']),
                    _buildInfoRow('Phone', personalInfo['phone_number']),
                    _buildInfoRow('Ghana Card', personalInfo['ghana_card_number']),
                    _buildInfoRow('Services', provider['additional_data']?['services']?.join(', ')),
                    _buildInfoRow('Hourly Rate', 'GHS ${provider['additional_data']?['hourly_rate']}'),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Verification History
                  if (provider['verification_history'] != null && provider['verification_history'].isNotEmpty)
                    _buildVerificationHistory(provider['verification_history']),
                  
                  const SizedBox(height: 24),
                  
                  // Promotion/Demotion Actions
                  _buildPromotionActions(currentTrustLevel),
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
          Icon(Icons.person_search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Select a provider to view details',
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

  Widget _buildTrustLevelBenefits(TrustLevel trustLevel) {
    final benefits = _getTrustLevelBenefits(trustLevel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Benefits:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(benefit)),
            ],
          ),
        )),
      ],
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
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
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
                          color: _getActionColor(entry['action']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry['action']?.toString().toUpperCase() ?? 'UNKNOWN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(entry['timestamp']),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (entry['trust_level'] != null)
                    Text('Trust Level: ${entry['trust_level'].toString().toUpperCase()}'),
                  if (entry['notes'] != null && entry['notes'].isNotEmpty)
                    Text(entry['notes']),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionActions(TrustLevel currentTrustLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Trust Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Trust Level Selector
            DropdownButtonFormField<TrustLevel>(
              value: _newTrustLevel,
              decoration: const InputDecoration(
                labelText: 'New Trust Level',
                border: OutlineInputBorder(),
              ),
              items: TrustLevel.values.map((level) {
                final isCurrentLevel = level == currentTrustLevel;
                return DropdownMenuItem(
                  value: level,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getTrustLevelColor(level.name),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        level.name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
                          color: isCurrentLevel ? Colors.blue : null,
                        ),
                      ),
                      if (isCurrentLevel) ...[
                        const SizedBox(width: 8),
                        const Text('(Current)', style: TextStyle(color: Colors.blue)),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _newTrustLevel = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Reason Input
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Change *',
                border: OutlineInputBorder(),
                hintText: 'Explain why you are changing the trust level...',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Benefits Comparison
            _buildBenefitsComparison(currentTrustLevel, _newTrustLevel),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing || _newTrustLevel == currentTrustLevel
                        ? null
                        : _changeTrustLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _newTrustLevel.value > currentTrustLevel.value
                          ? Colors.green
                          : Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_newTrustLevel.value > currentTrustLevel.value ? 'Promote' : 'Demote'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsComparison(TrustLevel currentLevel, TrustLevel newLevel) {
    final currentBenefits = _getTrustLevelBenefits(currentLevel);
    final newBenefits = _getTrustLevelBenefits(newLevel);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Benefits Comparison',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current (${currentLevel.name.toUpperCase()})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    ...currentBenefits.map((benefit) => Text(
                      '• $benefit',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New (${newLevel.name.toUpperCase()})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    ...newBenefits.map((benefit) => Text(
                      '• $benefit',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _loadVerifiedProviders() async {
    setState(() => _isLoading = true);
    try {
      final verifications = await GhanaCardVerificationService.getPendingVerifications();
      final verifiedProviders = verifications.where((v) => v['status'] == 'verified').toList();
      
      setState(() {
        _verifiedProviders = verifiedProviders;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading providers: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _changeTrustLevel() async {
    if (_selectedProvider == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for the change')),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final result = await GhanaCardVerificationService.promoteUserTrustLevel(
        userId: _selectedProvider!['user_id'],
        adminId: widget.adminId,
        newTrustLevel: _newTrustLevel,
        promotionReason: _reasonController.text,
      );
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trust level changed successfully to ${_newTrustLevel.name.toUpperCase()}')),
        );
        _loadVerifiedProviders();
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing trust level: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _resetForm() {
    setState(() {
      _newTrustLevel = TrustLevel.basic;
      _reasonController.clear();
    });
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

  List<String> _getTrustLevelBenefits(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.basic:
        return [
          'Basic booking access',
          'Standard support',
          '15% commission rate',
        ];
      case TrustLevel.standard:
        return [
          'All basic features',
          'Higher value transactions',
          'Priority support',
          '12% commission rate',
        ];
      case TrustLevel.premium:
        return [
          'All standard features',
          'Premium listings',
          'Featured placement',
          '10% commission rate',
        ];
      case TrustLevel.elite:
        return [
          'All premium features',
          'Admin tools access',
          'Special privileges',
          '8% commission rate',
        ];
      default:
        return ['Limited access'];
    }
  }

  Color _getActionColor(String? action) {
    switch (action?.toLowerCase()) {
      case 'approved':
      case 'promoted':
        return Colors.green;
      case 'demoted':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
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
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}