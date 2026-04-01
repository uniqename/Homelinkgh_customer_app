import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/service_types.dart';
import '../services/pricing_api_service.dart';
import '../services/notification_service.dart';

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
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Form data
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedProvider;
  String? selectedPaymentMethod = 'Mobile Money';
  bool isRecurring = false;
  String? recurringFrequency;
  Map<String, dynamic> dynamicFieldValues = {};

  final List<Map<String, dynamic>> _availableProviders = [
    {
      'name': 'Kwame Asante',
      'rating': 4.8,
      'reviews': 156,
      'experience': '5+ years',
      'avatar': 'KA',
      'verified': true,
      'available': true,
    },
    {
      'name': 'Akosua Mensah',
      'rating': 4.9,
      'reviews': 234,
      'experience': '3+ years',
      'avatar': 'AM',
      'verified': true,
      'available': true,
    },
    {
      'name': 'Samuel Osei',
      'rating': 4.7,
      'reviews': 89,
      'experience': '7+ years',
      'avatar': 'SO',
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
                        ServiceTypes.getDetailedServiceDescription(widget.serviceName),
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
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Service Description *',
              hintText: 'Describe what you need in detail',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe the service you need';
              }
              return null;
            },
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Additional Notes',
              hintText: 'Any specific requirements or instructions',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // General Framework Questions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text(
                      'General Service Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...ServiceTypes.getGeneralFields().map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDynamicField(field),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Service-specific questions
          if (ServiceTypes.getServiceSpecificFields(widget.serviceName).isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🇬🇭', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.serviceName} Specific Details',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...ServiceTypes.getServiceSpecificFields(widget.serviceName).map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDynamicField(field),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Estimated Pricing Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showEstimatedPricing(),
              icon: const Icon(Icons.calculate, color: Color(0xFF006B3C)),
              label: const Text('Get Estimated Quote'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF006B3C),
                side: const BorderSide(color: Color(0xFF006B3C)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
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
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF006B3C)),
                  ),
                  child: const Text(
                    'Get Quote',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF006B3C),
                    ),
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
        _buildSummaryItem('Description', _descriptionController.text),
        _buildSummaryItem('Address', _addressController.text),
        _buildSummaryItem('Payment', selectedPaymentMethod ?? 'Not selected'),
        if (isRecurring)
          _buildSummaryItem('Recurring', recurringFrequency ?? 'Not set'),
        const SizedBox(height: 24),
        
        // Cancellation Policy Notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cancellation Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getCancellationPolicyText(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        
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
        // Validate form fields
        final isFormValid = _formKey.currentState?.validate() ?? false;
        if (!isFormValid) return false;
        
        // Validate all dynamic fields (general + service-specific)
        final allFields = ServiceTypes.getAllFieldsForService(widget.serviceName);
        for (final field in allFields) {
          final isRequired = field['required'] ?? false;
          if (isRequired) {
            final fieldName = field['name'];
            final value = dynamicFieldValues[fieldName];
            
            if (value == null || 
                (value is String && value.isEmpty) ||
                (value is List && value.isEmpty) ||
                (value is int && value == 0)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in ${field['label']}')),
              );
              return false;
            }
          }
        }
        return true;
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
    
    // Generate request ID
    final requestId = 'REQ${DateTime.now().millisecondsSinceEpoch}';
    
    // Send notification to providers about new quote request
    final location = dynamicFieldValues['jobLocation'] ?? _addressController.text;
    final urgency = dynamicFieldValues['urgency'] ?? 'Scheduled (within 3 days)';
    
    NotificationService().sendNewQuoteRequestNotification(
      requestId: requestId,
      serviceName: widget.serviceName,
      customerLocation: location,
      urgency: urgency,
    );
    
    // Here you would typically send the booking data to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking submitted successfully! Providers will be notified.'),
        backgroundColor: Colors.green,
      ),
    );
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

  String _getCancellationPolicyText() {
    if (selectedDate == null) return '';
    
    final now = DateTime.now();
    final serviceDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime?.hour ?? 0,
      selectedTime?.minute ?? 0,
    );
    
    final timeDifference = serviceDateTime.difference(now);
    final daysUntilService = timeDifference.inDays;
    final hoursUntilService = timeDifference.inHours;
    
    if (daysUntilService >= 2) {
      return '✅ Free cancellation available until 48 hours before your scheduled service time. You can cancel or reschedule without any charges.';
    } else if (hoursUntilService >= 48) {
      return '✅ Free cancellation available until 48 hours before your scheduled service time. You have $hoursUntilService hours remaining for free cancellation.';
    } else {
      return '⚠️ Cancellation not available: Less than 48 hours until service. Cancellations within 48 hours may incur charges. Please contact support for assistance.';
    }
  }

  Widget _buildDynamicField(Map<String, dynamic> field) {
    final String fieldName = field['name'];
    final String label = field['label'];
    final String type = field['type'];
    final bool isRequired = field['required'] ?? false;
    
    switch (type) {
      case 'text':
      case 'textarea':
        return TextFormField(
          decoration: InputDecoration(
            labelText: '$label${isRequired ? ' *' : ''}',
            border: const OutlineInputBorder(),
          ),
          maxLines: type == 'textarea' ? 3 : 1,
          onChanged: (value) {
            setState(() {
              dynamicFieldValues[fieldName] = value;
            });
          },
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          } : null,
        );
        
      case 'number':
        return TextFormField(
          decoration: InputDecoration(
            labelText: '$label${isRequired ? ' *' : ''}',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              dynamicFieldValues[fieldName] = int.tryParse(value) ?? 0;
            });
          },
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          } : null,
        );
        
      case 'dropdown':
        final List<String> options = List<String>.from(field['options'] ?? []);
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '$label${isRequired ? ' *' : ''}',
            border: const OutlineInputBorder(),
          ),
          value: dynamicFieldValues[fieldName] as String?,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              dynamicFieldValues[fieldName] = value;
            });
          },
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          } : null,
        );
        
      case 'multiselect':
        final List<String> options = List<String>.from(field['options'] ?? []);
        final List<String> selectedValues = List<String>.from(dynamicFieldValues[fieldName] ?? []);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label${isRequired ? ' *' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: options.map((option) {
                  final isSelected = selectedValues.contains(option);
                  return CheckboxListTile(
                    title: Text(option),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedValues.add(option);
                        } else {
                          selectedValues.remove(option);
                        }
                        dynamicFieldValues[fieldName] = selectedValues;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            if (isRequired && selectedValues.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one option',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
        
      case 'boolean':
        return CheckboxListTile(
          title: Text('$label${isRequired ? ' *' : ''}'),
          value: dynamicFieldValues[fieldName] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              dynamicFieldValues[fieldName] = value ?? false;
            });
          },
        );
        
      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label${isRequired ? ' *' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dynamicFieldValues[fieldName] as DateTime? ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    dynamicFieldValues[fieldName] = date;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                dynamicFieldValues[fieldName] != null
                    ? '${(dynamicFieldValues[fieldName] as DateTime).day}/${(dynamicFieldValues[fieldName] as DateTime).month}/${(dynamicFieldValues[fieldName] as DateTime).year}'
                    : 'Select Date',
              ),
            ),
          ],
        );
        
      case 'file_upload':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label${isRequired ? ' *' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Tap to upload photos/videos'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _uploadFiles(fieldName),
                    child: const Text('Choose Files'),
                  ),
                  if (dynamicFieldValues[fieldName] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(dynamicFieldValues[fieldName] as List).length} file(s) selected',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildFilePreview(dynamicFieldValues[fieldName] as List<String>),
                  ],
                ],
              ),
            ),
          ],
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  void _uploadFiles(String fieldName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Media',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  'Camera',
                  Icons.camera_alt,
                  () => _pickMedia(fieldName, ImageSource.camera),
                ),
                _buildMediaOption(
                  'Gallery',
                  Icons.photo_library,
                  () => _pickMedia(fieldName, ImageSource.gallery),
                ),
                _buildMediaOption(
                  'Multiple',
                  Icons.photo_library_outlined,
                  () => _pickMultipleImages(fieldName),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'You can upload photos and videos of the work area',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 30,
              color: const Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(String fieldName, ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (image != null) {
        final List<String> currentFiles = List<String>.from(dynamicFieldValues[fieldName] ?? []);
        currentFiles.add(image.path);
        
        setState(() {
          dynamicFieldValues[fieldName] = currentFiles;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo added successfully! (${currentFiles.length} total)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickMultipleImages(String fieldName) async {
    Navigator.pop(context); // Close bottom sheet
    
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        final List<String> currentFiles = List<String>.from(dynamicFieldValues[fieldName] ?? []);
        currentFiles.addAll(images.map((e) => e.path));
        
        setState(() {
          dynamicFieldValues[fieldName] = currentFiles;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} photos added! (${currentFiles.length} total)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFilePreview(List<String> filePaths) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filePaths.length,
        itemBuilder: (context, index) {
          final filePath = filePaths[index];
          final fileName = filePath.split('/').last;
          
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: File(filePath).existsSync()
                      ? Image.file(
                          File(filePath),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 30),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        filePaths.removeAt(index);
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEstimatedPricing() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting real-time pricing...'),
          ],
        ),
      ),
    );

    try {
      // Get location from dynamic fields or use default
      final location = dynamicFieldValues['jobLocation'] ?? 'Greater Accra, Ghana';
      
      // Call pricing API
      final pricing = await PricingApiService().getServicePricing(
        serviceName: widget.serviceName,
        serviceDetails: dynamicFieldValues,
        location: location,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show pricing results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('💰 Real-Time Pricing'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service: ${widget.serviceName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (pricing['success'] == true) ...[
                  Text('Market Range: ${pricing['pricing']['priceRange']}'),
                  const SizedBox(height: 8),
                  Text(
                    'Request Quote for Competitive Pricing',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Pricing factors
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Pricing Factors:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 4),
                        const Text('Base Rate: Quote-based pricing'),
                        if (pricing['factors']['urgencyMultiplier'] != 1.0)
                          Text('Urgency: ${(pricing['factors']['urgencyMultiplier'] * 100).toInt()}% of base'),
                        Text('Location: ${pricing['factors']['location']}'),
                        Text('Market: ${pricing['factors']['marketConditions']}'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Get provider quotes button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _getProviderQuotes(),
                      icon: const Icon(Icons.people),
                      label: const Text('Get Provider Quotes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF006B3C),
                        side: const BorderSide(color: Color(0xFF006B3C)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Fallback pricing display
                  const Text('Unable to get live pricing. Using estimated ranges:'),
                  const SizedBox(height: 8),
                  Text(
                    'Get personalized quote',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Important Note:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pricing['note'] ?? 'Pricing based on current market conditions. Final quote confirmed after provider assessment.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showProviderSelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Find Providers'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog and show error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting pricing: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Show fallback pricing
      _showFallbackPricing();
    }
  }

  void _showFallbackPricing() {
    final fallbackPricing = ServiceTypes.calculateRoughPricing(widget.serviceName, dynamicFieldValues);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💰 Estimated Pricing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${widget.serviceName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Contact for quote'),
            const SizedBox(height: 8),
            Text(
              'Estimated Total: ${fallbackPricing['priceRange']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fallbackPricing['note'],
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showProviderSelection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _getProviderQuotes() async {
    Navigator.pop(context); // Close pricing dialog
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding available providers...'),
          ],
        ),
      ),
    );

    try {
      final location = dynamicFieldValues['jobLocation'] ?? 'Greater Accra, Ghana';
      
      final providerQuotes = await PricingApiService().getProviderQuotes(
        serviceName: widget.serviceName,
        serviceDetails: dynamicFieldValues,
        location: location,
      );

      Navigator.pop(context); // Close loading
      _showProviderQuotes(providerQuotes);
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting provider quotes: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _showProviderSelection(); // Fallback to regular provider selection
    }
  }

  void _showProviderQuotes(List<Map<String, dynamic>> quotes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Available Providers',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF006B3C),
                                child: Text(
                                  quote['name'][0],
                                  style: const TextStyle(color: Colors.white),
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
                                          quote['name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        if (quote['verified'] == true) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, size: 16, color: Colors.blue),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 16, color: Colors.amber),
                                        Text(' ${quote['rating']} (${quote['reviews']} reviews)'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₵${quote['price']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF006B3C),
                                    ),
                                  ),
                                  Text(
                                    quote['availability'],
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Duration: ${quote['estimatedDuration']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                selectedProvider = quote['name'];
                                setState(() {
                                  _currentStep = 2; // Move to scheduling step
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006B3C),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Select Provider'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProviderSelection() {
    // Fallback to existing provider selection logic
    setState(() {
      _currentStep = 1; // Move to provider selection step
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}