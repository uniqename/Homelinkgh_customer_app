import 'package:flutter/material.dart';
import '../models/provider.dart';

class EarningsPayoutSystem extends StatefulWidget {
  final Provider? provider;

  const EarningsPayoutSystem({super.key, this.provider});

  @override
  State<EarningsPayoutSystem> createState() => _EarningsPayoutSystemState();
}

class _EarningsPayoutSystemState extends State<EarningsPayoutSystem>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Earnings data
  final double _todayEarnings = 340.0;
  final double _weeklyEarnings = 1250.0;
  final double _monthlyEarnings = 4800.0;
  final double _totalEarnings = 18500.0;
  final double _availableBalance = 850.0;
  final double _pendingEarnings = 420.0;

  // Recent earnings
  final List<EarningRecord> _recentEarnings = [
    EarningRecord(
      id: 'earn_001',
      jobTitle: 'Kitchen Plumbing Repair',
      customerName: 'Akosua Mensah',
      amount: 180.0,
      platformFee: 18.0,
      netAmount: 162.0,
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: EarningStatus.completed,
      paymentMethod: 'Mobile Money',
    ),
    EarningRecord(
      id: 'earn_002',
      jobTitle: 'Electrical Installation',
      customerName: 'Kwame Asante',
      amount: 120.0,
      platformFee: 12.0,
      netAmount: 108.0,
      completedAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: EarningStatus.pending,
      paymentMethod: 'Bank Transfer',
    ),
    EarningRecord(
      id: 'earn_003',
      jobTitle: 'Deep House Cleaning',
      customerName: 'Ama Osei',
      amount: 250.0,
      platformFee: 25.0,
      netAmount: 225.0,
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: EarningStatus.completed,
      paymentMethod: 'Mobile Money',
    ),
  ];

  // Payout history
  final List<PayoutRecord> _payoutHistory = [
    PayoutRecord(
      id: 'payout_001',
      amount: 500.0,
      method: PayoutMethod.mobileMoney,
      destination: 'MTN Mobile Money - **** 4567',
      initiatedAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      status: PayoutStatus.completed,
      transactionId: 'TXN123456789',
      processingFee: 5.0,
    ),
    PayoutRecord(
      id: 'payout_002',
      amount: 750.0,
      method: PayoutMethod.bankTransfer,
      destination: 'GCB Bank - ****5678',
      initiatedAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 4)),
      status: PayoutStatus.completed,
      transactionId: 'TXN987654321',
      processingFee: 15.0,
    ),
    PayoutRecord(
      id: 'payout_003',
      amount: 300.0,
      method: PayoutMethod.mobileMoney,
      destination: 'Vodafone Cash - **** 2345',
      initiatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: PayoutStatus.processing,
      processingFee: 3.0,
    ),
  ];

  // Payout methods
  final List<PayoutMethodConfig> _payoutMethods = [
    PayoutMethodConfig(
      id: 'mtn_mm',
      type: PayoutMethod.mobileMoney,
      provider: 'MTN Mobile Money',
      accountNumber: '**** 4567',
      isDefault: true,
      icon: Icons.phone_android,
      processingTime: 'Instant',
      fee: '1% (min GH₵2)',
    ),
    PayoutMethodConfig(
      id: 'gcb_bank',
      type: PayoutMethod.bankTransfer,
      provider: 'GCB Bank',
      accountNumber: '**** 5678',
      isDefault: false,
      icon: Icons.account_balance,
      processingTime: '1-2 business days',
      fee: 'GH₵5 + 2%',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Earnings & Payouts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 20),
                  SizedBox(width: 4),
                  Text('Earnings'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payments, size: 20),
                  SizedBox(width: 4),
                  Text('Payouts'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 4),
                  Text('Methods'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarningsTab(),
          _buildPayoutsTab(),
          _buildMethodsTab(),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance overview
          _buildBalanceOverview(),
          const SizedBox(height: 20),
          
          // Earnings summary
          _buildEarningsSummary(),
          const SizedBox(height: 20),
          
          // Quick payout button
          _buildQuickPayoutButton(),
          const SizedBox(height: 20),
          
          // Recent earnings header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Earnings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _viewAllEarnings,
                child: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Recent earnings list
          ..._recentEarnings.map((earning) => _buildEarningCard(earning)).toList(),
        ],
      ),
    );
  }

  Widget _buildBalanceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GH₵${_availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'Pending',
                  'GH₵${_pendingEarnings.toStringAsFixed(0)}',
                  Icons.schedule,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildBalanceItem(
                  'Total Earned',
                  'GH₵${_totalEarnings.toStringAsFixed(0)}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String amount, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEarningSummaryItem('Today', 'GH₵$_todayEarnings', Colors.green),
              ),
              Expanded(
                child: _buildEarningSummaryItem('This Week', 'GH₵$_weeklyEarnings', Colors.blue),
              ),
              Expanded(
                child: _buildEarningSummaryItem('This Month', 'GH₵$_monthlyEarnings', Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningSummaryItem(String period, String amount, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.trending_up,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          period,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPayoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payments,
              color: Color(0xFF2E7D32),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instant Payout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Get your earnings in your mobile money account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _availableBalance > 0 ? _initiateQuickPayout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Payout'),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningCard(EarningRecord earning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  earning.jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEarningStatusColor(earning.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getEarningStatusText(earning.status),
                  style: TextStyle(
                    color: _getEarningStatusColor(earning.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            earning.customerName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gross Amount',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'GH₵${earning.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Platform Fee',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'GH₵${earning.platformFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Your Earnings',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'GH₵${earning.netAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Completed ${_formatTimeAgo(earning.completedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                earning.paymentMethod,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutsTab() {
    return Column(
      children: [
        // Payout summary header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildPayoutSummaryItem(
                  'Available',
                  'GH₵${_availableBalance.toStringAsFixed(0)}',
                  Colors.green,
                  Icons.account_balance_wallet,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildPayoutSummaryItem(
                  'Processing',
                  '1 payout',
                  Colors.orange,
                  Icons.schedule,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildPayoutSummaryItem(
                  'Completed',
                  '${_payoutHistory.where((p) => p.status == PayoutStatus.completed).length}',
                  Colors.blue,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ),

        // Request payout button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: ElevatedButton.icon(
            onPressed: _availableBalance >= 50 ? _requestPayout : null,
            icon: const Icon(Icons.payments),
            label: const Text('Request Payout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Payout history
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _payoutHistory.length,
            itemBuilder: (context, index) {
              return _buildPayoutCard(_payoutHistory[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutCard(PayoutRecord payout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMethodColor(payout.method).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(payout.method),
                  color: _getMethodColor(payout.method),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GH₵${payout.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      payout.destination,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPayoutStatusColor(payout.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPayoutStatusText(payout.status),
                  style: TextStyle(
                    color: _getPayoutStatusColor(payout.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (payout.processingFee > 0) ...[
            Row(
              children: [
                const Text(
                  'Processing Fee: ',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'GH₵${payout.processingFee.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Initiated ${_formatTimeAgo(payout.initiatedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (payout.completedAt != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  'Completed ${_formatTimeAgo(payout.completedAt!)}',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ],
          ),
          if (payout.transactionId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Transaction ID: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  payout.transactionId!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add new method button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add_circle,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add New Payout Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _addPayoutMethod,
                  child: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Current methods
          const Text(
            'Your Payout Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Methods list
          ..._payoutMethods.map((method) => _buildPayoutMethodCard(method)).toList(),

          const SizedBox(height: 24),

          // Payout info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Payout Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Minimum payout amount: GH₵50',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Mobile Money: Instant transfer with 1% fee (min GH₵2)',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Bank Transfer: 1-2 business days with GH₵5 + 2% fee',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Payouts are processed 24/7 for Mobile Money',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMethodCard(PayoutMethodConfig method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: method.isDefault 
            ? Border.all(color: const Color(0xFF2E7D32), width: 2)
            : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMethodColor(method.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method.icon,
                  color: _getMethodColor(method.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.provider,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (method.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      method.accountNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMethodAction(method, value),
                itemBuilder: (context) => [
                  if (!method.isDefault)
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Text('Set as Default'),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Processing: ${method.processingTime}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Fee: ${method.fee}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getEarningStatusColor(EarningStatus status) {
    switch (status) {
      case EarningStatus.completed:
        return Colors.green;
      case EarningStatus.pending:
        return Colors.orange;
      case EarningStatus.processing:
        return Colors.blue;
    }
  }

  String _getEarningStatusText(EarningStatus status) {
    switch (status) {
      case EarningStatus.completed:
        return 'COMPLETED';
      case EarningStatus.pending:
        return 'PENDING';
      case EarningStatus.processing:
        return 'PROCESSING';
    }
  }

  Color _getPayoutStatusColor(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.completed:
        return Colors.green;
      case PayoutStatus.processing:
        return Colors.blue;
      case PayoutStatus.failed:
        return Colors.red;
      case PayoutStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getPayoutStatusText(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.completed:
        return 'COMPLETED';
      case PayoutStatus.processing:
        return 'PROCESSING';
      case PayoutStatus.failed:
        return 'FAILED';
      case PayoutStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color _getMethodColor(PayoutMethod method) {
    switch (method) {
      case PayoutMethod.mobileMoney:
        return Colors.green;
      case PayoutMethod.bankTransfer:
        return Colors.blue;
    }
  }

  IconData _getMethodIcon(PayoutMethod method) {
    switch (method) {
      case PayoutMethod.mobileMoney:
        return Icons.phone_android;
      case PayoutMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Action methods
  void _viewAllEarnings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Earnings'),
        content: const Text('This would show a detailed earnings history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _initiateQuickPayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payout GH₵${_availableBalance.toStringAsFixed(2)} to your default method?'),
            const SizedBox(height: 12),
            const Text(
              'MTN Mobile Money - **** 4567',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Processing fee: GH₵8.50 (1%)',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive: GH₵${(_availableBalance - 8.50).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout initiated! Funds will be transferred instantly.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Confirm Payout'),
          ),
        ],
      ),
    );
  }

  void _requestPayout() {
    showDialog(
      context: context,
      builder: (context) {
        double payoutAmount = _availableBalance;
        return AlertDialog(
          title: const Text('Request Payout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Payout Amount',
                  prefixText: 'GH₵',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: payoutAmount.toStringAsFixed(2)),
                onChanged: (value) {
                  payoutAmount = double.tryParse(value) ?? _availableBalance;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select payout method:'),
              // Add payout method selection here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payout request submitted!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Request'),
            ),
          ],
        );
      },
    );
  }

  void _addPayoutMethod() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payout Method'),
        content: const Text('This would show a form to add new payout methods.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New payout method added!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleMethodAction(PayoutMethodConfig method, String action) {
    switch (action) {
      case 'set_default':
        setState(() {
          for (var m in _payoutMethods) {
            m.isDefault = m.id == method.id;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${method.provider} set as default')),
        );
        break;
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Edit ${method.provider}'),
            content: const Text('This would show an edit form.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Method updated!')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Method'),
            content: Text('Are you sure you want to delete ${method.provider}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _payoutMethods.remove(method);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Method deleted')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

// Data models
class EarningRecord {
  final String id;
  final String jobTitle;
  final String customerName;
  final double amount;
  final double platformFee;
  final double netAmount;
  final DateTime completedAt;
  final EarningStatus status;
  final String paymentMethod;

  EarningRecord({
    required this.id,
    required this.jobTitle,
    required this.customerName,
    required this.amount,
    required this.platformFee,
    required this.netAmount,
    required this.completedAt,
    required this.status,
    required this.paymentMethod,
  });
}

class PayoutRecord {
  final String id;
  final double amount;
  final PayoutMethod method;
  final String destination;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final PayoutStatus status;
  final String? transactionId;
  final double processingFee;

  PayoutRecord({
    required this.id,
    required this.amount,
    required this.method,
    required this.destination,
    required this.initiatedAt,
    this.completedAt,
    required this.status,
    this.transactionId,
    required this.processingFee,
  });
}

class PayoutMethodConfig {
  final String id;
  final PayoutMethod type;
  final String provider;
  final String accountNumber;
  bool isDefault;
  final IconData icon;
  final String processingTime;
  final String fee;

  PayoutMethodConfig({
    required this.id,
    required this.type,
    required this.provider,
    required this.accountNumber,
    required this.isDefault,
    required this.icon,
    required this.processingTime,
    required this.fee,
  });
}

enum EarningStatus {
  completed,
  pending,
  processing,
}

enum PayoutStatus {
  completed,
  processing,
  failed,
  cancelled,
}

enum PayoutMethod {
  mobileMoney,
  bankTransfer,
}