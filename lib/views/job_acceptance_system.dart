import 'package:flutter/material.dart';
import '../models/provider.dart';

class JobAcceptanceSystem extends StatefulWidget {
  final Provider? provider;

  const JobAcceptanceSystem({super.key, this.provider});

  @override
  State<JobAcceptanceSystem> createState() => _JobAcceptanceSystemState();
}

class _JobAcceptanceSystemState extends State<JobAcceptanceSystem>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Job acceptance preferences
  bool _autoDispatchEnabled = true;
  double _autoAcceptRadius = 5.0; // km
  double _minimumJobValue = 50.0; // GH₵
  List<String> _preferredServices = ['Plumbing', 'Electrical'];
  List<String> _blacklistedAreas = [];
  
  // Available jobs for browsing
  final List<BrowsableJob> _availableJobs = [
    BrowsableJob(
      id: 'browse_001',
      title: 'Kitchen Plumbing Repair',
      customerName: 'Akosua Mensah',
      location: 'East Legon, Accra',
      description: 'Kitchen sink not draining properly. Need professional plumber to fix drainage issue and check pipes.',
      budget: 180.0,
      distance: 3.2,
      urgency: JobUrgency.standard,
      timeSlot: 'Morning (8AM - 12PM)',
      postedTime: DateTime.now().subtract(const Duration(minutes: 30)),
      applicants: 2,
      customerRating: 4.8,
      isVerifiedCustomer: true,
      requirements: ['Licensed plumber', 'Own tools', 'Insurance'],
    ),
    BrowsableJob(
      id: 'browse_002', 
      title: 'Electrical Outlet Installation',
      customerName: 'Kwame Asante',
      location: 'Tema, Greater Accra',
      description: 'Need 3 new electrical outlets installed in home office. Must be certified electrician.',
      budget: 120.0,
      distance: 8.5,
      urgency: JobUrgency.urgent,
      timeSlot: 'ASAP - Today',
      postedTime: DateTime.now().subtract(const Duration(minutes: 15)),
      applicants: 5,
      customerRating: 4.6,
      isVerifiedCustomer: true,
      requirements: ['Certified electrician', 'Same day availability'],
    ),
    BrowsableJob(
      id: 'browse_003',
      title: 'Deep House Cleaning',
      customerName: 'Ama Osei',
      location: 'Osu, Accra',
      description: 'Full house deep cleaning needed. 4-bedroom house, including kitchen and bathrooms.',
      budget: 250.0,
      distance: 4.7,
      urgency: JobUrgency.flexible,
      timeSlot: 'Weekend preferred',
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      applicants: 8,
      customerRating: 4.9,
      isVerifiedCustomer: true,
      requirements: ['Professional cleaning supplies', 'References required'],
    ),
  ];

  // Auto-dispatch queue
  final List<AutoDispatchJob> _autoDispatchQueue = [
    AutoDispatchJob(
      id: 'auto_001',
      title: 'Emergency Plumbing',
      customerName: 'Samuel Nkrumah',
      location: 'Airport Residential, Accra',
      description: 'Burst pipe in bathroom - urgent repair needed',
      offeredAmount: 200.0,
      distance: 2.1,
      timeLimit: DateTime.now().add(const Duration(minutes: 10)),
      customerRating: 4.7,
      isVerifiedCustomer: true,
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
          'Job Opportunities',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, size: 20),
                  const SizedBox(width: 4),
                  const Text('Auto-Dispatch'),
                  if (_autoDispatchQueue.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_autoDispatchQueue.length}',
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
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 20),
                  SizedBox(width: 4),
                  Text('Browse Jobs'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 4),
                  Text('Preferences'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAutoDispatchTab(),
          _buildBrowseJobsTab(),
          _buildPreferencesTab(),
        ],
      ),
    );
  }

  Widget _buildAutoDispatchTab() {
    return Column(
      children: [
        // Auto-dispatch status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _autoDispatchEnabled 
                ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _autoDispatchEnabled 
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _autoDispatchEnabled ? Icons.flash_on : Icons.flash_off,
                color: _autoDispatchEnabled ? const Color(0xFF2E7D32) : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _autoDispatchEnabled ? 'Auto-Dispatch ACTIVE' : 'Auto-Dispatch PAUSED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _autoDispatchEnabled ? const Color(0xFF2E7D32) : Colors.grey,
                      ),
                    ),
                    Text(
                      _autoDispatchEnabled 
                          ? 'Jobs matching your criteria will be sent automatically'
                          : 'Enable to receive automatic job offers',
                      style: TextStyle(
                        fontSize: 14,
                        color: _autoDispatchEnabled ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoDispatchEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoDispatchEnabled = value;
                  });
                },
                activeColor: const Color(0xFF2E7D32),
              ),
            ],
          ),
        ),

        // Auto-dispatch queue
        Expanded(
          child: _autoDispatchQueue.isEmpty
              ? _buildEmptyAutoDispatchState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _autoDispatchQueue.length,
                  itemBuilder: (context, index) {
                    return _buildAutoDispatchCard(_autoDispatchQueue[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyAutoDispatchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _autoDispatchEnabled ? Icons.schedule : Icons.flash_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _autoDispatchEnabled 
                ? 'Waiting for matching jobs...'
                : 'Auto-dispatch is disabled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _autoDispatchEnabled
                ? 'Jobs matching your preferences will appear here'
                : 'Enable auto-dispatch to receive automatic job offers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (!_autoDispatchEnabled) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _autoDispatchEnabled = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Enable Auto-Dispatch'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoDispatchCard(AutoDispatchJob job) {
    final timeRemaining = job.timeLimit.difference(DateTime.now());
    final minutesLeft = timeRemaining.inMinutes;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with urgency indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AUTO-DISPATCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: minutesLeft <= 5 ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${minutesLeft}m left',
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
          
          const SizedBox(height: 8),
          
          // Location and distance
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.location} • ${job.distance}km away',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            job.description,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Customer rating and verification
          Row(
            children: [
              if (job.isVerifiedCustomer) ...[
                const Icon(Icons.verified, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Verified',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
                const SizedBox(width: 12),
              ],
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${job.customerRating}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GH₵${job.offeredAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineAutoDispatch(job),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _acceptAutoDispatch(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Accept Job',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseJobsTab() {
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs by service or location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _showFilterOptions,
                icon: const Icon(Icons.tune),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Job count and sorting
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Text(
                '${_availableJobs.length} jobs available',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showSortOptions,
                icon: const Icon(Icons.sort, size: 16),
                label: const Text('Sort'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        
        // Jobs list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _availableJobs.length,
            itemBuilder: (context, index) {
              return _buildBrowsableJobCard(_availableJobs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrowsableJobCard(BrowsableJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: job.urgency == JobUrgency.urgent 
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
          // Header with urgency and applicants
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (job.urgency == JobUrgency.urgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Customer and verification
          Row(
            children: [
              Text(
                job.customerName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (job.isVerifiedCustomer) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Colors.blue, size: 16),
              ],
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${job.applicants} applied',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Location and distance
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.location} • ${job.distance}km away',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            job.description,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Requirements (if any)
          if (job.requirements.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: job.requirements.take(2).map((req) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Bottom row with ratings, time slot, budget, and action
          Row(
            children: [
              // Customer rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${job.customerRating}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Time slot
              Text(
                job.timeSlot,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              
              const Spacer(),
              
              // Budget
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GH₵${job.budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Apply button
              ElevatedButton(
                onPressed: () => _applyForJob(job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Posted time
          Text(
            'Posted ${_formatTimeAgo(job.postedTime)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto-dispatch settings section
          _buildPreferenceSection(
            'Auto-Dispatch Settings',
            Icons.settings,
            [
              _buildSwitchPreference(
                'Enable Auto-Dispatch',
                'Automatically receive job offers matching your criteria',
                _autoDispatchEnabled,
                (value) => setState(() => _autoDispatchEnabled = value),
              ),
              
              _buildSliderPreference(
                'Maximum Distance',
                'Jobs within ${_autoAcceptRadius.round()}km radius',
                _autoAcceptRadius,
                1.0,
                20.0,
                (value) => setState(() => _autoAcceptRadius = value),
                '${_autoAcceptRadius.round()}km',
              ),
              
              _buildSliderPreference(
                'Minimum Job Value',
                'Only accept jobs worth GH₵${_minimumJobValue.round()} or more',
                _minimumJobValue,
                25.0,
                500.0,
                (value) => setState(() => _minimumJobValue = value),
                'GH₵${_minimumJobValue.round()}',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Service preferences
          _buildPreferenceSection(
            'Service Preferences',
            Icons.work,
            [
              _buildServiceSelection(),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Location preferences
          _buildPreferenceSection(
            'Location Preferences',
            Icons.location_on,
            [
              _buildLocationPreferences(),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notification settings
          _buildPreferenceSection(
            'Notifications',
            Icons.notifications,
            [
              _buildSwitchPreference(
                'Push Notifications',
                'Get notified about new job opportunities',
                true,
                (value) {},
              ),
              _buildSwitchPreference(
                'SMS Notifications',
                'Receive urgent job offers via SMS',
                false,
                (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(String title, IconData icon, List<Widget> children) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchPreference(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderPreference(String title, String subtitle, double value, double min, double max, ValueChanged<double> onChanged, String displayValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / (max > 100 ? 25 : 1)).round(),
            activeColor: const Color(0xFF2E7D32),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    final availableServices = [
      'Plumbing', 'Electrical', 'Cleaning', 'Gardening', 
      'Carpentry', 'Painting', 'AC Repair', 'Appliance Repair'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your service specialties',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Auto-dispatch will only send jobs for selected services',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableServices.map((service) {
              final isSelected = _preferredServices.contains(service);
              return FilterChip(
                label: Text(service),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _preferredServices.add(service);
                    } else {
                      _preferredServices.remove(service);
                    }
                  });
                },
                selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF2E7D32),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPreferences() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Blacklisted Areas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addBlacklistedArea,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Area'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Areas you prefer not to work in',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          if (_blacklistedAreas.isEmpty)
            Text(
              'No blacklisted areas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _blacklistedAreas.map((area) => Chip(
                label: Text(area),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _blacklistedAreas.remove(area);
                  });
                },
              )).toList(),
            ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Placeholder(child: Text('Filter options')),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Placeholder(child: Text('Sort options')),
    );
  }

  void _addBlacklistedArea() {
    showDialog(
      context: context,
      builder: (context) {
        String newArea = '';
        return AlertDialog(
          title: const Text('Add Blacklisted Area'),
          content: TextField(
            onChanged: (value) => newArea = value,
            decoration: const InputDecoration(
              hintText: 'Enter area name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newArea.isNotEmpty) {
                  setState(() {
                    _blacklistedAreas.add(newArea);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _acceptAutoDispatch(AutoDispatchJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Auto-Dispatch Job'),
        content: Text('Accept "${job.title}" for GH₵${job.offeredAmount}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _autoDispatchQueue.remove(job);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job accepted! Check your dashboard for details.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _declineAutoDispatch(AutoDispatchJob job) {
    setState(() {
      _autoDispatchQueue.remove(job);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job declined')),
    );
  }

  void _applyForJob(BrowsableJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply for "${job.title}"?'),
            const SizedBox(height: 8),
            Text(
              'Budget: GH₵${job.budget}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${job.applicants} other providers have applied'),
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
              setState(() {
                job.applicants++;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application submitted! You\'ll be notified if selected.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Apply'),
          ),
        ],
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
}

// Data models for the job acceptance system
class AutoDispatchJob {
  final String id;
  final String title;
  final String customerName;
  final String location;
  final String description;
  final double offeredAmount;
  final double distance;
  final DateTime timeLimit;
  final double customerRating;
  final bool isVerifiedCustomer;

  AutoDispatchJob({
    required this.id,
    required this.title,
    required this.customerName,
    required this.location,
    required this.description,
    required this.offeredAmount,
    required this.distance,
    required this.timeLimit,
    required this.customerRating,
    required this.isVerifiedCustomer,
  });
}

class BrowsableJob {
  final String id;
  final String title;
  final String customerName;
  final String location;
  final String description;
  final double budget;
  final double distance;
  final JobUrgency urgency;
  final String timeSlot;
  final DateTime postedTime;
  int applicants;
  final double customerRating;
  final bool isVerifiedCustomer;
  final List<String> requirements;

  BrowsableJob({
    required this.id,
    required this.title,
    required this.customerName,
    required this.location,
    required this.description,
    required this.budget,
    required this.distance,
    required this.urgency,
    required this.timeSlot,
    required this.postedTime,
    required this.applicants,
    required this.customerRating,
    required this.isVerifiedCustomer,
    required this.requirements,
  });
}

enum JobUrgency {
  urgent,
  standard,
  flexible,
}