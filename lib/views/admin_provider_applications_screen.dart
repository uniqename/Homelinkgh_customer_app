import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/admin_auth_guard.dart';

class AdminProviderApplicationsScreen extends StatefulWidget {
  const AdminProviderApplicationsScreen({super.key});

  @override
  State<AdminProviderApplicationsScreen> createState() =>
      _AdminProviderApplicationsScreenState();
}

class _AdminProviderApplicationsScreenState
    extends State<AdminProviderApplicationsScreen> {
  final SupabaseService _supabase = SupabaseService();

  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String _filterStatus = 'pending'; // pending, verified, rejected, all

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      var query = _supabase.supabase.from('providers').select();
      if (_filterStatus != 'all') {
        query = query.eq('status', _filterStatus);
      }
      final rows = await query.order('created_at', ascending: false);
      setState(() {
        _applications = List<Map<String, dynamic>>.from(rows);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load applications: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminAuthGuard(
      screenName: 'Provider Applications',
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Provider Applications'),
              Text(
                _filterStatus == 'all'
                    ? '${_applications.length} total'
                    : '${_applications.length} $_filterStatus',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF006B3C),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterOptions,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadApplications,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddProviderManually,
          backgroundColor: const Color(0xFF006B3C),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Provider'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF006B3C)))
            : _applications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.business_center,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus == 'pending'
                              ? 'No Pending Applications'
                              : 'No ${_filterStatus.capitalize()} Applications',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Use "Add Provider" to register providers directly',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _applications.length,
                    itemBuilder: (context, index) {
                      return _buildApplicationCard(_applications[index], index);
                    },
                  ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app, int index) {
    final name = app['name']?.toString() ?? 'Unknown';
    final location = app['location']?.toString() ?? 'Location not set';
    final phone = app['phone']?.toString() ?? 'No phone';
    final email = app['email']?.toString() ?? 'No email';
    final bio = app['bio']?.toString() ?? '';
    final services = List<String>.from(app['services'] ?? []);
    final status = app['status']?.toString() ?? 'pending';
    final createdAt = app['created_at'] != null
        ? DateTime.tryParse(app['created_at'].toString())
        : null;

    final statusColor = status == 'verified'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;
    final statusLabel = status == 'verified'
        ? 'Verified'
        : status == 'rejected'
            ? 'Rejected'
            : 'Pending Review';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 13, color: Colors.grey[600]),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (createdAt != null)
                        Text(
                          'Applied ${_timeAgo(createdAt)}',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Contact info
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(phone,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (services.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Services offered:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: services
                    .map((s) => Chip(
                          label: Text(s,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white)),
                          backgroundColor: const Color(0xFF006B3C),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],

            if (bio.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                bio,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[700], height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons — only show approve/reject for pending
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectApplication(app, index),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _approveApplication(app, index),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve & Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              )
            else if (status == 'verified')
              OutlinedButton.icon(
                onPressed: () => _suspendProvider(app, index),
                icon: const Icon(Icons.pause_circle_outline, size: 16),
                label: const Text('Suspend Provider'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APPROVE
  // ─────────────────────────────────────────────────────────────────────────

  void _approveApplication(Map<String, dynamic> app, int index) {
    final name = app['name']?.toString() ?? 'Provider';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Provider'),
        content: Text('Approve $name? They will be notified and can start receiving jobs immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProviderStatus(app, index, 'verified',
                  notificationTitle: 'Congratulations! You\'re Approved',
                  notificationMessage:
                      'Your HomeLinkGH provider application has been approved. You can now receive job requests from customers.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REJECT
  // ─────────────────────────────────────────────────────────────────────────

  void _rejectApplication(Map<String, dynamic> app, int index) {
    final reasonController = TextEditingController();
    final name = app['name']?.toString() ?? 'Provider';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject $name\'s application?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (shown to applicant)',
                border: OutlineInputBorder(),
                hintText: 'e.g. Incomplete documents, service area not covered...',
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
            onPressed: () async {
              Navigator.pop(context);
              final reason = reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : 'Your application did not meet our current requirements.';
              await _updateProviderStatus(app, index, 'rejected',
                  notificationTitle: 'Application Update',
                  notificationMessage:
                      'Your HomeLinkGH provider application was not approved at this time. Reason: $reason. You may reapply after 30 days.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUSPEND
  // ─────────────────────────────────────────────────────────────────────────

  void _suspendProvider(Map<String, dynamic> app, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Provider'),
        content: Text('Suspend ${app['name']}? They will no longer receive job requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProviderStatus(app, index, 'suspended',
                  notificationTitle: 'Account Suspended',
                  notificationMessage:
                      'Your HomeLinkGH provider account has been suspended. Please contact support for more information.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProviderStatus(
    Map<String, dynamic> app,
    int index,
    String newStatus, {
    required String notificationTitle,
    required String notificationMessage,
  }) async {
    try {
      await _supabase.supabase.from('providers').update({
        'status': newStatus,
        'is_verified': newStatus == 'verified',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', app['id'].toString());

      // Notify the provider via in-app notification
      final userId = app['user_id']?.toString();
      if (userId != null) {
        await _supabase.sendNotification(
          userId: userId,
          title: notificationTitle,
          message: notificationMessage,
          type: 'provider_status',
        );
      }

      // Remove from list if we're filtering by a specific status
      setState(() {
        if (_filterStatus != 'all' && _filterStatus != newStatus) {
          _applications.removeAt(index);
        } else {
          _applications[index] = {...app, 'status': newStatus};
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${app['name']} ${newStatus == 'verified' ? 'approved ✓' : newStatus}'),
            backgroundColor: newStatus == 'verified' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MANUALLY ADD A PROVIDER (for providers you've already recruited)
  // ─────────────────────────────────────────────────────────────────────────

  void _showAddProviderManually() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final selectedServices = <String>[];

    final allServices = [
      'House Cleaning', 'Plumbing', 'Electrical Services',
      'Beauty Services', 'Laundry Service', 'Food Delivery',
      'Transportation', 'Carpentry', 'Painting', 'Roofing',
      'Masonry', 'Landscaping', 'Babysitting', 'Elderly Care',
      'Cooking Service', 'AC Repair', 'Generator Service',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Provider Directly',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provider will be immediately verified and can start receiving jobs.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                      hintText: '+233 XX XXX XXXX',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location / Area *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. East Legon, Accra',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Short Bio (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. 5 years experience in residential cleaning',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Services Offered *',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: allServices.map((s) {
                      final selected = selectedServices.contains(s);
                      return FilterChip(
                        label: Text(s, style: const TextStyle(fontSize: 11)),
                        selected: selected,
                        onSelected: (v) {
                          setModalState(() {
                            v ? selectedServices.add(s) : selectedServices.remove(s);
                          });
                        },
                        selectedColor: const Color(0xFF006B3C).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF006B3C),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            phoneCtrl.text.trim().isEmpty ||
                            locationCtrl.text.trim().isEmpty ||
                            selectedServices.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in name, phone, location and select at least one service.'),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        await _saveManualProvider(
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          location: locationCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          services: selectedServices,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Add & Verify Provider',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _saveManualProvider({
    required String name,
    required String phone,
    required String email,
    required String location,
    required String bio,
    required List<String> services,
  }) async {
    try {
      await _supabase.supabase.from('providers').insert({
        'name': name,
        'phone': phone,
        'email': email,
        'location': location,
        'bio': bio,
        'services': services,
        'status': 'verified',
        'is_verified': true,
        'ghana_card_verified': false,
        'rating': 0.0,
        'total_jobs': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added and verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadApplications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add provider: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FILTER
  // ─────────────────────────────────────────────────────────────────────────

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Providers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              for (final opt in [
                ('pending', 'Pending Review', Colors.orange),
                ('verified', 'Verified Providers', Colors.green),
                ('rejected', 'Rejected', Colors.red),
                ('all', 'All Providers', Colors.blue),
              ])
                ListTile(
                  leading: Icon(
                    _filterStatus == opt.$1
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: opt.$3,
                  ),
                  title: Text(opt.$2),
                  onTap: () {
                    setState(() => _filterStatus = opt.$1);
                    Navigator.pop(context);
                    _loadApplications();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
