import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import '../models/payment_result.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  // ── Brand colours ──────────────────────────────────────────────────────────
  static const _bg      = Color(0xFF040D08);
  static const _card    = Color(0xFF0A1A0F);
  static const _green   = Color(0xFF006B3C);
  static const _greenLt = Color(0xFF00A651);
  static const _gold    = Color(0xFFFCD116);
  static const _white   = Colors.white;

  final _amountCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _service    = PaymentService();

  _PayMethod _method    = _PayMethod.momo;
  String     _network   = 'MTN';
  String     _currency  = 'GHS';
  double?    _fixedAmt;
  bool       _recurring = false;
  bool       _loading   = false;

  static const _ghsAmts = [50.0, 100.0, 200.0, 500.0, 1000.0];
  static const _usdAmts = [5.0, 10.0, 25.0, 50.0, 100.0];

  List<double> get _quickAmts => _currency == 'GHS' ? _ghsAmts : _usdAmts;
  String get _sym => _currency == 'GHS' ? 'GH₵' : '\$';

  double? get _amount {
    if (_fixedAmt != null) return _fixedAmt;
    return double.tryParse(_amountCtrl.text.trim());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Payment logic ──────────────────────────────────────────────────────────

  Future<void> _donate() async {
    final amt = _amount;
    if (amt == null || amt <= 0) {
      _snack('Please select or enter a donation amount.');
      return;
    }
    if (_method == _PayMethod.momo && _phoneCtrl.text.trim().isEmpty) {
      _snack('Enter your Mobile Money number.');
      return;
    }

    setState(() => _loading = true);

    try {
      final desc = 'HomeLinkGH Donation${_recurring ? ' (Monthly)' : ''}';
      final name = _nameCtrl.text.trim().isEmpty ? 'Donor' : _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim().isEmpty ? 'donor@homelinkgh.com' : _emailCtrl.text.trim();

      PaymentResult result;
      switch (_method) {
        case _PayMethod.momo:
          result = await _service.processMomoPayment(
            context: context,
            amount: amt,
            phoneNumber: _phoneCtrl.text.trim(),
            network: _network,
            customerName: name,
            customerEmail: email,
            description: desc,
          );
          break;
        case _PayMethod.card:
          result = await _service.processCardPayment(
            context: context,
            amount: amt,
            currency: _currency,
            customerName: name,
            customerEmail: email,
            description: desc,
          );
          break;
        case _PayMethod.paypal:
          result = await _service.processPayPalPayment(
            context: context,
            amount: amt,
            currency: 'USD',
            description: desc,
          );
          break;
        case _PayMethod.paystack:
          result = await _service.processPaystackPayment(
            amount: amt,
            email: email,
            serviceRequestId: 'donation_${DateTime.now().millisecondsSinceEpoch}',
          );
          break;
      }

      if (!mounted) return;
      if (result.success || result.isPending) {
        _showThankYou(amt);
      } else {
        _snack(result.message ?? 'Payment failed. Please try again.');
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e');
      setState(() => _loading = false);
    }
  }

  void _showThankYou(double amt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: _gold, size: 38),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank You!',
                style: TextStyle(
                  color: _white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your donation of $_sym${amt.toStringAsFixed(2)} helps connect more Ghanaian families with skilled professionals.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        title: const Text(
          'Support HomeLinkGH',
          style: TextStyle(color: _white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(),
            const SizedBox(height: 20),
            _currencyRow(),
            const SizedBox(height: 20),
            _section('Donation Amount', _amountSection()),
            const SizedBox(height: 20),
            _recurringRow(),
            const SizedBox(height: 20),
            _section('Payment Method', _methodSection()),
            const SizedBox(height: 20),
            _section('Your Details (Optional)', _donorFields()),
            const SizedBox(height: 28),
            _donateBtn(),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 13, color: Colors.white38),
                  const SizedBox(width: 4),
                  const Text(
                    'Secured by Flutterwave · PayStack · PayPal',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_green, _greenLt],
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
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite, color: _gold, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Make a Difference',
                  style: TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your donation trains local service professionals, reduces unemployment, and brings quality home services to every Ghanaian household.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(Icons.people, '12K+ Workers'),
              _chip(Icons.home, '45K+ Homes Served'),
              _chip(Icons.star, '4.8★ Rated'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _gold, size: 13),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: _white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _currencyRow() {
    return Row(
      children: [
        const Text('Currency',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 16),
        _currencyChip('GH₵  GHS', 'GHS'),
        const SizedBox(width: 8),
        _currencyChip('\$  USD', 'USD'),
      ],
    );
  }

  Widget _currencyChip(String label, String value) {
    final sel = _currency == value;
    return GestureDetector(
      onTap: () => setState(() {
        _currency = value;
        _fixedAmt = null;
        _amountCtrl.clear();
        if (value == 'USD') _method = _PayMethod.paypal;
        else if (_method == _PayMethod.paypal) _method = _PayMethod.momo;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _green : _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _green : Colors.white24),
        ),
        child: Text(label,
          style: TextStyle(
            color: sel ? _white : Colors.white60,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _amountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickAmts.map((amt) {
            final sel = _fixedAmt == amt;
            return GestureDetector(
              onTap: () => setState(() {
                _fixedAmt = amt;
                _amountCtrl.clear();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(
                  color: sel ? _green : _card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? _green : Colors.white24,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Text(
                  '$_sym${amt.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: sel ? _white : Colors.white70,
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
          style: const TextStyle(color: _white),
          onChanged: (_) => setState(() => _fixedAmt = null),
          decoration: InputDecoration(
            labelText: 'Custom amount ($_currency)',
            labelStyle: const TextStyle(color: Colors.white54),
            prefixText: '$_sym  ',
            prefixStyle: const TextStyle(color: Colors.white70),
            hintText: '0.00',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recurringRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat, color: _greenLt),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Donation',
                  style: TextStyle(color: _white, fontWeight: FontWeight.w600)),
                Text('Give automatically every month',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _recurring,
            onChanged: (v) => setState(() => _recurring = v),
            activeThumbColor: _white,
            activeTrackColor: _green,
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _methodSection() {
    final isUsd = _currency == 'USD';
    return Column(
      children: [
        if (!isUsd) ...[
          _methodTile(_PayMethod.momo,     'Mobile Money',       'MTN · Vodafone · AirtelTigo'),
          _methodTile(_PayMethod.card,     'Debit / Credit Card','Visa · Mastercard · Verve'),
          _methodTile(_PayMethod.paystack, 'Bank Transfer',      'Any Ghana bank account'),
        ],
        _methodTile(_PayMethod.paypal, 'PayPal', isUsd ? 'Pay in USD' : 'For diaspora / USD payments'),

        if (_method == _PayMethod.momo && !isUsd) ...[
          const SizedBox(height: 12),
          _networkPicker(),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: _white),
            decoration: InputDecoration(
              labelText: 'Mobile Money Number',
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: '0241234567',
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: const Icon(Icons.phone, color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
            ),
          ),
        ],

        if (_method == _PayMethod.paystack && !isUsd) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You'll be redirected to your bank's page to complete the transfer.",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _methodTile(_PayMethod m, String title, String subtitle) {
    // Don't show GHS-only methods in USD mode
    if (_currency == 'USD' &&
        (m == _PayMethod.momo || m == _PayMethod.card || m == _PayMethod.paystack)) {
      return const SizedBox.shrink();
    }
    final sel = _method == m;
    return GestureDetector(
      onTap: () => setState(() => _method = m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? _green.withValues(alpha: 0.15) : _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? _green : Colors.white12,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              sel ? Icons.radio_button_checked : Icons.radio_button_off,
              color: sel ? _gold : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      color: sel ? _white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
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
                color: sel ? _gold.withValues(alpha: 0.15) : _card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel ? _gold : Colors.white24),
              ),
              child: Text(
                n == 'AIRTELTIGO' ? 'AirtelTigo' : n,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sel ? _gold : Colors.white54,
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

  Widget _donorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Leave blank to donate anonymously',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _field(_nameCtrl, 'Your Name', Icons.person_outline, TextInputType.name),
        const SizedBox(height: 12),
        _field(_emailCtrl, 'Email (for receipt)', Icons.email_outlined, TextInputType.emailAddress),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: _white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green, width: 2),
        ),
      ),
    );
  }

  Widget _donateBtn() {
    final amt = _amount;
    final label = (amt != null && amt > 0)
        ? 'Donate $_sym${amt.toStringAsFixed(2)}'
        : 'Donate Now';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _donate,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: _white,
          disabledBackgroundColor: Colors.white12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        icon: _loading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: _white, strokeWidth: 2),
              )
            : const Icon(Icons.favorite),
        label: Text(
          _loading ? 'Processing...' : label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

enum _PayMethod { momo, card, paypal, paystack }
