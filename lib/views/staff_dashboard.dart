import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/notification_service.dart';
import '../services/dispute_service.dart';
import '../services/data_export_service.dart';
import 'dispute_resolution.dart';
import 'data_privacy.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String staffRole;
  final String staffName;
  final String staffId;

  const StaffDashboardScreen({
    super.key,
    required this.staffRole,
    required this.staffName,
    required this.staffId,
  });

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  Map<String, dynamic> dashboardStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);
    
    try {
      final jobStats = await JobService.getJobStatistics();
      final disputeMetrics = await DisputeService.getDisputeMetrics();
      
      setState(() {
        dashboardStats = {
          'jobStats': jobStats,
          'disputeMetrics': disputeMetrics,
          'totalUsers': 1250, // Mock data
          'activeBookings': 47,
          'monthlyRevenue': 85000,
          'customerSatisfaction': 4.8,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HomeLinkGH ${_getRoleDisplayName()}'),
            Text(
              'Welcome, ${widget.staffName}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showNotificationCenter(),
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () => _showStaffProfile(),
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      drawer: _buildStaffDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsOverview(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRoleSpecificSection(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildStaffDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006B3C), Color(0xFF228B22)],
              ),
            ),
            accountName: Text(widget.staffName),
            accountEmail: Text(_getRoleDisplayName()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.staffName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _getMenuItems(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _logout(),
          ),
        ],
      ),
    );
  }

  List<Widget> _getMenuItems() {
    final commonItems = [
      _buildMenuItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
      _buildMenuItem(Icons.people, 'Customers', () => _openCustomersView()),
      _buildMenuItem(Icons.verified, 'Providers', () => _openProvidersView()),
      _buildMenuItem(Icons.book_online, 'Bookings', () => _openBookingsView()),
      _buildMenuItem(Icons.payment, 'Payments', () => _openPaymentsView()),
      _buildMenuItem(Icons.support, 'Disputes', () => _openDisputesView()),
      _buildMenuItem(Icons.notifications, 'Notifications', () => _openNotificationsView()),
      _buildMenuItem(Icons.analytics, 'Analytics', () => _openAnalyticsView()),
    ];

    switch (widget.staffRole) {
      case 'general_manager':
        return [
          ...commonItems,
          _buildMenuItem(Icons.business, 'Business Intelligence', () => _openBusinessIntelligence()),
          _buildMenuItem(Icons.trending_up, 'Growth Metrics', () => _openGrowthMetrics()),
          _buildMenuItem(Icons.handshake, 'Partnerships', () => _openPartnerships()),
          _buildMenuItem(Icons.account_balance, 'Financial Reports', () => _openFinancialReports()),
        ];
      
      case 'operations_manager':
        return [
          ...commonItems,
          _buildMenuItem(Icons.location_on, 'Service Areas', () => _openServiceAreas()),
          _buildMenuItem(Icons.schedule, 'Scheduling', () => _openScheduling()),
          _buildMenuItem(Icons.inventory, 'Inventory', () => _openInventory()),
          _buildMenuItem(Icons.verified, 'Quality Control', () => _openQualityControl()),
        ];
      
      case 'customer_support':
        return [
          _buildMenuItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
          _buildMenuItem(Icons.support_agent, 'Support Tickets', () => _openSupportTickets()),
          _buildMenuItem(Icons.chat, 'Live Chat', () => _openLiveChat()),
          _buildMenuItem(Icons.phone, 'Call Center', () => _openCallCenter()),
          _buildMenuItem(Icons.feedback, 'Customer Feedback', () => _openCustomerFeedback()),
          _buildMenuItem(Icons.help, 'Knowledge Base', () => _openKnowledgeBase()),
        ];
      
      case 'marketing_manager':
        return [
          _buildMenuItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
          _buildMenuItem(Icons.campaign, 'Campaigns', () => _openCampaigns()),
          _buildMenuItem(Icons.share, 'Social Media', () => _openSocialMedia()),
          _buildMenuItem(Icons.email, 'Email Marketing', () => _openEmailMarketing()),
          _buildMenuItem(Icons.people_alt, 'Influencers', () => _openInfluencers()),
          _buildMenuItem(Icons.event, 'Events', () => _openEvents()),
        ];
      
      case 'finance_assistant':
        return [
          _buildMenuItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
          _buildMenuItem(Icons.account_balance, 'Transactions', () => _openTransactions()),
          _buildMenuItem(Icons.receipt, 'Invoices', () => _openInvoices()),
          _buildMenuItem(Icons.money, 'Payouts', () => _openPayouts()),
          _buildMenuItem(Icons.assessment, 'Financial Reports', () => _openFinancialReports()),
          _buildMenuItem(Icons.currency_exchange, 'Exchange Rates', () => _openExchangeRates()),
        ];
      
      case 'field_supervisor':
        return [
          ...commonItems,
          _buildMenuItem(Icons.location_on, 'Field Locations', () => _openFieldLocations()),
          _buildMenuItem(Icons.group, 'Field Teams', () => _openFieldTeams()),
          _buildMenuItem(Icons.assignment, 'Site Inspections', () => _openSiteInspections()),
          _buildMenuItem(Icons.emergency, 'Emergency Response', () => _openEmergencyResponse()),
        ];
      
      default:
        return commonItems;
    }
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF006B3C)),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _getStatsCards(),
        ),
      ],
    );
  }

  List<Widget> _getStatsCards() {
    final baseCards = [
      _buildStatCard('Total Users', '${dashboardStats['totalUsers'] ?? 0}', Icons.people, Colors.blue),
      _buildStatCard('Active Bookings', '${dashboardStats['activeBookings'] ?? 0}', Icons.book_online, Colors.green),
      _buildStatCard('Monthly Revenue', '₵${dashboardStats['monthlyRevenue'] ?? 0}', Icons.attach_money, Colors.orange),
      _buildStatCard('Satisfaction', '${dashboardStats['customerSatisfaction'] ?? 0}/5', Icons.star, Colors.purple),
    ];

    switch (widget.staffRole) {
      case 'customer_support':
        return [
          _buildStatCard('Open Tickets', '23', Icons.support, Colors.red),
          _buildStatCard('Avg Response', '4.2 min', Icons.timer, Colors.blue),
          _buildStatCard('Resolution Rate', '94%', Icons.check_circle, Colors.green),
          _buildStatCard('CSAT Score', '4.8/5', Icons.sentiment_very_satisfied, Colors.orange),
        ];
      
      case 'marketing_manager':
        return [
          _buildStatCard('Campaign ROI', '284%', Icons.trending_up, Colors.green),
          _buildStatCard('New Users', '156', Icons.person_add, Colors.blue),
          _buildStatCard('Social Reach', '25.4K', Icons.visibility, Colors.purple),
          _buildStatCard('Conversion', '3.2%', Icons.trending_up, Colors.orange),
        ];
      
      case 'finance_assistant':
        return [
          _buildStatCard('Daily Revenue', '₵12,450', Icons.today, Colors.green),
          _buildStatCard('Pending Payouts', '₵8,200', Icons.schedule, Colors.orange),
          _buildStatCard('Refunds Today', '₵1,120', Icons.money_off, Colors.red),
          _buildStatCard('Exchange Rate', '1 USD = ₵12.1', Icons.currency_exchange, Colors.blue),
        ];
      
      default:
        return baseCards;
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _getQuickActions(),
        ),
      ],
    );
  }

  List<Widget> _getQuickActions() {
    final commonActions = [
      _buildActionChip('View Disputes', Icons.support, () => _openDisputesView()),
      _buildActionChip('Send Notification', Icons.notifications, () => _sendBulkNotification()),
      _buildActionChip('Export Data', Icons.download, () => _exportData()),
      _buildActionChip('Generate Report', Icons.assessment, () => _generateReport()),
    ];

    switch (widget.staffRole) {
      case 'customer_support':
        return [
          _buildActionChip('Answer Chat', Icons.chat, () => _openLiveChat()),
          _buildActionChip('Process Refund', Icons.money_off, () => _processRefund()),
          _buildActionChip('Call Customer', Icons.phone, () => _callCustomer()),
          _buildActionChip('Create Ticket', Icons.add_task, () => _createSupportTicket()),
        ];
      
      case 'marketing_manager':
        return [
          _buildActionChip('New Campaign', Icons.add_circle, () => _createCampaign()),
          _buildActionChip('Social Post', Icons.post_add, () => _createSocialPost()),
          _buildActionChip('Email Blast', Icons.email, () => _sendEmailBlast()),
          _buildActionChip('View Analytics', Icons.analytics, () => _openAnalyticsView()),
        ];
      
      case 'finance_assistant':
        return [
          _buildActionChip('Process Payout', Icons.payment, () => _processPayout()),
          _buildActionChip('Reconcile Payments', Icons.account_balance, () => _reconcilePayments()),
          _buildActionChip('Update Rates', Icons.currency_exchange, () => _updateExchangeRates()),
          _buildActionChip('Financial Report', Icons.assessment, () => _generateFinancialReport()),
        ];
      
      default:
        return commonActions;
    }
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onPressed) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF006B3C)),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: const Color(0xFF006B3C).withOpacity(0.1),
      side: const BorderSide(color: Color(0xFF006B3C)),
    );
  }

  Widget _buildRoleSpecificSection() {
    switch (widget.staffRole) {
      case 'general_manager':
        return _buildGeneralManagerSection();
      case 'operations_manager':
        return _buildOperationsManagerSection();
      case 'customer_support':
        return _buildCustomerSupportSection();
      case 'marketing_manager':
        return _buildMarketingManagerSection();
      case 'finance_assistant':
        return _buildFinanceAssistantSection();
      case 'field_supervisor':
        return _buildFieldSupervisorSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGeneralManagerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Executive Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Monthly Growth', '+12.5%', Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile('Diaspora Users', '1,847', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Provider Network', '423', Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile('Service Coverage', '8/10 Regions', Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSupportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support Queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSupportTicket('Booking Issue', 'High', 'John Doe', '2 min ago'),
            _buildSupportTicket('Payment Failed', 'Medium', 'Jane Smith', '5 min ago'),
            _buildSupportTicket('Provider Late', 'Low', 'Mike Johnson', '12 min ago'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openSupportTickets(),
              icon: const Icon(Icons.support_agent),
              label: const Text('View All Tickets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingManagerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Campaigns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCampaignTile('Diaspora Holiday Special', '87%', 'Instagram', Colors.purple),
            _buildCampaignTile('New User Onboarding', '92%', 'Email', Colors.blue),
            _buildCampaignTile('Provider Recruitment', '68%', 'Facebook', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceAssistantSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTransactionTile('Service Payment', '₵150.00', 'Completed', Colors.green),
            _buildTransactionTile('Provider Payout', '₵1,200.00', 'Processing', Colors.orange),
            _buildTransactionTile('Refund Request', '₵75.00', 'Pending', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSupervisorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Field Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Active Teams', '8', Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile('Inspections Today', '12', Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Coverage Areas', '5 Regions', Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile('Quality Score', '96%', Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsManagerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operations Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Service Efficiency', '94%', Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile('Provider Utilization', '78%', Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTicket(String issue, String priority, String customer, String time) {
    Color priorityColor = priority == 'High' ? Colors.red : priority == 'Medium' ? Colors.orange : Colors.green;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(issue, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$customer • $time', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priority,
              style: TextStyle(fontSize: 10, color: priorityColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignTile(String name, String performance, String channel, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.campaign, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(channel, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(
            performance,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(String type, String amount, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.payment, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(amount, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityItem('New booking created', '2 min ago', Icons.book_online),
            _buildActivityItem('Provider verified', '5 min ago', Icons.verified),
            _buildActivityItem('Payment processed', '12 min ago', Icons.payment),
            _buildActivityItem('Dispute resolved', '1 hour ago', Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF006B3C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(activity),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName() {
    switch (widget.staffRole) {
      case 'general_manager': return 'General Manager';
      case 'operations_manager': return 'Operations Manager';
      case 'customer_support': return 'Customer Support';
      case 'provider_verification': return 'Provider Verification Officer';
      case 'app_coordinator': return 'Mobile App Project Coordinator';
      case 'marketing_manager': return 'Marketing & Social Media Manager';
      case 'finance_assistant': return 'Finance & Payments Assistant';
      case 'field_supervisor': return 'Field Supervisor';
      default: return 'Staff Member';
    }
  }

  // Navigation methods
  void _openCustomersView() => _navigateToFeature('Customers Management');
  void _openProvidersView() => _navigateToFeature('Providers Management');
  void _openBookingsView() => _navigateToFeature('Bookings Management');
  void _openPaymentsView() => _navigateToFeature('Payments Management');
  void _openDisputesView() => Navigator.push(context, MaterialPageRoute(builder: (context) => const DisputeResolutionScreen(bookingId: 'admin_view', bookingDetails: {'service': 'Admin View', 'customer': 'System Admin'})));
  void _openNotificationsView() => _navigateToFeature('Notifications Management');
  void _openAnalyticsView() => _navigateToFeature('Analytics Dashboard');
  void _openBusinessIntelligence() => _navigateToFeature('Business Intelligence');
  void _openGrowthMetrics() => _navigateToFeature('Growth Metrics');
  void _openPartnerships() => _navigateToFeature('Partnerships Management');
  void _openFinancialReports() => _navigateToFeature('Financial Reports');
  void _openServiceAreas() => _navigateToFeature('Service Areas Management');
  void _openScheduling() => _navigateToFeature('Scheduling System');
  void _openInventory() => _navigateToFeature('Inventory Management');
  void _openQualityControl() => _navigateToFeature('Quality Control');
  void _openSupportTickets() => _navigateToFeature('Support Tickets');
  void _openLiveChat() => _navigateToFeature('Live Chat System');
  void _openCallCenter() => _navigateToFeature('Call Center');
  void _openCustomerFeedback() => _navigateToFeature('Customer Feedback');
  void _openKnowledgeBase() => _navigateToFeature('Knowledge Base');
  void _openCampaigns() => _navigateToFeature('Marketing Campaigns');
  void _openSocialMedia() => _navigateToFeature('Social Media Management');
  void _openEmailMarketing() => _navigateToFeature('Email Marketing');
  void _openInfluencers() => _navigateToFeature('Influencer Management');
  void _openEvents() => _navigateToFeature('Events Management');
  void _openTransactions() => _navigateToFeature('Transaction Management');
  void _openInvoices() => _navigateToFeature('Invoice Management');
  void _openPayouts() => _navigateToFeature('Payout Management');
  void _openExchangeRates() => _navigateToFeature('Exchange Rate Management');
  void _openFieldLocations() => _navigateToFeature('Field Locations');
  void _openFieldTeams() => _navigateToFeature('Field Teams Management');
  void _openSiteInspections() => _navigateToFeature('Site Inspections');
  void _openEmergencyResponse() => _navigateToFeature('Emergency Response');

  void _navigateToFeature(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature available in full app'),
        backgroundColor: const Color(0xFF006B3C),
      ),
    );
  }

  void _showNotificationCenter() => _navigateToFeature('Notification Center');
  void _showStaffProfile() => _navigateToFeature('Staff Profile');
  void _sendBulkNotification() => _navigateToFeature('Bulk Notification Sender');
  void _exportData() => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPrivacyScreen()));
  void _generateReport() => _navigateToFeature('Report Generator');
  void _processRefund() => _navigateToFeature('Refund Processor');
  void _callCustomer() => _navigateToFeature('Customer Call System');
  void _createSupportTicket() => _navigateToFeature('Ticket Creator');
  void _createCampaign() => _navigateToFeature('Campaign Creator');
  void _createSocialPost() => _navigateToFeature('Social Media Poster');
  void _sendEmailBlast() => _navigateToFeature('Email Blast Sender');
  void _processPayout() => _navigateToFeature('Payout Processor');
  void _reconcilePayments() => _navigateToFeature('Payment Reconciliation');
  void _updateExchangeRates() => _navigateToFeature('Exchange Rate Updater');
  void _generateFinancialReport() => _navigateToFeature('Financial Report Generator');

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}