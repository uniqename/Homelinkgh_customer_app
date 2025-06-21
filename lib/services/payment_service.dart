import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const String _flutterwavePublicKey = 'FLWPUBK_TEST-SANDBOXDEMOKEY-X'; // Replace with actual key
  static const String _paystackPublicKey = 'pk_test_REPLACE_WITH_ACTUAL_KEY'; // Replace with actual key

  static void initialize() {
    // Initialize payment gateways if needed
    debugPrint('Payment service initialized');
  }

  // Flutterwave Payment for International Users
  static Future<bool> processFlutterwavePayment({
    required BuildContext context,
    required String amount,
    required String currency,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String transactionRef,
    required String description,
  }) async {
    try {
      const String baseUrl = 'https://api.flutterwave.com/v3';
      
      final Map<String, dynamic> paymentData = {
        'tx_ref': transactionRef,
        'amount': amount,
        'currency': currency,
        'redirect_url': 'https://homelink.gh/payment/callback',
        'payment_options': 'card,mobilemoney,ussd,banktransfer',
        'customer': {
          'email': customerEmail,
          'phonenumber': customerPhone,
          'name': customerName,
        },
        'customizations': {
          'title': 'HomeLinkGH Payment',
          'description': description,
          'logo': 'https://homelink.gh/logo.png',
        },
      };

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Authorization': 'Bearer $_flutterwavePublicKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Open payment link in WebView or browser
          return await _openPaymentLink(context, data['data']['link']);
        }
      }
      
      return false;
    } catch (error) {
      debugPrint('Flutterwave payment error: $error');
      return false;
    }
  }

  // Paystack Payment for Ghana-based Users
  static Future<bool> processPaystackPayment({
    required BuildContext context,
    required String amount,
    required String customerEmail,
    required String reference,
    required String description,
  }) async {
    try {
      const String baseUrl = 'https://api.paystack.co';
      
      final Map<String, dynamic> paymentData = {
        'reference': reference,
        'amount': (double.parse(amount) * 100).toInt(), // Convert to pesewas
        'email': customerEmail,
        'currency': 'GHS',
        'callback_url': 'https://homelink.gh/payment/callback',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_paystackPublicKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Open payment link in WebView or browser
          return await _openPaymentLink(context, data['data']['authorization_url']);
        }
      }
      
      return false;
    } catch (error) {
      debugPrint('Paystack payment error: $error');
      return false;
    }
  }

  // Open payment link in WebView
  static Future<bool> _openPaymentLink(BuildContext context, String paymentUrl) async {
    // In a real implementation, open the URL in a WebView or external browser
    // For now, show a dialog with the payment URL
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment link ready. In production, this would open in a secure WebView.'),
            const SizedBox(height: 16),
            Text(
              paymentUrl,
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Payment Complete'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Mobile Money Payment for Local Users
  static Future<bool> processMobileMoneyPayment({
    required String amount,
    required String customerPhone,
    required String network, // MTN, VODAFONE, TIGO
    required String transactionRef,
  }) async {
    try {
      // Implement mobile money payment logic
      // This would typically involve calling Ghana's mobile money APIs
      
      // For demo purposes, simulate success
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (error) {
      debugPrint('Mobile Money payment error: $error');
      return false;
    }
  }

  static Future<bool> _verifyFlutterwavePayment(String transactionId) async {
    // Implement backend verification
    // Call your backend API to verify with Flutterwave
    return true;
  }

  static Future<bool> _verifyPaystackPayment(String reference) async {
    // Implement backend verification
    // Call your backend API to verify with Paystack
    return true;
  }

  // Process refund
  static Future<Map<String, dynamic>> processRefund({
    required String originalTransactionId,
    required double amount,
    required String reason,
    String? disputeId,
    String? refundMethod,
    Map<String, String>? accountDetails,
  }) async {
    try {
      // Generate refund reference
      final refundReference = 'REF_${DateTime.now().millisecondsSinceEpoch}';
      
      // Process refund through payment gateway
      final response = await http.post(
        Uri.parse('https://api.paystack.co/refund'),
        headers: {
          'Authorization': 'Bearer $_paystackPublicKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'transaction': originalTransactionId,
          'amount': (amount * 100).toInt(), // Convert to pesewas
          'merchant_note': reason,
          'customer_note': 'Refund processed via HomeLinkGH',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return {
            'success': true,
            'refundTransactionId': data['data']['id'].toString(),
            'refundReference': refundReference,
            'amount': amount,
            'method': refundMethod ?? 'original_payment_method',
            'processingTime': _getRefundProcessingTime(refundMethod ?? 'bank_transfer'),
          };
        }
      }
      
      return {
        'success': false,
        'error': 'Refund processing failed',
      };
    } catch (error) {
      debugPrint('Refund processing error: $error');
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  // Get refund processing time
  static String _getRefundProcessingTime(String method) {
    switch (method) {
      case 'mobile_money':
        return 'Instant';
      case 'bank_transfer':
        return '3-5 business days';
      case 'credit':
        return 'Instant';
      case 'international':
        return '5-7 business days';
      default:
        return '3-5 business days';
    }
  }

  // Generate unique transaction reference
  static String generateTransactionRef() {
    return 'HL_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Currency conversion helper
  static Map<String, String> getCurrencyForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'GH':
        return {'currency': 'GHS', 'symbol': '₵'};
      case 'US':
        return {'currency': 'USD', 'symbol': '\$'};
      case 'GB':
        return {'currency': 'GBP', 'symbol': '£'};
      case 'CA':
        return {'currency': 'CAD', 'symbol': 'C\$'};
      case 'DE':
      case 'FR':
      case 'IT':
      case 'ES':
        return {'currency': 'EUR', 'symbol': '€'};
      default:
        return {'currency': 'USD', 'symbol': '\$'};
    }
  }

  // Payment method selection for diaspora
  static List<PaymentMethod> getPaymentMethodsForCountry(String countryCode) {
    if (countryCode.toUpperCase() == 'GH') {
      return [
        PaymentMethod('Mobile Money', 'MTN, Vodafone, AirtelTigo', Icons.phone_android),
        PaymentMethod('Bank Card', 'Visa, Mastercard', Icons.credit_card),
        PaymentMethod('Bank Transfer', 'Direct bank transfer', Icons.account_balance),
      ];
    } else {
      return [
        PaymentMethod('Credit/Debit Card', 'International cards', Icons.credit_card),
        PaymentMethod('Bank Transfer', 'International transfer', Icons.account_balance),
        PaymentMethod('Digital Wallet', 'PayPal, etc.', Icons.account_balance_wallet),
      ];
    }
  }
}

class PaymentMethod {
  final String name;
  final String description;
  final IconData icon;

  PaymentMethod(this.name, this.description, this.icon);
}