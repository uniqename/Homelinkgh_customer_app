import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import '../models/payment_result.dart';

/// HomeLinkGH Donation Screen
/// Allows anyone — customers, guests, diaspora — to donate to support
/// HomeLinkGH's mission of connecting Ghanaian households with skilled workers.
class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  static const _green = Color(0xFF006B3C);
  static const _gold = Color(0xFFFCD116);

  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _service = PaymentService();

  // Payment method
  _PayMethod _method = _PayMethod.momo;
  String _network = 'MTN';

  // Amount
  double? _selectedAmount;
  String _currency = 'GHS';
  bool _isRecurring = false;
  bool _isLoading = false;

  static const _quickAmountsGhs = [50.0, 100.0, 200.0, 500.0, 1000.0];
  static const _quickAmountsUsd = [5.0, 10.0, 25.0, 50.0, 100.0];

  List<double> get _quickAmounts =>
      _currency == 'GHS' ? _quickAmountsGhs : _quickAmountsUsd;

  String get _currencySymbol => _currency == 'GHS' ? 'GH₵' : '\$';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  double? get _amount {
    if (_selectedAmount != null) return _selectedAmount;
    return double.tryParse(_amountCtrl.text.trim());
  }

  Future<void> _donate() async {
    final amount = _amount;
    if (amount == null || amount <= 0) {
      _snack('Please enter or select a donation amount.');
      return;
    }
    if (_method == _PayMethod.momo && _phoneCtrl.text.trim().isEmpty) {
      _snack('Enter your Mobile Money number.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      PaymentResult result;
      final desc =
          'HomeLinkGH Donation${_isRecurring ? ' (Monthly)' : ''} — thank you!';

      switch (_method) {
        case _PayMethod.momo:
          result = await _service.processMomoPayment(
            context: context,
            amount: amount,
            phoneNumber: _phoneCtrl.text.trim(),
            network: _network,
            customerName: _nameCtrl.text.trim().isEmpty ? 'Donor' : _nameCtrl.text.trim(),
            customerEmail: _emailCtrl.text.trim(),
            description: desc,
          );
          break;

        case _PayMethod.card:
          result = await _service.processCardPayment(
            context: context,
            amount: amount,
            currency: _currency,
            customerName: _nameCtrl.text.trim().isEmpty ? 'Donor' : _nameCtrl.text.trim(),
            customerEmail: _emailCtrl.text.trim(),
            description: desc,
          );
          break;

        case _PayMethod.paypal:
          result = await _service.processPayPalPayment(
            context: context,
            amount: amount,
            currency: 'USD',
            description: desc,
          );
          break;

        case _PayMethod.paystack:
          result = await _service.processPaystackPayment(
            amount: amount,
            email: _emailCtrl.text.trim().isEmpty
                ? 'donor@homelinkgh.com'
                : _emailCtrl.text.trim(),
            serviceRequestId: 'donation_${DateTime.now().millisecondsSinceEpoch}',
          );
          break;
      }

      if (!mounted) return;

      if (result.success || result.isPending) {
        _showThankYou(amount);
      } else {
        _snack(result.message ?? 'Payment failed. Please try again.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showThankYou(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: _green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your donation of $_currencySymbol${amount.toStringAsFixed(2)} helps us connect more Ghanaian families with skilled service professionals.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close donation screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Support HomeLinkGH',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(),
            const SizedBox(height: 20),
            _currencyToggle(),
            const SizedBox(height: 20),
            _amountSection(),
            const SizedBox(height: 20),
            _recurringToggle(),
            const SizedBox(height: 20),
            _paymentMethodSection(),
            const SizedBox(height: 20),
            _donorInfoSection(),
            const SizedBox(height: 24),
            _donateButton(),
            const SizedBox(height: 12),
            _securityNote(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_green, _green.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite, color: _gold, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Make a Difference',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your donation helps us train more local service professionals, reduce unemployment, and bring quality home services to every Ghanaian household.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _impactChip(Icons.people, '12K+ Workers'),
              const SizedBox(width: 8),
              _impactChip(Icons.home, '45K+ Homes'),
              const SizedBox(width: 8),
              _impactChip(Icons.star, '4.8★ Rated'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _gold, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _currencyToggle() {
    return Row(
      children: [
        const Text(
          'Currency',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(width: 16),
        _CurrencyChip(
          label: 'GH₵ GHS',
          selected: _currency == 'GHS',
          onTap: () => setState(() {
            _currency = 'GHS';
            _selectedAmount = null;
            _amountCtrl.clear();
            if (_method == _PayMethod.paypal) _method = _PayMethod.momo;
          }),
        ),
        const SizedBox(width: 8),
        _CurrencyChip(
          label: '\$ USD',
          selected: _currency == 'USD',
          onTap: () => setState(() {
            _currency = 'USD';
            _selectedAmount = null;
            _amountCtrl.clear();
            _method = _PayMethod.paypal;
          }),
        ),
      ],
    );
  }

  Widget _amountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donation Amount',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quickAmounts.map((amt) {
            final selected = _selectedAmount == amt;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedAmount = amt;
                _amountCtrl.clear();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? _green : Colors.grey.shade300,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 6)]
                      : [],
                ),
                child: Text(
                  '$_currencySymbol${amt.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          onChanged: (_) => setState(() => _selectedAmount = null),
          decoration: InputDecoration(
            labelText: 'Or enter custom amount ($_currency)',
            prefixText: '$_currencySymbol ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recurringToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat, color: _green),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Donation',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Give automatically every month',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _isRecurring,
            onChanged: (val) => setState(() => _isRecurring = val),
            activeThumbColor: _green,
            activeTrackColor: _green.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodSection() {
    final isUsd = _currency == 'USD';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),
        if (!isUsd) ...[
          _methodTile(_PayMethod.momo, 'Mobile Money', 'MTN · Vodafone · AirtelTigo'),
          _methodTile(_PayMethod.card, 'Debit / Credit Card', 'Visa · Mastercard · Verve'),
          _methodTile(_PayMethod.paystack, 'Bank Transfer', 'Any Ghana bank account'),
        ],
        _methodTile(_PayMethod.paypal, 'PayPal (USD)', 'For diaspora payments'),

        // MoMo network picker
        if (_method == _PayMethod.momo && !isUsd) ...[
          const SizedBox(height: 12),
          _networkPicker(),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Mobile Money Number',
              hintText: '0241234567',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
            ),
          ),
        ],

        if (_method == _PayMethod.paystack && !isUsd)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll be redirected to your bank\'s page to complete the transfer.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _methodTile(_PayMethod method, String title, String subtitle) {
    // Skip GHS-only options when in USD mode
    if (_currency == 'USD' &&
        (method == _PayMethod.momo ||
            method == _PayMethod.card ||
            method == _PayMethod.paystack)) return const SizedBox.shrink();

    final sel = _method == method;
    return GestureDetector(
      onTap: () => setState(() => _method = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? _green.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? _green : Colors.grey.shade300,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              sel ? Icons.radio_button_checked : Icons.radio_button_off,
              color: sel ? _green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.black : Colors.black87)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                color: sel ? _gold.withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: sel ? _gold : Colors.grey.shade300,
                    width: sel ? 2 : 1),
              ),
              child: Text(
                n == 'AIRTELTIGO' ? 'AirtelTigo' : n,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sel ? Colors.orange.shade800 : Colors.grey,
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

  Widget _donorInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Details (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 4),
        const Text(
          'Leave blank to donate anonymously',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Your Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email (for receipt)',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _donateButton() {
    final amt = _amount;
    final label = amt != null && amt > 0
        ? 'Donate $_currencySymbol${amt.toStringAsFixed(2)}'
        : 'Donate Now';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _donate,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.favorite),
        label: Text(
          _isLoading ? 'Processing...' : label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _securityNote() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            'Secured by Flutterwave · PayStack · PayPal',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

enum _PayMethod { momo, card, paypal, paystack }

class _CurrencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF006B3C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF006B3C) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
