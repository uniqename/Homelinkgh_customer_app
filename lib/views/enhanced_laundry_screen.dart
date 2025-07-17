import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnhancedLaundryScreen extends StatefulWidget {
  const EnhancedLaundryScreen({super.key});

  @override
  State<EnhancedLaundryScreen> createState() => _EnhancedLaundryScreenState();
}

class _EnhancedLaundryScreenState extends State<EnhancedLaundryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Service selection
  String _selectedService = '';
  final List<Map<String, dynamic>> _laundryServices = [
    {
      'name': 'Regular Wash & Fold',
      'price': 15.0,
      'duration': '24 hours',
      'description': 'Standard washing, drying, and folding service',
    },
    {
      'name': 'Express Service',
      'price': 25.0,
      'duration': '6 hours',
      'description': 'Same-day service for urgent laundry needs',
    },
    {
      'name': 'Dry Cleaning',
      'price': 35.0,
      'duration': '48 hours',
      'description': 'Professional dry cleaning for delicate items',
    },
    {
      'name': 'Ironing Only',
      'price': 8.0,
      'duration': '2 hours',
      'description': 'Professional ironing service for clean clothes',
    },
  ];
  
  // Pickup scheduling
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  String _pickupAddress = '';
  String _pickupInstructions = '';
  
  // Delivery scheduling
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  String _deliveryAddress = '';
  String _deliveryInstructions = '';
  
  // Item details
  int _estimatedWeight = 5; // kg
  List<String> _specialItems = [];
  String _additionalNotes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Service'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? Colors.teal : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: [
                _buildServiceSelectionStep(),
                _buildPickupSchedulingStep(),
                _buildDeliverySchedulingStep(),
                _buildOrderSummaryStep(),
              ],
            ),
          ),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Laundry Service',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: _laundryServices.length,
              itemBuilder: (context, index) {
                final service = _laundryServices[index];
                final isSelected = _selectedService == service['name'];
                
                return Card(
                  elevation: isSelected ? 4 : 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected ? Colors.teal.withValues(alpha: 0.1) : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedService = service['name'];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.local_laundry_service, color: Colors.teal, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  service['description'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'GH₵${service['price'].toStringAsFixed(0)}/kg',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Ready in ${service['duration']}',
                                      style: const TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: service['name'],
                            groupValue: _selectedService,
                            onChanged: (value) {
                              setState(() {
                                _selectedService = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Weight estimation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Weight (kg):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _estimatedWeight > 1 ? () {
                        setState(() {
                          _estimatedWeight--;
                        });
                      } : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_estimatedWeight kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _estimatedWeight++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    if (_selectedService.isNotEmpty)
                      Text(
                        'Est. Cost: GH₵${(_getSelectedServicePrice() * _estimatedWeight).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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

  Widget _buildPickupSchedulingStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup Scheduling',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup Date
                  const Text('Pickup Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectPickupDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            _pickupDate != null 
                                ? DateFormat('EEEE, MMM d, y').format(_pickupDate!)
                                : 'Select pickup date',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pickup Time
                  const Text('Pickup Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectPickupTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            _pickupTime != null 
                                ? _pickupTime!.format(context)
                                : 'Select pickup time',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pickup Address
                  const Text('Pickup Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter your pickup address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _pickupAddress = value;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Special Instructions
                  const Text('Pickup Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Any special instructions for pickup? (e.g., apartment number, gate code)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _pickupInstructions = value;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time slots info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Available Pickup Times',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Monday - Friday: 8:00 AM - 6:00 PM'),
                        Text('Saturday: 9:00 AM - 4:00 PM'),
                        Text('Sunday: 10:00 AM - 2:00 PM'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySchedulingStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Scheduling',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expected delivery info
                  if (_pickupDate != null && _selectedService.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Expected completion: ${_getExpectedDeliveryDate()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Delivery Date
                  const Text('Preferred Delivery Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDeliveryDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            _deliveryDate != null 
                                ? DateFormat('EEEE, MMM d, y').format(_deliveryDate!)
                                : 'Select delivery date',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Delivery Time
                  const Text('Preferred Delivery Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDeliveryTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            _deliveryTime != null 
                                ? _deliveryTime!.format(context)
                                : 'Select delivery time',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Same as pickup address option
                  CheckboxListTile(
                    title: const Text('Same as pickup address'),
                    value: _deliveryAddress == _pickupAddress && _deliveryAddress.isNotEmpty,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _deliveryAddress = _pickupAddress;
                        } else {
                          _deliveryAddress = '';
                        }
                      });
                    },
                  ),
                  
                  // Delivery Address
                  const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter your delivery address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    controller: TextEditingController(text: _deliveryAddress),
                    onChanged: (value) {
                      _deliveryAddress = value;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Delivery Instructions
                  const Text('Delivery Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Any special instructions for delivery?',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _deliveryInstructions = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryStep() {
    final serviceCost = _getSelectedServicePrice() * _estimatedWeight;
    final pickupFee = 5.0;
    final deliveryFee = 5.0;
    final total = serviceCost + pickupFee + deliveryFee;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Service Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Service: $_selectedService'),
                          Text('Weight: $_estimatedWeight kg'),
                          Text('Service Cost: GH₵${serviceCost.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Pickup details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (_pickupDate != null && _pickupTime != null)
                            Text('Date & Time: ${DateFormat('MMM d, y').format(_pickupDate!)} at ${_pickupTime!.format(context)}'),
                          if (_pickupAddress.isNotEmpty)
                            Text('Address: $_pickupAddress'),
                          if (_pickupInstructions.isNotEmpty)
                            Text('Instructions: $_pickupInstructions'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Delivery details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (_deliveryDate != null && _deliveryTime != null)
                            Text('Date & Time: ${DateFormat('MMM d, y').format(_deliveryDate!)} at ${_deliveryTime!.format(context)}'),
                          if (_deliveryAddress.isNotEmpty)
                            Text('Address: $_deliveryAddress'),
                          if (_deliveryInstructions.isNotEmpty)
                            Text('Instructions: $_deliveryInstructions'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Cost breakdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Service Cost:'),
                              Text('GH₵${serviceCost.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Pickup Fee:'),
                              Text('GH₵${pickupFee.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery Fee:'),
                              Text('GH₵${deliveryFee.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('GH₵${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentStep == 3 ? 'Book Service' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _bookService();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedService.isNotEmpty;
      case 1:
        return _pickupDate != null && _pickupTime != null && _pickupAddress.isNotEmpty;
      case 2:
        return _deliveryDate != null && _deliveryTime != null && _deliveryAddress.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _pickupDate) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  void _selectPickupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _pickupTime) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  void _selectDeliveryDate() async {
    DateTime minDate = DateTime.now().add(const Duration(days: 1));
    if (_pickupDate != null) {
      final serviceDuration = _getSelectedServiceDurationInDays();
      minDate = _pickupDate!.add(Duration(days: serviceDuration));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _deliveryDate) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  void _selectDeliveryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _deliveryTime) {
      setState(() {
        _deliveryTime = picked;
      });
    }
  }

  double _getSelectedServicePrice() {
    if (_selectedService.isEmpty) return 0.0;
    final service = _laundryServices.firstWhere((s) => s['name'] == _selectedService);
    return service['price'].toDouble();
  }

  int _getSelectedServiceDurationInDays() {
    if (_selectedService.isEmpty) return 1;
    final service = _laundryServices.firstWhere((s) => s['name'] == _selectedService);
    final duration = service['duration'] as String;
    
    if (duration.contains('6 hours')) return 1;
    if (duration.contains('24 hours')) return 1;
    if (duration.contains('48 hours')) return 2;
    if (duration.contains('2 hours')) return 1;
    
    return 1;
  }

  String _getExpectedDeliveryDate() {
    if (_pickupDate == null || _selectedService.isEmpty) return 'Select pickup date first';
    
    final durationDays = _getSelectedServiceDurationInDays();
    final expectedDate = _pickupDate!.add(Duration(days: durationDays));
    
    return DateFormat('EEEE, MMM d, y').format(expectedDate);
  }

  void _bookService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Booked!'),
        content: const Text('Your laundry service has been booked successfully. You will receive confirmation and tracking details shortly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}