import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Africa's Talking SMS + WhatsApp service for Ghana
/// Sign up at: https://africastalking.com/
/// Add credentials to .env: AT_API_KEY, AT_USERNAME, AT_SENDER_ID
class AfricaTalkingService {
  static final AfricaTalkingService _instance = AfricaTalkingService._internal();
  factory AfricaTalkingService() => _instance;
  AfricaTalkingService._internal();

  String get _apiKey => dotenv.env['AT_API_KEY'] ?? '';
  String get _username => dotenv.env['AT_USERNAME'] ?? 'sandbox';
  String get _senderId => dotenv.env['AT_SENDER_ID'] ?? 'HomeLinkGH';

  bool get _isConfigured => _apiKey.isNotEmpty && _apiKey != 'your_at_api_key_here';

  static const String _smsUrl = 'https://api.africastalking.com/version1/messaging';
  static const String _whatsappUrl = 'https://content.africastalking.com/version1/messaging/whatsapp';

  /// Send an SMS to a Ghana phone number.
  /// Phone number should be in international format: +233XXXXXXXXX
  Future<bool> sendSMS({
    required String phone,
    required String message,
  }) async {
    if (!_isConfigured) {
      print('⚠️ [AT] Africa\'s Talking not configured — add AT_API_KEY to .env');
      return false;
    }

    try {
      final to = _toInternational(phone);
      if (to == null) {
        print('⚠️ [AT] Invalid phone number: $phone');
        return false;
      }

      final response = await http.post(
        Uri.parse(_smsUrl),
        headers: {
          'apiKey': _apiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': _username,
          'to': to,
          'message': message,
          'from': _senderId,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final recipients = data['SMSMessageData']?['Recipients'] as List?;
        final status = recipients?.first?['status'] ?? 'unknown';
        if (status == 'Success') {
          print('✅ [AT] SMS sent to $to');
          return true;
        } else {
          print('⚠️ [AT] SMS status: $status');
          return false;
        }
      } else {
        print('❌ [AT] SMS failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [AT] SMS error: $e');
      return false;
    }
  }

  /// Send a WhatsApp message via Africa's Talking Programmable Messaging.
  /// Requires AT WhatsApp Business channel enabled on your account.
  Future<bool> sendWhatsApp({
    required String phone,
    required String message,
  }) async {
    if (!_isConfigured) {
      print('⚠️ [AT] Africa\'s Talking not configured — WhatsApp skipped');
      return false;
    }

    try {
      final to = _toInternational(phone);
      if (to == null) {
        print('⚠️ [AT] Invalid phone number for WhatsApp: $phone');
        return false;
      }

      final response = await http.post(
        Uri.parse(_whatsappUrl),
        headers: {
          'apiKey': _apiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': _username,
          'to': to,
          'message': message,
          'channel': 'whatsapp',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ [AT] WhatsApp sent to $to');
        return true;
      } else {
        print('❌ [AT] WhatsApp failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [AT] WhatsApp error: $e');
      return false;
    }
  }

  /// Notify a provider about a new job via SMS + WhatsApp
  Future<void> notifyProviderNewJob({
    required String phone,
    required String providerName,
    required String serviceType,
    required String customerLocation,
    required double budget,
    required bool isUrgent,
  }) async {
    final urgencyTag = isUrgent ? 'URGENT' : 'New';
    final message =
        'HomeLinkGH: $urgencyTag job for $providerName!\n'
        'Service: $serviceType\n'
        'Location: $customerLocation\n'
        'Budget: GH₵${budget.toStringAsFixed(0)}\n'
        'Open your HomeLinkGH app to view and quote.';

    // Send both SMS and WhatsApp — best-effort, non-blocking
    await Future.wait([
      sendSMS(phone: phone, message: message),
      sendWhatsApp(phone: phone, message: message),
    ]);
  }

  /// Notify a customer that their quote was received
  Future<void> notifyCustomerQuoteReceived({
    required String phone,
    required String serviceType,
    required String providerName,
    required double amount,
  }) async {
    final message =
        'HomeLinkGH: $providerName quoted GH₵${amount.toStringAsFixed(0)} '
        'for your $serviceType request.\n'
        'Open your HomeLinkGH app to review and accept.';

    await Future.wait([
      sendSMS(phone: phone, message: message),
      sendWhatsApp(phone: phone, message: message),
    ]);
  }

  /// Notify a provider their quote was accepted
  Future<void> notifyProviderQuoteAccepted({
    required String phone,
    required String providerName,
    required String serviceType,
  }) async {
    final message =
        'HomeLinkGH: Great news $providerName!\n'
        'A customer accepted your quote for $serviceType.\n'
        'Open your HomeLinkGH app to confirm the booking.';

    await Future.wait([
      sendSMS(phone: phone, message: message),
      sendWhatsApp(phone: phone, message: message),
    ]);
  }

  /// Convert Ghana phone number to international format (+233XXXXXXXXX)
  String? _toInternational(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+233') && cleaned.length == 13) return cleaned;
    if (cleaned.startsWith('233') && cleaned.length == 12) return '+$cleaned';
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+233${cleaned.substring(1)}';
    }
    // Already in another valid format (e.g., no leading 0)
    if (cleaned.length == 9 && RegExp(r'^[2-5]').hasMatch(cleaned)) {
      return '+233$cleaned';
    }
    return null;
  }
}
