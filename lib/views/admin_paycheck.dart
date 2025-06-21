import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminPaycheckScreen extends StatefulWidget {
  const AdminPaycheckScreen({super.key});

  @override
  State<AdminPaycheckScreen> createState() => _AdminPaycheckScreenState();
}

class _AdminPaycheckScreenState extends State<AdminPaycheckScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'This Month';
  
  // Sample admin paycheck data
  final Map<String, dynamic> currentPaycheck = {
    'period': 'December 2024',
    'grossRevenue': 45800.0,
    'totalCommissions': 6870.0, // 15% of bookings
    'totalTax': 2290.0, // 5% of bookings
    'operationalCosts': 12500.0,
    'netProfit': 31540.0,
    'totalBookings': 312,
    'activeProviders': 89,
    'avgBookingValue': 146.79,
    'growthRate': 23.5,
    'customerSatisfaction': 4.7,
  };

  final List<Map<String, dynamic>> monthlyPaychecks = [
    {
      'month': 'December 2024',
      'revenue': 45800.0,
      'profit': 31540.0,
      'bookings': 312,
      'growth': 23.5,
    },
    {
      'month': 'November 2024',
      'revenue': 37200.0,
      'profit': 25680.0,
      'bookings': 253,
      'growth': 18.2,
    },
    {
      'month': 'October 2024',
      'revenue': 31500.0,
      'profit': 21750.0,
      'bookings': 215,
      'growth': 15.8,
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
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPaycheck(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(),
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
            // Revenue Summary Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main Revenue Card
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Net Profit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentPaycheck['period'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.trending_up, size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${currentPaycheck['growthRate']}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                              NumberFormat('#,###').format(currentPaycheck['netProfit']),
                              style: const TextStyle(
                                fontSize: 36,
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
                              child: _buildSummaryItem(
                                'Gross Revenue',
                                '₵${NumberFormat('#,###').format(currentPaycheck['grossRevenue'])}',
                                Icons.account_balance,
                              ),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey[300]),
                            Expanded(
                              child: _buildSummaryItem(
                                'Total Bookings',
                                currentPaycheck['totalBookings'].toString(),
                                Icons.assignment,
                              ),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey[300]),
                            Expanded(
                              child: _buildSummaryItem(
                                'Active Providers',
                                currentPaycheck['activeProviders'].toString(),
                                Icons.people,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Key Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Avg Booking',
                          '₵${currentPaycheck['avgBookingValue'].toStringAsFixed(0)}',
                          Icons.payments,
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Customer Rating',
                          '${currentPaycheck['customerSatisfaction']}⭐',
                          Icons.star,
                          const Color(0xFFF57C00),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Commission',
                          '₵${NumberFormat('#,###').format(currentPaycheck['totalCommissions'])}',
                          Icons.percent,
                          const Color(0xFF1565C0),
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
                          Tab(text: 'Breakdown'),
                          Tab(text: 'Analytics'),
                          Tab(text: 'History'),
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
                          _buildBreakdownTab(),
                          _buildAnalyticsTab(),
                          _buildHistoryTab(),
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

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF006B3C), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3C),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildBreakdownTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Breakdown
          const Text(
            'Revenue Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownCard(
            'Platform Commissions',
            currentPaycheck['totalCommissions'],
            currentPaycheck['grossRevenue'],
            Icons.percent,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildBreakdownCard(
            'Tax Collections',
            currentPaycheck['totalTax'],
            currentPaycheck['grossRevenue'],
            Icons.receipt,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildBreakdownCard(
            'Transaction Fees',
            currentPaycheck['grossRevenue'] - currentPaycheck['totalCommissions'] - currentPaycheck['totalTax'],
            currentPaycheck['grossRevenue'],
            Icons.payment,
            Colors.orange,
          ),
          
          const SizedBox(height: 24),
          
          // Operational Costs
          const Text(
            'Operational Costs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          _buildOperationalCostItem('Payment Processing', 3750.0, 0.30),
          _buildOperationalCostItem('Customer Support', 2500.0, 0.20),
          _buildOperationalCostItem('Marketing & Growth', 3125.0, 0.25),
          _buildOperationalCostItem('Technology & Infrastructure', 1875.0, 0.15),
          _buildOperationalCostItem('Operations & Admin', 1250.0, 0.10),
          
          const SizedBox(height: 24),
          
          // Bottom Line
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gross Revenue',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '₵${NumberFormat('#,###').format(currentPaycheck['grossRevenue'])}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Operational Costs',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    Text(
                      '-₵${NumberFormat('#,###').format(currentPaycheck['operationalCosts'])}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Net Profit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₵${NumberFormat('#,###').format(currentPaycheck['netProfit'])}',
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF006B3C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs Grid
          const Text(
            'Key Performance Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildKPICard('Revenue Growth', '+23.5%', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Profit Margin', '68.9%', Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKPICard('Provider Retention', '94.2%', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Booking Success', '97.8%', Colors.purple)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Chart Placeholder
          const Text(
            'Revenue Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
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
                  Icon(Icons.show_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Revenue Analytics Chart'),
                  Text('Integration Coming Soon', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top Performing Categories
          const Text(
            'Top Service Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceCategoryItem('House Cleaning', 89, 12500.0),
          _buildServiceCategoryItem('Grocery Shopping', 67, 8900.0),
          _buildServiceCategoryItem('Plumbing', 45, 11200.0),
          _buildServiceCategoryItem('Food Delivery', 111, 6700.0),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: monthlyPaychecks.length,
      itemBuilder: (context, index) {
        final paycheck = monthlyPaychecks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                child: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF006B3C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paycheck['month'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${paycheck['bookings']} bookings • ${paycheck['growth']}% growth',
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
                    '₵${NumberFormat('#,###').format(paycheck['profit'])}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                  Text(
                    'Net Profit',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownCard(String title, double amount, double total, IconData icon, Color color) {
    final percentage = (amount / total * 100).toStringAsFixed(1);
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
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
                  '$percentage% of gross revenue',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₵${NumberFormat('#,###').format(amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalCostItem(String category, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: const TextStyle(fontSize: 14),
          ),
          Row(
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '₵${NumberFormat('#,###').format(amount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildServiceCategoryItem(String category, int bookings, double revenue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$bookings bookings',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              '₵${NumberFormat('#,###').format(revenue)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadPaycheck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Paycheck'),
        content: const Text('Generate PDF report for this period?'),
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
                  content: Text('Paycheck report downloaded!'),
                  backgroundColor: Color(0xFF006B3C),
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    // Navigate to admin settings
  }
}