import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/payment_result.dart';
import 'supabase_service.dart';

/// HomeLinkGH Payment Service
/// Supports: MoMo (MTN/Vodafone/AirtelTigo), Card, Stripe, PayPal, PayStack
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  String? _flutterwavePublicKey;
  String? _flutterwaveSecretKey;
  String? _paypalClientId;
  String? _paypalSecret;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _flutterwavePublicKey = dotenv.env['FLUTTERWAVE_PUBLIC_KEY'];
      _flutterwaveSecretKey = dotenv.env['FLUTTERWAVE_SECRET_KEY'];
      _paypalClientId      = dotenv.env['PAYPAL_CLIENT_ID'];
      _paypalSecret        = dotenv.env['PAYPAL_SECRET'];
      _isInitialized = true;
      developer.log('✅ [Payment] HomeLinkGH payment service initialized');
    } catch (e) {
      developer.log('❌ [Payment] Init failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE MONEY  (MTN, Vodafone Cash, AirtelTigo)
  // ─────────────────────────────────────────────────────────────────────────
  Future<PaymentResult> processMomoPayment({
    required BuildContext context,
    required double amount,
    required String phoneNumber,
    required String network,
    required String customerEmail,
    String? customerName,
    String? description,
    String? transactionRef,
    String? serviceRequestId,
    String? quoteId,
    String? providerId,
    String? providerName,
    String? serviceType,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      if (_flutterwavePublicKey == null || _flutterwavePublicKey!.isEmpty) {
        return PaymentResult.failure(message: 'Payment gateway not configured.');
      }
      if (!_isValidGhanaPhone(phoneNumber)) {
        return PaymentResult.failure(
            message: 'Invalid phone number. Use Ghana format e.g. 024 000 0000');
      }

      final txRef = transactionRef ?? 'HLG-MOMO-${DateTime.now().millisecondsSinceEpoch}';

      final flutterwave = Flutterwave(
        publicKey: _flutterwavePublicKey!,
        currency: 'GHS',
        redirectUrl: 'https://homelinkgh.com/payment/callback',
        txRef: txRef,
        amount: amount.toString(),
        customer: Customer(
          name: customerName ?? 'HomeLinkGH Customer',
          phoneNumber: phoneNumber,
          email: customerEmail,
        ),
        paymentOptions: 'mobilemoneyghana',
        customization: Customization(
          title: 'HomeLinkGH Services',
          description: description ?? 'Service Payment',
          logo: 'https://homelinkgh.com/logo.png',
        ),
        isTestMode: _flutterwavePublicKey!.contains('TEST'),
      );

      final response = await flutterwave.charge(context);

      if (response.success == true) {
        final verified = await _verifyFlutterwave(response.transactionId ?? '');
        if (verified) {
          await _recordBooking(
            transactionId: response.transactionId ?? txRef,
            amount: amount, currency: 'GHS', method: 'momo',
            serviceRequestId: serviceRequestId, quoteId: quoteId,
            providerId: providerId, providerName: providerName,
            serviceType: serviceType,
          );
          return PaymentResult.success(
            transactionId: response.transactionId ?? txRef,
            message: 'Mobile Money payment completed',
            rawResponse: {'tx_ref': response.txRef, 'network': network},
          );
        }
        return PaymentResult.failure(message: 'Payment verification failed.');
      }
      return PaymentResult.failure(
          message: 'MoMo payment ${response.status ?? "failed"}. Please try again.');
    } catch (e) {
      return PaymentResult.failure(message: 'MoMo payment failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD  (Visa, Mastercard, Verve via Flutterwave)
  // ─────────────────────────────────────────────────────────────────────────
  Future<PaymentResult> processCardPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
    String? customerPhone,
    String? description,
    String? transactionRef,
    String? serviceRequestId,
    String? quoteId,
    String? providerId,
    String? providerName,
    String? serviceType,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      if (_flutterwavePublicKey == null || _flutterwavePublicKey!.isEmpty) {
        return PaymentResult.failure(message: 'Payment gateway not configured.');
      }

      final txRef = transactionRef ?? 'HLG-TXN-${DateTime.now().millisecondsSinceEpoch}';

      final flutterwave = Flutterwave(
        publicKey: _flutterwavePublicKey!,
        currency: currency,
        redirectUrl: 'https://homelinkgh.com/payment/callback',
        txRef: txRef,
        amount: amount.toString(),
        customer: Customer(
          name: customerName,
          phoneNumber: customerPhone ?? '',
          email: customerEmail,
        ),
        paymentOptions: 'card',
        customization: Customization(
          title: 'HomeLinkGH Services',
          description: description ?? 'Service Payment',
          logo: 'https://homelinkgh.com/logo.png',
        ),
        isTestMode: _flutterwavePublicKey!.contains('TEST'),
      );

      final response = await flutterwave.charge(context);

      if (response.success == true) {
        final verified = await _verifyFlutterwave(response.transactionId ?? '');
        if (verified) {
          await _recordBooking(
            transactionId: response.transactionId ?? txRef,
            amount: amount, currency: currency, method: 'card',
            serviceRequestId: serviceRequestId, quoteId: quoteId,
            providerId: providerId, providerName: providerName,
            serviceType: serviceType,
          );
          return PaymentResult.success(
            transactionId: response.transactionId ?? txRef,
            message: 'Card payment completed',
          );
        }
        return PaymentResult.failure(message: 'Payment verification failed.');
      }
      return PaymentResult.failure(
          message: 'Card payment ${response.status ?? "failed"}. Please try again.');
    } catch (e) {
      return PaymentResult.failure(message: 'Card payment failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAYPAL
  // ─────────────────────────────────────────────────────────────────────────
  Future<PaymentResult> processPayPalPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    String? transactionRef,
    String? serviceRequestId,
    String? quoteId,
    String? providerId,
    String? providerName,
    String? serviceType,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      if (_paypalClientId == null || _paypalClientId!.isEmpty) {
        return PaymentResult.failure(message: 'PayPal not configured.');
      }

      final txRef = transactionRef ?? 'HLG-PP-${DateTime.now().millisecondsSinceEpoch}';
      PaymentResult? result;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaypalCheckoutView(
            sandboxMode: _paypalClientId!.contains('sandbox'),
            clientId: _paypalClientId!,
            secretKey: _paypalSecret ?? '',
            transactions: [
              {
                "amount": {
                  "total": amount.toStringAsFixed(2),
                  "currency": currency,
                  "details": {
                    "subtotal": amount.toStringAsFixed(2),
                    "shipping": '0',
                    "shipping_discount": 0,
                  }
                },
                "description": description,
                "item_list": {
                  "items": [
                    {
                      "name": description,
                      "quantity": 1,
                      "price": amount.toStringAsFixed(2),
                      "currency": currency,
                    }
                  ],
                }
              }
            ],
            note: "Thank you for using HomeLinkGH!",
            onSuccess: (Map params) async {
              final txId = params['paymentId'] ?? txRef;
              await _recordBooking(
                transactionId: txId,
                amount: amount, currency: currency, method: 'paypal',
                serviceRequestId: serviceRequestId, quoteId: quoteId,
                providerId: providerId, providerName: providerName,
                serviceType: serviceType,
              );
              result = PaymentResult.success(
                transactionId: txId,
                message: 'PayPal payment completed',
                rawResponse: Map<String, dynamic>.from(params),
              );
            },
            onError: (error) {
              result = PaymentResult.failure(message: 'PayPal failed: $error');
            },
            onCancel: () {
              result = PaymentResult.failure(message: 'Payment cancelled');
            },
          ),
        ),
      );

      return result ?? PaymentResult.failure(message: 'Payment incomplete');
    } catch (e) {
      return PaymentResult.failure(message: 'PayPal payment failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAYSTACK  (Bank transfer + local Ghana cards)
  // ─────────────────────────────────────────────────────────────────────────
  Future<PaymentResult> processPaystackPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
    String? description,
    String? transactionRef,
    String? serviceRequestId,
    String? quoteId,
    String? providerId,
    String? providerName,
    String? serviceType,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final secretKey = dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';
      if (secretKey.isEmpty) {
        return PaymentResult.failure(message: 'PayStack not configured.');
      }

      final txRef = transactionRef ?? 'HLG-PS-${DateTime.now().millisecondsSinceEpoch}';
      final amountInPesewas = (amount * 100).round();

      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': customerEmail,
          'amount': amountInPesewas,
          'currency': currency,
          'reference': txRef,
          'callback_url': 'https://homelinkgh.com/payment/callback',
          'metadata': {
            'name': customerName,
            'description': description ?? 'HomeLinkGH Service Payment',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final authUrl = data['data']['authorization_url'] as String;
          final reference = data['data']['reference'] as String;
          await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
          return PaymentResult(
            success: false,
            isPending: true,
            transactionId: reference,
            message: 'Payment opened in browser. Tap "Verify Payment" when done.',
          );
        }
        return PaymentResult.failure(
            message: data['message'] ?? 'PayStack initialisation failed.');
      }
      return PaymentResult.failure(
          message: 'PayStack error (${response.statusCode}). Try again.');
    } catch (e) {
      return PaymentResult.failure(message: 'PayStack payment failed: $e');
    }
  }

  Future<PaymentResult> verifyPaystackPayment(
    String reference, {
    String? serviceRequestId,
    String? quoteId,
    String? providerId,
    String? providerName,
    String? serviceType,
    double? amount,
  }) async {
    try {
      final secretKey = dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {'Authorization': 'Bearer $secretKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data']['status'] == 'success') {
          await _recordBooking(
            transactionId: reference,
            amount: amount ?? 0, currency: 'GHS', method: 'paystack',
            serviceRequestId: serviceRequestId, quoteId: quoteId,
            providerId: providerId, providerName: providerName,
            serviceType: serviceType,
          );
          return PaymentResult.success(
            transactionId: reference,
            message: 'Bank transfer verified successfully',
            rawResponse: Map<String, dynamic>.from(data['data']),
          );
        }
        final status = data['data']?['status'] ?? 'failed';
        return PaymentResult.failure(
            message: 'Payment not completed (status: $status). Try again.');
      }
      return PaymentResult.failure(
          message: 'Verification error (${response.statusCode}).');
    } catch (e) {
      return PaymentResult.failure(message: 'Verification failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNAL HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _verifyFlutterwave(String transactionId) async {
    try {
      if (transactionId.isEmpty || _flutterwaveSecretKey == null) return false;
      final response = await http.get(
        Uri.parse('https://api.flutterwave.com/v3/transactions/$transactionId/verify'),
        headers: {'Authorization': 'Bearer $_flutterwaveSecretKey'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success' &&
            data['data']['status'] == 'successful';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _recordBooking({
    required String transactionId,
    required double amount,
    required String currency,
    required String method,
    String? serviceRequestId,
    String? quoteId,
    String? providerId,
    String? providerName,
    String? serviceType,
  }) async {
    try {
      if (serviceRequestId == null && quoteId == null) return;
      final supabase = SupabaseService();
      await supabase.supabase.from('bookings').insert({
        'transaction_id': transactionId,
        'amount': amount,
        'currency': currency,
        'payment_method': method,
        'service_request_id': serviceRequestId,
        'quote_id': quoteId,
        'provider_id': providerId,
        'provider_name': providerName,
        'service_type': serviceType,
        'status': 'confirmed',
        'created_at': DateTime.now().toIso8601String(),
      });
      if (serviceRequestId != null) {
        await supabase.supabase
            .from('service_requests')
            .update({'status': 'booked'})
            .eq('id', serviceRequestId);
      }
    } catch (e) {
      developer.log('⚠️ [Payment] Booking record failed: $e');
    }
  }

  bool _isValidGhanaPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^0[2-5][0-9]{8}$').hasMatch(cleaned) ||
        RegExp(r'^233[2-5][0-9]{8}$').hasMatch(cleaned) ||
        RegExp(r'^\+233[2-5][0-9]{8}$').hasMatch(cleaned);
  }

  bool get isInitialized => _isInitialized;
}
