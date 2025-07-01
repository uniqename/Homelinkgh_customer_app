import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == data['userType'],
        orElse: () => UserType.survivor,
      ),
      isAnonymous: data['isAnonymous'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : null,
      emergencyContact: data['emergencyContact'],
      emergencyContactPhone: data['emergencyContactPhone'],
      supportNeeds: data['supportNeeds'] != null 
          ? List<String>.from(data['supportNeeds']) 
          : null,
      currentLocation: data['currentLocation'],
      hasActiveCases: data['hasActiveCases'] ?? false,
      specialization: data['specialization'],
      qualifications: data['qualifications'] != null 
          ? List<String>.from(data['qualifications']) 
          : null,
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'userType': userType.toString().split('.').last,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null 
          ? Timestamp.fromDate(lastLoginAt!) 
          : null,
      'emergencyContact': emergencyContact,
      'emergencyContactPhone': emergencyContactPhone,
      'supportNeeds': supportNeeds,
      'currentLocation': currentLocation,
      'hasActiveCases': hasActiveCases,
      'specialization': specialization,
      'qualifications': qualifications,
      'isAvailable': isAvailable,
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