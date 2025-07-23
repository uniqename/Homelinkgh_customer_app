class Quote {
  final String id;
  final String serviceRequestId;
  final String providerId;
  final String providerName;
  final double amount;
  final String currency;
  final String description;
  final Map<String, dynamic>? breakdown;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final QuoteStatus status;
  final String? customerMessage;
  final String? providerMessage;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  Quote({
    required this.id,
    required this.serviceRequestId,
    required this.providerId,
    required this.providerName,
    required this.amount,
    this.currency = 'GHS',
    required this.description,
    this.breakdown,
    required this.createdAt,
    this.expiresAt,
    this.status = QuoteStatus.pending,
    this.customerMessage,
    this.providerMessage,
    this.attachments,
    this.metadata,
  });

  factory Quote.fromMap(Map<String, dynamic> map, String id) {
    return Quote(
      id: id,
      serviceRequestId: map['serviceRequestId'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'GHS',
      description: map['description'] ?? '',
      breakdown: map['breakdown'] != null 
          ? Map<String, dynamic>.from(map['breakdown'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      expiresAt: map['expiresAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'])
          : null,
      status: QuoteStatus.values.firstWhere(
        (e) => e.toString() == 'QuoteStatus.${map['status'] ?? 'pending'}',
        orElse: () => QuoteStatus.pending,
      ),
      customerMessage: map['customerMessage'],
      providerMessage: map['providerMessage'],
      attachments: map['attachments'] != null 
          ? List<String>.from(map['attachments'])
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceRequestId': serviceRequestId,
      'providerId': providerId,
      'providerName': providerName,
      'amount': amount,
      'currency': currency,
      'description': description,
      'breakdown': breakdown,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'customerMessage': customerMessage,
      'providerMessage': providerMessage,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  Quote copyWith({
    String? id,
    String? serviceRequestId,
    String? providerId,
    String? providerName,
    double? amount,
    String? currency,
    String? description,
    Map<String, dynamic>? breakdown,
    DateTime? createdAt,
    DateTime? expiresAt,
    QuoteStatus? status,
    String? customerMessage,
    String? providerMessage,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Quote(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      breakdown: breakdown ?? this.breakdown,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      customerMessage: customerMessage ?? this.customerMessage,
      providerMessage: providerMessage ?? this.providerMessage,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum QuoteStatus {
  pending,
  accepted,
  rejected,
  expired,
  withdrawn,
  negotiating,
}