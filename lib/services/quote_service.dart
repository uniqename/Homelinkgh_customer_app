import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote.dart';
import 'supabase_service.dart';
import 'africa_talking_service.dart';

/// Real Quote Service — persists to Supabase and notifies providers
class QuoteService {
  final SupabaseService _supabase = SupabaseService();
  final AfricaTalkingService _at = AfricaTalkingService();

  SupabaseClient get _client => _supabase.supabase;

  // ============================================================================
  // CUSTOMER: submit a service request
  // ============================================================================

  Future<String> createServiceRequest({
    required String serviceType,
    required String description,
    required String location,
    required DateTime scheduledDate,
    required double budget,
    bool isUrgent = false,
    String? urgencyLabel,
    Map<String, dynamic>? answers,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('You must be signed in to request a service.');

    // Fetch the customer's name/phone from their profile
    final profile = await _supabase.getUserProfile(user.id);
    final customerName = profile?['name'] ?? 'Customer';
    final customerPhone = profile?['phone'] ?? '';

    final data = {
      'customer_id': user.id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_type': serviceType,
      'description': description,
      'location': location,
      'budget': budget,
      'urgency': urgencyLabel ?? (isUrgent ? 'Urgent (same day)' : 'Scheduled (within 3 days)'),
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': 'open',
      'answers': answers ?? {},
    };

    final response = await _client
        .from('service_requests')
        .insert(data)
        .select()
        .single();

    final requestId = response['id'].toString();

    // Notify all providers who offer this service type
    await _notifyMatchingProviders(
      requestId: requestId,
      serviceType: serviceType,
      customerName: customerName,
      location: location,
      budget: budget,
      isUrgent: isUrgent,
    );

    return requestId;
  }

  /// Find providers who offer this service type and send them in-app notifications.
  /// They will also receive real-time updates via Supabase subscriptions.
  Future<void> _notifyMatchingProviders({
    required String requestId,
    required String serviceType,
    required String customerName,
    required String location,
    required double budget,
    required bool isUrgent,
  }) async {
    try {
      // Get all verified providers who offer this service
      final providers = await _client
          .from('providers')
          .select('id, user_id, name')
          .eq('status', 'verified')
          .contains('services', [serviceType]);

      for (final provider in providers) {
        final providerUserId = provider['user_id']?.toString();
        if (providerUserId == null) continue;

        // In-app notification (Supabase realtime)
        await _supabase.sendNotification(
          userId: providerUserId,
          title: isUrgent ? '🚨 Urgent Job: $serviceType' : 'New Job: $serviceType',
          message:
              '$customerName needs $serviceType in $location. Budget: GH₵${budget.toStringAsFixed(0)}. Tap to view and quote.',
          type: 'new_job',
          data: {
            'service_request_id': requestId,
            'service_type': serviceType,
            'location': location,
            'budget': budget,
          },
        );

        // SMS + WhatsApp via Africa's Talking (best-effort)
        final providerPhone = provider['phone']?.toString();
        if (providerPhone != null && providerPhone.isNotEmpty) {
          _at.notifyProviderNewJob(
            phone: providerPhone,
            providerName: provider['name']?.toString() ?? 'Provider',
            serviceType: serviceType,
            customerLocation: location,
            budget: budget,
            isUrgent: isUrgent,
          ).catchError((e) => print('⚠️ AT notify failed: $e'));
        }
      }
    } catch (e) {
      // Non-fatal — request was already saved; notifications are best-effort
      print('⚠️ Could not notify providers: $e');
    }
  }

  // ============================================================================
  // PROVIDER: submit a quote for a service request
  // ============================================================================

  Future<void> submitQuote({
    required String serviceRequestId,
    required String providerId,
    required String providerName,
    required double amount,
    required String description,
    Map<String, dynamic>? breakdown,
    String? estimatedDuration,
    String? providerMessage,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('You must be signed in to submit a quote.');

    await _client.from('quotes').insert({
      'service_request_id': serviceRequestId,
      'provider_id': providerId,
      'provider_name': providerName,
      'amount': amount,
      'description': description,
      'breakdown': breakdown,
      'estimated_duration': estimatedDuration,
      'provider_message': providerMessage,
      'status': 'pending',
    });

    // Notify the customer that they received a quote (in-app + SMS/WhatsApp)
    try {
      final request = await _client
          .from('service_requests')
          .select('customer_id, customer_phone, service_type')
          .eq('id', serviceRequestId)
          .single();

      await _supabase.sendNotification(
        userId: request['customer_id'].toString(),
        title: 'Quote Received: ${request['service_type']}',
        message:
            '$providerName quoted GH₵${amount.toStringAsFixed(0)} for your ${request['service_type']} request. Tap to review.',
        type: 'quote_received',
        data: {
          'service_request_id': serviceRequestId,
          'provider_name': providerName,
          'amount': amount,
        },
      );

      final customerPhone = request['customer_phone']?.toString();
      if (customerPhone != null && customerPhone.isNotEmpty) {
        _at.notifyCustomerQuoteReceived(
          phone: customerPhone,
          serviceType: request['service_type']?.toString() ?? 'service',
          providerName: providerName,
          amount: amount,
        ).catchError((e) => print('⚠️ AT customer notify failed: $e'));
      }
    } catch (e) {
      print('⚠️ Could not notify customer: $e');
    }
  }

  // ============================================================================
  // CUSTOMER: get quotes for a service request
  // ============================================================================

  Future<List<Quote>> getQuotesForRequest(String serviceRequestId) async {
    final rows = await _client
        .from('quotes')
        .select()
        .eq('service_request_id', serviceRequestId)
        .order('created_at', ascending: true);

    return rows.map<Quote>((row) {
      return Quote(
        id: row['id'].toString(),
        serviceRequestId: row['service_request_id'].toString(),
        providerId: row['provider_id'].toString(),
        providerName: row['provider_name'] ?? '',
        amount: double.tryParse(row['amount'].toString()) ?? 0,
        description: row['description'] ?? '',
        breakdown: row['breakdown'] != null
            ? Map<String, dynamic>.from(row['breakdown'])
            : null,
        createdAt: DateTime.parse(row['created_at']),
        expiresAt: DateTime.parse(row['expires_at']),
        status: _statusFromString(row['status']),
        providerMessage: row['provider_message'],
        customerMessage: row['customer_message'],
        metadata: row['estimated_duration'] != null
            ? {'estimatedDuration': row['estimated_duration']}
            : null,
      );
    }).toList();
  }

  /// Real-time stream of quotes for a request — UI rebuilds as new quotes arrive
  Stream<List<Quote>> watchQuotesForRequest(String serviceRequestId) {
    return _client
        .from('quotes')
        .stream(primaryKey: ['id'])
        .eq('service_request_id', serviceRequestId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map<Quote>((row) {
              return Quote(
                id: row['id'].toString(),
                serviceRequestId: row['service_request_id'].toString(),
                providerId: row['provider_id'].toString(),
                providerName: row['provider_name'] ?? '',
                amount: double.tryParse(row['amount'].toString()) ?? 0,
                description: row['description'] ?? '',
                breakdown: row['breakdown'] != null
                    ? Map<String, dynamic>.from(row['breakdown'])
                    : null,
                createdAt: DateTime.parse(row['created_at']),
                expiresAt: DateTime.parse(row['expires_at']),
                status: _statusFromString(row['status']),
                providerMessage: row['provider_message'],
                customerMessage: row['customer_message'],
                metadata: row['estimated_duration'] != null
                    ? {'estimatedDuration': row['estimated_duration']}
                    : null,
              );
            }).toList());
  }

  // ============================================================================
  // CUSTOMER: respond to a quote (accept / reject / negotiate)
  // ============================================================================

  Future<void> respondToQuote({
    required String quoteId,
    required QuoteStatus response,
    String? customerMessage,
    double? counterOffer,
  }) async {
    final updates = <String, dynamic>{
      'status': _statusToString(response),
      if (customerMessage != null) 'customer_message': customerMessage,
    };

    await _client.from('quotes').update(updates).eq('id', quoteId);

    // If accepted, notify the provider
    if (response == QuoteStatus.accepted) {
      try {
        final quote = await _client
            .from('quotes')
            .select('provider_id, provider_name, service_request_id')
            .eq('id', quoteId)
            .single();

        final provider = await _client
            .from('providers')
            .select('user_id')
            .eq('id', quote['provider_id'].toString())
            .single();

        await _supabase.sendNotification(
          userId: provider['user_id'].toString(),
          title: 'Quote Accepted!',
          message:
              'A customer accepted your quote. Please confirm the booking and prepare for the job.',
          type: 'quote_accepted',
          data: {
            'quote_id': quoteId,
            'service_request_id': quote['service_request_id'].toString(),
          },
        );

        // SMS + WhatsApp notification to provider
        final providerPhone = provider['phone']?.toString();
        final serviceType = quote['service_request_id']?.toString() ?? 'the job';
        if (providerPhone != null && providerPhone.isNotEmpty) {
          _at.notifyProviderQuoteAccepted(
            phone: providerPhone,
            providerName: quote['provider_name']?.toString() ?? 'Provider',
            serviceType: serviceType,
          ).catchError((e) => print('⚠️ AT acceptance notify failed: $e'));
        }
      } catch (e) {
        print('⚠️ Could not notify provider of acceptance: $e');
      }
    }
  }

  // ============================================================================
  // PROVIDER: stream of open service requests matching provider's services
  // ============================================================================

  Stream<List<Map<String, dynamic>>> watchOpenRequestsForProvider(
      List<String> providerServices) {
    return _client
        .from('service_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'open')
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((row) => providerServices.any(
                (svc) => row['service_type']?.toString().toLowerCase() ==
                    svc.toLowerCase()))
            .toList());
  }

  /// One-shot fetch of open requests for a provider
  Future<List<Map<String, dynamic>>> getOpenRequestsForProvider(
      List<String> providerServices) async {
    final rows = await _client
        .from('service_requests')
        .select()
        .eq('status', 'open')
        .order('created_at', ascending: false);

    return rows
        .where((row) => providerServices.any((svc) =>
            row['service_type']?.toString().toLowerCase() == svc.toLowerCase()))
        .toList();
  }

  // ============================================================================
  // CUSTOMER: stream of their own service requests
  // ============================================================================

  Stream<List<Map<String, dynamic>>> watchCustomerRequests(String customerId) {
    return _client
        .from('service_requests')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at', ascending: false)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  QuoteStatus _statusFromString(String? s) {
    switch (s) {
      case 'accepted':
        return QuoteStatus.accepted;
      case 'rejected':
        return QuoteStatus.rejected;
      case 'negotiating':
        return QuoteStatus.negotiating;
      case 'expired':
        return QuoteStatus.expired;
      default:
        return QuoteStatus.pending;
    }
  }

  String _statusToString(QuoteStatus s) {
    switch (s) {
      case QuoteStatus.accepted:
        return 'accepted';
      case QuoteStatus.rejected:
        return 'rejected';
      case QuoteStatus.negotiating:
        return 'negotiating';
      case QuoteStatus.expired:
        return 'expired';
      default:
        return 'pending';
    }
  }
}
