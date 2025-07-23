import 'package:flutter/material.dart';

class WorkerDashboard extends StatefulWidget {
  final String workerRole; // 'support', 'dispatch', 'onboarding'
  final String workerName;

  const WorkerDashboard({
    super.key,
    required this.workerRole,
    required this.workerName,
  });

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Support tickets data
  final List<SupportTicket> _supportTickets = [
    SupportTicket(
      id: 'ticket_001',
      customerName: 'Akosua Mensah',
      issue: 'Provider Not Showing Up',
      description: 'My plumber was supposed to arrive 2 hours ago but hasn\'t shown up. I tried calling but no response.',
      priority: TicketPriority.high,
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      assignedWorker: 'Sarah K.',
    ),
    SupportTicket(
      id: 'ticket_002',
      customerName: 'Kwame Asante',
      issue: 'Payment Issue',
      description: 'My payment was charged twice for the same electrical service. Need refund for duplicate charge.',
      priority: TicketPriority.medium,
      status: TicketStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      assignedWorker: 'Current Worker',
    ),
    SupportTicket(
      id: 'ticket_003',
      customerName: 'Ama Osei',
      issue: 'Service Quality Complaint',
      description: 'The cleaning service was not up to standard. Several areas were missed and I\'m not satisfied.',
      priority: TicketPriority.medium,
      status: TicketStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      assignedWorker: 'John D.',
      resolvedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  // Dispatch assignments
  final List<DispatchAssignment> _dispatchAssignments = [
    DispatchAssignment(
      id: 'dispatch_001',
      customerName: 'Samuel Nkrumah',
      serviceName: 'Emergency Plumbing',
      location: 'Airport Residential, Accra',
      urgency: JobUrgency.urgent,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: DispatchStatus.finding,
      preferredProviders: ['Provider A', 'Provider B'],
      budget: 200.0,
    ),
    DispatchAssignment(
      id: 'dispatch_002',
      customerName: 'Grace Mensah',
      serviceName: 'House Cleaning',
      location: 'East Legon, Accra',
      urgency: JobUrgency.standard,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      status: DispatchStatus.assigned,
      preferredProviders: ['Provider C', 'Provider D'],
      assignedProvider: 'Cleaning Pro Ltd',
      budget: 150.0,
    ),
  ];

  // Provider onboarding queue
  final List<ProviderOnboarding> _onboardingQueue = [
    ProviderOnboarding(
      id: 'onboard_001',
      providerName: 'Michael Osei',
      email: 'michael.osei@email.com',
      phone: '+233 24 123 4567',
      services: ['Plumbing', 'General Repairs'],
      applicationDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OnboardingStatus.documentsSubmitted,
      currentStep: 'Document Verification',
      documentsUploaded: 3,
      totalDocuments: 4,
    ),
    ProviderOnboarding(
      id: 'onboard_002',
      providerName: 'Sarah Addo',
      email: 'sarah.addo@email.com',
      phone: '+233 20 987 6543',
      services: ['Cleaning', 'Laundry'],
      applicationDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OnboardingStatus.backgroundCheck,
      currentStep: 'Background Verification',
      documentsUploaded: 4,
      totalDocuments: 4,
    ),
    ProviderOnboarding(
      id: 'onboard_003',
      providerName: 'Joseph Mensah',
      email: 'joseph.mensah@email.com',
      phone: '+233 55 246 8135',
      services: ['Electrical', 'AC Repair'],
      applicationDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OnboardingStatus.approved,
      currentStep: 'Complete',
      documentsUploaded: 4,
      totalDocuments: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _getTabCount(), vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    switch (widget.workerRole) {
      case 'support':
        return 2; // Support, Analytics
      case 'dispatch':
        return 2; // Dispatch, Analytics
      case 'onboarding':
        return 2; // Onboarding, Analytics
      default:
        return 4; // All tabs for admin workers
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getRoleTitle()} Dashboard',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Welcome, ${widget.workerName}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showNotifications,
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: _buildTabs(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildTabViews(),
      ),
    );
  }

  String _getRoleTitle() {
    switch (widget.workerRole) {
      case 'support':
        return 'Customer Support';
      case 'dispatch':
        return 'Dispatch';
      case 'onboarding':
        return 'Provider Onboarding';
      default:
        return 'Worker';
    }
  }

  List<Widget> _buildTabs() {
    switch (widget.workerRole) {
      case 'support':
        return [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent, size: 20),
                SizedBox(width: 4),
                Text('Support'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 20),
                SizedBox(width: 4),
                Text('Analytics'),
              ],
            ),
          ),
        ];
      case 'dispatch':
        return [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, size: 20),
                SizedBox(width: 4),
                Text('Dispatch'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 20),
                SizedBox(width: 4),
                Text('Analytics'),
              ],
            ),
          ),
        ];
      case 'onboarding':
        return [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 20),
                SizedBox(width: 4),
                Text('Onboarding'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 20),
                SizedBox(width: 4),
                Text('Analytics'),
              ],
            ),
          ),
        ];
      default:
        return [
          const Tab(text: 'Overview'),
          const Tab(text: 'Tasks'),
          const Tab(text: 'Analytics'),
          const Tab(text: 'Settings'),
        ];
    }
  }

  List<Widget> _buildTabViews() {
    switch (widget.workerRole) {
      case 'support':
        return [
          _buildSupportTab(),
          _buildAnalyticsTab(),
        ];
      case 'dispatch':
        return [
          _buildDispatchTab(),
          _buildAnalyticsTab(),
        ];
      case 'onboarding':
        return [
          _buildOnboardingTab(),
          _buildAnalyticsTab(),
        ];
      default:
        return [
          _buildOverviewTab(),
          _buildTasksTab(),
          _buildAnalyticsTab(),
          _buildSettingsTab(),
        ];
    }
  }

  Widget _buildSupportTab() {
    return Column(
      children: [
        // Quick stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Open Tickets',
                  '${_supportTickets.where((t) => t.status == TicketStatus.open).length}',
                  Colors.red,
                  Icons.support_agent,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'In Progress',
                  '${_supportTickets.where((t) => t.status == TicketStatus.inProgress).length}',
                  Colors.orange,
                  Icons.work,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Resolved Today',
                  '${_supportTickets.where((t) => t.status == TicketStatus.resolved).length}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ),

        // Priority filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              const Text('Filter by priority: '),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('High'),
                selected: true,
                onSelected: (selected) {},
                selectedColor: Colors.red.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Medium'),
                selected: false,
                onSelected: (selected) {},
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Low'),
                selected: false,
                onSelected: (selected) {},
              ),
            ],
          ),
        ),

        // Support tickets list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _supportTickets.length,
            itemBuilder: (context, index) {
              return _buildSupportTicketCard(_supportTickets[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportTicketCard(SupportTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTicketPriorityColor(ticket.priority).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTicketPriorityColor(ticket.priority),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.priority.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTicketStatusColor(ticket.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getTicketStatusColor(ticket.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(ticket.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.issue,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${ticket.customerName}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Assigned to: ${ticket.assignedWorker}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              if (ticket.status != TicketStatus.resolved)
                ElevatedButton(
                  onPressed: () => _handleTicket(ticket),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'Handle',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchTab() {
    return Column(
      children: [
        // Dispatch stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Finding Provider',
                  '${_dispatchAssignments.where((d) => d.status == DispatchStatus.finding).length}',
                  Colors.orange,
                  Icons.search,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Assigned',
                  '${_dispatchAssignments.where((d) => d.status == DispatchStatus.assigned).length}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Urgent Jobs',
                  '${_dispatchAssignments.where((d) => d.urgency == JobUrgency.urgent).length}',
                  Colors.red,
                  Icons.priority_high,
                ),
              ),
            ],
          ),
        ),

        // Dispatch assignments
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dispatchAssignments.length,
            itemBuilder: (context, index) {
              return _buildDispatchCard(_dispatchAssignments[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDispatchCard(DispatchAssignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: assignment.urgency == JobUrgency.urgent 
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (assignment.urgency == JobUrgency.urgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDispatchStatusColor(assignment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assignment.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getDispatchStatusColor(assignment.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(assignment.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            assignment.serviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${assignment.customerName}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  assignment.location,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Budget: GH₵${assignment.budget}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (assignment.status == DispatchStatus.finding)
                ElevatedButton(
                  onPressed: () => _assignProvider(assignment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'Assign Provider',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else if (assignment.assignedProvider != null)
                Text(
                  'Assigned to: ${assignment.assignedProvider}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingTab() {
    return Column(
      children: [
        // Onboarding stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Review',
                  '${_onboardingQueue.where((o) => o.status == OnboardingStatus.documentsSubmitted).length}',
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'In Progress',
                  '${_onboardingQueue.where((o) => o.status == OnboardingStatus.backgroundCheck || o.status == OnboardingStatus.interview).length}',
                  Colors.blue,
                  Icons.work,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  '${_onboardingQueue.where((o) => o.status == OnboardingStatus.approved).length}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ),

        // Onboarding queue
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _onboardingQueue.length,
            itemBuilder: (context, index) {
              return _buildOnboardingCard(_onboardingQueue[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingCard(ProviderOnboarding onboarding) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF2E7D32),
                child: Text(
                  onboarding.providerName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      onboarding.providerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      onboarding.services.join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getOnboardingStatusColor(onboarding.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  onboarding.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getOnboardingStatusColor(onboarding.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                onboarding.email,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                onboarding.phone,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Current Step: ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                onboarding.currentStep,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: onboarding.documentsUploaded / onboarding.totalDocuments,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${onboarding.documentsUploaded}/${onboarding.totalDocuments}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Applied ${_formatTimeAgo(onboarding.applicationDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              if (onboarding.status != OnboardingStatus.approved)
                ElevatedButton(
                  onPressed: () => _reviewProvider(onboarding),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            'Daily Metrics',
            [
              AnalyticMetric('Tasks Completed', '12', Colors.green, Icons.check_circle),
              AnalyticMetric('Response Time', '3.2 min', Colors.blue, Icons.timer),
              AnalyticMetric('Customer Satisfaction', '4.8/5', Colors.orange, Icons.star),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            'Weekly Overview',
            [
              AnalyticMetric('Total Issues Resolved', '68', Colors.purple, Icons.task_alt),
              AnalyticMetric('Average Resolution Time', '24 min', Colors.teal, Icons.schedule),
              AnalyticMetric('Success Rate', '94%', Colors.green, Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return const Center(
      child: Text('Overview Tab'),
    );
  }

  Widget _buildTasksTab() {
    return const Center(
      child: Text('Tasks Tab'),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Settings Tab'),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, List<AnalyticMetric> metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: metrics.map((metric) => Expanded(
              child: Column(
                children: [
                  Icon(metric.icon, color: metric.color, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: metric.color,
                    ),
                  ),
                  Text(
                    metric.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTicketPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.high:
        return Colors.red;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.low:
        return Colors.green;
    }
  }

  Color _getTicketStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Colors.red;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.resolved:
        return Colors.green;
    }
  }

  Color _getDispatchStatusColor(DispatchStatus status) {
    switch (status) {
      case DispatchStatus.finding:
        return Colors.orange;
      case DispatchStatus.assigned:
        return Colors.green;
      case DispatchStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getOnboardingStatusColor(OnboardingStatus status) {
    switch (status) {
      case OnboardingStatus.applied:
        return Colors.blue;
      case OnboardingStatus.documentsSubmitted:
        return Colors.orange;
      case OnboardingStatus.backgroundCheck:
        return Colors.purple;
      case OnboardingStatus.interview:
        return Colors.teal;
      case OnboardingStatus.approved:
        return Colors.green;
      case OnboardingStatus.rejected:
        return Colors.red;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Action methods
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('Recent notifications will appear here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleTicket(SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Handle Ticket: ${ticket.issue}'),
        content: const Text('This would open the ticket handling interface.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket handling initiated')),
              );
            },
            child: const Text('Handle'),
          ),
        ],
      ),
    );
  }

  void _assignProvider(DispatchAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Provider'),
        content: const Text('This would show available providers for assignment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                assignment.status = DispatchStatus.assigned;
                assignment.assignedProvider = 'Selected Provider';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Provider assigned successfully!')),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _reviewProvider(ProviderOnboarding onboarding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review: ${onboarding.providerName}'),
        content: const Text('This would open the provider review interface.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review process initiated')),
              );
            },
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}

// Data models
class SupportTicket {
  final String id;
  final String customerName;
  final String issue;
  final String description;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final String assignedWorker;
  final DateTime? resolvedAt;

  SupportTicket({
    required this.id,
    required this.customerName,
    required this.issue,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.assignedWorker,
    this.resolvedAt,
  });
}

class DispatchAssignment {
  final String id;
  final String customerName;
  final String serviceName;
  final String location;
  final JobUrgency urgency;
  final DateTime createdAt;
  DispatchStatus status;
  final List<String> preferredProviders;
  String? assignedProvider;
  final double budget;

  DispatchAssignment({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.location,
    required this.urgency,
    required this.createdAt,
    required this.status,
    required this.preferredProviders,
    this.assignedProvider,
    required this.budget,
  });
}

class ProviderOnboarding {
  final String id;
  final String providerName;
  final String email;
  final String phone;
  final List<String> services;
  final DateTime applicationDate;
  final OnboardingStatus status;
  final String currentStep;
  final int documentsUploaded;
  final int totalDocuments;

  ProviderOnboarding({
    required this.id,
    required this.providerName,
    required this.email,
    required this.phone,
    required this.services,
    required this.applicationDate,
    required this.status,
    required this.currentStep,
    required this.documentsUploaded,
    required this.totalDocuments,
  });
}

class AnalyticMetric {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  AnalyticMetric(this.title, this.value, this.color, this.icon);
}

enum TicketPriority { high, medium, low }
enum TicketStatus { open, inProgress, resolved }
enum DispatchStatus { finding, assigned, cancelled }
enum OnboardingStatus { applied, documentsSubmitted, backgroundCheck, interview, approved, rejected }
enum JobUrgency { urgent, standard, flexible }