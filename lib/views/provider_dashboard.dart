import 'package:flutter/material.dart';
import '../models/provider.dart';
import '../models/user_role.dart';
import 'calendar.dart';
import 'provider_profile.dart';
import 'unified_customer_home.dart';
import 'job_acceptance_system.dart';
import 'job_management_workflow.dart';
import 'earnings_payout_system.dart';
import 'ratings_reviews_system.dart';
import 'provider_quote_submission_screen.dart';

class ProviderDashboard extends StatefulWidget {
  final Provider? provider;

  const ProviderDashboard({super.key, this.provider});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _selectedIndex = 0;
  bool isLoading = false;
  
  // Mock provider service types - in real app, get from provider profile
  final List<String> providerServices = [
    'House Cleaning',
    'Plumbing',
    'Electrical Services'
  ];

  // Mock job requests data with photos/videos
  final List<Map<String, dynamic>> _newJobRequests = [
    {
      'id': 'job_001',
      'customerName': 'Kofi Asante',
      'serviceName': 'Plumbing',
      'location': 'East Legon, Accra',
      'urgency': 'Standard',
      'description': 'Fix leaking kitchen pipe and check bathroom faucets. Water is dripping continuously and there\'s some water damage under the sink.',
      'budget': 250.0,
      'timeSlot': 'Morning (8AM - 12PM)',
      'distance': 2.5,
      'postedTime': DateTime.now().subtract(const Duration(minutes: 15)),
      'images': ['kitchen_leak_1.jpg', 'under_sink_damage.jpg', 'bathroom_faucet.jpg'],
      'videos': ['leak_demonstration.mp4'],
      'customerPhone': '+233 24 123 4567',
      'additionalNotes': 'Kitchen is on the ground floor. Parking available.',
    },
    {
      'id': 'job_002', 
      'customerName': 'Ama Osei',
      'serviceName': 'Electrical Services',
      'location': 'Tema, Greater Accra',
      'urgency': 'Urgent',
      'description': 'Power outage in living room - need immediate fix. All outlets stopped working suddenly.',
      'budget': 180.0,
      'timeSlot': 'ASAP',
      'distance': 8.2,
      'postedTime': DateTime.now().subtract(const Duration(minutes: 8)),
      'images': ['electrical_panel.jpg', 'living_room_outlets.jpg'],
      'videos': [],
      'customerPhone': '+233 26 234 5678',
      'additionalNotes': 'Safety concern - children in the house.',
    },
    {
      'id': 'job_003',
      'customerName': 'Grace Mensah',
      'serviceName': 'House Cleaning',
      'location': 'Airport Residential, Accra',
      'urgency': 'Standard',
      'description': 'Deep cleaning needed for 3-bedroom house before family visit. Focus on kitchen, bathrooms, and living areas.',
      'budget': 300.0,
      'timeSlot': 'Weekend (Saturday)',
      'distance': 4.1,
      'postedTime': DateTime.now().subtract(const Duration(hours: 2)),
      'images': ['house_overview.jpg', 'kitchen_state.jpg', 'bathroom_1.jpg', 'bathroom_2.jpg'],
      'videos': ['house_walkthrough.mp4'],
      'customerPhone': '+233 25 345 6789',
      'additionalNotes': 'House is fully furnished. Cleaning supplies can be provided.',
    },
  ];

  final List<JobBooking> _upcomingJobs = [
    JobBooking(
      id: 'booking_001',
      customerName: 'Kwame Nkrumah',
      serviceName: 'Cleaning',
      location: 'Osu, Accra',
      scheduledDate: DateTime.now().add(const Duration(hours: 3)),
      status: JobStatus.confirmed,
      amount: 120.0,
      notes: 'Deep cleaning for 3-bedroom apartment',
    ),
    JobBooking(
      id: 'booking_002',
      customerName: 'Abena Mensah',
      serviceName: 'Gardening',
      location: 'Adenta, Accra',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      status: JobStatus.scheduled,
      amount: 200.0,
      notes: 'Lawn mowing and hedge trimming',
    ),
  ];

  final double _todayEarnings = 340.0;
  final double _weeklyEarnings = 1250.0;
  final double _monthlyEarnings = 4800.0;
  final int _unreadMessages = 3;
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              widget.provider?.name ?? 'Provider',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _navigateToMessages,
                icon: const Icon(Icons.message),
              ),
              if (_unreadMessages > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadMessages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderCalendar(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'switch':
                  _switchToCustomer();
                  break;
                case 'signout':
                  _signOut();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'switch',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, color: Color(0xFF006B3C)),
                    SizedBox(width: 8),
                    Text('Switch to Customer'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _getSelectedWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return JobAcceptanceSystem(provider: widget.provider);
      case 2:
        return const ProviderCalendar();
      case 3:
        return EarningsPayoutSystem(provider: widget.provider);
      case 4:
        return const ProviderProfile();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildEarningsSummary(),
          const SizedBox(height: 20),
          _buildNewJobRequests(),
          const SizedBox(height: 20),
          _buildUpcomingJobs(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isVerified = widget.provider?.isVerified ?? true;
    final rating = widget.provider?.rating ?? 4.8;
    final completedJobs = widget.provider?.completedJobs ?? 15;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVerified ? 'Verified Provider' : 'Pending Verification',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isAvailable ? 'Available for jobs' : 'Currently offline',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (value) => _toggleAvailability(value),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Rating',
                  '${rating.toStringAsFixed(1)} ⭐',
                  Icons.star,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  '$completedJobs',
                  Icons.check_circle,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Response Time',
                  '15 mins',
                  Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Accept Jobs',
                Icons.work_outline,
                const Color(0xFF2E7D32),
                () => setState(() => _selectedIndex = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'My Jobs',
                Icons.work,
                Colors.indigo,
                _navigateToJobManagement,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Reviews',
                Icons.star,
                Colors.amber,
                _navigateToReviews,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Earnings',
                Icons.attach_money,
                Colors.orange,
                () => setState(() => _selectedIndex = 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary() {
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
          const Text(
            'Earnings Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEarningItem('Today', 'GH₵$_todayEarnings', Colors.green),
              ),
              Expanded(
                child: _buildEarningItem('This Week', 'GH₵$_weeklyEarnings', Colors.blue),
              ),
              Expanded(
                child: _buildEarningItem('This Month', 'GH₵$_monthlyEarnings', Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(String period, String amount, Color color) {
    return Column(
      children: [
        Text(
          period,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNewJobRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Job Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_newJobRequests.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_newJobRequests.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_newJobRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No new job requests',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: _newJobRequests.map((job) => _buildJobRequestCard(job)).toList(),
          ),
      ],
    );
  }

  Widget _buildJobRequestCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: job['urgency'] == 'Urgent' ? Colors.red.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job['serviceName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (job['urgency'] == 'Urgent')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job['customerName'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job['location']} • ${job['distance']}km away',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job['description'],
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Budget: GH₵${job['budget']}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                job['timeSlot'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(job['postedTime']),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineJob(job),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitQuote(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Quote'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Jobs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_upcomingJobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No upcoming jobs scheduled',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: _upcomingJobs.map((job) => _buildUpcomingJobCard(job)).toList(),
          ),
      ],
    );
  }

  Widget _buildUpcomingJobCard(JobBooking job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getJobStatusColor(job.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getJobStatusColor(job.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.customerName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(job.scheduledDate),
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Text(
                'GH₵${job.amount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (job.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              job.notes,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }


  void _switchToCustomer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch to Customer'),
        content: const Text('Do you want to switch to customer mode? You can switch back to provider mode anytime from your profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to unified customer home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UnifiedCustomerHomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your HomeLinkGH provider account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear any stored authentication data here
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully signed out'),
                  backgroundColor: Color(0xFF006B3C),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(bool isAvailable) {
    setState(() {
      _isAvailable = isAvailable;
    });
  }

  void _navigateToMessages() {
    Navigator.pushNamed(context, '/messages');
  }

  void _navigateToJobManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobManagementWorkflow(provider: widget.provider),
      ),
    );
  }

  void _navigateToReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingsReviewsSystem(provider: widget.provider),
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
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

  Color _getJobStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.confirmed:
        return Colors.green;
      case JobStatus.scheduled:
        return Colors.blue;
      case JobStatus.inProgress:
        return Colors.orange;
      case JobStatus.completed:
        return Colors.purple;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }

  void _submitQuote(Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderQuoteSubmissionScreen(jobRequest: job),
      ),
    ).then((result) {
      if (result != null) {
        // Quote was submitted successfully
        setState(() {
          _newJobRequests.remove(job);
        });
      }
    });
  }

  void _declineJob(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Job Request'),
        content: Text('Are you sure you want to decline this job from ${job['customerName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _newJobRequests.remove(job);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job request declined')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class JobRequest {
  final String id;
  final String customerName;
  final String serviceName;
  final String location;
  final String urgency;
  final String description;
  final double budget;
  final String timeSlot;
  final double distance;
  final DateTime postedTime;

  JobRequest({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.location,
    required this.urgency,
    required this.description,
    required this.budget,
    required this.timeSlot,
    required this.distance,
    required this.postedTime,
  });
}

class JobBooking {
  final String id;
  final String customerName;
  final String serviceName;
  final String location;
  final DateTime scheduledDate;
  final JobStatus status;
  final double amount;
  final String notes;

  JobBooking({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.location,
    required this.scheduledDate,
    required this.status,
    required this.amount,
    required this.notes,
  });
}

enum JobStatus {
  confirmed,
  scheduled,
  inProgress,
  completed,
  cancelled,
}