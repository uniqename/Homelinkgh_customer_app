import 'package:flutter/material.dart';

class ServiceBookingScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;

  const ServiceBookingScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
  });

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Form data
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedProvider;
  String? selectedPaymentMethod = 'Mobile Money';
  bool isRecurring = false;
  String? recurringFrequency;

  final List<Map<String, dynamic>> _availableProviders = [
    {
      'name': 'John Smith',
      'rating': 4.8,
      'reviews': 156,
      'experience': '5+ years',
      'price': '\$25/hour',
      'avatar': 'JS',
      'verified': true,
      'available': true,
    },
    {
      'name': 'Sarah Johnson',
      'rating': 4.9,
      'reviews': 234,
      'experience': '3+ years',
      'price': '\$30/hour',
      'avatar': 'SJ',
      'verified': true,
      'available': true,
    },
    {
      'name': 'Mike Wilson',
      'rating': 4.7,
      'reviews': 89,
      'experience': '7+ years',
      'price': '\$35/hour',
      'avatar': 'MW',
      'verified': true,
      'available': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.serviceName}'),
        backgroundColor: widget.serviceColor.withValues(alpha: 0.1),
        foregroundColor: widget.serviceColor,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.serviceColor,
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex < 3)
                  ElevatedButton(
                    onPressed: () {
                      if (_validateCurrentStep()) {
                        if (_currentStep == 2) {
                          _submitBooking();
                        } else {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      }
                    },
                    child: Text(details.stepIndex == 2 ? 'Book Now' : 'Next'),
                  ),
                const SizedBox(width: 8),
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text('Back'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Service Details'),
              content: _buildServiceDetailsStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Choose Provider'),
              content: _buildProviderSelectionStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : 
                     _currentStep == 1 ? StepState.indexed : StepState.disabled,
            ),
            Step(
              title: const Text('Schedule & Payment'),
              content: _buildSchedulePaymentStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : 
                     _currentStep == 2 ? StepState.indexed : StepState.disabled,
            ),
            Step(
              title: const Text('Confirmation'),
              content: _buildConfirmationStep(),
              isActive: _currentStep >= 3,
              state: _currentStep == 3 ? StepState.complete : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.serviceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.serviceIcon,
                  size: 40,
                  color: widget.serviceColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getServiceDescription(),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Service Address *',
              hintText: 'Enter your full address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter service address';
              }
              return null;
            },
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Additional Notes',
              hintText: 'Any specific requirements or instructions',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          if (_shouldShowRecurringOption()) ...[
            CheckboxListTile(
              title: const Text('Recurring Service'),
              subtitle: const Text('Set up regular bookings'),
              value: isRecurring,
              onChanged: (value) {
                setState(() {
                  isRecurring = value ?? false;
                });
              },
            ),
            if (isRecurring) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                value: recurringFrequency,
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'biweekly', child: Text('Bi-weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  setState(() {
                    recurringFrequency = value;
                  });
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProviderSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Providers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableProviders.length,
          itemBuilder: (context, index) {
            final provider = _availableProviders[index];
            final isSelected = selectedProvider == provider['name'];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? widget.serviceColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? widget.serviceColor.withValues(alpha: 0.05) : null,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.serviceColor,
                  child: Text(
                    provider['avatar'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      provider['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (provider['verified'])
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                    if (!provider['available'])
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                        Text(' ${provider['rating']} (${provider['reviews']} reviews)'),
                      ],
                    ),
                    Text('Experience: ${provider['experience']}'),
                  ],
                ),
                trailing: Text(
                  provider['price'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                enabled: provider['available'],
                onTap: provider['available'] ? () {
                  setState(() {
                    selectedProvider = provider['name'];
                  });
                } : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSchedulePaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Select Date',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : 'Select Time',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            RadioListTile<String>(
              title: const Text('Mobile Money'),
              subtitle: const Text('MTN, Vodafone, AirtelTigo'),
              value: 'Mobile Money',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Credit/Debit Card'),
              subtitle: const Text('Visa, Mastercard'),
              value: 'Card',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Pay when service is completed'),
              value: 'Cash',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 8),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your service has been successfully booked. You will receive a confirmation via SMS and email.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Booking Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryItem('Service', widget.serviceName),
        _buildSummaryItem('Provider', selectedProvider ?? 'Not selected'),
        _buildSummaryItem('Date', selectedDate != null ? 
          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'Not selected'),
        _buildSummaryItem('Time', selectedTime?.format(context) ?? 'Not selected'),
        _buildSummaryItem('Address', _addressController.text),
        _buildSummaryItem('Payment', selectedPaymentMethod ?? 'Not selected'),
        if (isRecurring)
          _buildSummaryItem('Recurring', recurringFrequency ?? 'Not set'),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            child: const Text('Go to Home'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (selectedProvider == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a provider')),
          );
          return false;
        }
        return true;
      case 2:
        if (selectedDate == null || selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select date and time')),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _submitBooking() {
    setState(() {
      _currentStep = 3;
    });
    
    // Here you would typically send the booking data to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getServiceDescription() {
    switch (widget.serviceName) {
      case 'Food Delivery':
        return 'Restaurant delivery, groceries, and more';
      case 'Grocery':
        return 'Fresh groceries delivered to your door';
      case 'Cleaning':
        return 'House cleaning and maintenance services';
      case 'Laundry':
        return 'Pickup, wash, dry, and delivery service';
      case 'Nail Tech / Makeup':
        return 'Beauty services at your location';
      case 'Plumbing':
        return 'Pipes, fixtures, and water system repairs';
      case 'Electrical':
        return 'Wiring, outlets, and electrical installations';
      case 'HVAC':
        return 'Heating, ventilation, and air conditioning';
      case 'Painting':
        return 'Interior and exterior painting services';
      case 'Carpentry':
        return 'Custom woodwork and furniture repair';
      case 'Landscaping':
        return 'Garden design, lawn care, and outdoor spaces';
      case 'Babysitting':
        return 'Trusted childcare services';
      case 'Adult Sitter':
        return 'Elderly care and companion services';
      default:
        return 'Professional service at your convenience';
    }
  }

  bool _shouldShowRecurringOption() {
    const recurringServices = [
      'Cleaning',
      'Laundry',
      'Grocery',
      'Babysitting',
      'Adult Sitter',
    ];
    return recurringServices.contains(widget.serviceName);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}