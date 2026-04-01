import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// PayStack Payment Service for Ghana
/// Handles all payment processing for HomeLinkGH using PayStack API
class PayStackService {
  static final PayStackService _instance = PayStackService._internal();
  factory PayStackService() => _instance;
  PayStackService._internal();

  // PayStack Configuration
  static const String _testPublicKey = 'pk_test_your_test_key_here'; // Replace with actual test key
  static const String _testSecretKey = 'sk_test_your_test_secret_here'; // Replace with actual test secret
  static const String _livePublicKey = 'pk_live_your_live_key_here'; // Replace with actual live key
  static const String _liveSecretKey = 'sk_live_your_live_secret_here'; // Replace with actual live secret
  
  static const String _baseUrl = 'https://api.paystack.co';
  static const bool _isProduction = false; // Set to true for production
  
  // Current configuration
  String get _publicKey => _isProduction ? _livePublicKey : _testPublicKey;
  String get _secretKey => _isProduction ? _liveSecretKey : _testSecretKey;
  
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_secretKey',
    'Content-Type': 'application/json',
  };

  /// Initialize PayStack service
  Future<void> initialize() async {
    try {
      print('Initializing PayStack service for Ghana...');
      print('Mode: ${_isProduction ? "PRODUCTION" : "TEST"}');
      
      // Verify API keys
      final isValid = await _verifyApiKeys();
      if (!isValid) {
        throw Exception('Invalid PayStack API keys');
      }
      
      print('PayStack service initialized successfully!');
    } catch (e) {
      print('Error initializing PayStack: $e');
      throw Exception('Failed to initialize PayStack service');
    }
  }

  /// Verify API keys with PayStack
  Future<bool> _verifyApiKeys() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('API key verification failed: $e');
      return false;
    }
  }

  /// Initialize a payment transaction
  Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required double amount,
    required String currency,
    required String reference,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to kobo (PayStack uses kobo for GHS)
      final amountInKobo = (amount * 100).round();
      
      final requestBody = {
        'email': email,
        'amount': amountInKobo,
        'currency': currency.toUpperCase(),
        'reference': reference,
        'callback_url': callbackUrl ?? 'https://homelinkgh.com/payment/callback',
        'metadata': {
          'app': 'HomeLinkGH',
          'platform': 'flutter',
          'version': '3.1.1',
          ...?metadata,
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/initialize'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'status': 'success',
          'data': responseData['data'],
          'reference': reference,
          'authorization_url': responseData['data']['authorization_url'],
          'access_code': responseData['data']['access_code'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to initialize transaction');
      }
    } catch (e) {
      print('Error initializing transaction: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Verify a payment transaction
  Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction/verify/$reference'),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final transactionData = responseData['data'];
        
        return {
          'status': 'success',
          'verified': true,
          'data': {
            'id': transactionData['id'],
            'reference': transactionData['reference'],
            'amount': transactionData['amount'] / 100, // Convert back from kobo
            'currency': transactionData['currency'],
            'status': transactionData['status'],
            'paid_at': transactionData['paid_at'],
            'customer': transactionData['customer'],
            'authorization': transactionData['authorization'],
            'metadata': transactionData['metadata'],
          }
        };
      } else {
        return {
          'status': 'error',
          'verified': false,
          'message': responseData['message'] ?? 'Transaction verification failed',
        };
      }
    } catch (e) {
      print('Error verifying transaction: $e');
      return {
        'status': 'error',
        'verified': false,
        'message': e.toString(),
      };
    }
  }

  /// Create a customer profile on PayStack
  Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'metadata': {
          'app': 'HomeLinkGH',
          'country': 'Ghana',
          'platform': 'flutter',
          ...?metadata,
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/customer'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'status': 'success',
          'customer': responseData['data'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create customer');
      }
    } catch (e) {
      print('Error creating customer: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Process a service booking payment
  Future<Map<String, dynamic>> processServicePayment({
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required double amount,
    required String serviceType,
    required String bookingId,
    required String providerId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      // Generate unique reference
      final reference = _generatePaymentReference(bookingId);
      
      // Prepare metadata
      final metadata = {
        'booking_id': bookingId,
        'provider_id': providerId,
        'service_type': serviceType,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'payment_type': 'service_booking',
        'app_version': '3.1.1',
        ...?additionalMetadata,
      };

      // Initialize transaction
      final initResult = await initializeTransaction(
        email: customerEmail,
        amount: amount,
        currency: 'GHS',
        reference: reference,
        metadata: metadata,
      );

      if (initResult['status'] == 'success') {
        // Save payment details locally for verification later
        await _savePaymentDetails(reference, {
          'booking_id': bookingId,
          'provider_id': providerId,
          'amount': amount,
          'customer_email': customerEmail,
          'service_type': serviceType,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });

        return {
          'status': 'success',
          'payment_url': initResult['authorization_url'],
          'reference': reference,
          'access_code': initResult['access_code'],
          'message': 'Payment initialized successfully',
        };
      } else {
        return initResult;
      }
    } catch (e) {
      print('Error processing service payment: $e');
      return {
        'status': 'error',
        'message': 'Failed to process payment: $e',
      };
    }
  }

  /// Handle payment callback and verification
  Future<Map<String, dynamic>> handlePaymentCallback(String reference) async {
    try {
      // Verify the transaction with PayStack
      final verificationResult = await verifyTransaction(reference);
      
      if (verificationResult['verified'] == true) {
        final transactionData = verificationResult['data'];
        
        // Update local payment record
        await _updatePaymentStatus(reference, 'success', transactionData);
        
        // Process successful payment
        await _processSuccessfulPayment(reference, transactionData);
        
        return {
          'status': 'success',
          'verified': true,
          'transaction': transactionData,
          'message': 'Payment verified successfully',
        };
      } else {
        await _updatePaymentStatus(reference, 'failed', null);
        
        return {
          'status': 'error',
          'verified': false,
          'message': verificationResult['message'] ?? 'Payment verification failed',
        };
      }
    } catch (e) {
      print('Error handling payment callback: $e');
      return {
        'status': 'error',
        'verified': false,
        'message': 'Failed to handle payment callback: $e',
      };
    }
  }

  /// Get payment history for a customer
  Future<List<Map<String, dynamic>>> getPaymentHistory(String customerEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customer/$customerEmail'),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        // Get transactions for this customer
        return await _getCustomerTransactions(customerEmail);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }

  /// Get customer transactions
  Future<List<Map<String, dynamic>>> _getCustomerTransactions(String customerEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction?customer=$customerEmail'),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final transactions = responseData['data'] as List<dynamic>;
        
        return transactions.map((transaction) => {
          'id': transaction['id'],
          'reference': transaction['reference'],
          'amount': transaction['amount'] / 100, // Convert from kobo
          'currency': transaction['currency'],
          'status': transaction['status'],
          'paid_at': transaction['paid_at'],
          'created_at': transaction['created_at'],
          'metadata': transaction['metadata'],
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting customer transactions: $e');
      return [];
    }
  }

  /// Generate payment reference
  String _generatePaymentReference(String bookingId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'HLG_${bookingId}_${timestamp}_$random';
  }

  /// Save payment details locally
  Future<void> _savePaymentDetails(String reference, Map<String, dynamic> details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPayments = prefs.getString('payment_records') ?? '{}';
      final payments = json.decode(existingPayments) as Map<String, dynamic>;
      
      payments[reference] = details;
      
      await prefs.setString('payment_records', json.encode(payments));
    } catch (e) {
      print('Error saving payment details: $e');
    }
  }

  /// Update payment status
  Future<void> _updatePaymentStatus(String reference, String status, Map<String, dynamic>? transactionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPayments = prefs.getString('payment_records') ?? '{}';
      final payments = json.decode(existingPayments) as Map<String, dynamic>;
      
      if (payments.containsKey(reference)) {
        payments[reference]['status'] = status;
        payments[reference]['updated_at'] = DateTime.now().toIso8601String();
        
        if (transactionData != null) {
          payments[reference]['transaction_data'] = transactionData;
        }
        
        await prefs.setString('payment_records', json.encode(payments));
      }
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  /// Process successful payment
  Future<void> _processSuccessfulPayment(String reference, Map<String, dynamic> transactionData) async {
    try {
      final metadata = transactionData['metadata'] as Map<String, dynamic>?;
      if (metadata != null) {
        final bookingId = metadata['booking_id'];
        final providerId = metadata['provider_id'];
        
        // Here you would update the booking status, notify the provider, etc.
        print('Processing successful payment for booking: $bookingId');
        print('Provider: $providerId');
        print('Amount: GHS ${transactionData['amount']}');
        
        // TODO: Integrate with Firebase to update booking status
        // TODO: Send notification to provider
        // TODO: Update provider earnings
        // TODO: Send receipt to customer
      }
    } catch (e) {
      print('Error processing successful payment: $e');
    }
  }

  /// Refund a transaction
  Future<Map<String, dynamic>> refundTransaction({
    required String transactionReference,
    double? amount, // If null, full refund
    String? reason,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'transaction': transactionReference,
      };
      
      if (amount != null) {
        requestBody['amount'] = (amount * 100).round(); // Convert to kobo
      }
      
      if (reason != null) {
        requestBody['customer_note'] = reason;
        requestBody['merchant_note'] = 'Refund processed via HomeLinkGH app';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/refund'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'status': 'success',
          'refund': responseData['data'],
          'message': 'Refund processed successfully',
        };
      } else {
        throw Exception(responseData['message'] ?? 'Refund failed');
      }
    } catch (e) {
      print('Error processing refund: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Get supported banks for bank transfer
  Future<List<Map<String, dynamic>>> getSupportedBanks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bank?country=ghana'),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final banks = responseData['data'] as List<dynamic>;
        
        return banks.map((bank) => {
          'id': bank['id'],
          'name': bank['name'],
          'code': bank['code'],
          'country': bank['country'],
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting supported banks: $e');
      return [];
    }
  }

  /// Calculate PayStack fees
  double calculatePayStackFees(double amount) {
    // PayStack Ghana fees: 1.95% + GHS 0.30
    // Cap at GHS 2000
    final percentageFee = amount * 0.0195;
    final totalFee = percentageFee + 0.30;
    return totalFee > 2000 ? 2000 : totalFee;
  }

  /// Get payment configuration for display
  Map<String, dynamic> getPaymentConfig() {
    return {
      'is_production': _isProduction,
      'supported_currencies': ['GHS'],
      'supported_countries': ['Ghana'],
      'payment_methods': [
        'Card (Visa, Mastercard)',
        'Mobile Money (MTN, Vodafone, AirtelTigo)',
        'Bank Transfer',
        'USSD',
      ],
      'fee_structure': 'PayStack fees: 1.95% + GHS 0.30 (capped at GHS 2000)',
      'settlement_time': '1-2 business days',
    };
  }
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  refunded,
  cancelled,
}

/// Payment method enumeration
enum PaymentMethod {
  card,
  mobileMoney,
  bankTransfer,
  ussd,
}

/// Payment result class
class PaymentResult {
  final bool isSuccess;
  final String? reference;
  final double? amount;
  final String? currency;
  final String? status;
  final String? message;
  final Map<String, dynamic>? transactionData;

  PaymentResult({
    required this.isSuccess,
    this.reference,
    this.amount,
    this.currency,
    this.status,
    this.message,
    this.transactionData,
  });

  factory PaymentResult.success({
    required String reference,
    required double amount,
    required String currency,
    required Map<String, dynamic> transactionData,
  }) {
    return PaymentResult(
      isSuccess: true,
      reference: reference,
      amount: amount,
      currency: currency,
      status: 'success',
      message: 'Payment completed successfully',
      transactionData: transactionData,
    );
  }

  factory PaymentResult.failure({
    required String message,
    String? reference,
  }) {
    return PaymentResult(
      isSuccess: false,
      reference: reference,
      status: 'failed',
      message: message,
    );
  }
}