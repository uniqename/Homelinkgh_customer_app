enum ProviderStatus {
  pending,
  verified,
  suspended,
  rejected,
}

enum VerificationStatus {
  pending,
  approved,
  rejected,
  incomplete,
}

class ProviderVerification {
  final String providerId;
  final VerificationData verification;
  final ServiceArea serviceArea;
  final ProviderAvailability availability;
  final BankingInfo banking;
  final ProviderStatus status;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  ProviderVerification({
    required this.providerId,
    required this.verification,
    required this.serviceArea,
    required this.availability,
    required this.banking,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
    this.rejectionReason,
  });

  factory ProviderVerification.fromMap(Map<String, dynamic> map) {
    return ProviderVerification(
      providerId: map['providerId'] ?? '',
      verification: VerificationData.fromMap(map['verification'] ?? {}),
      serviceArea: ServiceArea.fromMap(map['serviceArea'] ?? {}),
      availability: ProviderAvailability.fromMap(map['availability'] ?? {}),
      banking: BankingInfo.fromMap(map['banking'] ?? {}),
      status: ProviderStatus.values.firstWhere(
        (e) => e.toString() == 'ProviderStatus.${map['status'] ?? 'pending'}',
        orElse: () => ProviderStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      verifiedAt: map['verifiedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['verifiedAt'])
          : null,
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'verification': verification.toMap(),
      'serviceArea': serviceArea.toMap(),
      'availability': availability.toMap(),
      'banking': banking.toMap(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'verifiedAt': verifiedAt?.millisecondsSinceEpoch,
      'rejectionReason': rejectionReason,
    };
  }
}

class VerificationData {
  final String? idDocumentUrl;
  final String? licenseUrl;
  final String? selfieUrl;
  final VerificationStatus idStatus;
  final VerificationStatus licenseStatus;
  final VerificationStatus backgroundCheckStatus;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  VerificationData({
    this.idDocumentUrl,
    this.licenseUrl,
    this.selfieUrl,
    required this.idStatus,
    required this.licenseStatus,
    required this.backgroundCheckStatus,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory VerificationData.fromMap(Map<String, dynamic> map) {
    return VerificationData(
      idDocumentUrl: map['idDocumentUrl'],
      licenseUrl: map['licenseUrl'],
      selfieUrl: map['selfieUrl'],
      idStatus: VerificationStatus.values.firstWhere(
        (e) => e.toString() == 'VerificationStatus.${map['idStatus'] ?? 'pending'}',
        orElse: () => VerificationStatus.pending,
      ),
      licenseStatus: VerificationStatus.values.firstWhere(
        (e) => e.toString() == 'VerificationStatus.${map['licenseStatus'] ?? 'pending'}',
        orElse: () => VerificationStatus.pending,
      ),
      backgroundCheckStatus: VerificationStatus.values.firstWhere(
        (e) => e.toString() == 'VerificationStatus.${map['backgroundCheckStatus'] ?? 'pending'}',
        orElse: () => VerificationStatus.pending,
      ),
      rejectionReason: map['rejectionReason'],
      submittedAt: map['submittedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['submittedAt'])
          : null,
      reviewedAt: map['reviewedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['reviewedAt'])
          : null,
      reviewedBy: map['reviewedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idDocumentUrl': idDocumentUrl,
      'licenseUrl': licenseUrl,
      'selfieUrl': selfieUrl,
      'idStatus': idStatus.toString().split('.').last,
      'licenseStatus': licenseStatus.toString().split('.').last,
      'backgroundCheckStatus': backgroundCheckStatus.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt?.millisecondsSinceEpoch,
      'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
      'reviewedBy': reviewedBy,
    };
  }
}

class ServiceArea {
  final String city;
  final List<String> neighborhoods;
  final double radiusKm;
  final double? centerLat;
  final double? centerLng;

  ServiceArea({
    required this.city,
    required this.neighborhoods,
    required this.radiusKm,
    this.centerLat,
    this.centerLng,
  });

  factory ServiceArea.fromMap(Map<String, dynamic> map) {
    return ServiceArea(
      city: map['city'] ?? '',
      neighborhoods: List<String>.from(map['neighborhoods'] ?? []),
      radiusKm: (map['radiusKm'] ?? 0.0).toDouble(),
      centerLat: map['centerLat']?.toDouble(),
      centerLng: map['centerLng']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'neighborhoods': neighborhoods,
      'radiusKm': radiusKm,
      'centerLat': centerLat,
      'centerLng': centerLng,
    };
  }
}

class ProviderAvailability {
  final Map<String, TimeSlot> weeklySchedule; // 'monday', 'tuesday', etc.
  final List<String> unavailableDates; // ISO date strings
  final bool isActive;

  ProviderAvailability({
    required this.weeklySchedule,
    required this.unavailableDates,
    required this.isActive,
  });

  factory ProviderAvailability.fromMap(Map<String, dynamic> map) {
    final schedule = <String, TimeSlot>{};
    final weeklyScheduleMap = map['weeklySchedule'] as Map<String, dynamic>? ?? {};
    
    for (final entry in weeklyScheduleMap.entries) {
      schedule[entry.key] = TimeSlot.fromMap(entry.value);
    }

    return ProviderAvailability(
      weeklySchedule: schedule,
      unavailableDates: List<String>.from(map['unavailableDates'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final scheduleMap = <String, dynamic>{};
    for (final entry in weeklySchedule.entries) {
      scheduleMap[entry.key] = entry.value.toMap();
    }

    return {
      'weeklySchedule': scheduleMap,
      'unavailableDates': unavailableDates,
      'isActive': isActive,
    };
  }
}

class TimeSlot {
  final String startTime; // '09:00'
  final String endTime; // '17:00'
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}

class BankingInfo {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String? mobileMoneyNumber;
  final String? mobileMoneyProvider; // MTN, Vodafone, AirtelTigo
  final String preferredPayoutMethod; // 'bank', 'mobile_money'

  BankingInfo({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    this.mobileMoneyNumber,
    this.mobileMoneyProvider,
    required this.preferredPayoutMethod,
  });

  factory BankingInfo.fromMap(Map<String, dynamic> map) {
    return BankingInfo(
      accountHolderName: map['accountHolderName'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      mobileMoneyNumber: map['mobileMoneyNumber'],
      mobileMoneyProvider: map['mobileMoneyProvider'],
      preferredPayoutMethod: map['preferredPayoutMethod'] ?? 'bank',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'mobileMoneyNumber': mobileMoneyNumber,
      'mobileMoneyProvider': mobileMoneyProvider,
      'preferredPayoutMethod': preferredPayoutMethod,
    };
  }
}