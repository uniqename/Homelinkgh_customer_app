import 'package:flutter/material.dart';

class AdminCommissionManagementScreen extends StatefulWidget {
  const AdminCommissionManagementScreen({super.key});

  @override
  State<AdminCommissionManagementScreen> createState() => _AdminCommissionManagementScreenState();
}

class _AdminCommissionManagementScreenState extends State<AdminCommissionManagementScreen> {
  final Map<String, double> _commissionRates = {
    'House Cleaning': 15.0,
    'Plumbing': 18.0,
    'Electrical Services': 20.0,
    'Food Delivery': 12.0,
    'Beauty Services': 25.0,
    'Transportation': 10.0,
    'Laundry Service': 15.0,
    'AC Repair': 22.0,
    'Generator Service': 20.0,
    'Cooking Service': 18.0,
    'Grocery Shopping': 8.0,
  };

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each service
    _commissionRates.forEach((service, rate) {
      _controllers[service] = TextEditingController(text: rate.toString());
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commission Management'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Platform Commission Rates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set commission percentages for each service category',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Commission rates list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _commissionRates.length,
              itemBuilder: (context, index) {
                final service = _commissionRates.keys.elementAt(index);
                final rate = _commissionRates[service]!;
                return _buildCommissionCard(service, rate);
              },
            ),
          ),
          
          // Save button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(String service, double currentRate) {
    final controller = _controllers[service]!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getServiceCategoryColor(service),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getServiceCategory(service),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commission Rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                suffixText: '%',
                              ),
                              onChanged: (value) {
                                final newRate = double.tryParse(value);
                                if (newRate != null && newRate >= 0 && newRate <= 50) {
                                  setState(() {
                                    _commissionRates[service] = newRate;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => _adjustRate(service, 0.5),
                                icon: const Icon(Icons.keyboard_arrow_up),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                              IconButton(
                                onPressed: () => _adjustRate(service, -0.5),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Examples',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRevenueExample('GH₵100 job', 100, currentRate),
                      _buildRevenueExample('GH₵500 job', 500, currentRate),
                      _buildRevenueExample('GH₵1000 job', 1000, currentRate),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueExample(String label, double amount, double rate) {
    final commission = amount * (rate / 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            'GH₵${commission.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceCategory(String service) {
    if (['House Cleaning', 'Laundry Service'].contains(service)) return 'Cleaning';
    if (['Plumbing', 'Electrical Services', 'AC Repair', 'Generator Service'].contains(service)) return 'Technical';
    if (['Beauty Services'].contains(service)) return 'Beauty';
    if (['Food Delivery', 'Grocery Shopping', 'Cooking Service'].contains(service)) return 'Food';
    if (['Transportation'].contains(service)) return 'Transport';
    return 'General';
  }

  Color _getServiceCategoryColor(String service) {
    final category = _getServiceCategory(service);
    switch (category) {
      case 'Cleaning':
        return Colors.blue;
      case 'Technical':
        return Colors.orange;
      case 'Beauty':
        return Colors.pink;
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _adjustRate(String service, double adjustment) {
    final currentRate = _commissionRates[service]!;
    final newRate = (currentRate + adjustment).clamp(0.0, 50.0);
    
    setState(() {
      _commissionRates[service] = newRate;
      _controllers[service]!.text = newRate.toString();
    });
  }

  void _saveChanges() {
    // Validate all rates
    for (final entry in _commissionRates.entries) {
      final rate = entry.value;
      if (rate < 0 || rate > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid rate for ${entry.key}: Must be between 0% and 50%'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Save changes
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Commission Changes'),
        content: const Text('Are you sure you want to save these commission rate changes? This will affect all future bookings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Here you would save to your backend/database
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commission rates saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all commission rates to their default values. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Reset to default rates
              setState(() {
                _commissionRates.clear();
                _commissionRates.addAll({
                  'House Cleaning': 15.0,
                  'Plumbing': 18.0,
                  'Electrical Services': 20.0,
                  'Food Delivery': 12.0,
                  'Beauty Services': 25.0,
                  'Transportation': 10.0,
                  'Laundry Service': 15.0,
                  'AC Repair': 22.0,
                  'Generator Service': 20.0,
                  'Cooking Service': 18.0,
                  'Grocery Shopping': 8.0,
                });
                
                // Update controllers
                _commissionRates.forEach((service, rate) {
                  _controllers[service]!.text = rate.toString();
                });
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commission rates reset to defaults'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}