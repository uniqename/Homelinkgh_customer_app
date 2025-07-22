enum UserType { survivor, counselor, admin, volunteer }

enum CaseStatus { active, closed, pending }

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final UserType userType;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  // Survivor-specific fields
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final List<String>? supportNeeds;
  final String? currentLocation;
  final bool hasActiveCases;
  
  // Staff-specific fields
  final String? specialization;
  final List<String>? qualifications;
  final bool isAvailable;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    required this.userType,
    this.isAnonymous = false,
    required this.createdAt,
    this.lastLoginAt,
    this.emergencyContact,
    this.emergencyContactPhone,
    this.supportNeeds,
    this.currentLocation,
    this.hasActiveCases = false,
    this.specialization,
    this.qualifications,
    this.isAvailable = true,
  });

  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['display_name'],
      phoneNumber: data['phone_number'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == data['user_type'],
        orElse: () => UserType.survivor,
      ),
      isAnonymous: data['is_anonymous'] ?? false,
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: data['last_login_at'] != null 
          ? DateTime.parse(data['last_login_at'])
          : null,
      emergencyContact: data['emergency_contact'],
      emergencyContactPhone: data['emergency_contact_phone'],
      supportNeeds: data['support_needs'] != null 
          ? List<String>.from(data['support_needs']) 
          : null,
      currentLocation: data['current_location'],
      hasActiveCases: data['has_active_cases'] ?? false,
      specialization: data['specialization'],
      qualifications: data['qualifications'] != null 
          ? List<String>.from(data['qualifications']) 
          : null,
      isAvailable: data['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'email': email,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'user_type': userType.toString().split('.').last,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'emergency_contact': emergencyContact,
      'emergency_contact_phone': emergencyContactPhone,
      'support_needs': supportNeeds,
      'current_location': currentLocation,
      'has_active_cases': hasActiveCases,
      'specialization': specialization,
      'qualifications': qualifications,
      'is_available': isAvailable,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? phoneNumber,
    UserType? userType,
    bool? isAnonymous,
    DateTime? lastLoginAt,
    String? emergencyContact,
    String? emergencyContactPhone,
    List<String>? supportNeeds,
    String? currentLocation,
    bool? hasActiveCases,
    String? specialization,
    List<String>? qualifications,
    bool? isAvailable,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      supportNeeds: supportNeeds ?? this.supportNeeds,
      currentLocation: currentLocation ?? this.currentLocation,
      hasActiveCases: hasActiveCases ?? this.hasActiveCases,
      specialization: specialization ?? this.specialization,
      qualifications: qualifications ?? this.qualifications,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}