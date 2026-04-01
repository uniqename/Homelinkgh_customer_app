/// Saved Payment Method Model for HomeLinkGH
/// Stores tokenized payment methods for faster checkout

class SavedPaymentMethod {
  final String id;
  final String userId;
  final String type; // 'card' or 'momo'
  final String token; // Flutterwave payment token
  final String last4; // Last 4 digits of card/phone
  final String brand; // 'visa', 'mastercard', 'mtn', 'vodafone', 'airteltigo'
  final String? expiryMonth;
  final String? expiryYear;
  final String? phoneNumber; // For MoMo
  final String? cardholderName;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime lastUsed;

  const SavedPaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.token,
    required this.last4,
    required this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.phoneNumber,
    this.cardholderName,
    this.isDefault = false,
    required this.createdAt,
    required this.lastUsed,
  });

  factory SavedPaymentMethod.fromMap(Map<String, dynamic> map) {
    return SavedPaymentMethod(
      id: map['id'] ?? '',
      userId: map['userId'] ?? map['user_id'] ?? '',
      type: map['type'] ?? 'card',
      token: map['token'] ?? '',
      last4: map['last4'] ?? '',
      brand: map['brand'] ?? '',
      expiryMonth: map['expiryMonth'] ?? map['expiry_month'],
      expiryYear: map['expiryYear'] ?? map['expiry_year'],
      phoneNumber: map['phoneNumber'] ?? map['phone_number'],
      cardholderName: map['cardholderName'] ?? map['cardholder_name'],
      isDefault: map['isDefault'] ?? map['is_default'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? map['created_at'] ?? DateTime.now().toIso8601String()),
      lastUsed: DateTime.parse(map['lastUsed'] ?? map['last_used'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'token': token,
      'last4': last4,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'phoneNumber': phoneNumber,
      'cardholderName': cardholderName,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  SavedPaymentMethod copyWith({
    String? id,
    String? userId,
    String? type,
    String? token,
    String? last4,
    String? brand,
    String? expiryMonth,
    String? expiryYear,
    String? phoneNumber,
    String? cardholderName,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return SavedPaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      token: token ?? this.token,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  /// Get display name for payment method
  String get displayName {
    if (type == 'card') {
      return '${brand.toUpperCase()} •••• $last4';
    } else {
      return '${brand.toUpperCase()} MoMo ${phoneNumber ?? last4}';
    }
  }

  /// Get icon for payment method
  String get icon {
    switch (brand.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '💳';
      case 'mtn':
        return '📱';
      case 'vodafone':
        return '📱';
      case 'airteltigo':
        return '📱';
      default:
        return '💰';
    }
  }

  /// Check if card is expired
  bool get isExpired {
    if (type != 'card' || expiryMonth == null || expiryYear == null) {
      return false;
    }
    final now = DateTime.now();
    final expiry = DateTime(int.parse(expiryYear!), int.parse(expiryMonth!));
    return expiry.isBefore(now);
  }
}
