import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import '../models/payment_result.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level helper — present the payment bottom sheet from anywhere.
// Returns PaymentResult on completion, null if user dismisses.
// ─────────────────────────────────────────────────────────────────────────────
Future<PaymentResult?> showPaymentSheet(
  BuildContext context, {
  required double amount,
  required String currency,
  required String customerEmail,
  required String customerName,
  String? description,
  String? serviceRequestId,
  String? quoteId,
  String? providerId,
  String? providerName,
  String? serviceType,
}) {
  return showModalBottomSheet<PaymentResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentSheet(
      amount: amount,
      currency: currency,
      customerEmail: customerEmail,
      customerName: customerName,
      description: description,
      serviceRequestId: serviceRequestId,
      quoteId: quoteId,
      providerId: providerId,
      providerName: providerName,
      serviceType: serviceType,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal bottom-sheet widget
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentSheet extends StatefulWidget {
  final double amount;
  final String currency;
  final String customerEmail;
  final String customerName;
  final String? description;
  final String? serviceRequestId;
  final String? quoteId;
  final String? providerId;
  final String? providerName;
  final String? serviceType;

  const _PaymentSheet({
    required this.amount,
    required this.currency,
    required this.customerEmail,
    required this.customerName,
    this.description,
    this.serviceRequestId,
    this.quoteId,
    this.providerId,
    this.providerName,
    this.serviceType,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

enum _Method { momo, card, stripe, paypal, paystack }

class _PaymentSheetState extends State<_PaymentSheet> {
  _Method? _selected;
  bool _processing = false;
  String? _error;

  // MoMo fields
  final _phoneController = TextEditingController();
  String _momoNetwork = 'MTN';
  static const _networks = ['MTN', 'Vodafone', 'AirtelTigo'];

  // PayStack pending verify
  String? _paystackRef;

  final _paymentService = PaymentService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ── Colours ─────────────────────────────────────────────────────────────────
  static const _green = Color(0xFF006B3C);
  static const _gold  = Color(0xFFFCD116);
  static const _bg    = Color(0xFF0A1A10);
  static const _card  = Color(0xFF0D2016);

  // ── Tiles ───────────────────────────────────────────────────────────────────
  Widget _tile(_Method method, String emoji, String title, String subtitle) {
    final sel = _selected == method;
    return GestureDetector(
      onTap: _processing ? null : () => setState(() { _selected = method; _error = null; _paystackRef = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? _green.withValues(alpha: 0.15) : _card,
          border: Border.all(
            color: sel ? _green : Colors.white.withValues(alpha: 0.1),
            width: sel ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white.withValues(alpha: 0.87),
                      fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            if (sel)
              const Icon(Icons.check_circle, color: _green, size: 20)
            else
              const Icon(Icons.radio_button_off, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _momoExtra() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mobile Network', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: _networks.map((n) {
              final sel = _momoNetwork == n;
              return GestureDetector(
                onTap: () => setState(() => _momoNetwork = n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _green : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? _green : Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(n,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white60,
                      fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text('Phone Number', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: '024 000 0000',
              hintStyle: const TextStyle(color: Colors.white24),
              prefixText: '+233  ',
              prefixStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _green)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: _gold, size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: _gold, fontSize: 12))),
        ],
      ),
    );
  }

  // ── Payment dispatch ─────────────────────────────────────────────────────────
  Future<void> _pay() async {
    if (_selected == null) {
      setState(() => _error = 'Please select a payment method');
      return;
    }
    if (_selected == _Method.momo && _phoneController.text.length < 9) {
      setState(() => _error = 'Enter a valid Ghana phone number');
      return;
    }

    setState(() { _processing = true; _error = null; });

    try {
      PaymentResult result;

      switch (_selected!) {
        case _Method.momo:
          result = await _paymentService.processMomoPayment(
            context: context,
            amount: widget.amount,
            phoneNumber: '+233${_phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')}',
            network: _momoNetwork,
            customerEmail: widget.customerEmail,
            customerName: widget.customerName,
            description: widget.description,
            serviceRequestId: widget.serviceRequestId,
            quoteId: widget.quoteId,
            providerId: widget.providerId,
            providerName: widget.providerName,
            serviceType: widget.serviceType,
          );

        case _Method.card:
          result = await _paymentService.processCardPayment(
            context: context,
            amount: widget.amount,
            currency: widget.currency,
            customerEmail: widget.customerEmail,
            customerName: widget.customerName,
            description: widget.description,
            serviceRequestId: widget.serviceRequestId,
            quoteId: widget.quoteId,
            providerId: widget.providerId,
            providerName: widget.providerName,
            serviceType: widget.serviceType,
          );

        case _Method.stripe:
          result = await _paymentService.processStripePayment(
            context: context,
            amount: widget.amount,
            currency: widget.currency,
            customerEmail: widget.customerEmail,
            customerName: widget.customerName,
            description: widget.description,
            serviceRequestId: widget.serviceRequestId,
            quoteId: widget.quoteId,
            providerId: widget.providerId,
            providerName: widget.providerName,
            serviceType: widget.serviceType,
          );

        case _Method.paypal:
          result = await _paymentService.processPayPalPayment(
            context: context,
            amount: widget.amount,
            currency: widget.currency == 'GHS' ? 'USD' : widget.currency,
            description: widget.description ?? 'HomeLinkGH Payment',
            serviceRequestId: widget.serviceRequestId,
            quoteId: widget.quoteId,
            providerId: widget.providerId,
            providerName: widget.providerName,
            serviceType: widget.serviceType,
          );

        case _Method.paystack:
          result = await _paymentService.processPaystackPayment(
            amount: widget.amount,
            currency: widget.currency,
            customerEmail: widget.customerEmail,
            customerName: widget.customerName,
            description: widget.description,
          );
          // PayStack opens a browser — show verify button
          if (result.isPending) {
            setState(() {
              _paystackRef = result.transactionId;
              _processing = false;
            });
            return;
          }
      }

      if (!mounted) return;
      if (result.success) {
        Navigator.pop(context, result);
      } else {
        setState(() { _processing = false; _error = result.message ?? 'Payment failed. Try again.'; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _processing = false; _error = 'Payment error: $e'; });
    }
  }

  Future<void> _verifyPaystack() async {
    if (_paystackRef == null) return;
    setState(() { _processing = true; _error = null; });

    final result = await _paymentService.verifyPaystackPayment(
      _paystackRef!,
      serviceRequestId: widget.serviceRequestId,
      quoteId: widget.quoteId,
      providerId: widget.providerId,
      providerName: widget.providerName,
      serviceType: widget.serviceType,
      amount: widget.amount,
    );

    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context, result);
    } else {
      setState(() { _processing = false; _error = result.message ?? 'Verification failed. Try again.'; });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final symbol = widget.currency == 'GHS' ? 'GH₵' : widget.currency;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 18),

              // Amount summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003D1F), Color(0xFF0A1A10)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _green.withValues(alpha: 0.35)),
                ),
                child: Column(
                  children: [
                    const Text('Total Amount',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('$symbol ${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32,
                        fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    if (widget.description != null) ...[
                      const SizedBox(height: 4),
                      Text(widget.description!,
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Choose Payment Method',
                style: TextStyle(color: Colors.white, fontSize: 17,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              // ── MoMo ──
              _tile(_Method.momo, '📱', 'Mobile Money (MoMo)',
                'MTN, Vodafone Cash, AirtelTigo'),
              if (_selected == _Method.momo) _momoExtra(),

              // ── Flutterwave card ──
              _tile(_Method.card, '💳', 'Debit / Credit Card',
                'Visa, Mastercard, Verve  via Flutterwave'),

              // ── Stripe ──
              _tile(_Method.stripe, '⚡', 'Card / Apple Pay / Google Pay',
                'Powered by Stripe  ·  Link supported'),

              // ── PayPal ──
              _tile(_Method.paypal, '🌐', 'PayPal',
                'International payments in USD'),

              // ── PayStack bank transfer ──
              _tile(_Method.paystack, '🏦', 'Bank Transfer (GHS)',
                'Local Ghana bank accounts via PayStack'),
              if (_selected == _Method.paystack)
                _infoBox('PayStack will open in your browser. Come back and tap '
                    '"Verify Payment" after completing the transfer.'),

              // PayStack pending verify button
              if (_paystackRef != null) ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : _verifyPaystack,
                    icon: const Icon(Icons.verified_outlined, color: _green),
                    label: const Text('Verify Payment',
                      style: TextStyle(color: _green, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Error
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Pay button (hidden when PayStack pending)
              if (_paystackRef == null)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _processing ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _green.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _processing
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                      : Text('Pay $symbol ${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity, height: 44,
                child: TextButton(
                  onPressed: _processing ? null : () => Navigator.pop(context, null),
                  child: const Text('Cancel',
                    style: TextStyle(color: Colors.white38, fontSize: 14)),
                ),
              ),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 11, color: Colors.white24),
                    const SizedBox(width: 4),
                    const Text('Flutterwave · Stripe · PayPal · PayStack',
                      style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kept for backward compatibility
// ─────────────────────────────────────────────────────────────────────────────
class PaymentMethodSelector extends StatelessWidget {
  final String userId;
  final Function(dynamic) onMethodSelected;
  final bool allowAddNew;

  const PaymentMethodSelector({
    super.key,
    required this.userId,
    required this.onMethodSelected,
    this.allowAddNew = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2016),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Use showPaymentSheet() to present the payment UI.',
        style: TextStyle(color: Colors.white54, fontSize: 13),
      ),
    );
  }
}
