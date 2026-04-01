import 'package:flutter/foundation.dart';
import '../models/staff_payroll.dart';

/// Staff Payroll Service for managing HomeLinkGH employee payments
class StaffPayrollService {
  static final StaffPayrollService _instance = StaffPayrollService._internal();
  factory StaffPayrollService() => _instance;
  StaffPayrollService._internal();

  // In-memory storage for demo (replace with Supabase in production)
  final List<StaffPayroll> _paychecks = [];
  final Map<String, StaffCompensationConfig> _compensationConfigs =
      StaffCompensationConfig.getDefaultConfigs();

  /// Get all paychecks for a specific period
  Future<List<StaffPayroll>> getPaychecksForPeriod(DateTime start, DateTime end) async {
    try {
      return _paychecks.where((paycheck) {
        return paycheck.periodStart.isAfter(start.subtract(const Duration(days: 1))) &&
               paycheck.periodEnd.isBefore(end.add(const Duration(days: 1)));
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error getting paychecks: $e');
      return [];
    }
  }

  /// Get all paychecks for a specific staff member
  Future<List<StaffPayroll>> getStaffPaychecks(String staffId) async {
    try {
      return _paychecks
          .where((paycheck) => paycheck.staffId == staffId)
          .toList()
        ..sort((a, b) => b.periodStart.compareTo(a.periodStart));
    } catch (e) {
      debugPrint('Error getting staff paychecks: $e');
      return [];
    }
  }

  /// Calculate paycheck for a staff member for a given period
  Future<StaffPayroll> calculatePaycheck({
    required String staffId,
    required String staffName,
    required String staffEmail,
    required String staffRole,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int jobsFacilitated,
    required double totalServiceFees,
    double bonuses = 0.0,
    double deductions = 0.0,
  }) async {
    try {
      // Get compensation config for this role
      final config = _compensationConfigs[staffRole] ??
          StaffCompensationConfig(role: staffRole, baseSalary: 1500.0, commissionRate: 2.0);

      // Calculate commission
      final commissionEarned = totalServiceFees * (config.commissionRate / 100);

      // Calculate gross and net pay
      final grossPay = config.baseSalary + commissionEarned + bonuses;
      final netPay = grossPay - deductions;

      final paycheck = StaffPayroll(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        staffId: staffId,
        staffName: staffName,
        staffEmail: staffEmail,
        staffRole: staffRole,
        periodStart: periodStart,
        periodEnd: periodEnd,
        baseSalary: config.baseSalary,
        commissionRate: config.commissionRate,
        jobsFacilitated: jobsFacilitated,
        totalServiceFees: totalServiceFees,
        commissionEarned: commissionEarned,
        bonuses: bonuses,
        deductions: deductions,
        grossPay: grossPay,
        netPay: netPay,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      return paycheck;
    } catch (e) {
      debugPrint('Error calculating paycheck: $e');
      rethrow;
    }
  }

  /// Create and save a paycheck
  Future<StaffPayroll> createPaycheck(StaffPayroll paycheck) async {
    try {
      // In production, save to Supabase
      _paychecks.add(paycheck);
      return paycheck;
    } catch (e) {
      debugPrint('Error creating paycheck: $e');
      rethrow;
    }
  }

  /// Update paycheck status (approve/pay)
  Future<bool> updatePaycheckStatus({
    required String paycheckId,
    required String status,
    String? paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final index = _paychecks.indexWhere((p) => p.id == paycheckId);
      if (index != -1) {
        _paychecks[index] = _paychecks[index].copyWith(
          status: status,
          paymentMethod: paymentMethod,
          paymentReference: paymentReference,
          paidAt: status == 'paid' ? DateTime.now() : null,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating paycheck status: $e');
      return false;
    }
  }

  /// Get compensation config for a role
  StaffCompensationConfig? getCompensationConfig(String role) {
    return _compensationConfigs[role];
  }

  /// Update compensation config for a role
  Future<bool> updateCompensationConfig(StaffCompensationConfig config) async {
    try {
      _compensationConfigs[config.role] = config;
      // In production, save to Supabase
      return true;
    } catch (e) {
      debugPrint('Error updating compensation config: $e');
      return false;
    }
  }

  /// Get all compensation configs
  Map<String, StaffCompensationConfig> getAllCompensationConfigs() {
    return Map.from(_compensationConfigs);
  }

  /// Get payroll summary statistics
  Future<Map<String, dynamic>> getPayrollSummary(DateTime start, DateTime end) async {
    try {
      final paychecks = await getPaychecksForPeriod(start, end);

      final totalPaid = paychecks
          .where((p) => p.status == 'paid')
          .fold(0.0, (sum, p) => sum + p.netPay);

      final totalPending = paychecks
          .where((p) => p.status == 'pending')
          .fold(0.0, (sum, p) => sum + p.netPay);

      final totalApproved = paychecks
          .where((p) => p.status == 'approved')
          .fold(0.0, (sum, p) => sum + p.netPay);

      return {
        'totalPaychecks': paychecks.length,
        'totalPaid': totalPaid,
        'totalPending': totalPending,
        'totalApproved': totalApproved,
        'totalPayroll': totalPaid + totalPending + totalApproved,
        'averagePaycheck': paychecks.isEmpty ? 0.0 :
            (totalPaid + totalPending + totalApproved) / paychecks.length,
      };
    } catch (e) {
      debugPrint('Error getting payroll summary: $e');
      return {
        'totalPaychecks': 0,
        'totalPaid': 0.0,
        'totalPending': 0.0,
        'totalApproved': 0.0,
        'totalPayroll': 0.0,
        'averagePaycheck': 0.0,
      };
    }
  }

  /// Generate mock paychecks for demo purposes
  Future<void> generateMockPaychecks() async {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    final mockStaff = [
      {'id': 'staff_001', 'name': 'Akosua Mensah', 'email': 'akosua@homelinkgh.com', 'role': 'supportAgent'},
      {'id': 'staff_002', 'name': 'Kwame Boateng', 'email': 'kwame@homelinkgh.com', 'role': 'dispatchCoordinator'},
      {'id': 'staff_003', 'name': 'Ama Asante', 'email': 'ama@homelinkgh.com', 'role': 'onboardingSpecialist'},
      {'id': 'staff_004', 'name': 'Kofi Owusu', 'email': 'kofi@homelinkgh.com', 'role': 'financeManager'},
    ];

    for (var staff in mockStaff) {
      // Current month paycheck
      final currentPaycheck = await calculatePaycheck(
        staffId: staff['id'] as String,
        staffName: staff['name'] as String,
        staffEmail: staff['email'] as String,
        staffRole: staff['role'] as String,
        periodStart: currentMonthStart,
        periodEnd: currentMonthEnd,
        jobsFacilitated: 45 + (staff['id'].hashCode % 20),
        totalServiceFees: 12000.0 + (staff['id'].hashCode % 5000),
        bonuses: 200.0,
      );
      await createPaycheck(currentPaycheck);

      // Last month paycheck (paid)
      final lastPaycheck = await calculatePaycheck(
        staffId: staff['id'] as String,
        staffName: staff['name'] as String,
        staffEmail: staff['email'] as String,
        staffRole: staff['role'] as String,
        periodStart: lastMonthStart,
        periodEnd: lastMonthEnd,
        jobsFacilitated: 38 + (staff['id'].hashCode % 15),
        totalServiceFees: 10500.0 + (staff['id'].hashCode % 4000),
        bonuses: 150.0,
      );
      final paidPaycheck = lastPaycheck.copyWith(
        status: 'paid',
        paidAt: lastMonthEnd.add(const Duration(days: 5)),
        paymentMethod: 'Bank Transfer',
        paymentReference: 'TXN-${lastPaycheck.id}',
      );
      await createPaycheck(paidPaycheck);
    }
  }
}
