import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key});

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Today';
  
  // Sample data - replace with Firebase data
  final double totalEarnings = 2850.0;
  final double pendingEarnings = 450.0;
  final double availableBalance = 2400.0;
  final int totalJobs = 47;
  final double avgRating = 4.8;

  final List<Map<String, dynamic>> recentEarnings = [
    {
      'service': 'House Cleaning',
      'customer': 'Akosua M.',
      'amount': 120.0,
      'commission': 18.0,
      'net': 102.0,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'completed',
      'location': 'East Legon',
      'rating': 5.0,
    },
    {
      'service': 'Grocery Shopping',
      'customer': 'Kwame A.',
      'amount': 80.0,
      'commission': 12.0,
      'net': 68.0,
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'pending',
      'location': 'Airport Residential',
      'rating': null,
    },
    {
      'service': 'Plumbing Repair',
      'customer': 'Ama D.',
      'amount': 250.0,
      'commission': 37.5,
      'net': 212.5,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'completed',
      'location': 'Cantonments',
      'rating': 4.5,
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
        title: const Text('My Earnings'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // Navigate to detailed analytics
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006B3C),
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Earnings Summary Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Total Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006B3C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Diaspora Friendly',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF006B3C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '₵',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                            Text(
                              availableBalance.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                            const Text(
                              '.00',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showCashOutOptions(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006B3C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.account_balance_wallet, size: 20),
                                    SizedBox(width: 8),
                                    Text('Cash Out'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showEarningsBreakdown(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF006B3C),
                                  side: const BorderSide(color: Color(0xFF006B3C)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pie_chart, size: 20),
                                    SizedBox(width: 8),
                                    Text('Breakdown'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickStat(
                          'Total Earned',
                          '₵${totalEarnings.toStringAsFixed(0)}',
                          Icons.trending_up,
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStat(
                          'Jobs Done',
                          totalJobs.toString(),
                          Icons.assignment_turned_in,
                          const Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStat(
                          'Avg Rating',
                          avgRating.toString(),
                          Icons.star,
                          const Color(0xFFF57C00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs and Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Recent'),
                          Tab(text: 'Analytics'),
                          Tab(text: 'Payouts'),
                        ],
                        indicator: BoxDecoration(
                          color: const Color(0xFF006B3C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRecentEarnings(),
                          _buildAnalytics(),
                          _buildPayouts(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEarnings() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recentEarnings.length,
      itemBuilder: (context, index) {
        final earning = recentEarnings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earning['service'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${earning['customer']} • ${earning['location']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₵${earning['net'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: earning['status'] == 'completed' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          earning['status'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: earning['status'] == 'completed' 
                                ? Colors.green 
                                : Colors.orange,
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
                    DateFormat('MMM dd, yyyy • HH:mm').format(earning['date']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (earning['rating'] != null)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          earning['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Original: ₵${earning['amount'].toStringAsFixed(0)}', 
                       style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 16),
                  Text('Commission: ₵${earning['commission'].toStringAsFixed(0)}', 
                       style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            children: ['Today', 'Week', 'Month', 'Year'].map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedPeriod = period),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF006B3C) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Charts and Analytics would go here
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Analytics Chart'),
                  Text('Coming Soon', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Performance Metrics
          _buildMetricCard('Best Performing Service', 'House Cleaning', '₵1,200 this month'),
          const SizedBox(height: 12),
          _buildMetricCard('Peak Hours', '10:00 AM - 2:00 PM', '65% of bookings'),
          const SizedBox(height: 12),
          _buildMetricCard('Customer Retention', '78%', 'Repeat customers'),
        ],
      ),
    );
  }

  Widget _buildPayouts() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildPayoutCard(
          'Mobile Money - MTN',
          '₵800.00',
          'Completed',
          'Dec 15, 2024',
          Icons.phone_android,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildPayoutCard(
          'Bank Transfer - GCB',
          '₵1,200.00',
          'Processing',
          'Dec 18, 2024',
          Icons.account_balance,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildPayoutCard(
          'Mobile Money - Vodafone',
          '₵400.00',
          'Completed',
          'Dec 10, 2024',
          Icons.phone_android,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(String method, String amount, String status, String date, IconData icon, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: const Color(0xFF006B3C)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
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
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCashOutOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Cash Out Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCashOutOption(
                      'Mobile Money',
                      'MTN, Vodafone, AirtelTigo',
                      Icons.phone_android,
                      '₵5 fee • Instant',
                    ),
                    const SizedBox(height: 12),
                    _buildCashOutOption(
                      'Bank Transfer',
                      'All Ghana banks supported',
                      Icons.account_balance,
                      '₵2 fee • 1-2 business days',
                    ),
                    const SizedBox(height: 12),
                    _buildCashOutOption(
                      'Diaspora Transfer',
                      'International bank transfer',
                      Icons.send,
                      '₵15 fee • 3-5 business days',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashOutOption(String title, String subtitle, IconData icon, String fee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: const Color(0xFF006B3C)),
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  fee,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF006B3C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ],
      ),
    );
  }

  void _showEarningsBreakdown() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earnings Breakdown'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBreakdownRow('Service Fee', '₵120.00'),
            _buildBreakdownRow('Platform Commission (15%)', '-₵18.00'),
            _buildBreakdownRow('Tax (5%)', '-₵6.00'),
            _buildBreakdownRow('Processing Fee', '-₵2.00'),
            const Divider(),
            _buildBreakdownRow('Your Earnings', '₵94.00', isBold: true),
          ],
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

  Widget _buildBreakdownRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: amount.startsWith('-') ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}