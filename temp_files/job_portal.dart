import 'package:flutter/material.dart';

class JobPortalScreen extends StatefulWidget {
  const JobPortalScreen({super.key});

  @override
  State<JobPortalScreen> createState() => _JobPortalScreenState();
}

class _JobPortalScreenState extends State<JobPortalScreen> {
  String selectedCategory = 'all';
  final List<String> jobCategories = [
    'all',
    'Home Services',
    'Delivery',
    'Technology',
    'Healthcare',
    'Education',
    'Construction',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeJobs();
  }

  Future<void> _initializeJobs() async {
    try {
      // Check if jobs already exist
      final existingJobs = await FirebaseService.jobs.limit(1).get();
      if (existingJobs.docs.isNotEmpty) return;

      // Create sample jobs
      final sampleJobs = [
        {
          'title': 'House Cleaner',
          'category': 'Home Services',
          'location': 'Accra, Ghana',
          'salaryMin': 800.0,
          'salaryMax': 1200.0,
          'currency': 'GHS',
          'type': 'Part-time',
          'description': 'Experienced house cleaner needed for residential properties in Accra. Must be reliable, thorough, and have attention to detail.',
          'requirements': ['2+ years experience', 'Own cleaning supplies preferred', 'References required'],
          'benefits': ['Flexible hours', 'Weekly pay', 'Transportation allowance'],
          'postedBy': 'HomeLinkGH Admin',
          'contactEmail': 'jobs@homelink.gh',
          'contactPhone': '+233 24 123 4567',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Delivery Driver',
          'category': 'Delivery',
          'location': 'Kumasi, Ghana',
          'salaryMin': 1000.0,
          'salaryMax': 1500.0,
          'currency': 'GHS',
          'type': 'Full-time',
          'description': 'Reliable delivery driver needed with own motorcycle or car. Must know Kumasi roads well and have good customer service skills.',
          'requirements': ['Valid driving license', 'Own vehicle', '1+ years delivery experience'],
          'benefits': ['Fuel allowance', 'Health insurance', 'Performance bonuses'],
          'postedBy': 'HomeLinkGH Admin',
          'contactEmail': 'jobs@homelink.gh',
          'contactPhone': '+233 24 123 4567',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Plumber',
          'category': 'Home Services',
          'location': 'Tema, Ghana',
          'salaryMin': 1200.0,
          'salaryMax': 2000.0,
          'currency': 'GHS',
          'type': 'Contract',
          'description': 'Skilled plumber needed for residential and commercial projects. Must have experience with modern plumbing systems.',
          'requirements': ['5+ years experience', 'Professional certification', 'Own tools'],
          'benefits': ['Project-based pay', 'Flexible schedule', 'Training opportunities'],
          'postedBy': 'HomeLinkGH Admin',
          'contactEmail': 'jobs@homelink.gh',
          'contactPhone': '+233 24 123 4567',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Gardener/Landscaper',
          'category': 'Home Services',
          'location': 'East Legon, Accra',
          'salaryMin': 900.0,
          'salaryMax': 1400.0,
          'currency': 'GHS',
          'type': 'Part-time',
          'description': 'Professional gardener needed for high-end residential properties. Experience with landscape design and maintenance required.',
          'requirements': ['3+ years gardening experience', 'Knowledge of local plants', 'Physical fitness'],
          'benefits': ['Flexible hours', 'Equipment provided', 'Growth opportunities'],
          'postedBy': 'HomeLinkGH Admin',
          'contactEmail': 'jobs@homelink.gh',
          'contactPhone': '+233 24 123 4567',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final job in sampleJobs) {
        await FirebaseService.jobs.add(job);
      }
    } catch (e) {
      print('Error initializing jobs: $e');
    }
  }

  Widget _buildJobCard(DocumentSnapshot job) {
    final data = job.data() as Map<String, dynamic>;
    final salaryMin = data['salaryMin']?.toDouble() ?? 0.0;
    final salaryMax = data['salaryMax']?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data['title'] ?? 'Job Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      data['type'] ?? 'Full-time',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    data['location'] ?? 'Location not specified',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.payments, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'GH₵${salaryMin.toStringAsFixed(0)} - GH₵${salaryMax.toStringAsFixed(0)}/month',
                    style: const TextStyle(
                      color: Color(0xFF006B3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data['description'] ?? 'No description available',
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'By ${data['postedBy'] ?? 'HomeLinkGH'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetails(DocumentSnapshot job) {
    final data = job.data() as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title'] ?? 'Job Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Location', data['location'] ?? 'Not specified'),
              _buildDetailSection('Type', data['type'] ?? 'Full-time'),
              _buildDetailSection('Salary', 
                'GH₵${(data['salaryMin']?.toDouble() ?? 0.0).toStringAsFixed(0)} - GH₵${(data['salaryMax']?.toDouble() ?? 0.0).toStringAsFixed(0)}/month'),
              _buildDetailSection('Description', data['description'] ?? 'No description'),
              if (data['requirements'] != null) ...[
                const SizedBox(height: 16),
                const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...((data['requirements'] as List).map((req) => Text('• $req'))),
              ],
              if (data['benefits'] != null) ...[
                const SizedBox(height: 16),
                const Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...((data['benefits'] as List).map((benefit) => Text('• $benefit'))),
              ],
              const SizedBox(height: 16),
              _buildDetailSection('Contact Email', data['contactEmail'] ?? 'jobs@homelink.gh'),
              _buildDetailSection('Contact Phone', data['contactPhone'] ?? '+233 24 123 4567'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyForJob(job.id, data);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _applyForJob(String jobId, Map<String, dynamic> jobData) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to apply for jobs')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final messageController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Apply for Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Applying for: ${jobData['title']}'),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Cover message (optional)',
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
              onPressed: () async {
                try {
                  await FirebaseService.jobApplications.add({
                    'jobId': jobId,
                    'userId': user.uid,
                    'userEmail': user.email,
                    'message': messageController.text,
                    'status': 'pending',
                    'appliedAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting application: $e')),
                  );
                }
              },
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Portal'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            itemBuilder: (context) => jobCategories.map((category) {
              return PopupMenuItem(
                value: category,
                child: Text(category == 'all' ? 'All Categories' : category),
              );
            }).toList(),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: selectedCategory == 'all'
            ? FirebaseService.jobs
                .where('isActive', isEqualTo: true)
                .orderBy('createdAt', descending: true)
                .snapshots()
            : FirebaseService.jobs
                .where('isActive', isEqualTo: true)
                .where('category', isEqualTo: selectedCategory)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final jobs = snapshot.data?.docs ?? [];

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    selectedCategory == 'all' 
                        ? 'No jobs available'
                        : 'No jobs in $selectedCategory',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for new opportunities',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (selectedCategory != 'all')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                  child: Text(
                    'Showing jobs in: $selectedCategory',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return _buildJobCard(jobs[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}