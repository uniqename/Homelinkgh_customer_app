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

// Demo accounts for testing
class DemoAccounts {
  static List<UserProfile> get demoUsers => [
    // Super Admin
    UserProfile(
      id: 'user_001',
      email: 'admin@homelinkgh.com',
      fullName: 'Kwame Nkrumah',
      firstName: 'Kwame',
      lastName: 'Nkrumah',
      phone: '+233 24 123 4567',
      role: UserRole.superAdmin,
      permissions: EmployeePermission.values,
      createdAt: DateTime(2024, 1, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      metadata: {'department': 'Executive', 'location': 'Accra HQ'},
    ),

    // Operations Manager
    UserProfile(
      id: 'user_002',
      email: 'operations@homelinkgh.com',
      fullName: 'Akosua Agyemang',
      firstName: 'Akosua',
      lastName: 'Agyemang',
      phone: '+233 26 234 5678',
      role: UserRole.operationsManager,
      permissions: [
        EmployeePermission.viewUsers,
        EmployeePermission.editUsers,
        EmployeePermission.viewProviders,
        EmployeePermission.approveProviders,
        EmployeePermission.manageProviderDocuments,
        EmployeePermission.viewAnalytics,
        EmployeePermission.manageServices,
        EmployeePermission.viewFinancials,
        EmployeePermission.viewRevenue,
      ],
      createdAt: DateTime(2024, 1, 15),
      lastLogin: DateTime.now().subtract(const Duration(hours: 4)),
      metadata: {'department': 'Operations', 'location': 'Accra HQ'},
    ),

    // Finance Manager
    UserProfile(
      id: 'user_003',
      email: 'finance@homelinkgh.com',
      fullName: 'Yaw Asante',
      firstName: 'Yaw',
      lastName: 'Asante',
      phone: '+233 25 345 6789',
      role: UserRole.financeManager,
      permissions: [
        EmployeePermission.viewFinancials,
        EmployeePermission.processPayouts,
        EmployeePermission.manageCommissions,
        EmployeePermission.viewRevenue,
        EmployeePermission.viewAnalytics,
        EmployeePermission.viewProviders,
      ],
      createdAt: DateTime(2024, 2, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 6)),
      metadata: {'department': 'Finance', 'location': 'Accra HQ'},
    ),

    // Support Agent
    UserProfile(
      id: 'user_004',
      email: 'support@homelinkgh.com',
      fullName: 'Ama Osei',
      firstName: 'Ama',
      lastName: 'Osei',
      phone: '+233 27 456 7890',
      role: UserRole.supportAgent,
      permissions: [
        EmployeePermission.viewTickets,
        EmployeePermission.resolveTickets,
        EmployeePermission.escalateTickets,
        EmployeePermission.viewUsers,
        EmployeePermission.viewProviders,
      ],
      createdAt: DateTime(2024, 2, 15),
      lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
      metadata: {'department': 'Customer Support', 'location': 'Accra HQ'},
    ),

    // Onboarding Specialist
    UserProfile(
      id: 'user_005',
      email: 'onboarding@homelinkgh.com',
      fullName: 'Kofi Mensah',
      firstName: 'Kofi',
      lastName: 'Mensah',
      phone: '+233 28 567 8901',
      role: UserRole.onboardingSpecialist,
      permissions: [
        EmployeePermission.viewProviders,
        EmployeePermission.approveProviders,
        EmployeePermission.manageProviderDocuments,
        EmployeePermission.viewUsers,
        EmployeePermission.editUsers,
      ],
      createdAt: DateTime(2024, 3, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      metadata: {'department': 'Provider Relations', 'location': 'Accra HQ'},
    ),

    // Dispatch Coordinator
    UserProfile(
      id: 'user_006',
      email: 'dispatch@homelinkgh.com',
      fullName: 'Abena Boateng',
      firstName: 'Abena',
      lastName: 'Boateng',
      phone: '+233 29 678 9012',
      role: UserRole.dispatchCoordinator,
      permissions: [
        EmployeePermission.viewProviders,
        EmployeePermission.viewUsers,
        EmployeePermission.viewAnalytics,
      ],
      createdAt: DateTime(2024, 3, 15),
      lastLogin: DateTime.now().subtract(const Duration(minutes: 45)),
      metadata: {'department': 'Operations', 'location': 'Kumasi Branch'},
    ),

    // Regular Admin
    UserProfile(
      id: 'user_007',
      email: 'admin2@homelinkgh.com',
      fullName: 'Samuel Adjei',
      firstName: 'Samuel',
      lastName: 'Adjei',
      phone: '+233 20 789 0123',
      role: UserRole.admin,
      permissions: [
        EmployeePermission.viewUsers,
        EmployeePermission.editUsers,
        EmployeePermission.suspendUsers,
        EmployeePermission.viewProviders,
        EmployeePermission.approveProviders,
        EmployeePermission.manageProviderDocuments,
        EmployeePermission.viewAnalytics,
        EmployeePermission.manageServices,
        EmployeePermission.viewFinancials,
      ],
      createdAt: DateTime(2024, 4, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
      metadata: {'department': 'Administration', 'location': 'Tamale Branch'},
    ),

    // Demo Customers
    UserProfile(
      id: 'user_008',
      email: 'customer1@email.com',
      fullName: 'Grace Owusu',
      firstName: 'Grace',
      lastName: 'Owusu',
      phone: '+233 24 890 1234',
      role: UserRole.customer,
      permissions: [],
      createdAt: DateTime(2024, 5, 1),
      lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
      metadata: {'location': 'East Legon, Accra', 'verified': true},
    ),

    UserProfile(
      id: 'user_009',
      email: 'customer2@email.com',
      fullName: 'Joseph Nkrumah',
      firstName: 'Joseph',
      lastName: 'Nkrumah',
      phone: '+233 26 901 2345',
      role: UserRole.customer,
      permissions: [],
      createdAt: DateTime(2024, 5, 15),
      lastLogin: DateTime.now().subtract(const Duration(days: 2)),
      metadata: {'location': 'Osu, Accra', 'verified': false},
    ),

    // Demo Providers
    UserProfile(
      id: 'user_010',
      email: 'provider1@email.com',
      fullName: 'Michael Asante',
      firstName: 'Michael',
      lastName: 'Asante',
      phone: '+233 25 012 3456',
      role: UserRole.provider,
      permissions: [],
      createdAt: DateTime(2024, 4, 15),
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      metadata: {
        'business': 'Asante Electrical Services',
        'service': 'Electrical Services',
        'location': 'Tema, Greater Accra',
        'verified': true,
        'rating': 4.8,
      },
    ),

    UserProfile(
      id: 'user_011',
      email: 'provider2@email.com',
      fullName: 'Efua Mensah',
      firstName: 'Efua',
      lastName: 'Mensah',
      phone: '+233 27 123 4567',
      role: UserRole.provider,
      permissions: [],
      createdAt: DateTime(2024, 5, 1),
      lastLogin: DateTime.now().subtract(const Duration(minutes: 20)),
      metadata: {
        'business': 'Clean Pro Services',
        'service': 'Cleaning Services',
        'location': 'Spintex, Accra',
        'verified': true,
        'rating': 4.6,
      },
    ),
  ];

  // Demo login credentials
  static Map<String, String> get demoCredentials => {
    // Staff/Employee Accounts
    'admin@homelinkgh.com': 'HomeLinkGH2024!',
    'operations@homelinkgh.com': 'Operations2024!',
    'finance@homelinkgh.com': 'Finance2024!',
    'support@homelinkgh.com': 'Support2024!',
    'onboarding@homelinkgh.com': 'Onboarding2024!',
    'dispatch@homelinkgh.com': 'Dispatch2024!',
    'admin2@homelinkgh.com': 'Admin2024!',
    
    // Customer Test Accounts
    'customer1@email.com': 'Customer123!',
    'customer2@email.com': 'Customer123!',
    
    // Provider Test Accounts
    'provider1@email.com': 'Provider123!',
    'provider2@email.com': 'Provider123!',
  };

  static UserProfile? getUserByEmail(String email) {
    try {
      return demoUsers.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  static bool validateCredentials(String email, String password) {
    return demoCredentials.containsKey(email) && 
           demoCredentials[email] == password;
  }
}