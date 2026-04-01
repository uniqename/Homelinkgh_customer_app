import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_auth_guard.dart';
import '../models/staff_payroll.dart';
import '../services/staff_payroll_service.dart';

class AdminStaffPayrollScreen extends StatefulWidget {
  const AdminStaffPayrollScreen({super.key});

  @override
  State<AdminStaffPayrollScreen> createState() => _AdminStaffPayrollScreenState();
}

class _AdminStaffPayrollScreenState extends State<AdminStaffPayrollScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StaffPayrollService _payrollService = StaffPayrollService();

  List<StaffPayroll> _paychecks = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = false;
  DateTime _selectedPeriodStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedPeriodEnd = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Generate mock data if empty (remove in production)
    final existing = await _payrollService.getPaychecksForPeriod(
      _selectedPeriodStart,
      _selectedPeriodEnd,
    );
    if (existing.isEmpty) {
      await _payrollService.generateMockPaychecks();
    }

    _paychecks = await _payrollService.getPaychecksForPeriod(
      _selectedPeriodStart,
      _selectedPeriodEnd,
    );
    _summary = await _payrollService.getPayrollSummary(
      _selectedPeriodStart,
      _selectedPeriodEnd,
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminAuthGuard(
      screenName: 'Staff Payroll',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Payroll Management'),
          backgroundColor: const Color(0xFF006B3C),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showCompensationSettings,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Paychecks'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPaychecksTab(),
                  _buildHistoryTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createNewPaycheck,
          backgroundColor: const Color(0xFF006B3C),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Paycheck'),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_summary == null) return const Center(child: Text('No data available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildStaffBreakdown(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final formatter = DateFormat('MMM yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF006B3C)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pay Period',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    formatter.format(_selectedPeriodStart),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedPeriodStart = DateTime(
                    _selectedPeriodStart.year,
                    _selectedPeriodStart.month - 1,
                    1,
                  );
                  _selectedPeriodEnd = DateTime(
                    _selectedPeriodStart.year,
                    _selectedPeriodStart.month + 1,
                    0,
                  );
                });
                _loadData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedPeriodStart = DateTime(
                    _selectedPeriodStart.year,
                    _selectedPeriodStart.month + 1,
                    1,
                  );
                  _selectedPeriodEnd = DateTime(
                    _selectedPeriodStart.year,
                    _selectedPeriodStart.month + 1,
                    0,
                  );
                });
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Payroll',
                currency.format(_summary!['totalPayroll']),
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Paid Out',
                currency.format(_summary!['totalPaid']),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pending',
                currency.format(_summary!['totalPending']),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Staff Count',
                _summary!['totalPaychecks'].toString(),
                Icons.people,
                const Color(0xFF006B3C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffBreakdown() {
    final byRole = <String, List<StaffPayroll>>{};
    for (var paycheck in _paychecks) {
      byRole.putIfAbsent(paycheck.staffRole, () => []).add(paycheck);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Breakdown by Role',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...byRole.entries.map((entry) {
              final total = entry.value.fold(0.0, (sum, p) => sum + p.netPay);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getRoleDisplayName(entry.key),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${entry.value.length} staff',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2).format(total),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaychecksTab() {
    if (_paychecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No paychecks for this period',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewPaycheck,
              icon: const Icon(Icons.add),
              label: const Text('Create Paycheck'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paychecks.length,
      itemBuilder: (context, index) {
        final paycheck = _paychecks[index];
        return _buildPaycheckCard(paycheck);
      },
    );
  }

  Widget _buildPaycheckCard(StaffPayroll paycheck) {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);
    final statusColor = paycheck.status == 'paid'
        ? Colors.green
        : paycheck.status == 'approved'
            ? Colors.blue
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPaycheckDetails(paycheck),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF006B3C).withOpacity(0.1),
                    child: Text(
                      paycheck.staffName[0],
                      style: const TextStyle(
                        color: Color(0xFF006B3C),
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
                          paycheck.staffName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getRoleDisplayName(paycheck.staffRole),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      paycheck.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPaycheckDetail('Base Salary', currency.format(paycheck.baseSalary)),
                  _buildPaycheckDetail('Commission', currency.format(paycheck.commissionEarned)),
                  _buildPaycheckDetail('Net Pay', currency.format(paycheck.netPay)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.work, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${paycheck.jobsFacilitated} jobs facilitated',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '${paycheck.commissionRate}% commission rate',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaycheckDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    // Filter paid paychecks only
    final paidPaychecks = _paychecks.where((p) => p.status == 'paid').toList();

    if (paidPaychecks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payment history yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paidPaychecks.length,
      itemBuilder: (context, index) {
        final paycheck = paidPaychecks[index];
        return _buildHistoryCard(paycheck);
      },
    );
  }

  Widget _buildHistoryCard(StaffPayroll paycheck) {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        ),
        title: Text(paycheck.staffName),
        subtitle: Text(
          '${dateFormat.format(paycheck.paidAt!)} • ${paycheck.paymentMethod ?? "N/A"}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          currency.format(paycheck.netPay),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    final roleNames = {
      'supportAgent': 'Support Agent',
      'dispatchCoordinator': 'Dispatch Coordinator',
      'onboardingSpecialist': 'Onboarding Specialist',
      'financeManager': 'Finance Manager',
      'operationsManager': 'Operations Manager',
      'admin': 'Administrator',
      'superAdmin': 'Super Administrator',
    };
    return roleNames[role] ?? role;
  }

  void _showPaycheckDetails(StaffPayroll paycheck) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaycheckDetailsSheet(
        paycheck: paycheck,
        onApprove: () async {
          await _payrollService.updatePaycheckStatus(
            paycheckId: paycheck.id,
            status: 'approved',
          );
          Navigator.pop(context);
          _loadData();
        },
        onMarkPaid: () async {
          _showMarkAsPaidDialog(paycheck);
        },
      ),
    );
  }

  void _showMarkAsPaidDialog(StaffPayroll paycheck) {
    final paymentMethodController = TextEditingController(text: 'Bank Transfer');
    final referenceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: referenceController,
              decoration: const InputDecoration(
                labelText: 'Payment Reference (optional)',
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
            onPressed: () async {
              await _payrollService.updatePaycheckStatus(
                paycheckId: paycheck.id,
                status: 'paid',
                paymentMethod: paymentMethodController.text,
                paymentReference: referenceController.text.isEmpty
                    ? null
                    : referenceController.text,
              );
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _createNewPaycheck() {
    showDialog(
      context: context,
      builder: (context) => _CreatePaycheckDialog(
        periodStart: _selectedPeriodStart,
        periodEnd: _selectedPeriodEnd,
        onCreated: () {
          _loadData();
        },
      ),
    );
  }

  void _showCompensationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _CompensationSettingsScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Paycheck Details Bottom Sheet
class _PaycheckDetailsSheet extends StatelessWidget {
  final StaffPayroll paycheck;
  final VoidCallback onApprove;
  final VoidCallback onMarkPaid;

  const _PaycheckDetailsSheet({
    required this.paycheck,
    required this.onApprove,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF006B3C).withOpacity(0.1),
                child: Text(
                  paycheck.staffName[0],
                  style: const TextStyle(
                    color: Color(0xFF006B3C),
                    fontSize: 24,
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
                      paycheck.staffName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      paycheck.staffEmail,
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
          const Divider(height: 32),
          _buildDetailRow('Period', '${dateFormat.format(paycheck.periodStart)} - ${dateFormat.format(paycheck.periodEnd)}'),
          _buildDetailRow('Base Salary', currency.format(paycheck.baseSalary)),
          _buildDetailRow('Jobs Facilitated', '${paycheck.jobsFacilitated} jobs'),
          _buildDetailRow('Service Fees Generated', currency.format(paycheck.totalServiceFees)),
          _buildDetailRow('Commission Rate', '${paycheck.commissionRate}%'),
          _buildDetailRow('Commission Earned', currency.format(paycheck.commissionEarned)),
          if (paycheck.bonuses > 0)
            _buildDetailRow('Bonuses', currency.format(paycheck.bonuses), color: Colors.green),
          if (paycheck.deductions > 0)
            _buildDetailRow('Deductions', currency.format(paycheck.deductions), color: Colors.red),
          const Divider(height: 24),
          _buildDetailRow('Gross Pay', currency.format(paycheck.grossPay), bold: true),
          _buildDetailRow('Net Pay', currency.format(paycheck.netPay), bold: true, color: const Color(0xFF006B3C)),
          const SizedBox(height: 24),
          if (paycheck.status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check),
                label: const Text('Approve Paycheck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (paycheck.status == 'approved')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onMarkPaid,
                icon: const Icon(Icons.payment),
                label: const Text('Mark as Paid'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (paycheck.status == 'paid')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (paycheck.paidAt != null)
                          Text(
                            'on ${dateFormat.format(paycheck.paidAt!)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (paycheck.paymentMethod != null)
                          Text(
                            'via ${paycheck.paymentMethod}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Create Paycheck Dialog - DYNAMIC COMPENSATION TYPE
class _CreatePaycheckDialog extends StatefulWidget {
  final DateTime periodStart;
  final DateTime periodEnd;
  final VoidCallback onCreated;

  const _CreatePaycheckDialog({
    required this.periodStart,
    required this.periodEnd,
    required this.onCreated,
  });

  @override
  State<_CreatePaycheckDialog> createState() => _CreatePaycheckDialogState();
}

class _CreatePaycheckDialogState extends State<_CreatePaycheckDialog> {
  final _formKey = GlobalKey<FormState>();
  final _staffNameController = TextEditingController();
  final _staffEmailController = TextEditingController();
  final _baseSalaryController = TextEditingController(text: '0');
  final _commissionRateController = TextEditingController(text: '0');
  final _jobsFacilitatedController = TextEditingController(text: '0');
  final _serviceFeesController = TextEditingController(text: '0');
  final _bonusesController = TextEditingController(text: '0');
  final _deductionsController = TextEditingController(text: '0');

  String _selectedRole = 'supportAgent';
  String _compensationType = 'both'; // 'fixed', 'commission', 'both'

  final roles = [
    'supportAgent',
    'dispatchCoordinator',
    'onboardingSpecialist',
    'financeManager',
    'operationsManager',
    'admin',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Staff Paycheck'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _staffNameController,
                decoration: const InputDecoration(
                  labelText: 'Staff Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter staff name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _staffEmailController,
                decoration: const InputDecoration(
                  labelText: 'Staff Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(_getRoleDisplayName(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedRole = value!);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Compensation Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCompensationTypeChip('Fixed Salary Only', 'fixed'),
              _buildCompensationTypeChip('Commission Only', 'commission'),
              _buildCompensationTypeChip('Fixed + Commission', 'both'),
              const SizedBox(height: 16),
              if (_compensationType == 'fixed' || _compensationType == 'both')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _baseSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'Base Salary (GHS) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
              if (_compensationType == 'commission' || _compensationType == 'both')
                Column(
                  children: [
                    TextFormField(
                      controller: _commissionRateController,
                      decoration: const InputDecoration(
                        labelText: 'Commission Rate (%) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0 || rate > 100) {
                          return 'Enter 0-100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jobsFacilitatedController,
                      decoration: const InputDecoration(
                        labelText: 'Jobs Facilitated *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceFeesController,
                      decoration: const InputDecoration(
                        labelText: 'Total Service Fees (GHS) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              TextFormField(
                controller: _bonusesController,
                decoration: const InputDecoration(
                  labelText: 'Bonuses (GHS)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deductionsController,
                decoration: const InputDecoration(
                  labelText: 'Deductions (GHS)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.remove_circle),
                ),
                keyboardType: TextInputType.number,
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
          onPressed: _createPaycheck,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006B3C),
            foregroundColor: Colors.white,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildCompensationTypeChip(String label, String value) {
    final isSelected = _compensationType == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _compensationType = value;
            // Reset fields based on type
            if (value == 'fixed') {
              _commissionRateController.text = '0';
              _jobsFacilitatedController.text = '0';
              _serviceFeesController.text = '0';
            } else if (value == 'commission') {
              _baseSalaryController.text = '0';
            }
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006B3C).withOpacity(0.1) : Colors.grey[100],
            border: Border.all(
              color: isSelected ? const Color(0xFF006B3C) : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? const Color(0xFF006B3C) : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF006B3C) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPaycheck() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final baseSalary = double.parse(_baseSalaryController.text);
      final commissionRate = double.parse(_commissionRateController.text);
      final jobsFacilitated = int.parse(_jobsFacilitatedController.text);
      final serviceFees = double.parse(_serviceFeesController.text);
      final bonuses = double.tryParse(_bonusesController.text) ?? 0.0;
      final deductions = double.tryParse(_deductionsController.text) ?? 0.0;

      final payroll = await StaffPayrollService().calculatePaycheck(
        staffId: DateTime.now().millisecondsSinceEpoch.toString(),
        staffName: _staffNameController.text,
        staffEmail: _staffEmailController.text,
        staffRole: _selectedRole,
        periodStart: widget.periodStart,
        periodEnd: widget.periodEnd,
        jobsFacilitated: jobsFacilitated,
        totalServiceFees: serviceFees,
        bonuses: bonuses,
        deductions: deductions,
      );

      // Override with custom values
      final customPayroll = payroll.copyWith(
        baseSalary: baseSalary,
        commissionRate: commissionRate,
        commissionEarned: serviceFees * (commissionRate / 100),
        grossPay: baseSalary + (serviceFees * (commissionRate / 100)) + bonuses,
        netPay: baseSalary + (serviceFees * (commissionRate / 100)) + bonuses - deductions,
      );

      await StaffPayrollService().createPaycheck(customPayroll);

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paycheck created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRoleDisplayName(String role) {
    final roleNames = {
      'supportAgent': 'Support Agent',
      'dispatchCoordinator': 'Dispatch Coordinator',
      'onboardingSpecialist': 'Onboarding Specialist',
      'financeManager': 'Finance Manager',
      'operationsManager': 'Operations Manager',
      'admin': 'Administrator',
    };
    return roleNames[role] ?? role;
  }

  @override
  void dispose() {
    _staffNameController.dispose();
    _staffEmailController.dispose();
    _baseSalaryController.dispose();
    _commissionRateController.dispose();
    _jobsFacilitatedController.dispose();
    _serviceFeesController.dispose();
    _bonusesController.dispose();
    _deductionsController.dispose();
    super.dispose();
  }
}

// Compensation Settings Screen
class _CompensationSettingsScreen extends StatefulWidget {
  const _CompensationSettingsScreen();

  @override
  State<_CompensationSettingsScreen> createState() => _CompensationSettingsScreenState();
}

class _CompensationSettingsScreenState extends State<_CompensationSettingsScreen> {
  final StaffPayrollService _payrollService = StaffPayrollService();
  Map<String, StaffCompensationConfig> _configs = {};

  @override
  void initState() {
    super.initState();
    _configs = _payrollService.getAllCompensationConfigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compensation Settings'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _configs.length,
        itemBuilder: (context, index) {
          final entry = _configs.entries.elementAt(index);
          final config = entry.value;
          return _buildConfigCard(config);
        },
      ),
    );
  }

  Widget _buildConfigCard(StaffCompensationConfig config) {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getRoleDisplayName(config.role),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Salary:'),
                Text(
                  currency.format(config.baseSalary),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Commission Rate:'),
                Text(
                  '${config.commissionRate}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _editConfig(config),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editConfig(StaffCompensationConfig config) {
    final salaryController = TextEditingController(text: config.baseSalary.toString());
    final rateController = TextEditingController(text: config.commissionRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${_getRoleDisplayName(config.role)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: salaryController,
              decoration: const InputDecoration(
                labelText: 'Base Salary (GHS)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Commission Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final newConfig = StaffCompensationConfig(
                role: config.role,
                baseSalary: double.parse(salaryController.text),
                commissionRate: double.parse(rateController.text),
              );
              await _payrollService.updateCompensationConfig(newConfig);
              setState(() {
                _configs = _payrollService.getAllCompensationConfigs();
              });
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    final roleNames = {
      'supportAgent': 'Support Agent',
      'dispatchCoordinator': 'Dispatch Coordinator',
      'onboardingSpecialist': 'Onboarding Specialist',
      'financeManager': 'Finance Manager',
      'operationsManager': 'Operations Manager',
      'admin': 'Administrator',
      'superAdmin': 'Super Administrator',
    };
    return roleNames[role] ?? role;
  }
}
