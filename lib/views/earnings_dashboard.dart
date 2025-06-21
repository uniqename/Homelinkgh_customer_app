import 'package:flutter/material.dart';

class EarningsDashboard extends StatefulWidget {
  const EarningsDashboard({super.key});

  @override
  State<EarningsDashboard> createState() => _EarningsDashboardState();
}

class _EarningsDashboardState extends State<EarningsDashboard> {
  String selectedPeriod = 'Today';
  
  final List<String> periods = ['Today', 'This Week', 'This Month', 'All Time'];
  
  final Map<String, Map<String, dynamic>> earningsData = {
    'Today': {
      'total': 156.75,
      'trips': 12,
      'hours': 6.5,
      'tips': 23.50,
      'bonuses': 15.00,
      'deliveries': [
        {'time': '2:30 PM', 'restaurant': 'KFC', 'amount': 18.50, 'tip': 3.00, 'distance': '2.1 km'},
        {'time': '1:45 PM', 'restaurant': 'Pizza Hut', 'amount': 22.75, 'tip': 5.00, 'distance': '3.2 km'},
        {'time': '12:15 PM', 'restaurant': 'Burger King', 'amount': 15.25, 'tip': 2.50, 'distance': '1.8 km'},
        {'time': '11:30 AM', 'restaurant': 'Subway', 'amount': 12.80, 'tip': 2.00, 'distance': '1.5 km'},
      ]
    },
    'This Week': {
      'total': 1250.40,
      'trips': 89,
      'hours': 45.5,
      'tips': 178.25,
      'bonuses': 95.00,
      'deliveries': []
    },
    'This Month': {
      'total': 4890.75,
      'trips': 342,
      'hours': 168.5,
      'tips': 689.50,
      'bonuses': 285.00,
      'deliveries': []
    },
    'All Time': {
      'total': 15670.25,
      'trips': 1156,
      'hours': 578.5,
      'tips': 2234.75,
      'bonuses': 890.00,
      'deliveries': []
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = earningsData[selectedPeriod]!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Dashboard'),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => _showCashOutDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withValues(alpha: 0.1), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: periods.map((period) {
                    final isSelected = selectedPeriod == period;
                    return GestureDetector(
                      onTap: () => setState(() => selectedPeriod = period),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Earnings',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₵${data['total'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildEarningsStat('Trips', data['trips'].toString(), Icons.delivery_dining),
                          _buildEarningsStat('Hours', data['hours'].toString(), Icons.access_time),
                          _buildEarningsStat('Avg/Trip', '₵${(data['total'] / data['trips']).toStringAsFixed(2)}', Icons.trending_up),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildBreakdownCard('Base Pay', data['total'] - data['tips'] - data['bonuses'], Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildBreakdownCard('Tips', data['tips'], Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildBreakdownCard('Bonuses', data['bonuses'], Colors.purple)),
              ],
            ),
          ),
          if (selectedPeriod == 'Today' && data['deliveries'].isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Deliveries',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _showAllDeliveries(),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data['deliveries'].length,
                itemBuilder: (context, index) {
                  final delivery = data['deliveries'][index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        child: const Icon(Icons.restaurant, color: Colors.green),
                      ),
                      title: Text(delivery['restaurant']),
                      subtitle: Text('${delivery['time']} • ${delivery['distance']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₵${delivery['amount'].toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '+₵${delivery['tip'].toStringAsFixed(2)} tip',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Earnings Summary for $selectedPeriod',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detailed breakdown available for daily view',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCashOutDialog(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
        label: const Text('Cash Out', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEarningsStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(String title, double amount, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₵${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCashOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cash Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Available Balance'),
            const SizedBox(height: 8),
            Text(
              '₵${earningsData[selectedPeriod]!['total'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose cash out method:'),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Transfer'),
              subtitle: const Text('1-2 business days • Free'),
              onTap: () => _processCashOut('Bank Transfer'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Mobile Money'),
              subtitle: const Text('Instant • ₵2.50 fee'),
              onTap: () => _processCashOut('Mobile Money'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _processCashOut(String method) {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cash out via $method initiated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showAllDeliveries() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Deliveries Today'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: earningsData['Today']!['deliveries'].length,
            itemBuilder: (context, index) {
              final delivery = earningsData['Today']!['deliveries'][index];
              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(delivery['restaurant']),
                subtitle: Text('${delivery['time']} • ${delivery['distance']}'),
                trailing: Text('₵${(delivery['amount'] + delivery['tip']).toStringAsFixed(2)}'),
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
}