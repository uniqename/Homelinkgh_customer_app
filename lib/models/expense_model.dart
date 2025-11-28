import 'user_role.dart';

/// Comprehensive expense model for HomeLinkGH operations
/// Includes all operational costs: salaries, transport, rent, utilities, etc.
class HomeLinkGHExpenseModel {
  final DateTime month;
  final Map<ExpenseCategory, List<ExpenseItem>> expenses;

  const HomeLinkGHExpenseModel({
    required this.month,
    required this.expenses,
  });

  /// Calculate total expenses for the month
  double get totalMonthlyExpenses {
    double total = 0;
    for (final categoryExpenses in expenses.values) {
      for (final expense in categoryExpenses) {
        total += expense.amount;
      }
    }
    return total;
  }

  /// Get expenses by category
  double getExpenseByCategory(ExpenseCategory category) {
    final categoryExpenses = expenses[category] ?? [];
    return categoryExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  /// Calculate total annual expenses
  double get totalAnnualExpenses => totalMonthlyExpenses * 12;

  /// Get expense breakdown as percentage
  Map<ExpenseCategory, double> get expenseBreakdownPercentage {
    final total = totalMonthlyExpenses;
    if (total == 0) return {};
    
    return expenses.map((category, items) {
      final categoryTotal = items.fold(0.0, (sum, item) => sum + item.amount);
      return MapEntry(category, (categoryTotal / total) * 100);
    });
  }

  /// Generate default HomeLinkGH monthly expenses (realistic Ghana market rates)
  static HomeLinkGHExpenseModel generateMonthlyExpenses({DateTime? month}) {
    final targetMonth = month ?? DateTime.now();
    
    return HomeLinkGHExpenseModel(
      month: targetMonth,
      expenses: {
        // Personnel/Salary Expenses (Largest cost center)
        ExpenseCategory.salaries: [
          ExpenseItem(
            name: 'Super Admin Salary',
            amount: 2000.0,
            description: 'CEO/Founder compensation',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Finance Manager Salary',
            amount: 1500.0,
            description: 'Monthly salary + allowances',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Operations Manager Salary',
            amount: 1500.0,
            description: 'Monthly salary + allowances',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Admin Staff Salary',
            amount: 1300.0,
            description: 'Monthly salary + allowances',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Onboarding Specialist Salary',
            amount: 1200.0,
            description: 'Monthly salary + allowances',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Dispatch Coordinator Salary (2 staff)',
            amount: 2000.0, // 1000 * 2
            description: 'Monthly salary + allowances (Accra + Kumasi)',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Support Agents Salary (3 staff)',
            amount: 2400.0, // 800 * 3
            description: 'Monthly salary + allowances',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'SSNIT Contributions (13.5%)',
            amount: 1620.0, // ~13.5% of total salaries
            description: 'Employer social security contributions',
            isRecurring: true,
          ),
        ],

        // Office & Infrastructure
        ExpenseCategory.rent: [
          ExpenseItem(
            name: 'Accra HQ Office Rent',
            amount: 2500.0,
            description: '4-bedroom office space in East Legon',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Kumasi Branch Office Rent',
            amount: 1200.0,
            description: '2-bedroom office space',
            isRecurring: true,
          ),
        ],

        // Utilities & Communications
        ExpenseCategory.utilities: [
          ExpenseItem(
            name: 'Electricity (Accra HQ)',
            amount: 800.0,
            description: 'ECG bills for office operations',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Electricity (Kumasi Branch)',
            amount: 400.0,
            description: 'ECG bills for branch office',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Water Bills',
            amount: 200.0,
            description: 'Ghana Water Company bills',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Internet & Telecommunications',
            amount: 600.0,
            description: 'Vodafone Business/MTN fiber connections',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Mobile Data Allowances',
            amount: 500.0,
            description: 'Staff mobile data allowances',
            isRecurring: true,
          ),
        ],

        // Technology & Software
        ExpenseCategory.technology: [
          ExpenseItem(
            name: 'Cloud Hosting (AWS/Google Cloud)',
            amount: 800.0,
            description: 'App hosting, database, CDN',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Software Licenses',
            amount: 300.0,
            description: 'Office 365, design tools, analytics',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Payment Processing Fees',
            amount: 1200.0,
            description: 'PayStack transaction fees (~2.9%)',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'SMS & Push Notifications',
            amount: 400.0,
            description: 'Customer/provider communications',
            isRecurring: true,
          ),
        ],

        // Marketing & Customer Acquisition
        ExpenseCategory.marketing: [
          ExpenseItem(
            name: 'Digital Marketing (Facebook/Google Ads)',
            amount: 2000.0,
            description: 'Customer acquisition campaigns',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Radio/TV Advertising',
            amount: 1500.0,
            description: 'Local media campaigns',
            isRecurring: false,
          ),
          ExpenseItem(
            name: 'Community Events & Sponsorships',
            amount: 800.0,
            description: 'Local community engagement',
            isRecurring: false,
          ),
          ExpenseItem(
            name: 'Referral Program Payouts',
            amount: 600.0,
            description: 'Customer/provider referral bonuses',
            isRecurring: true,
          ),
        ],

        // Transportation & Logistics
        ExpenseCategory.transport: [
          ExpenseItem(
            name: 'Company Vehicle Fuel',
            amount: 800.0,
            description: 'Field operations, provider visits',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Vehicle Maintenance',
            amount: 300.0,
            description: 'Company vehicle servicing',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Staff Transport Allowances',
            amount: 950.0, // Sum of all transport allowances
            description: 'Employee transport reimbursements',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Emergency Response Transport',
            amount: 200.0,
            description: 'Customer support emergency visits',
            isRecurring: true,
          ),
        ],

        // Insurance & Legal
        ExpenseCategory.insurance: [
          ExpenseItem(
            name: 'General Business Insurance',
            amount: 400.0,
            description: 'Office, equipment, liability coverage',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Employee Health Insurance',
            amount: 900.0,
            description: 'Staff medical coverage contributions',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Professional Indemnity Insurance',
            amount: 250.0,
            description: 'Service provider liability coverage',
            isRecurring: true,
          ),
        ],

        // Regulatory & Compliance
        ExpenseCategory.regulatory: [
          ExpenseItem(
            name: 'Business Registration & Permits',
            amount: 150.0,
            description: 'Registrar General, local permits',
            isRecurring: false,
          ),
          ExpenseItem(
            name: 'Tax Compliance & Accounting',
            amount: 800.0,
            description: 'Professional accounting services',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Legal & Advisory Services',
            amount: 600.0,
            description: 'Legal counsel, contract reviews',
            isRecurring: true,
          ),
        ],

        // Operations & Miscellaneous
        ExpenseCategory.operations: [
          ExpenseItem(
            name: 'Office Supplies & Equipment',
            amount: 400.0,
            description: 'Stationery, computers, furniture',
            isRecurring: false,
          ),
          ExpenseItem(
            name: 'Background Check Services',
            amount: 300.0,
            description: 'Provider verification costs',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Training & Development',
            amount: 500.0,
            description: 'Staff skill development programs',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Quality Assurance Audits',
            amount: 200.0,
            description: 'Service quality monitoring',
            isRecurring: true,
          ),
          ExpenseItem(
            name: 'Emergency Fund Reserve',
            amount: 1000.0,
            description: 'Contingency for unexpected costs',
            isRecurring: true,
          ),
        ],
      },
    );
  }
}

enum ExpenseCategory {
  salaries('Personnel & Salaries'),
  rent('Office Rent'),
  utilities('Utilities & Communications'),
  technology('Technology & Software'),
  marketing('Marketing & Advertising'),
  transport('Transportation & Logistics'),
  insurance('Insurance & Risk Management'),
  regulatory('Regulatory & Compliance'),
  operations('Operations & Miscellaneous');

  const ExpenseCategory(this.displayName);
  final String displayName;
}

class ExpenseItem {
  final String name;
  final double amount;
  final String description;
  final bool isRecurring;
  final ExpenseCategory? category;

  const ExpenseItem({
    required this.name,
    required this.amount,
    required this.description,
    this.isRecurring = true,
    this.category,
  });

  /// Calculate annual cost for this expense item
  double get annualCost => isRecurring ? amount * 12 : amount;
}

/// Revenue and Profit Analysis
class FinancialAnalysis {
  final double monthlyRevenue;
  final HomeLinkGHExpenseModel expenses;

  const FinancialAnalysis({
    required this.monthlyRevenue,
    required this.expenses,
  });

  /// Calculate net profit (revenue - expenses)
  double get monthlyNetProfit => monthlyRevenue - expenses.totalMonthlyExpenses;

  /// Calculate profit margin percentage
  double get profitMarginPercentage {
    if (monthlyRevenue == 0) return 0;
    return (monthlyNetProfit / monthlyRevenue) * 100;
  }

  /// Calculate break-even revenue needed
  double get breakEvenRevenue => expenses.totalMonthlyExpenses;

  /// Check if business is profitable
  bool get isProfitable => monthlyNetProfit > 0;

  /// Calculate annual profit
  double get annualNetProfit => monthlyNetProfit * 12;

  /// Get expense-to-revenue ratio by category
  Map<ExpenseCategory, double> get expenseToRevenueRatio {
    if (monthlyRevenue == 0) return {};
    
    return expenses.expenseBreakdownPercentage.map((category, percentage) {
      final categoryAmount = expenses.getExpenseByCategory(category);
      return MapEntry(category, (categoryAmount / monthlyRevenue) * 100);
    });
  }

  /// Generate realistic financial scenario for HomeLinkGH
  static FinancialAnalysis generateScenario({
    DateTime? month,
    double? monthlyRevenue,
  }) {
    final targetMonth = month ?? DateTime.now();
    final revenue = monthlyRevenue ?? _calculateProjectedRevenue();
    
    return FinancialAnalysis(
      monthlyRevenue: revenue,
      expenses: HomeLinkGHExpenseModel.generateMonthlyExpenses(month: targetMonth),
    );
  }

  /// Calculate projected monthly revenue based on platform activity
  static double _calculateProjectedRevenue() {
    // Based on realistic Ghana service marketplace metrics
    const double averageOrderValue = 85.0; // GH₵ per service
    const double platformFeeRate = 0.15; // 15% platform fee
    const int monthlyActiveUsers = 2500;
    const double orderConversionRate = 0.12; // 12% of users place orders
    const double averageOrdersPerUser = 1.8; // Per month
    
    final monthlyOrders = (monthlyActiveUsers * orderConversionRate * averageOrdersPerUser);
    final grossRevenue = monthlyOrders * averageOrderValue;
    final platformRevenue = grossRevenue * platformFeeRate;
    
    // Add additional revenue streams
    const double subscriptionRevenue = 800.0; // Premium provider subscriptions
    const double advertisingRevenue = 300.0; // Featured provider placements
    const double verificationFees = 450.0; // Provider verification fees
    
    return platformRevenue + subscriptionRevenue + advertisingRevenue + verificationFees;
  }
}