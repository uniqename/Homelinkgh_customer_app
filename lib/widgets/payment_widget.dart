import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/paystack_service.dart';

/// Payment Widget for HomeLinkGH
/// Handles payment UI and processing for service bookings
class PaymentWidget extends StatefulWidget {
  final double amount;
  final String serviceType;
  final String bookingId;
  final String providerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final VoidCallback? onPaymentSuccess;
  final Function(String)? onPaymentFailure;
  final VoidCallback? onPaymentCancelled;

  const PaymentWidget({
    super.key,
    required this.amount,
    required this.serviceType,
    required this.bookingId,
    required this.providerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.onPaymentSuccess,
    this.onPaymentFailure,
    this.onPaymentCancelled,
  });

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  final PayStackService _payStackService = PayStackService();
  bool _isLoading = false;
  bool _isInitialized = false;
  String _selectedPaymentMethod = 'card';
  
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': 'Card Payment',
      'description': 'Visa, Mastercard, Verve',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'id': 'mobile_money',
      'name': 'Mobile Money',
      'description': 'MTN, Vodafone, AirtelTigo',
      'icon': Icons.phone_android,
      'color': Colors.green,
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'description': 'Direct bank transfer',
      'icon': Icons.account_balance,
      'color': Colors.orange,
    },
    {
      'id': 'ussd',
      'name': 'USSD',
      'description': 'Pay with USSD code',
      'icon': Icons.dialpad,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializePayStack();
  }

  Future<void> _initializePayStack() async {
    setState(() => _isLoading = true);
    
    try {
      await _payStackService.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      _showErrorDialog('Failed to initialize payment system: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing payment system...'),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Payment system unavailable'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializePayStack,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentCancelled?.call();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildPaymentButton(),
            const SizedBox(height: 16),
            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final payStackFee = _payStackService.calculatePayStackFees(widget.amount);
    final totalAmount = widget.amount + payStackFee;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: Color(0xFF006B3C)),
                const SizedBox(width: 8),
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Service', widget.serviceType),
            _buildSummaryRow('Service Amount', 'GH₵${widget.amount.toStringAsFixed(2)}'),
            _buildSummaryRow('Payment Processing Fee', 'GH₵${payStackFee.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              'GH₵${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment will be processed securely by PayStack',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF006B3C) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...(_paymentMethods.map((method) => _buildPaymentMethodCard(method))),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF006B3C) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: method['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method['icon'],
                  color: method['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF006B3C),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006B3C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : Text(
                'Pay GH₵${(widget.amount + _payStackService.calculatePayStackFees(widget.amount)).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Secure Payment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Your payment is processed securely by PayStack\n'
            '• We never store your card details\n'
            '• All transactions are encrypted\n'
            '• PCI DSS compliant payment processing',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset(
                'assets/paystack_logo.png',
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'PayStack',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text('Powered by PayStack'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final result = await _payStackService.processServicePayment(
        customerEmail: widget.customerEmail,
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        amount: widget.amount,
        serviceType: widget.serviceType,
        bookingId: widget.bookingId,
        providerId: widget.providerId,
        additionalMetadata: {
          'payment_method': _selectedPaymentMethod,
          'platform': 'flutter_app',
        },
      );

      if (result['status'] == 'success') {
        // In a real implementation, you would open a WebView
        // to load the PayStack payment page
        await _openPayStackPaymentPage(result['payment_url'], result['reference']);
      } else {
        _showErrorDialog(result['message'] ?? 'Payment initialization failed');
      }
    } catch (e) {
      _showErrorDialog('Payment failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openPayStackPaymentPage(String paymentUrl, String reference) async {
    // Simulate payment processing
    // In a real implementation, you would use a WebView or launch browser
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Processing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Redirecting to PayStack...'),
            const SizedBox(height: 8),
            Text(
              'Reference: $reference',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing time
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      // Simulate successful payment
      _handlePaymentSuccess(reference);
    }
  }

  Future<void> _handlePaymentSuccess(String reference) async {
    try {
      // Verify payment with PayStack
      final verification = await _payStackService.handlePaymentCallback(reference);
      
      if (verification['verified'] == true) {
        _showSuccessDialog(reference);
        widget.onPaymentSuccess?.call();
      } else {
        _showErrorDialog('Payment verification failed');
        widget.onPaymentFailure?.call(verification['message'] ?? 'Payment failed');
      }
    } catch (e) {
      _showErrorDialog('Payment verification error: $e');
      widget.onPaymentFailure?.call(e.toString());
    }
  }

  void _showSuccessDialog(String reference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your payment has been processed successfully.'),
            const SizedBox(height: 8),
            Text(
              'Reference: $reference',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            const Text('You will receive a confirmation SMS and email shortly.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close payment widget
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Payment method selection widget
class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'id': 'card', 'name': 'Card', 'icon': Icons.credit_card},
      {'id': 'mobile_money', 'name': 'Mobile Money', 'icon': Icons.phone_android},
      {'id': 'bank_transfer', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
      {'id': 'ussd', 'name': 'USSD', 'icon': Icons.dialpad},
    ];

    return Wrap(
      spacing: 8,
      children: methods.map((method) {
        final isSelected = selectedMethod == method['id'];
        
        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(method['icon'] as IconData, size: 16),
              const SizedBox(width: 4),
              Text(method['name'] as String),
            ],
          ),
          onSelected: (selected) {
            if (selected) {
              onMethodSelected(method['id'] as String);
            }
          },
          selectedColor: const Color(0xFF006B3C).withValues(alpha: 0.2),
          checkmarkColor: const Color(0xFF006B3C),
        );
      }).toList(),
    );
  }
}