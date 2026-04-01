/// Staff Payroll Models for HomeLinkGH Employee Payment System

class StaffPayroll {
  final String id;
  final String staffId;
  final String staffName;
  final String staffEmail;
  final String staffRole; // 'supportAgent', 'dispatchCoordinator', etc.
  final DateTime periodStart;
  final DateTime periodEnd;
  final double baseSalary;
  final double commissionRate; // Percentage per job facilitated
  final int jobsFacilitated;
  final double totalServiceFees; // Total fees from jobs they handled
  final double commissionEarned;
  final double bonuses;
  final double deductions;
  final double grossPay;
  final double netPay;
  final String status; // 'pending', 'approved', 'paid'
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime createdAt;

  StaffPayroll({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffEmail,
    required this.staffRole,
    required this.periodStart,
    required this.periodEnd,
    required this.baseSalary,
    required this.commissionRate,
    required this.jobsFacilitated,
    required this.totalServiceFees,
    required this.commissionEarned,
    this.bonuses = 0.0,
    this.deductions = 0.0,
    required this.grossPay,
    required this.netPay,
    this.status = 'pending',
    this.paidAt,
    this.paymentMethod,
    this.paymentReference,
    required this.createdAt,
  });

  factory StaffPayroll.fromMap(Map<String, dynamic> map) {
    return StaffPayroll(
      id: map['id'],
      staffId: map['staff_id'],
      staffName: map['staff_name'],
      staffEmail: map['staff_email'],
      staffRole: map['staff_role'],
      periodStart: DateTime.parse(map['period_start']),
      periodEnd: DateTime.parse(map['period_end']),
      baseSalary: (map['base_salary'] as num).toDouble(),
      commissionRate: (map['commission_rate'] as num).toDouble(),
      jobsFacilitated: map['jobs_facilitated'],
      totalServiceFees: (map['total_service_fees'] as num).toDouble(),
      commissionEarned: (map['commission_earned'] as num).toDouble(),
      bonuses: (map['bonuses'] as num?)?.toDouble() ?? 0.0,
      deductions: (map['deductions'] as num?)?.toDouble() ?? 0.0,
      grossPay: (map['gross_pay'] as num).toDouble(),
      netPay: (map['net_pay'] as num).toDouble(),
      status: map['status'] ?? 'pending',
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      paymentMethod: map['payment_method'],
      paymentReference: map['payment_reference'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'staff_name': staffName,
      'staff_email': staffEmail,
      'staff_role': staffRole,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'base_salary': baseSalary,
      'commission_rate': commissionRate,
      'jobs_facilitated': jobsFacilitated,
      'total_service_fees': totalServiceFees,
      'commission_earned': commissionEarned,
      'bonuses': bonuses,
      'deductions': deductions,
      'gross_pay': grossPay,
      'net_pay': netPay,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StaffPayroll copyWith({
    String? id,
    String? staffId,
    String? staffName,
    String? staffEmail,
    String? staffRole,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? baseSalary,
    double? commissionRate,
    int? jobsFacilitated,
    double? totalServiceFees,
    double? commissionEarned,
    double? bonuses,
    double? deductions,
    double? grossPay,
    double? netPay,
    String? status,
    DateTime? paidAt,
    String? paymentMethod,
    String? paymentReference,
    DateTime? createdAt,
  }) {
    return StaffPayroll(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      staffEmail: staffEmail ?? this.staffEmail,
      staffRole: staffRole ?? this.staffRole,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      baseSalary: baseSalary ?? this.baseSalary,
      commissionRate: commissionRate ?? this.commissionRate,
      jobsFacilitated: jobsFacilitated ?? this.jobsFacilitated,
      totalServiceFees: totalServiceFees ?? this.totalServiceFees,
      commissionEarned: commissionEarned ?? this.commissionEarned,
      bonuses: bonuses ?? this.bonuses,
      deductions: deductions ?? this.deductions,
      grossPay: grossPay ?? this.grossPay,
      netPay: netPay ?? this.netPay,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Staff Compensation Configuration
class StaffCompensationConfig {
  final String role;
  final double baseSalary; // Monthly base salary
  final double commissionRate; // Percentage of service fees (0-100)
  final bool isActive;

  StaffCompensationConfig({
    required this.role,
    required this.baseSalary,
    required this.commissionRate,
    this.isActive = true,
  });

  factory StaffCompensationConfig.fromMap(Map<String, dynamic> map) {
    return StaffCompensationConfig(
      role: map['role'],
      baseSalary: (map['base_salary'] as num).toDouble(),
      commissionRate: (map['commission_rate'] as num).toDouble(),
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'base_salary': baseSalary,
      'commission_rate': commissionRate,
      'is_active': isActive,
    };
  }

  /// Default compensation configs for different staff roles
  static Map<String, StaffCompensationConfig> getDefaultConfigs() {
    return {
      'supportAgent': StaffCompensationConfig(
        role: 'supportAgent',
        baseSalary: 1500.0, // GHS per month
        commissionRate: 2.0, // 2% of service fees
      ),
      'dispatchCoordinator': StaffCompensationConfig(
        role: 'dispatchCoordinator',
        baseSalary: 1800.0,
        commissionRate: 3.0, // 3% of service fees
      ),
      'onboardingSpecialist': StaffCompensationConfig(
        role: 'onboardingSpecialist',
        baseSalary: 2000.0,
        commissionRate: 2.5, // 2.5% of service fees
      ),
      'financeManager': StaffCompensationConfig(
        role: 'financeManager',
        baseSalary: 3500.0,
        commissionRate: 1.5, // 1.5% of service fees
      ),
      'operationsManager': StaffCompensationConfig(
        role: 'operationsManager',
        baseSalary: 4000.0,
        commissionRate: 2.0, // 2% of service fees
      ),
      'admin': StaffCompensationConfig(
        role: 'admin',
        baseSalary: 3000.0,
        commissionRate: 1.0, // 1% of service fees
      ),
      'superAdmin': StaffCompensationConfig(
        role: 'superAdmin',
        baseSalary: 5000.0,
        commissionRate: 0.5, // 0.5% of service fees
      ),
    };
  }
}
