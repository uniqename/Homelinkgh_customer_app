import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service_fee.dart';

class ProviderQuoteSubmissionScreen extends StatefulWidget {
  final Map<String, dynamic> jobRequest;

  const ProviderQuoteSubmissionScreen({
    super.key,
    required this.jobRequest,
  });

  @override
  State<ProviderQuoteSubmissionScreen> createState() => _ProviderQuoteSubmissionScreenState();
}

class _ProviderQuoteSubmissionScreenState extends State<ProviderQuoteSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quoteController = TextEditingController();
  final _messageController = TextEditingController();
  final _durationController = TextEditingController();
  
  DateTime? _availableDate;
  TimeOfDay? _availableTime;
  bool _isSubmitting = false;
  
  final List<String> _selectedImages = [];
  final ServiceFee _serviceFee = ServiceFee.standard;

  @override
  void initState() {
    super.initState();
    // Set default availability to tomorrow
    _availableDate = DateTime.now().add(const Duration(days: 1));
    _availableTime = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Submit Quote'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Job details header
            _buildJobDetailsHeader(),
            
            // Job photos/videos section
            _buildMediaSection(),
            
            // Quote form
            _buildQuoteForm(),
            
            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.jobRequest['serviceName'] ?? 'Service Request',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer: ${widget.jobRequest['customerName'] ?? 'N/A'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.jobRequest['location'] ?? 'Location not specified',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.jobRequest['description'] ?? 'No description provided',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    final jobImages = widget.jobRequest['images'] as List<String>? ?? [];
    final jobVideos = widget.jobRequest['videos'] as List<String>? ?? [];
    
    if (jobImages.isEmpty && jobVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Photos & Videos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Photos
          if (jobImages.isNotEmpty) ...[
            const Text(
              'Photos:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: jobImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: GestureDetector(
                      onTap: () => _viewMedia(jobImages[index], 'image'),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image, size: 32, color: Colors.grey),
                                const SizedBox(height: 4),
                                Text(
                                  'Image ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Videos
          if (jobVideos.isNotEmpty) ...[
            const Text(
              'Videos:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: jobVideos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: GestureDetector(
                      onTap: () => _viewMedia(jobVideos[index], 'video'),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle_fill, size: 32, color: Colors.red),
                                const SizedBox(height: 4),
                                Text(
                                  'Video ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '0:30',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Your Quote',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Quote amount
            TextFormField(
              controller: _quoteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your Quote Amount (GH₵)',
                hintText: 'Enter your service price',
                prefixText: 'GH₵ ',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your quote amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Fee breakdown (if quote amount is entered)
            if (_quoteController.text.isNotEmpty && double.tryParse(_quoteController.text) != null)
              _buildFeeBreakdown(),

            const SizedBox(height: 16),

            // Availability date
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Available Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _availableDate != null
                            ? '${_availableDate!.day}/${_availableDate!.month}/${_availableDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Available Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _availableTime != null
                            ? _availableTime!.format(context)
                            : 'Select time',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estimated duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Estimated Duration',
                hintText: 'e.g., 2-3 hours, Half day, etc.',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.schedule),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please estimate how long the job will take';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Message to customer
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message to Customer',
                hintText: 'Explain your approach, experience, what\'s included...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please include a message explaining your quote';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Terms checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                ),
                const Expanded(
                  child: Text(
                    'I understand that HomeLinkGH will add platform fees to my quote before showing the final price to the customer.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    final quote = double.tryParse(_quoteController.text);
    if (quote == null) return const SizedBox.shrink();

    final serviceCategory = widget.jobRequest['serviceName'] ?? 'General';
    final breakdown = _serviceFee.calculateTotal(quote, serviceCategory);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown (What customer will see):',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          _buildBreakdownRow('Your Quote', 'GH₵${breakdown.providerQuote.toStringAsFixed(2)}'),
          _buildBreakdownRow('Platform Fee (${(breakdown.feePercentage * 100).toStringAsFixed(1)}%)', 'GH₵${breakdown.platformFee.toStringAsFixed(2)}'),
          _buildBreakdownRow('Processing Fee', 'GH₵${breakdown.processingFee.toStringAsFixed(2)}'),
          _buildBreakdownRow('Insurance Coverage', 'GH₵${breakdown.insuranceFee.toStringAsFixed(2)}'),
          const Divider(height: 8),
          _buildBreakdownRow(
            'Customer Total',
            'GH₵${breakdown.totalCustomerPrice.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 4),
          Text(
            'You will receive: GH₵${breakdown.providerQuote.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? const Color(0xFF2E7D32) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitQuote,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting Quote...'),
                ],
              )
            : const Text(
                'Submit Quote to Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _viewMedia(String mediaUrl, String type) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                title: Text('${type == 'image' ? 'Photo' : 'Video'} Preview'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: type == 'image'
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Customer Photo Preview',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '(In production, actual image would display)',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'Customer Video Preview',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '(In production, video player would appear)',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _availableDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _availableDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _availableTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() {
        _availableTime = time;
      });
    }
  }

  void _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_availableDate == null || _availableTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your availability')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final quote = double.parse(_quoteController.text);
      final serviceCategory = widget.jobRequest['serviceName'] ?? 'General';
      final breakdown = _serviceFee.calculateTotal(quote, serviceCategory);

      // In real app, save quote to backend
      final quoteData = {
        'jobRequestId': widget.jobRequest['id'],
        'providerId': 'current_provider_id',
        'providerQuote': breakdown.providerQuote,
        'customerPrice': breakdown.totalCustomerPrice,
        'platformFee': breakdown.platformFee,
        'processingFee': breakdown.processingFee,
        'insuranceFee': breakdown.insuranceFee,
        'availableDate': _availableDate!.toIso8601String(),
        'availableTime': '${_availableTime!.hour}:${_availableTime!.minute}',
        'estimatedDuration': _durationController.text,
        'message': _messageController.text,
        'status': 'pending',
        'submittedAt': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        Navigator.of(context).pop(quoteData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote submitted successfully! Customer will be notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit quote. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _messageController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}