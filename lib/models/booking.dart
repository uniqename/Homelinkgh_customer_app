class Booking {
  final String? id;
  final String customerId;
  final String providerId;
  final String serviceType;
  final String description;
  final DateTime scheduledDate;
  final String address;
  final double price;
  final String status;
  final DateTime? createdAt;
  final DateTime? completedAt;

  Booking({
    this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceType,
    required this.description,
    required this.scheduledDate,
    required this.address,
    required this.price,
    required this.status,
    this.createdAt,
    this.completedAt,
  });

  Booking copyWith({
    String? id,
    String? customerId,
    String? providerId,
    String? serviceType,
    String? description,
    DateTime? scheduledDate,
    String? address,
    double? price,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      address: address ?? this.address,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'serviceType': serviceType,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'address': address,
      'price': price,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      customerId: map['customerId'] ?? '',
      providerId: map['providerId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      description: map['description'] ?? '',
      scheduledDate: DateTime.parse(map['scheduledDate']),
      address: map['address'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}