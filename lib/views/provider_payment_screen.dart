import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProviderPaymentScreen extends StatefulWidget {
  const ProviderPaymentScreen({super.key});

  @override
  State<ProviderPaymentScreen> createState() => _ProviderPaymentScreenState();
}

class _ProviderPaymentScreenState extends State<ProviderPaymentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedPaymentMethod = 'Mobile Money';
  
  // Payment data
  final double availableBalance = 2400.0;
  final double pendingEarnings = 450.0;
  final double totalEarnings = 8950.0;
  final double thisWeekEarnings = 850.0;
  final double thisMonthEarnings = 2400.0;
  
  final List<Map<String, dynamic>> paymentHistory = [
    {
      'id': 'PAY_001',
      'amount': 850.0,
      'method': 'Mobile Money',
      'account': '024-XXX-XXXX',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'fees': 8.5,
      'reference': 'MM240721001',
    },
    {
      'id': 'PAY_002',
      'amount': 650.0,
      'method': 'Bank Transfer',
      'account': 'GCB Bank - XXXX-5678',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Completed',
      'fees': 5.0,
      'reference': 'BT240714001',
    },
    {
      'id': 'PAY_003',
      'amount': 1200.0,
      'method': 'Mobile Money',
      'account': '055-XXX-XXXX',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'status': 'Completed',
      'fees': 12.0,
      'reference': 'MM240707001',
    },
  ];

  final List<Map<String, dynamic>> earningsBreakdown = [
    {
      'service': 'House Cleaning',
      'jobs': 12,
      'gross': 1440.0,
      'commission': 216.0,
      'net': 1224.0,
      'tips': 50.0,
    },
    {
      'service': 'Plumbing',
      'jobs': 8,
      'gross': 2000.0,
      'commission': 360.0,
      'net': 1640.0,
      'tips': 120.0,
    },
    {
      'service': 'Food Delivery',
      'jobs': 25,
      'gross': 750.0,
      'commission': 90.0,
      'net': 660.0,
      'tips': 180.0,
    },
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
        title: const Text('Earnings & Payments'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showPaymentHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          // Earnings Summary
          Container(
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
                Row(
                  children: [
                    Expanded(
                      child: _buildEarningSummaryCard(
                        'Available Balance',
                        'GH₵${availableBalance.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEarningSummaryCard(
                        'Pending Earnings',
                        'GH₵${pendingEarnings.toStringAsFixed(2)}',
                        Icons.hourglass_empty,
                        Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildEarningSummaryCard(
                        'This Week',
                        'GH₵${thisWeekEarnings.toStringAsFixed(2)}',
                        Icons.calendar_view_week,
                        Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEarningSummaryCard(
                        'This Month',
                        'GH₵${thisMonthEarnings.toStringAsFixed(2)}',
                        Icons.calendar_month,
                        Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: availableBalance >= 100 ? _requestPayment : null,
                    icon: const Icon(Icons.payment),
                    label: const Text('Request Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _viewPaymentMethods,
                    icon: const Icon(Icons.account_balance),
                    label: const Text('Payment Methods'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF006B3C),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF006B3C),
            tabs: const [
              Tab(text: 'Payment History'),
              Tab(text: 'Earnings Breakdown'),
              Tab(text: 'Tips & Bonuses'),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentHistoryTab(),
                _buildEarningsBreakdownTab(),
                _buildTipsAndBonusesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningSummaryCard(String title, String amount, IconData icon, Color textColor) {
    return Column(
      children: [
        Icon(icon, color: textColor, size: 32),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paymentHistory.length,
      itemBuilder: (context, index) {
        final payment = paymentHistory[index];
        return _buildPaymentHistoryCard(payment);
      },
    );
  }

  Widget _buildPaymentHistoryCard(Map<String, dynamic> payment) {
    final isCompleted = payment['status'] == 'Completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon(payment['method']),
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['method'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        payment['account'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'GH₵${payment['amount'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(payment['date'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Fees: GH₵${payment['fees'].toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Ref: ${payment['reference']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdownTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Earnings by Service Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...earningsBreakdown.map((service) => _buildEarningsServiceCard(service)),
        const SizedBox(height: 20),
        _buildEarningsTotalsCard(),
      ],
    );
  }

  Widget _buildEarningsServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getServiceIcon(service['service']),
                    color: const Color(0xFF006B3C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['service'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${service['jobs']} jobs completed',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'GH₵${(service['net'] + service['tips']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEarningsDetailItem('Gross', service['gross']),
                _buildEarningsDetailItem('Commission', -service['commission']),
                _buildEarningsDetailItem('Tips', service['tips']),
                _buildEarningsDetailItem('Net', service['net']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsDetailItem(String label, double amount) {
    final isNegative = amount < 0;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'GH₵${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsTotalsCard() {
    final totalJobs = earningsBreakdown.fold<int>(0, (sum, service) => sum + service['jobs'] as int);
    final totalGross = earningsBreakdown.fold<double>(0, (sum, service) => sum + service['gross']);
    final totalCommission = earningsBreakdown.fold<double>(0, (sum, service) => sum + service['commission']);
    final totalTips = earningsBreakdown.fold<double>(0, (sum, service) => sum + service['tips']);
    final totalNet = earningsBreakdown.fold<double>(0, (sum, service) => sum + service['net']);
    
    return Card(
      color: const Color(0xFF006B3C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTotalItem('Total Jobs', totalJobs.toString(), Colors.white),
                _buildTotalItem('Gross Earnings', 'GH₵${totalGross.toStringAsFixed(0)}', Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTotalItem('Platform Commission', 'GH₵${totalCommission.toStringAsFixed(0)}', Colors.red[300]!),
                _buildTotalItem('Tips Received', 'GH₵${totalTips.toStringAsFixed(0)}', Colors.green[300]!),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white54),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Earnings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'GH₵${(totalNet + totalTips).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsAndBonusesTab() {
    final List<Map<String, dynamic>> tipsAndBonuses = [
      {
        'type': 'Customer Tip',
        'customer': 'Akosua M.',
        'service': 'House Cleaning',
        'amount': 20.0,
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'note': 'Excellent job!',
      },
      {
        'type': 'Performance Bonus',
        'customer': 'HomeLinkGH',
        'service': 'Monthly Achievement',
        'amount': 100.0,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'note': '4.8+ rating maintenance bonus',
      },
      {
        'type': 'Customer Tip',
        'customer': 'Joseph K.',
        'service': 'Plumbing',
        'amount': 50.0,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'note': 'Fixed the problem perfectly',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.amber[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'Tips & Bonuses This Month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GH₵${tipsAndBonuses.fold<double>(0, (sum, item) => sum + item['amount']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...tipsAndBonuses.map((item) => _buildTipBonusCard(item)),
      ],
    );
  }

  Widget _buildTipBonusCard(Map<String, dynamic> item) {
    final isBonus = item['type'] == 'Performance Bonus';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBonus ? Colors.purple.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isBonus ? Icons.emoji_events : Icons.favorite,
                color: isBonus ? Colors.purple : Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['type'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'From: ${item['customer']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    item['service'],
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  if (item['note'] != null)
                    Text(
                      '"${item['note']}"',
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'GH₵${item['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(item['date']),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'mobile money':
        return Icons.phone_android;
      case 'bank transfer':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'house cleaning':
        return Icons.cleaning_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'food delivery':
        return Icons.delivery_dining;
      default:
        return Icons.work;
    }
  }

  void _requestPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Balance: GH₵${availableBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Select Payment Method:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              items: ['Mobile Money', 'Bank Transfer', 'Cash Pickup']
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment will be processed within 24-48 hours.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
                  content: Text('Payment request submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Request Payment'),
          ),
        ],
      ),
    );
  }

  void _viewPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentMethodsScreen(),
      ),
    );
  }

  void _showPaymentHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Information'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Payment Schedule:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Daily payouts available for Mobile Money'),
              Text('• Bank transfers processed 2-3 times per week'),
              Text('• Minimum payout: GH₵100'),
              SizedBox(height: 16),
              Text(
                'Payment Fees:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Mobile Money: 1% (min GH₵2, max GH₵20)'),
              Text('• Bank Transfer: GH₵5 flat fee'),
              Text('• Cash Pickup: GH₵10 flat fee'),
              SizedBox(height: 16),
              Text(
                'Tips & Bonuses:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Customer tips are added to your earnings'),
              Text('• Performance bonuses for maintaining high ratings'),
              Text('• Referral bonuses for bringing new providers'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'type': 'Mobile Money',
      'name': 'MTN MoMo',
      'account': '024-XXX-XXXX',
      'isDefault': true,
      'icon': Icons.phone_android,
      'color': Colors.yellow,
    },
    {
      'type': 'Bank Account',
      'name': 'GCB Bank',
      'account': 'XXXX-XXXX-5678',
      'isDefault': false,
      'icon': Icons.account_balance,
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPaymentMethod,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
          const SizedBox(height: 20),
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method Requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Mobile Money: Must be registered in your name'),
                  Text('• Bank Account: Must match your verified identity'),
                  Text('• All methods require verification before use'),
                  Text('• Maximum 3 payment methods per account'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: method['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method['icon'],
                color: method['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (method['isDefault']) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
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
                    method['account'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    method['type'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'default') {
                  _setAsDefault(method);
                } else if (value == 'edit') {
                  _editPaymentMethod(method);
                } else if (value == 'delete') {
                  _deletePaymentMethod(method);
                }
              },
              itemBuilder: (context) => [
                if (!method['isDefault'])
                  const PopupMenuItem(
                    value: 'default',
                    child: Text('Set as Default'),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                if (paymentMethods.length > 1)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.orange),
              title: const Text('Mobile Money'),
              subtitle: const Text('MTN, Vodafone, AirtelTigo'),
              onTap: () {
                Navigator.pop(context);
                _showMobileMoneyForm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text('Bank Account'),
              subtitle: const Text('Local bank transfer'),
              onTap: () {
                Navigator.pop(context);
                _showBankAccountForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileMoneyForm() {
    final phoneController = TextEditingController();
    String selectedNetwork = 'MTN';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Mobile Money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedNetwork,
                items: ['MTN', 'Vodafone', 'AirtelTigo']
                    .map((network) => DropdownMenuItem(
                          value: network,
                          child: Text(network),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedNetwork = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Network',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: '024XXXXXXX',
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
                    content: Text('Mobile Money account added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankAccountForm() {
    final accountController = TextEditingController();
    String selectedBank = 'GCB Bank';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Bank Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBank,
                items: ['GCB Bank', 'Ecobank', 'Standard Chartered', 'Fidelity Bank', 'CAL Bank']
                    .map((bank) => DropdownMenuItem(
                          value: bank,
                          child: Text(bank),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedBank = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Bank',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank account added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _setAsDefault(Map<String, dynamic> method) {
    setState(() {
      for (var m in paymentMethods) {
        m['isDefault'] = false;
      }
      method['isDefault'] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${method['name']} set as default payment method'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPaymentMethod(Map<String, dynamic> method) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit payment method functionality')),
    );
  }

  void _deletePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                paymentMethods.remove(method);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${method['name']} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}