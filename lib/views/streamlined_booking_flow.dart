import 'package:flutter/material.dart';
import '../models/quote.dart';

class StreamlinedBookingFlow extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;

  const StreamlinedBookingFlow({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
  });

  @override
  State<StreamlinedBookingFlow> createState() => _StreamlinedBookingFlowState();
}

class _StreamlinedBookingFlowState extends State<StreamlinedBookingFlow> {
  int _currentStep = 0;
  
  // Form data
  String _selectedUrgency = 'standard';
  String _selectedTimeSlot = '';
  String _description = '';
  String _location = '';
  String _contactMethod = 'phone';
  double _budgetRange = 200;
  List<String> _selectedProviders = [];
  List<Quote> _receivedQuotes = [];
  Quote? _selectedQuote;

  final List<String> _timeSlots = [
    'Morning (8AM - 12PM)',
    'Afternoon (12PM - 5PM)', 
    'Evening (5PM - 8PM)',
    'Weekend only',
    'Flexible timing'
  ];

  final List<Map<String, dynamic>> _sampleProviders = [
    {
      'id': 'provider_1',
      'name': 'Kwame Professional Services',
      'rating': 4.8,
      'reviews': 156,
      'responseTime': 'Usually responds in 30 mins',
      'verified': true,
    },
    {
      'id': 'provider_2', 
      'name': 'Akosua Quality Care',
      'rating': 4.9,
      'reviews': 234,
      'responseTime': 'Usually responds in 1 hour',
      'verified': true,
    },
    {
      'id': 'provider_3',
      'name': 'Samuel Expert Solutions', 
      'rating': 4.7,
      'reviews': 89,
      'responseTime': 'Usually responds in 2 hours',
      'verified': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.serviceName}'),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: widget.serviceColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: List.generate(6, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < 5 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
                              ? Colors.white 
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  _getStepTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Step content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildServiceDetailsStep(),
                _buildSchedulingStep(),
                _buildProviderSelectionStep(),
                _buildQuoteReviewStep(),
                _buildBookingConfirmationStep(),
                _buildTrackingStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text('Back'),
                  ),
                const Spacer(),
                if (_currentStep < 5)
                  ElevatedButton(
                    onPressed: _canProceedToNext() ? _proceedToNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.serviceColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(_getNextButtonText()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Step 1: Service Details';
      case 1: return 'Step 2: Schedule & Location';
      case 2: return 'Step 3: Choose Providers';
      case 3: return 'Step 4: Review Quotes';
      case 4: return 'Step 5: Confirm Booking';
      case 5: return 'Step 6: Track Service';
      default: return '';
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0: return 'Continue';
      case 1: return 'Find Providers';
      case 2: return 'Request Quotes';
      case 3: return 'Select Quote';
      case 4: return 'Confirm Booking';
      default: return 'Next';
    }
  }

  Widget _buildServiceDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.serviceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.serviceColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  widget.serviceIcon,
                  size: 48,
                  color: widget.serviceColor,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.serviceColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us what you need',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'How urgent is this?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Urgency selection
          ...['standard', 'urgent', 'flexible'].map((urgency) {
            return RadioListTile<String>(
              title: Text(_getUrgencyTitle(urgency)),
              subtitle: Text(_getUrgencyDescription(urgency)),
              value: urgency,
              groupValue: _selectedUrgency,
              onChanged: (value) {
                setState(() {
                  _selectedUrgency = value!;
                });
              },
              activeColor: widget.serviceColor,
            );
          }).toList(),
          
          const SizedBox(height: 32),
          
          const Text(
            'Describe what you need',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Provide details about the service you need...',
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Budget Range (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Budget: GH₵${_budgetRange.round()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: _budgetRange,
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  activeColor: widget.serviceColor,
                  onChanged: (value) {
                    setState(() {
                      _budgetRange = value;
                    });
                  },
                ),
                const Text(
                  'This helps us match you with suitable providers',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When do you need this service?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Time slot selection
          ..._timeSlots.map((slot) {
            return RadioListTile<String>(
              title: Text(slot),
              value: slot,
              groupValue: _selectedTimeSlot,
              onChanged: (value) {
                setState(() {
                  _selectedTimeSlot = value!;
                });
              },
              activeColor: widget.serviceColor,
            );
          }).toList(),
          
          const SizedBox(height: 32),
          
          const Text(
            'Service Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your address or location details',
              prefixIcon: Icon(Icons.location_on),
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _location = value;
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Preferred Contact Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...['phone', 'whatsapp', 'in_app'].map((method) {
            return RadioListTile<String>(
              title: Text(_getContactMethodTitle(method)),
              subtitle: Text(_getContactMethodDescription(method)),
              value: method,
              groupValue: _contactMethod,
              onChanged: (value) {
                setState(() {
                  _contactMethod = value!;
                });
              },
              activeColor: widget.serviceColor,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProviderSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose providers to request quotes from',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select 2-3 providers for the best quotes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: _sampleProviders.length,
              itemBuilder: (context, index) {
                final provider = _sampleProviders[index];
                final isSelected = _selectedProviders.contains(provider['id']);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedProviders.add(provider['id']);
                        } else {
                          _selectedProviders.remove(provider['id']);
                        }
                      });
                    },
                    activeColor: widget.serviceColor,
                    title: Row(
                      children: [
                        Text(
                          provider['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (provider['verified'])
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('${provider['rating']} (${provider['reviews']} reviews)'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider['responseTime'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_selectedProviders.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.serviceColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.serviceColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${_selectedProviders.length} providers selected. They will receive your quote request.',
                style: TextStyle(
                  color: widget.serviceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuoteReviewStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Quotes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compare quotes and choose the best option',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          if (_receivedQuotes.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.serviceColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Waiting for quotes from providers...',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This usually takes 30 minutes to 2 hours',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _receivedQuotes.length,
                itemBuilder: (context, index) {
                  final quote = _receivedQuotes[index];
                  final isSelected = _selectedQuote?.id == quote.id;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<Quote>(
                      value: quote,
                      groupValue: _selectedQuote,
                      onChanged: (selectedQuote) {
                        setState(() {
                          _selectedQuote = selectedQuote;
                        });
                      },
                      activeColor: widget.serviceColor,
                      title: Text(
                        quote.providerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: GH₵${quote.amount.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text(quote.description),
                          const SizedBox(height: 4),
                          Text('Estimated time: ${quote.metadata?['estimatedDuration'] ?? 'TBD'}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Mock "quotes received" button for demo
          if (_receivedQuotes.isEmpty)
            ElevatedButton(
              onPressed: _loadMockQuotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simulate Received Quotes (Demo)'),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your service has been successfully booked',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (_selectedQuote != null) ...[
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Service', widget.serviceName),
                    _buildDetailRow('Provider', _selectedQuote!.providerName),
                    _buildDetailRow('Total Price', 'GH₵${_selectedQuote!.amount.toStringAsFixed(2)}'),
                    _buildDetailRow('Time Slot', _selectedTimeSlot),
                    _buildDetailRow('Location', _location),
                    _buildDetailRow('Status', 'Confirmed'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'What happens next?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• The provider will contact you within 30 minutes'),
                SizedBox(height: 8),
                Text('• You can track the service progress in real-time'),
                SizedBox(height: 8),
                Text('• Payment will be processed after service completion'),
                SizedBox(height: 8),
                Text('• You can rate and review the service afterwards'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingStep() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: Colors.blue,
          ),
          SizedBox(height: 16),
          Text(
            'Track Your Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'You can now track your service in the Bookings tab',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getUrgencyTitle(String urgency) {
    switch (urgency) {
      case 'standard': return 'Standard (1-3 days)';
      case 'urgent': return 'Urgent (Same day)';
      case 'flexible': return 'Flexible (1-2 weeks)';
      default: return urgency;
    }
  }

  String _getUrgencyDescription(String urgency) {
    switch (urgency) {
      case 'standard': return 'Normal pricing, good availability';
      case 'urgent': return 'Premium pricing for same-day service';
      case 'flexible': return 'Best pricing, provider chooses timing';
      default: return '';
    }
  }

  String _getContactMethodTitle(String method) {
    switch (method) {
      case 'phone': return 'Phone Call';
      case 'whatsapp': return 'WhatsApp';
      case 'in_app': return 'In-App Messaging';
      default: return method;
    }
  }

  String _getContactMethodDescription(String method) {
    switch (method) {
      case 'phone': return 'Direct phone communication';
      case 'whatsapp': return 'Messages via WhatsApp';
      case 'in_app': return 'Secure messaging within the app';
      default: return '';
    }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: return _description.isNotEmpty;
      case 1: return _selectedTimeSlot.isNotEmpty && _location.isNotEmpty;
      case 2: return _selectedProviders.isNotEmpty;
      case 3: return _selectedQuote != null;
      case 4: return true;
      default: return false;
    }
  }

  void _proceedToNext() {
    if (_currentStep == 2) {
      // Send quote requests
      _sendQuoteRequests();
    } else if (_currentStep == 4) {
      // Confirm booking
      _confirmBooking();
    }
    
    setState(() {
      _currentStep++;
    });
  }

  void _sendQuoteRequests() async {
    // In real app, send actual quote requests to selected providers
    // For now, simulate the process
    print('Sending quote requests to ${_selectedProviders.length} providers');
  }

  void _confirmBooking() async {
    // In real app, create actual booking with selected quote
    print('Confirming booking with quote: ${_selectedQuote?.id}');
  }

  void _loadMockQuotes() {
    // Mock quotes for demo purposes
    final mockQuotes = [
      Quote(
        id: 'quote_1',
        serviceRequestId: 'request_1',
        providerId: 'provider_1',
        providerName: 'Kwame Professional Services',
        amount: 180.00,
        description: 'Complete ${widget.serviceName.toLowerCase()} service with premium materials',
        status: QuoteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        metadata: {'estimatedDuration': '2-3 hours'},
      ),
      Quote(
        id: 'quote_2',
        serviceRequestId: 'request_1',
        providerId: 'provider_2',
        providerName: 'Akosua Quality Care',
        amount: 220.00,
        description: 'Premium ${widget.serviceName.toLowerCase()} with 1-year warranty',
        status: QuoteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        metadata: {'estimatedDuration': '3-4 hours'},
      ),
      Quote(
        id: 'quote_3',
        serviceRequestId: 'request_1',
        providerId: 'provider_3',
        providerName: 'Samuel Expert Solutions',
        amount: 160.00,
        description: 'Efficient ${widget.serviceName.toLowerCase()} service',
        status: QuoteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        metadata: {'estimatedDuration': '2 hours'},
      ),
    ];
    
    setState(() {
      _receivedQuotes = mockQuotes;
    });
  }
}