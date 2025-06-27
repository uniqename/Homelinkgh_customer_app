import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class BookingScreen extends StatefulWidget {
  final String categoryName;
  final Map<String, dynamic>? serviceData;

  const BookingScreen({super.key, required this.categoryName, this.serviceData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String? selectedPaymentMethod;
  Map<String, dynamic>? serviceInfo;
  bool isLoading = true;
  
  final List<String> paymentMethods = [
    'Mobile Money (MTN)',
    'Mobile Money (Vodafone)',
    'Mobile Money (AirtelTigo)',
    'Bank Transfer',
    'Cash on Delivery',
    'Credit/Debit Card'
  ];

  @override
  void initState() {
    super.initState();
    _loadServiceInfo();
  }

  Future<void> _loadServiceInfo() async {
    if (widget.serviceData != null) {
      setState(() {
        serviceInfo = widget.serviceData;
        isLoading = false;
      });
      return;
    }
    
    try {
      final services = await FirebaseService.services.get();
      final service = services.docs.firstWhere(
        (doc) => (doc.data() as Map<String, dynamic>)['name'] == widget.categoryName,
        orElse: () => throw Exception('Service not found'),
      );
      
      setState(() {
        serviceInfo = service.data() as Map<String, dynamic>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading service: $e')),
      );
    }
  }

  Future<void> _submitBooking() async {
    if (_addressController.text.isEmpty || 
        selectedDate == null || 
        selectedTime == null ||
        selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a booking')),
      );
      return;
    }

    try {
      final scheduledDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final bookingId = await FirebaseService.createBooking(
        customerId: user.uid,
        serviceType: widget.categoryName,
        description: _notesController.text.isNotEmpty ? _notesController.text : serviceInfo?['description'] ?? '',
        address: _addressController.text,
        priceGHS: serviceInfo?['basePrice']?.toDouble() ?? 0.0,
        scheduledDate: scheduledDateTime,
      );

      // Update booking with payment method
      await FirebaseService.bookings.doc(bookingId).update({
        'paymentMethod': selectedPaymentMethod,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully!')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.categoryName}'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Service Description Card
                if (serviceInfo != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceInfo!['name'] ?? widget.categoryName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF006B3C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            serviceInfo!['description'] ?? 'Professional service',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF006B3C), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Duration: ${serviceInfo!['duration'] ?? 'Variable'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.payments, color: Color(0xFF006B3C), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'From: GH₵${serviceInfo!['basePrice']?.toStringAsFixed(0) ?? '0'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF006B3C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Booking Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Service Address *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
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
                                    initialDate: DateTime.now(),
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
                                      : 'Select Date *',
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
                                      : 'Select Time *',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Notes (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Method Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payment),
                          ),
                          hint: const Text('Select Payment Method *'),
                          value: selectedPaymentMethod,
                          items: paymentMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Note
                const Text(
                  '* Required fields\n\nNote: Final pricing may vary based on specific requirements. You will be contacted to confirm details and payment.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}