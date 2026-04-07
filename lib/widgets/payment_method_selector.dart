import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import '../models/payment_result.dart';

/// Show the HomeLinkGH payment bottom sheet.
///
/// Returns a [PaymentResult] on success/pending, or null if the user cancelled.
Future<PaymentResult?> showPaymentSheet(
  BuildContext context, {
  required double amount,
  required String serviceRequestId,
  String? customerEmail,
  String? customerName,
  String? providerId,
}) {
  return showModalBottomSheet<PaymentResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentSheet(
      amount: amount,
      serviceRequestId: serviceRequestId,
      customerEmail: customerEmail ?? '',
      customerName: customerName ?? 'Customer',
      providerId: providerId,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

enum _Method { momo, card, paypal, paystack }

class _PaymentSheet extends StatefulWidget {
  final double amount;
  final String serviceRequestId;
  final String customerEmail;
  final String customerName;
  final String? providerId;

  const _PaymentSheet({
    required this.amount,
    required this.serviceRequestId,
    required this.customerEmail,
    required this.customerName,
    this.providerId,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  _Method _selected = _Method.momo;
  bool _loading = false;
  bool _pendingVerify = false;
  String _pendingRef = '';

  // MoMo fields
  final _phoneCtrl = TextEditingController();
  String _network = 'MTN';

  final _service = PaymentService();

  static const _green = Color(0xFF006B3C);
  static const _gold = Color(0xFFFCD116);

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      PaymentResult result;

      switch (_selected) {
        case _Method.momo:
          if (_phoneCtrl.text.trim().isEmpty) {
            _snack('Enter your Mobile Money phone number.');
            setState(() => _loading = false);
            return;
          }
          result = await _service.processMomoPayment(
            context: context,
            amount: widget.amount,
            phoneNumber: _phoneCtrl.text.trim(),
            network: _network,
            customerName: widget.customerName,
            customerEmail: widget.customerEmail,
            description: 'HomeLinkGH Service Payment',
          );
          break;

        case _Method.card:
          result = await _service.processCardPayment(
            context: context,
            amount: widget.amount,
            currency: 'GHS',
            customerName: widget.customerName,
            customerEmail: widget.customerEmail,
            description: 'HomeLinkGH Service Payment',
          );
          break;

        case _Method.paypal:
          result = await _service.processPayPalPayment(
            context: context,
            amount: widget.amount,
            currency: 'USD',
            description: 'HomeLinkGH Service Payment',
          );
          break;

        case _Method.paystack:
          result = await _service.processPaystackPayment(
            amount: widget.amount,
            email: widget.customerEmail,
            serviceRequestId: widget.serviceRequestId,
          );
          if (result.isPending && mounted) {
            setState(() {
              _pendingVerify = true;
              _pendingRef = result.transactionId ?? '';
              _loading = false;
            });
            return;
          }
          break;
      }

      if (!mounted) return;

      if (result.success) {
        Navigator.pop(context, result);
      } else {
        _snack(result.message ?? 'Payment failed. Please try again.');
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Payment error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final result = await _service.verifyPaystackPayment(
      reference: _pendingRef,
      serviceRequestId: widget.serviceRequestId,
      amount: widget.amount,
      providerId: widget.providerId,
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context, result);
    } else {
      _snack(result.message ?? 'Not verified yet. Please wait a moment.');
      setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pay for Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'GH₵ ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Secured by Flutterwave · PayPal · PayStack',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),

          if (_pendingVerify) ...[
            _pendingBanner(),
          ] else ...[
            // Method picker
            _methodRow(_Method.momo, 'Mobile Money', 'MTN · Vodafone · AirtelTigo'),
            _methodRow(_Method.card, 'Debit / Credit Card', 'Visa · Mastercard · Verve'),
            _methodRow(_Method.paystack, 'Bank Transfer', 'Any Ghana bank account'),
            _methodRow(_Method.paypal, 'PayPal (USD)', 'For diaspora payments'),
            const SizedBox(height: 16),

            // MoMo extra fields
            if (_selected == _Method.momo) ...[
              _networkPicker(),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mobile Money Number',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: '0241234567',
                  hintStyle: const TextStyle(color: Colors.white24),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _green),
                  ),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // PayStack info
            if (_selected == _Method.paystack)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white54, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be taken to your bank\'s page to complete the transfer. Come back and tap "Verify Payment" when done.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _selected == _Method.paystack
                            ? 'Open Bank Transfer'
                            : 'Pay GH₵ ${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _methodRow(_Method method, String title, String subtitle) {
    final selected = _selected == method;
    return GestureDetector(
      onTap: () => setState(() => _selected = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _green : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _gold : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkPicker() {
    return Row(
      children: ['MTN', 'VODAFONE', 'AIRTELTIGO'].map((n) {
        final sel = _network == n;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _network = n),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: sel ? _gold.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel ? _gold : Colors.white12),
              ),
              child: Text(
                n == 'AIRTELTIGO' ? 'AirtelTigo' : n,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sel ? _gold : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _pendingBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top, color: Colors.amber),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waiting for bank transfer',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Complete the transfer in your browser, then tap Verify Payment below.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Verify Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
