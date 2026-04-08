import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_result.dart';

/// Service for handling payment processing through various gateways
/// Supports: Flutterwave (Cards, Mobile Money), PayPal
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // API Keys (loaded from .env)
  String? _flutterwavePublicKey;
  String? _flutterwaveSecretKey;
  String? _flutterwaveEncryptionKey;
  String? _paypalClientId;
  String? _paypalSecret;
  String? _paystackPublicKey;
  String? _paystackSecretKey;
  bool _isInitialized = false;

  /// Initialize payment service and load API keys from environment
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('💳 [Payment] Already initialized');
      return;
    }

    try {
      developer.log('💳 [Payment] Initializing payment service...');

      // Load API keys from .env
      _flutterwavePublicKey = dotenv.env['FLUTTERWAVE_PUBLIC_KEY'];
      _flutterwaveSecretKey = dotenv.env['FLUTTERWAVE_SECRET_KEY'];
      _flutterwaveEncryptionKey = dotenv.env['FLUTTERWAVE_ENCRYPTION_KEY'];
      _paypalClientId = dotenv.env['PAYPAL_CLIENT_ID'];
      _paypalSecret = dotenv.env['PAYPAL_SECRET'];
      _paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'];
      _paystackSecretKey = dotenv.env['PAYSTACK_SECRET_KEY'];

      // Validate Flutterwave keys
      if (_flutterwavePublicKey == null || _flutterwavePublicKey!.isEmpty) {
        developer.log('⚠️ [Payment] Flutterwave public key not found in .env');
      }
      if (_flutterwaveSecretKey == null || _flutterwaveSecretKey!.isEmpty) {
        developer.log('⚠️ [Payment] Flutterwave secret key not found in .env');
      }

      // Validate PayPal keys
      if (_paypalClientId == null || _paypalClientId!.isEmpty) {
        developer.log('⚠️ [Payment] PayPal client ID not found in .env');
      }

      _isInitialized = true;
      developer.log('✅ [Payment] Payment service initialized successfully');
    } catch (e) {
      developer.log('❌ [Payment] Failed to initialize: $e');
      _isInitialized = false;
    }
  }

  /// Process card payment through Flutterwave
  ///
  /// Supports Visa, Mastercard, Verve cards
  /// Works for both USD and GHS currencies
  Future<PaymentResult> processCardPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
    String? customerPhone,
    String? description,
    String? transactionRef,
  }) async {
    try {
      developer.log('💳 [Payment] Processing card payment: $currency $amount');

      // Ensure initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Validate API keys
      if (_flutterwavePublicKey == null || _flutterwavePublicKey!.isEmpty) {
        return PaymentResult.failure(
          message: 'Payment gateway not configured. Please contact support.',
        );
      }

      // Generate transaction reference if not provided
      final String txRef = transactionRef ??
          'HLG-TXN-${DateTime.now().millisecondsSinceEpoch}';

      // Create Flutterwave customer
      final customer = Customer(
        name: customerName,
        phoneNumber: customerPhone ?? '',
        email: customerEmail,
      );

      // Create Flutterwave request
      final Flutterwave flutterwave = Flutterwave(
        publicKey: _flutterwavePublicKey!,
        currency: currency,
        redirectUrl: 'https://homelinkgh.com/payment/callback',
        txRef: txRef,
        amount: amount.toString(),
        customer: customer,
        paymentOptions: 'card',
        customization: Customization(
          title: 'HomeLinkGH Services',
          description: description ?? 'Service Payment',
          logo: 'https://homelinkgh.com/logo.png',
        ),
        isTestMode: _flutterwavePublicKey!.contains('TEST'), // Auto-detect test mode
      );

      // Initiate payment
      developer.log('💳 [Payment] Launching Flutterwave payment UI...');
      final ChargeResponse response = await flutterwave.charge(context);

      // Process response
      if (response.success == true) {
        developer.log('✅ [Payment] Card payment successful: ${response.transactionId}');

        // Verify payment on backend (important for security)
        final bool verified = await verifyFlutterwavePayment(
          response.transactionId ?? '',
        );

        if (verified) {
          return PaymentResult.success(
            transactionId: response.transactionId ?? txRef,
            message: 'Payment completed successfully',
            rawResponse: {
              'tx_ref': response.txRef,
              'transaction_id': response.transactionId,
              'status': response.status,
            },
          );
        } else {
          return PaymentResult.failure(
            message: 'Payment verification failed. Please contact support.',
            rawResponse: {'tx_ref': response.txRef},
          );
        }
      } else {
        developer.log('❌ [Payment] Card payment failed: ${response.status}');
        return PaymentResult.failure(
          message: 'Payment ${response.status ?? "failed"}. Please try again.',
          rawResponse: {
            'tx_ref': response.txRef,
            'status': response.status,
          },
        );
      }
    } catch (e) {
      developer.log('❌ [Payment] Card payment error: $e');
      return PaymentResult.failure(
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Process Mobile Money payment through Flutterwave
  ///
  /// Supports: MTN Mobile Money, Vodafone Cash, AirtelTigo Money
  /// Only works for GHS currency
  Future<PaymentResult> processMomoPayment({
    required BuildContext context,
    required double amount,
    required String phoneNumber,
    required String network, // 'MTN', 'VODAFONE', 'TIGO'
    required String customerEmail,
    String? customerName,
    String? description,
    String? transactionRef,
  }) async {
    try {
      developer.log('📱 [Payment] Processing MoMo payment: GHS $amount via $network');

      // Ensure initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Validate API keys
      if (_flutterwavePublicKey == null || _flutterwavePublicKey!.isEmpty) {
        return PaymentResult.failure(
          message: 'Payment gateway not configured. Please contact support.',
        );
      }

      // Generate transaction reference if not provided
      final String txRef = transactionRef ??
          'HLG-MOMO-${DateTime.now().millisecondsSinceEpoch}';

      // Validate phone number (Ghana format)
      if (!_isValidGhanaPhone(phoneNumber)) {
        return PaymentResult.failure(
          message: 'Invalid phone number. Please use Ghana format (e.g., 0241234567)',
        );
      }

      // Create Flutterwave customer
      final customer = Customer(
        name: customerName ?? 'Anonymous Donor',
        phoneNumber: phoneNumber,
        email: customerEmail,
      );

      // Create Flutterwave request with Mobile Money
      final Flutterwave flutterwave = Flutterwave(
        publicKey: _flutterwavePublicKey!,
        currency: 'GHS', // MoMo only supports GHS
        redirectUrl: 'https://homelinkgh.com/payment/callback',
        txRef: txRef,
        amount: amount.toString(),
        customer: customer,
        paymentOptions: 'mobilemoneyghana',
        customization: Customization(
          title: 'HomeLinkGH Services',
          description: description ?? 'Service Payment',
          logo: 'https://homelinkgh.com/logo.png',
        ),
        isTestMode: _flutterwavePublicKey!.contains('TEST'),
      );

      // Initiate payment
      developer.log('📱 [Payment] Launching Flutterwave MoMo UI...');
      final ChargeResponse response = await flutterwave.charge(context);

      // Process response
      if (response.success == true) {
        developer.log('✅ [Payment] MoMo payment successful: ${response.transactionId}');

        // Verify payment
        final bool verified = await verifyFlutterwavePayment(
          response.transactionId ?? '',
        );

        if (verified) {
          return PaymentResult.success(
            transactionId: response.transactionId ?? txRef,
            message: 'Mobile Money payment completed successfully',
            rawResponse: {
              'tx_ref': response.txRef,
              'transaction_id': response.transactionId,
              'status': response.status,
              'network': network,
              'phone': phoneNumber,
            },
          );
        } else {
          return PaymentResult.failure(
            message: 'Payment verification failed. Please contact support.',
            rawResponse: {'tx_ref': response.txRef},
          );
        }
      } else {
        developer.log('❌ [Payment] MoMo payment failed: ${response.status}');
        return PaymentResult.failure(
          message: 'Mobile Money payment ${response.status ?? "failed"}. Please try again.',
          rawResponse: {
            'tx_ref': response.txRef,
            'status': response.status,
          },
        );
      }
    } catch (e) {
      developer.log('❌ [Payment] MoMo payment error: $e');
      return PaymentResult.failure(
        message: 'Mobile Money payment failed: ${e.toString()}',
      );
    }
  }

  /// Process PayPal payment
  ///
  /// Opens PayPal checkout UI in webview
  /// Supports USD and other international currencies
  Future<PaymentResult> processPayPalPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    String? transactionRef,
  }) async {
    try {
      developer.log('🅿️ [Payment] Processing PayPal payment: $currency $amount');

      // Ensure initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Validate API keys
      if (_paypalClientId == null || _paypalClientId!.isEmpty) {
        return PaymentResult.failure(
          message: 'PayPal not configured. Please contact support.',
        );
      }

      // Generate transaction reference if not provided
      final String txRef = transactionRef ??
          'HLG-PP-${DateTime.now().millisecondsSinceEpoch}';

      // PayPal will be implemented via a Completer to handle async navigation
      PaymentResult? result;

      // Navigate to PayPal checkout
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => PaypalCheckoutView(
            sandboxMode: _paypalClientId!.contains('sandbox'), // Auto-detect sandbox
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
                    "shipping_discount": 0
                  }
                },
                "description": description,
                "item_list": {
                  "items": [
                    {
                      "name": "HomeLinkGH Service Payment",
                      "quantity": 1,
                      "price": amount.toStringAsFixed(2),
                      "currency": currency
                    }
                  ],
                }
              }
            ],
            note: "Thank you for your generous donation!",
            onSuccess: (Map params) async {
              developer.log('✅ [Payment] PayPal payment successful: ${params['paymentId']}');
              result = PaymentResult.success(
                transactionId: params['paymentId'] ?? txRef,
                message: 'PayPal payment completed successfully',
                rawResponse: Map<String, dynamic>.from(params),
              );
            },
            onError: (error) {
              developer.log('❌ [Payment] PayPal payment error: $error');
              result = PaymentResult.failure(
                message: 'PayPal payment failed: $error',
              );
            },
            onCancel: () {
              developer.log('⚠️ [Payment] PayPal payment cancelled by user');
              result = PaymentResult.failure(
                message: 'Payment cancelled',
              );
            },
          ),
        ),
      );

      // Return result or default failure if null
      return result ?? PaymentResult.failure(
        message: 'Payment was cancelled or incomplete',
      );
    } catch (e) {
      developer.log('❌ [Payment] PayPal payment error: $e');
      return PaymentResult.failure(
        message: 'PayPal payment failed: ${e.toString()}',
      );
    }
  }

  /// Verify Flutterwave payment transaction
  ///
  /// SECURITY NOTE: This implementation calls Flutterwave API directly from the client.
  /// For optimal security, verification should be done server-side (backend API).
  /// However, this client-side verification is significantly better than no verification.
  ///
  /// Production-grade approach:
  /// 1. Client initiates payment with Flutterwave
  /// 2. Client receives transaction ID
  /// 3. Client calls YOUR backend: POST /api/verify-payment { transaction_id }
  /// 4. Backend verifies with Flutterwave using SECRET key (never exposed to client)
  /// 5. Backend returns verification status to client
  Future<bool> verifyFlutterwavePayment(String transactionId) async {
    try {
      developer.log('🔍 [Payment] Verifying transaction: $transactionId');

      if (transactionId.isEmpty) {
        developer.log('❌ [Payment] Invalid transaction ID');
        return false;
      }

      // Validate secret key is available
      if (_flutterwaveSecretKey == null || _flutterwaveSecretKey!.isEmpty) {
        developer.log('❌ [Payment] Secret key not configured');
        return false;
      }

      // Call Flutterwave verification endpoint
      final url = Uri.parse(
        'https://api.flutterwave.com/v3/transactions/$transactionId/verify',
      );

      developer.log('🔍 [Payment] Calling Flutterwave verification API...');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_flutterwaveSecretKey',
          'Content-Type': 'application/json',
        },
      );

      developer.log('🔍 [Payment] Verification response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check response status
        if (data['status'] == 'success') {
          final transactionData = data['data'];
          final status = transactionData['status'];
          final amount = transactionData['amount'];
          final currency = transactionData['currency'];

          developer.log('🔍 [Payment] Transaction status: $status');
          developer.log('🔍 [Payment] Amount: $currency $amount');

          // Verify payment was successful
          if (status == 'successful') {
            developer.log('✅ [Payment] Payment verified successfully');
            return true;
          } else {
            developer.log('❌ [Payment] Payment not successful: $status');
            return false;
          }
        } else {
          developer.log('❌ [Payment] Verification API returned error: ${data['message']}');
          return false;
        }
      } else {
        developer.log('❌ [Payment] Verification failed with status ${response.statusCode}');
        developer.log('❌ [Payment] Response: ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('❌ [Payment] Verification error: $e');
      return false;
    }
  }

  /// Charge a tokenized payment method (saved card/MoMo)
  ///
  /// Uses Flutterwave tokenization to charge a previously saved payment method
  /// This is significantly faster than normal payment as it skips the UI flow
  Future<Map<String, dynamic>> chargeTokenizedPayment({
    required String token,
    required double amount,
    required String currency,
    required String description,
    required String email,
  }) async {
    try {
      developer.log('💳 [Payment] Charging tokenized payment: $currency $amount');

      // Ensure initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Validate API keys
      if (_flutterwaveSecretKey == null || _flutterwaveSecretKey!.isEmpty) {
        throw Exception('Flutterwave not configured');
      }

      // Generate transaction reference
      final String txRef = 'HLG-TOKEN-${DateTime.now().millisecondsSinceEpoch}';

      // Prepare request to Flutterwave tokenized charge API
      final response = await http.post(
        Uri.parse('https://api.flutterwave.com/v3/tokenized-charges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_flutterwaveSecretKey',
        },
        body: json.encode({
          'token': token,
          'currency': currency,
          'country': 'GH',
          'amount': amount,
          'email': email,
          'tx_ref': txRef,
          'narration': description,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        developer.log('✅ [Payment] Tokenized payment successful');

        return {
          'success': true,
          'transaction_id': data['data']['id']?.toString() ?? txRef,
          'tx_ref': txRef,
          'amount': amount,
          'currency': currency,
          'status': data['data']['status'],
          'charged_amount': data['data']['charged_amount'],
        };
      } else {
        developer.log('❌ [Payment] Tokenized payment failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Tokenized payment failed');
      }
    } catch (e) {
      developer.log('❌ [Payment] Tokenized payment error: $e');
      throw Exception('Tokenized payment failed: ${e.toString()}');
    }
  }

  /// Validate Ghana phone number format
  bool _isValidGhanaPhone(String phone) {
    // Remove spaces and dashes
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // Ghana format: 10 digits starting with 0, or 12 digits starting with 233
    final regex1 = RegExp(r'^0[2-5][0-9]{8}$'); // 0241234567
    final regex2 = RegExp(r'^233[2-5][0-9]{8}$'); // 233241234567

    return regex1.hasMatch(cleaned) || regex2.hasMatch(cleaned);
  }

  /// Get supported Mobile Money networks in Ghana
  List<String> getSupportedMoMoNetworks() {
    return ['MTN', 'VODAFONE', 'AIRTELTIGO'];
  }

  /// Check if payment service is ready
  bool get isInitialized => _isInitialized;

  /// Check if Flutterwave is configured
  bool get isFlutterwaveConfigured =>
      _flutterwavePublicKey != null && _flutterwavePublicKey!.isNotEmpty;

  /// Check if PayPal is configured
  bool get isPayPalConfigured =>
      _paypalClientId != null && _paypalClientId!.isNotEmpty;

  /// Check if in test mode
  bool get isTestMode =>
      _flutterwavePublicKey?.contains('TEST') == true ||
      _paypalClientId?.contains('sandbox') == true;

  // ─── PayStack ────────────────────────────────────────────────────────────

  /// Open PayStack payment page in browser.
  /// Returns a pending PaymentResult with the txRef so the caller can
  /// show a "Verify Payment" button and call verifyPaystackPayment().
  Future<PaymentResult> processPaystackPayment({
    required double amount,
    required String email,
    required String serviceRequestId,
    String currency = 'GHS',
  }) async {
    try {
      if (!_isInitialized) await initialize();
      if (_paystackPublicKey == null || _paystackPublicKey!.isEmpty) {
        return PaymentResult.failure(message: 'PayStack not configured.');
      }

      final txRef = 'HLG-PS-${DateTime.now().millisecondsSinceEpoch}';
      final amountKobo = (amount * 100).toInt(); // PayStack uses kobo/pesewas

      // Build PayStack Hosted Payment Page URL
      final uri = Uri.parse(
        'https://paystack.com/pay/homelinkgh?amount=$amountKobo'
        '&email=${Uri.encodeComponent(email)}'
        '&reference=$txRef'
        '&currency=$currency',
      );

      developer.log('💳 [PayStack] Opening browser: $uri');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // Return pending so UI can show "Verify" button
      return PaymentResult.pending(
        transactionId: txRef,
        message: 'Complete payment in your browser, then tap Verify.',
      );
    } catch (e) {
      developer.log('❌ [PayStack] Error: $e');
      return PaymentResult.failure(message: 'PayStack error: $e');
    }
  }

  /// Verify a PayStack payment by reference after user returns from browser.
  Future<PaymentResult> verifyPaystackPayment({
    required String reference,
    required String serviceRequestId,
    required double amount,
    String? providerId,
  }) async {
    try {
      if (_paystackSecretKey == null || _paystackSecretKey!.isEmpty) {
        return PaymentResult.failure(message: 'PayStack secret key not set.');
      }

      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_paystackSecretKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true &&
            data['data']['status'] == 'success') {
          developer.log('✅ [PayStack] Verified: $reference');
          await _recordBooking(
            serviceRequestId: serviceRequestId,
            transactionId: reference,
            amount: amount,
            paymentMethod: 'paystack',
            providerId: providerId,
          );
          return PaymentResult(
            success: true,
            transactionId: reference,
            message: 'Bank transfer verified successfully.',
          );
        }
        return PaymentResult.failure(
          message: 'Payment not yet confirmed. Please wait and try again.',
        );
      }
      return PaymentResult.failure(
        message: 'Verification failed (${response.statusCode}).',
      );
    } catch (e) {
      developer.log('❌ [PayStack] Verify error: $e');
      return PaymentResult.failure(message: 'Verification error: $e');
    }
  }

  // ─── Booking recording ────────────────────────────────────────────────────

  Future<void> _recordBooking({
    required String serviceRequestId,
    required String transactionId,
    required double amount,
    required String paymentMethod,
    String? providerId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('bookings').insert({
        'service_request_id': serviceRequestId,
        'customer_id': userId,
        'provider_id': providerId,
        'amount': amount,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'status': 'confirmed',
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabase
          .from('service_requests')
          .update({'status': 'booked'})
          .eq('id', serviceRequestId);

      developer.log('✅ [Payment] Booking recorded for request $serviceRequestId');
    } catch (e) {
      developer.log('⚠️ [Payment] Booking record error (non-fatal): $e');
    }
  }
}
