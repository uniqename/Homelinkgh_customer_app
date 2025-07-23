import 'dart:async';
import '../models/quote.dart';
import '../models/service_request.dart';

/// Simplified Quote Service for demo purposes
/// In production, this would integrate with Supabase backend
class QuoteService {
  // Mock data storage for demo
  static final List<ServiceRequest> _serviceRequests = [];
  static final List<Quote> _quotes = [];
  static final List<Map<String, dynamic>> _communications = [];

  /// Customer creates a service request for quotes
  Future<String> createServiceRequest({
    required String serviceType,
    required String description,
    required DateTime scheduledDate,
    required double budget,
    bool isUrgent = false,
  }) async {
    final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    
    final request = ServiceRequest(
      id: requestId,
      serviceType: serviceType,
      description: description,
      scheduledDate: scheduledDate,
      budget: budget,
      isUrgent: isUrgent,
    );
    
    _serviceRequests.add(request);
    
    // Simulate notifying providers
    await Future.delayed(const Duration(milliseconds: 500));
    
    return requestId;
  }

  /// Provider submits a quote for a service request
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
    final quoteId = 'quote_${DateTime.now().millisecondsSinceEpoch}';
    
    final quote = Quote(
      id: quoteId,
      serviceRequestId: serviceRequestId,
      providerId: providerId,
      providerName: providerName,
      amount: amount,
      description: description,
      breakdown: breakdown,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      status: QuoteStatus.pending,
      providerMessage: providerMessage,
      metadata: estimatedDuration != null ? {'estimatedDuration': estimatedDuration} : null,
    );
    
    _quotes.add(quote);
    
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Get quotes for a service request
  Future<List<Quote>> getQuotesForRequest(String serviceRequestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _quotes
        .where((quote) => quote.serviceRequestId == serviceRequestId)
        .toList();
  }

  /// Customer responds to a quote (accept/reject/negotiate)
  Future<void> respondToQuote({
    required String quoteId,
    required QuoteStatus response,
    String? customerMessage,
    double? counterOffer,
  }) async {
    final quoteIndex = _quotes.indexWhere((q) => q.id == quoteId);
    if (quoteIndex != -1) {
      final updatedQuote = _quotes[quoteIndex].copyWith(
        status: response,
        customerMessage: customerMessage,
      );
      _quotes[quoteIndex] = updatedQuote;
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Provider updates quote (for negotiations)
  Future<void> updateQuote({
    required String quoteId,
    required String providerId,
    double? newAmount,
    String? newDescription,
    Map<String, dynamic>? newBreakdown,
    String? providerMessage,
  }) async {
    final quoteIndex = _quotes.indexWhere((q) => q.id == quoteId);
    if (quoteIndex != -1) {
      final updatedQuote = _quotes[quoteIndex].copyWith(
        amount: newAmount ?? _quotes[quoteIndex].amount,
        description: newDescription ?? _quotes[quoteIndex].description,
        breakdown: newBreakdown ?? _quotes[quoteIndex].breakdown,
        providerMessage: providerMessage,
        status: QuoteStatus.negotiating,
      );
      _quotes[quoteIndex] = updatedQuote;
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Get provider's received quotes
  Future<List<Quote>> getProviderQuotes(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _quotes
        .where((quote) => quote.providerId == providerId)
        .toList();
  }

  /// Send message in quote communication
  Future<void> sendMessage({
    required String quoteId,
    required String senderId,
    required String senderType, // 'customer' or 'provider'
    required String message,
    List<String>? attachments,
  }) async {
    final messageData = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'quoteId': quoteId,
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
      'attachments': attachments,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    _communications.add(messageData);
    
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Get communication history for a quote
  Future<List<Map<String, dynamic>>> getQuoteCommunication(String quoteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _communications
        .where((comm) => comm['quoteId'] == quoteId)
        .toList()
      ..sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
  }

  /// Get all service requests (for admin/provider dashboard)
  Future<List<ServiceRequest>> getAllServiceRequests() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_serviceRequests);
  }

  /// Get quote by ID
  Future<Quote?> getQuoteById(String quoteId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _quotes.firstWhere((quote) => quote.id == quoteId);
    } catch (e) {
      return null;
    }
  }

  /// Get service request by ID
  Future<ServiceRequest?> getServiceRequestById(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _serviceRequests.firstWhere((request) => request.id == requestId);
    } catch (e) {
      return null;
    }
  }

  /// Create sample data for demo purposes
  static void initializeSampleData() {
    if (_serviceRequests.isNotEmpty) return; // Already initialized
    
    // Sample service requests
    final sampleRequests = [
      ServiceRequest(
        id: 'req_sample_1',
        serviceType: 'House Cleaning',
        description: 'Deep cleaning for 3-bedroom house before family visit',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        budget: 300.0,
        isUrgent: false,
      ),
      ServiceRequest(
        id: 'req_sample_2',
        serviceType: 'Plumbing',
        description: 'Fix leaking kitchen faucet and bathroom pipe',
        scheduledDate: DateTime.now().add(const Duration(hours: 4)),
        budget: 150.0,
        isUrgent: true,
      ),
    ];
    
    _serviceRequests.addAll(sampleRequests);
    
    // Sample quotes
    final sampleQuotes = [
      Quote(
        id: 'quote_sample_1',
        serviceRequestId: 'req_sample_1',
        providerId: 'provider_1',
        providerName: 'Kwame Professional Cleaners',
        amount: 280.0,
        description: 'Complete deep cleaning service with eco-friendly products',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        status: QuoteStatus.pending,
        metadata: {'estimatedDuration': '4-5 hours'},
      ),
      Quote(
        id: 'quote_sample_2',
        serviceRequestId: 'req_sample_1',
        providerId: 'provider_2',
        providerName: 'Akosua Home Care',
        amount: 320.0,
        description: 'Premium cleaning service with post-service maintenance tips',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        status: QuoteStatus.pending,
        metadata: {'estimatedDuration': '3-4 hours'},
      ),
    ];
    
    _quotes.addAll(sampleQuotes);
  }
}