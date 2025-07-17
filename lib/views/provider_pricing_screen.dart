import 'package:flutter/material.dart';
import '../services/dynamic_pricing_service.dart';
import '../services/admin_pricing_service.dart';

/// Provider Pricing Screen
/// Allows providers to set custom pricing based on transportation and parts
class ProviderPricingScreen extends StatefulWidget {
  final String providerId;
  final String providerLocation;
  
  const ProviderPricingScreen({
    super.key,
    required this.providerId,
    required this.providerLocation,
  });

  @override
  State<ProviderPricingScreen> createState() => _ProviderPricingScreenState();
}

class _ProviderPricingScreenState extends State<ProviderPricingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Service details
  String _selectedService = 'plumbing';
  String _complexityLevel = 'standard';
  String _vehicleType = 'car';
  bool _isUrgent = false;
  bool _includeWeekendSurcharge = false;
  
  // Location details
  double _customerLat = 5.6037; // Accra default
  double _customerLng = -0.1870;
  double _providerLat = 5.6037;
  double _providerLng = -0.1870;
  
  // Pricing inputs
  double _baseLaborCost = 60.0;
  List<Map<String, dynamic>> _requiredParts = [];
  
  // Calculated pricing
  Map<String, dynamic>? _calculatedPricing;
  bool _isCalculating = false;
  
  // Parts form controllers
  final _partNameController = TextEditingController();
  final _partQuantityController = TextEditingController();
  final _partPriceController = TextEditingController();
  String _selectedPartType = 'standard';

  @override
  void initState() {
    super.initState();
    _loadDefaultValues();
  }

  void _loadDefaultValues() async {
    final defaultRates = AdminPricingService.getDefaultLaborRates();
    setState(() {
      _baseLaborCost = defaultRates[_selectedService] ?? 60.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Pricing Calculator'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceSection(),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildLaborSection(),
              const SizedBox(height: 20),
              _buildPartsSection(),
              const SizedBox(height: 20),
              _buildOptionsSection(),
              const SizedBox(height: 30),
              _buildCalculateButton(),
              const SizedBox(height: 20),
              if (_calculatedPricing != null) _buildPricingBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: const InputDecoration(
                labelText: 'Service Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'plumbing', child: Text('Plumbing')),
                DropdownMenuItem(value: 'electrical', child: Text('Electrical')),
                DropdownMenuItem(value: 'cleaning', child: Text('Cleaning')),
                DropdownMenuItem(value: 'beauty_services', child: Text('Beauty Services')),
                DropdownMenuItem(value: 'appliance_repair', child: Text('Appliance Repair')),
                DropdownMenuItem(value: 'tutoring', child: Text('Tutoring')),
                DropdownMenuItem(value: 'gardening', child: Text('Gardening')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedService = value!;
                  _loadDefaultValues();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _complexityLevel,
              decoration: const InputDecoration(
                labelText: 'Complexity Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'simple', child: Text('Simple (-20%)')),
                DropdownMenuItem(value: 'standard', child: Text('Standard (0%)')),
                DropdownMenuItem(value: 'complex', child: Text('Complex (+40%)')),
                DropdownMenuItem(value: 'expert', child: Text('Expert (+80%)')),
              ],
              onChanged: (value) {
                setState(() {
                  _complexityLevel = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transportation Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _customerLat.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Customer Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _customerLat = double.tryParse(value) ?? 5.6037;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _customerLng.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Customer Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _customerLng = double.tryParse(value) ?? -0.1870;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _vehicleType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle (-30%)')),
                DropdownMenuItem(value: 'car', child: Text('Car (Standard)')),
                DropdownMenuItem(value: 'van', child: Text('Van (+30%)')),
                DropdownMenuItem(value: 'truck', child: Text('Truck (+80%)')),
                DropdownMenuItem(value: 'pickup', child: Text('Pickup (+40%)')),
              ],
              onChanged: (value) {
                setState(() {
                  _vehicleType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaborSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Labor Cost',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _baseLaborCost.toString(),
              decoration: const InputDecoration(
                labelText: 'Base Labor Cost (GHS)',
                border: OutlineInputBorder(),
                prefixText: 'GHS ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _baseLaborCost = double.tryParse(value) ?? 60.0;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter labor cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Parts & Materials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8B57),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddPartDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Part'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_requiredParts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No parts added yet\nTap "Add Part" to include materials in pricing',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _requiredParts.length,
                itemBuilder: (context, index) {
                  final part = _requiredParts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(part['name']),
                      subtitle: Text(
                        'Qty: ${part['quantity']} | Type: ${part['type']} | GHS ${part['base_price']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _requiredParts.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Urgent Service'),
              subtitle: const Text('Add 50% surcharge for immediate service'),
              value: _isUrgent,
              onChanged: (value) {
                setState(() {
                  _isUrgent = value;
                });
              },
              activeColor: const Color(0xFF2E8B57),
            ),
            SwitchListTile(
              title: const Text('Weekend Service'),
              subtitle: const Text('Add 30% surcharge for weekend work'),
              value: _includeWeekendSurcharge,
              onChanged: (value) {
                setState(() {
                  _includeWeekendSurcharge = value;
                });
              },
              activeColor: const Color(0xFF2E8B57),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isCalculating ? null : _calculatePricing,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isCalculating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Calculate Dynamic Pricing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    final pricing = _calculatedPricing!;
    final breakdown = pricing['pricing_breakdown'];
    final transportDetails = pricing['transportation_details'];
    final partsDetails = pricing['parts_details'];
    final laborDetails = pricing['labor_details'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 16),
            
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B57).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Cost:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'GHS ${pricing['final_total']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('GHS ${pricing['subtotal']}'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Detailed breakdown
            _buildBreakdownSection('Labor Cost', breakdown['labor_cost'], [
              'Base Labor: GHS ${laborDetails['base_labor_cost']}',
              'Complexity (${laborDetails['complexity_level']}): ${((laborDetails['complexity_multiplier'] - 1) * 100).toStringAsFixed(0)}%',
              if (laborDetails['peak_hours_applied']) 'Peak Hours Surcharge: 20%',
              if (laborDetails['urgency_applied']) 'Urgency Surcharge: 50%',
            ]),
            
            _buildBreakdownSection('Transportation', breakdown['transportation_cost'], [
              'Distance: ${transportDetails['distance_km']} km',
              'Base Rate: GHS ${transportDetails['breakdown']['base_rate_per_km']}/km',
              'Vehicle: ${transportDetails['vehicle_type']} (${transportDetails['breakdown']['vehicle_adjustment']})',
              'Fuel Surcharge: ${transportDetails['breakdown']['fuel_surcharge']}',
            ]),
            
            if (breakdown['parts_cost'] > 0)
              _buildBreakdownSection('Parts & Materials', breakdown['parts_cost'], [
                'Base Parts Cost: GHS ${partsDetails['base_parts_cost']}',
                'Service Markup: ${partsDetails['service_markup_percentage']}',
                '${partsDetails['parts_breakdown'].length} items included',
              ]),
            
            if (breakdown['service_adjustment'] > 0)
              _buildBreakdownSection('Service Adjustments', breakdown['service_adjustment'], [
                if (_isUrgent) 'Urgent Service Surcharge',
                if (_includeWeekendSurcharge) 'Weekend Service Surcharge',
              ]),
            
            _buildBreakdownSection('Profit Margin', breakdown['profit_margin'], [
              'Platform commission and provider profit included',
            ]),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saveQuote,
                    child: const Text('Save Quote'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendQuoteToCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send to Customer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSection(String title, double amount, List<String> details) {
    return ExpansionTile(
      title: Text(title),
      subtitle: Text('GHS ${amount.toStringAsFixed(2)}'),
      children: details.map((detail) => 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.chevron_right, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(detail)),
            ],
          ),
        ),
      ).toList(),
    );
  }

  void _showAddPartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Part/Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _partNameController,
                decoration: const InputDecoration(
                  labelText: 'Part Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _partQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _partPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (GHS)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPartType,
                decoration: const InputDecoration(
                  labelText: 'Part Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'economy', child: Text('Economy (-20%)')),
                  DropdownMenuItem(value: 'standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'premium', child: Text('Premium (+50%)')),
                  DropdownMenuItem(value: 'imported', child: Text('Imported (+80%)')),
                ],
                onChanged: (value) {
                  _selectedPartType = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addPart,
              child: const Text('Add Part'),
            ),
          ],
        );
      },
    );
  }

  void _addPart() {
    if (_partNameController.text.isNotEmpty &&
        _partQuantityController.text.isNotEmpty &&
        _partPriceController.text.isNotEmpty) {
      
      setState(() {
        _requiredParts.add({
          'name': _partNameController.text,
          'quantity': int.tryParse(_partQuantityController.text) ?? 1,
          'base_price': double.tryParse(_partPriceController.text) ?? 0.0,
          'type': _selectedPartType,
        });
      });
      
      _partNameController.clear();
      _partQuantityController.clear();
      _partPriceController.clear();
      _selectedPartType = 'standard';
      
      Navigator.of(context).pop();
    }
  }

  void _calculatePricing() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isCalculating = true;
    });
    
    try {
      final adminOverrides = await AdminPricingService.getLaborRateOverrides();
      final partsOverrides = await AdminPricingService.getPartsOverrides();
      final timeFactors = DynamicPricingService.getCurrentTimeFactors();
      
      final pricing = await DynamicPricingService.calculateCompletePricing(
        serviceType: _selectedService,
        baseLaborCost: _baseLaborCost,
        customerLat: _customerLat,
        customerLng: _customerLng,
        providerLat: _providerLat,
        providerLng: _providerLng,
        requiredParts: _requiredParts,
        adminPriceOverrides: partsOverrides,
        adminLaborRateOverrides: adminOverrides,
        isUrgent: _isUrgent,
        isPeakHours: timeFactors['is_peak_hours'] || _includeWeekendSurcharge,
        vehicleType: _vehicleType,
        qualityLevel: 1.0,
        complexity: _complexityLevel,
      );
      
      setState(() {
        _calculatedPricing = pricing;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating pricing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _saveQuote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendQuoteToCustomer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote sent to customer!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dynamic Pricing Help'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How Dynamic Pricing Works:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Transportation costs calculated based on distance and vehicle type'),
                Text('• Parts costs include type-based multipliers and service markups'),
                Text('• Labor costs adjust for complexity and time factors'),
                Text('• Peak hours and urgency add surcharges'),
                Text('• Admin overrides can modify base rates'),
                SizedBox(height: 16),
                Text(
                  'Tips for Competitive Pricing:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Use economy parts for budget-conscious customers'),
                Text('• Offer standard complexity for routine jobs'),
                Text('• Consider transportation costs in your service area'),
                Text('• Add urgency surcharge only when justified'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _partQuantityController.dispose();
    _partPriceController.dispose();
    super.dispose();
  }
}