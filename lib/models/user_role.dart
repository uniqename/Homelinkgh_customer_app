enum UserRole {
  customer,
  provider,
  admin,
  superAdmin,
  supportAgent,
  dispatchCoordinator,
  onboardingSpecialist,
  financeManager,
  operationsManager,
}

enum EmployeePermission {
  // User Management
  viewUsers,
  editUsers,
  suspendUsers,
  deleteUsers,
  
  // Provider Management
  viewProviders,
  approveProviders,
  suspendProviders,
  manageProviderDocuments,
  
  // Financial Operations
  viewFinancials,
  processPayouts,
  manageCommissions,
  viewRevenue,
  
  // Platform Operations
  viewAnalytics,
  manageServices,
  configurePlatform,
  accessLogs,
  
  // Support Operations
  viewTickets,
  resolveTickets,
  escalateTickets,
  
  // Admin Operations
  manageEmployees,
  systemConfiguration,
  dataBackup,
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final UserRole role;
  final List<EmployeePermission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? metadata;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.metadata,
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return fullName;
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.provider:
        return 'Service Provider';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.supportAgent:
        return 'Support Agent';
      case UserRole.dispatchCoordinator:
        return 'Dispatch Coordinator';
      case UserRole.onboardingSpecialist:
        return 'Onboarding Specialist';
      case UserRole.financeManager:
        return 'Finance Manager';
      case UserRole.operationsManager:
        return 'Operations Manager';
    }
  }

  bool hasPermission(EmployeePermission permission) {
    return permissions.contains(permission);
  }

  bool get canManageUsers => 
    hasPermission(EmployeePermission.viewUsers) || 
    role == UserRole.admin || 
    role == UserRole.superAdmin ||
    role == UserRole.operationsManager;

  bool get canManageProviders => 
    hasPermission(EmployeePermission.viewProviders) || 
    role == UserRole.admin || 
    role == UserRole.superAdmin ||
    role == UserRole.operationsManager ||
    role == UserRole.onboardingSpecialist;

  bool get canViewFinancials => 
    hasPermission(EmployeePermission.viewFinancials) || 
    role == UserRole.admin || 
    role == UserRole.superAdmin ||
    role == UserRole.financeManager ||
    role == UserRole.operationsManager;

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    List<EmployeePermission>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      metadata: metadata ?? this.metadata,
    );
  }
}