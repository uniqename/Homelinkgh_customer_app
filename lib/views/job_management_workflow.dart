import 'package:flutter/material.dart';
import '../models/provider.dart';

class JobManagementWorkflow extends StatefulWidget {
  final Provider? provider;

  const JobManagementWorkflow({super.key, this.provider});

  @override
  State<JobManagementWorkflow> createState() => _JobManagementWorkflowState();
}

class _JobManagementWorkflowState extends State<JobManagementWorkflow>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample jobs for different phases
  final List<JobWorkflow> _preJobPhaseJobs = [
    JobWorkflow(
      id: 'pre_001',
      title: 'Kitchen Plumbing Repair',
      customerName: 'Akosua Mensah',
      customerPhone: '+233 24 123 4567',
      location: 'East Legon, Accra',
      address: 'House 15, Boundary Road, East Legon',
      scheduledDate: DateTime.now().add(const Duration(hours: 4)),
      description: 'Kitchen sink not draining properly. Need professional plumber to fix drainage issue.',
      amount: 180.0,
      phase: JobPhase.preJob,
      status: JobWorkflowStatus.confirmed,
      customerRating: 4.8,
      isVerifiedCustomer: true,
      requirements: ['Licensed plumber', 'Own tools'],
      specialInstructions: 'Please call 30 minutes before arrival. Gate code is 1234.',
      estimatedDuration: '2-3 hours',
    ),
    JobWorkflow(
      id: 'pre_002',
      title: 'Electrical Outlet Installation',
      customerName: 'Kwame Asante',
      customerPhone: '+233 20 987 6543',
      location: 'Tema, Greater Accra',
      address: 'Block A, Apt 12, Community 25, Tema',
      scheduledDate: DateTime.now().add(const Duration(hours: 6)),
      description: 'Need 3 new electrical outlets installed in home office.',
      amount: 120.0,
      phase: JobPhase.preJob,
      status: JobWorkflowStatus.pendingConfirmation,
      customerRating: 4.6,
      isVerifiedCustomer: true,
      requirements: ['Certified electrician'],
      specialInstructions: 'Customer works from home. Please schedule during lunch break (12-1 PM).',
      estimatedDuration: '1-2 hours',
    ),
  ];

  final List<JobWorkflow> _activeJobs = [
    JobWorkflow(
      id: 'active_001',
      title: 'Deep House Cleaning',
      customerName: 'Ama Osei',
      customerPhone: '+233 55 234 5678',
      location: 'Osu, Accra',
      address: '22 Castle Road, Osu',
      scheduledDate: DateTime.now().subtract(const Duration(minutes: 30)),
      description: 'Full house deep cleaning. 4-bedroom house, including kitchen and bathrooms.',
      amount: 250.0,
      phase: JobPhase.duringJob,
      status: JobWorkflowStatus.inProgress,
      customerRating: 4.9,
      isVerifiedCustomer: true,
      requirements: ['Professional cleaning supplies'],
      specialInstructions: 'Focus on kitchen and master bathroom. Pet-friendly products only.',
      estimatedDuration: '4-5 hours',
      startTime: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  final List<JobWorkflow> _completedJobs = [
    JobWorkflow(
      id: 'completed_001',
      title: 'Garden Maintenance',
      customerName: 'Samuel Nkrumah',
      customerPhone: '+233 26 345 6789',
      location: 'Airport Residential, Accra',
      address: 'Villa 8, Airport Hills',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Lawn mowing, hedge trimming, and general garden maintenance.',
      amount: 200.0,
      phase: JobPhase.postJob,
      status: JobWorkflowStatus.completed,
      customerRating: 4.7,
      isVerifiedCustomer: true,
      requirements: ['Own equipment'],
      specialInstructions: 'Water plants after maintenance.',
      estimatedDuration: '3 hours',
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      endTime: DateTime.now().subtract(const Duration(days: 1)),
      actualDuration: '2h 45m',
      customerFeedback: 'Excellent work! Very professional and thorough.',
      customerRatedService: 5.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Job Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: [
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(height: 2),
                  const Text('Before', style: TextStyle(fontSize: 12)),
                  if (_preJobPhaseJobs.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_preJobPhaseJobs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work, size: 20),
                  const SizedBox(height: 2),
                  const Text('During', style: TextStyle(fontSize: 12)),
                  if (_activeJobs.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_activeJobs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 20),
                  const SizedBox(height: 2),
                  const Text('After', style: TextStyle(fontSize: 12)),
                  if (_completedJobs.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_completedJobs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPreJobPhase(),
          _buildDuringJobPhase(),
          _buildPostJobPhase(),
        ],
      ),
    );
  }

  Widget _buildPreJobPhase() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Phase description
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pre-Job Phase',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Prepare for upcoming jobs: contact customers, confirm details, plan your route.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Jobs list
        if (_preJobPhaseJobs.isEmpty)
          _buildEmptyState(
            'No upcoming jobs',
            'New job bookings will appear here',
            Icons.schedule,
            Colors.orange,
          )
        else
          ..._preJobPhaseJobs.map((job) => _buildPreJobCard(job)).toList(),
      ],
    );
  }

  Widget _buildPreJobCard(JobWorkflow job) {
    final timeUntilJob = job.scheduledDate.difference(DateTime.now());
    final hoursUntil = timeUntilJob.inHours;
    final minutesUntil = timeUntilJob.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with status and time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(job.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(job.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(job.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: hoursUntil <= 2 ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  hoursUntil > 0 ? '${hoursUntil}h ${minutesUntil}m' : '${minutesUntil}m',
                  style: TextStyle(
                    color: hoursUntil <= 2 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title and customer
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      job.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (job.isVerifiedCustomer) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${job.customerRating}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Scheduled time and location
                _buildInfoRow(Icons.schedule, 'Scheduled', _formatDateTime(job.scheduledDate)),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'Location', job.address),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 'Duration', job.estimatedDuration),

                const SizedBox(height: 12),

                // Special instructions
                if (job.specialInstructions.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            job.specialInstructions,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Amount
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'GH₵${job.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callCustomer(job),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _getDirections(job),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startJob(job),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuringJobPhase() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Phase description
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.work, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Jobs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'Track progress, communicate with customers, and manage ongoing work.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Jobs list
        if (_activeJobs.isEmpty)
          _buildEmptyState(
            'No active jobs',
            'Started jobs will appear here for tracking',
            Icons.work,
            Colors.red,
          )
        else
          ..._activeJobs.map((job) => _buildActiveJobCard(job)).toList(),
      ],
    );
  }

  Widget _buildActiveJobCard(JobWorkflow job) {
    final timeWorked = DateTime.now().difference(job.startTime!);
    final hoursWorked = timeWorked.inHours;
    final minutesWorked = timeWorked.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
          // Header with active status and timer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '${hoursWorked}h ${minutesWorked}m',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title and customer
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                // Started time and location
                _buildInfoRow(Icons.play_arrow, 'Started', _formatTime(job.startTime!)),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'Location', job.location),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.attach_money, 'Amount', 'GH₵${job.amount.toStringAsFixed(0)}'),

                const SizedBox(height: 16),

                // Progress tracking section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Job Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.6, // Mock progress
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '60% Complete - Kitchen drainage fixed, checking pipes',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callCustomer(job),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call Customer'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateProgress(job),
                        icon: const Icon(Icons.update, size: 16),
                        label: const Text('Update'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _completeJob(job),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Complete Job'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostJobPhase() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Phase description
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed Jobs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Review feedback, request payment, and follow up with customers.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Jobs list
        if (_completedJobs.isEmpty)
          _buildEmptyState(
            'No completed jobs',
            'Recently completed jobs will appear here',
            Icons.check_circle,
            Colors.green,
          )
        else
          ..._completedJobs.map((job) => _buildCompletedJobCard(job)).toList(),
      ],
    );
  }

  Widget _buildCompletedJobCard(JobWorkflow job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with completed status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Completed ${_formatTimeAgo(job.endTime!)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title and customer
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                // Completion details
                _buildInfoRow(Icons.access_time, 'Duration', job.actualDuration ?? 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.attach_money, 'Amount', 'GH₵${job.amount.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today, 'Completed', _formatDateTime(job.endTime!)),

                const SizedBox(height: 16),

                // Customer feedback
                if (job.customerFeedback != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Customer Feedback',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Spacer(),
                            if (job.customerRatedService != null) ...[
                              Row(
                                children: List.generate(5, (index) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < job.customerRatedService! 
                                      ? Colors.amber 
                                      : Colors.grey[300],
                                )),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.customerFeedback!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Earnings display
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Earned GH₵${job.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewJobDetails(job),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactForFollowUp(job),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Follow Up'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(icon, size: 64, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(JobWorkflowStatus status) {
    switch (status) {
      case JobWorkflowStatus.confirmed:
        return Colors.green;
      case JobWorkflowStatus.pendingConfirmation:
        return Colors.orange;
      case JobWorkflowStatus.inProgress:
        return Colors.red;
      case JobWorkflowStatus.completed:
        return Colors.green;
      case JobWorkflowStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(JobWorkflowStatus status) {
    switch (status) {
      case JobWorkflowStatus.confirmed:
        return 'CONFIRMED';
      case JobWorkflowStatus.pendingConfirmation:
        return 'PENDING';
      case JobWorkflowStatus.inProgress:
        return 'IN PROGRESS';
      case JobWorkflowStatus.completed:
        return 'COMPLETED';
      case JobWorkflowStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
    } else if (difference.inDays == -1) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
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
  void _callCustomer(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Customer'),
        content: Text('Call ${job.customerName} at ${job.customerPhone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app, launch phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${job.customerName}...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _getDirections(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Directions'),
        content: Text('Open directions to ${job.address}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app, launch maps with directions
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening directions...')),
              );
            },
            child: const Text('Open Maps'),
          ),
        ],
      ),
    );
  }

  void _startJob(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Job'),
        content: Text('Start working on "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                job.phase = JobPhase.duringJob;
                job.status = JobWorkflowStatus.inProgress;
                job.startTime = DateTime.now();
                _preJobPhaseJobs.remove(job);
                _activeJobs.add(job);
              });
              _tabController.animateTo(1); // Switch to "During" tab
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job started! Track your progress in the During tab.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _updateProgress(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) {
        String progressUpdate = '';
        return AlertDialog(
          title: const Text('Update Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Send progress update to customer:'),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => progressUpdate = value,
                decoration: const InputDecoration(
                  hintText: 'e.g., "50% complete - fixed main pipe"',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (progressUpdate.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress update sent to customer'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Send Update'),
            ),
          ],
        );
      },
    );
  }

  void _completeJob(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Job'),
        content: Text('Mark "${job.title}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                job.phase = JobPhase.postJob;
                job.status = JobWorkflowStatus.completed;
                job.endTime = DateTime.now();
                job.actualDuration = '${DateTime.now().difference(job.startTime!).inHours}h ${DateTime.now().difference(job.startTime!).inMinutes % 60}m';
                _activeJobs.remove(job);
                _completedJobs.insert(0, job);
              });
              _tabController.animateTo(2); // Switch to "After" tab
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job completed! Check the After tab for follow-up.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _viewJobDetails(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${job.customerName}'),
              Text('Location: ${job.location}'),
              Text('Amount: GH₵${job.amount}'),
              Text('Duration: ${job.actualDuration ?? job.estimatedDuration}'),
              if (job.customerFeedback != null) ...[
                const SizedBox(height: 8),
                const Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(job.customerFeedback!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactForFollowUp(JobWorkflow job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Follow Up'),
        content: Text('Contact ${job.customerName} for follow-up?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contacting ${job.customerName} for follow-up...')),
              );
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}

// Data models
class JobWorkflow {
  final String id;
  final String title;
  final String customerName;
  final String customerPhone;
  final String location;
  final String address;
  final DateTime scheduledDate;
  final String description;
  final double amount;
  JobPhase phase;
  JobWorkflowStatus status;
  final double customerRating;
  final bool isVerifiedCustomer;
  final List<String> requirements;
  final String specialInstructions;
  final String estimatedDuration;
  DateTime? startTime;
  DateTime? endTime;
  String? actualDuration;
  String? customerFeedback;
  double? customerRatedService;

  JobWorkflow({
    required this.id,
    required this.title,
    required this.customerName,
    required this.customerPhone,
    required this.location,
    required this.address,
    required this.scheduledDate,
    required this.description,
    required this.amount,
    required this.phase,
    required this.status,
    required this.customerRating,
    required this.isVerifiedCustomer,
    required this.requirements,
    required this.specialInstructions,
    required this.estimatedDuration,
    this.startTime,
    this.endTime,
    this.actualDuration,
    this.customerFeedback,
    this.customerRatedService,
  });
}

enum JobPhase {
  preJob,
  duringJob,
  postJob,
}

enum JobWorkflowStatus {
  confirmed,
  pendingConfirmation,
  inProgress,
  completed,
  cancelled,
}