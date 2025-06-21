import 'package:flutter/material.dart';
import '../services/job_service.dart';

class JobPortalScreen extends StatefulWidget {
  const JobPortalScreen({super.key});

  @override
  State<JobPortalScreen> createState() => _JobPortalScreenState();
}

class _JobPortalScreenState extends State<JobPortalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> availableJobs = [];
  List<Map<String, dynamic>> myApplications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobData();
  }

  Future<void> _loadJobData() async {
    setState(() => isLoading = true);
    
    final jobs = await JobService.getAvailableJobs();
    final applications = await JobService.getMyApplications('current_user_id');
    
    setState(() {
      availableJobs = jobs;
      myApplications = applications;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeLinkGH Careers'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available Jobs'),
            Tab(text: 'My Applications'),
            Tab(text: 'Help Desk'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFFCD116),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableJobsTab(),
          _buildMyApplicationsTab(),
          _buildHelpDeskTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableJobsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadJobData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006B3C), Color(0xFF228B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.work, size: 50, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Join the HomeLinkGH Team',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Build your career connecting Ghana\'s diaspora community',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Job listings
          ...availableJobs.map((job) => _buildJobCard(job)).toList(),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getJobIcon(job['title']),
                    color: const Color(0xFF006B3C),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['department'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getJobTypeColor(job['type']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Job details
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(job['location']),
                const SizedBox(width: 20),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(job['schedule']),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('₵${job['salaryRange']}'),
                const Spacer(),
                Text(
                  'Posted ${job['postedDays']} days ago',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              job['summary'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewJobDetails(job),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _applyForJob(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyApplicationsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (myApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Applications Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start applying for positions to track your progress here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Browse Jobs'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myApplications.length,
      itemBuilder: (context, index) {
        final application = myApplications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['jobTitle'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied on ${application['appliedDate']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (application['status'] == 'Interview Scheduled') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Interview: ${application['interviewDate']} at ${application['interviewTime']}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (application['feedback'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feedback:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(application['feedback']),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHelpDeskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Help Desk Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006B3C), Color(0xFF228B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.support_agent, size: 50, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Career Support Center',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Get help with your application process',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Help Options
          const Text(
            'Quick Help',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildHelpOption(
            'Application Process',
            'Learn how to apply for HomeLinkGH positions',
            Icons.assignment,
            () => _showApplicationGuide(),
          ),
          
          _buildHelpOption(
            'Interview Preparation',
            'Tips and resources for your interview',
            Icons.psychology,
            () => _showInterviewGuide(),
          ),
          
          _buildHelpOption(
            'Required Documents',
            'What documents you need for each role',
            Icons.description,
            () => _showDocumentGuide(),
          ),
          
          _buildHelpOption(
            'Contact HR',
            'Speak directly with our recruitment team',
            Icons.phone,
            () => _contactHR(),
          ),
          
          const SizedBox(height: 24),
          
          // FAQ Section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFAQItem(
            'What is the hiring process at HomeLinkGH?',
            'Our hiring process typically includes: 1) Application review, 2) Phone/video screening, 3) Technical/skills assessment (if applicable), 4) Final interview, 5) Reference check, 6) Job offer.',
          ),
          
          _buildFAQItem(
            'How long does the hiring process take?',
            'The typical hiring process takes 2-4 weeks from application to final decision, depending on the role and number of candidates.',
          ),
          
          _buildFAQItem(
            'Do you offer remote work options?',
            'Yes! Many of our positions offer flexible remote or hybrid work arrangements. Check individual job postings for specific requirements.',
          ),
          
          _buildFAQItem(
            'What benefits does HomeLinkGH offer?',
            'We offer competitive salaries, health insurance, performance bonuses, professional development opportunities, flexible work arrangements, and equity participation.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF006B3C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF006B3C)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  IconData _getJobIcon(String title) {
    if (title.contains('Manager')) return Icons.manage_accounts;
    if (title.contains('Support')) return Icons.support_agent;
    if (title.contains('Developer') || title.contains('Coordinator')) return Icons.code;
    if (title.contains('Marketing')) return Icons.campaign;
    if (title.contains('Finance')) return Icons.account_balance;
    if (title.contains('Supervisor')) return Icons.supervisor_account;
    if (title.contains('Verification')) return Icons.verified;
    return Icons.work;
  }

  Color _getJobTypeColor(String type) {
    switch (type) {
      case 'Full-time': return const Color(0xFF006B3C);
      case 'Part-time': return Colors.orange;
      case 'Contract': return Colors.purple;
      case 'Remote': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied': return Colors.blue;
      case 'Under Review': return Colors.orange;
      case 'Interview Scheduled': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Offered': return const Color(0xFF006B3C);
      default: return Colors.grey;
    }
  }

  void _viewJobDetails(Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(job: job),
      ),
    );
  }

  void _applyForJob(Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationScreen(job: job),
      ),
    );
  }

  void _showApplicationGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Process Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'How to Apply:\n\n'
            '1. Browse available positions in the "Available Jobs" tab\n'
            '2. Click "View Details" to read full job description\n'
            '3. Click "Apply Now" to start your application\n'
            '4. Complete the application form with accurate information\n'
            '5. Upload required documents (CV, certificates, etc.)\n'
            '6. Submit your application\n'
            '7. Track your application status in "My Applications"\n'
            '8. Respond promptly to any interview invitations\n\n'
            'Tips:\n'
            '• Tailor your application to each specific role\n'
            '• Ensure all documents are clear and up-to-date\n'
            '• Follow up professionally if needed',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showInterviewGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Interview Preparation'),
        content: const SingleChildScrollView(
          child: Text(
            'Interview Preparation Tips:\n\n'
            'Before the Interview:\n'
            '• Research HomeLinkGH and our mission\n'
            '• Review the job description thoroughly\n'
            '• Prepare examples of your relevant experience\n'
            '• Test your technology for video interviews\n'
            '• Prepare thoughtful questions about the role\n\n'
            'During the Interview:\n'
            '• Be punctual and professional\n'
            '• Show enthusiasm for the role and company\n'
            '• Use specific examples to demonstrate skills\n'
            '• Ask clarifying questions when needed\n'
            '• Be honest about your experience level\n\n'
            'Common Questions:\n'
            '• Why do you want to work at HomeLinkGH?\n'
            '• How do you handle challenging situations?\n'
            '• Describe your relevant experience\n'
            '• Where do you see yourself in 2-3 years?',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks'),
          ),
        ],
      ),
    );
  }

  void _showDocumentGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Required Documents'),
        content: const SingleChildScrollView(
          child: Text(
            'Documents Needed for Application:\n\n'
            'All Positions:\n'
            '• Updated CV/Resume\n'
            '• Cover letter\n'
            '• Valid Ghana ID or passport\n'
            '• Educational certificates\n'
            '• Professional references (2-3)\n\n'
            'Additional for Management Roles:\n'
            '• Leadership experience documentation\n'
            '• Performance reviews from previous roles\n\n'
            'Additional for Technical Roles:\n'
            '• Portfolio of work\n'
            '• Technical certifications\n'
            '• Code samples (if applicable)\n\n'
            'Additional for Financial Roles:\n'
            '• Professional accounting certifications\n'
            '• Financial analysis samples\n\n'
            'Document Requirements:\n'
            '• All documents must be in PDF format\n'
            '• Maximum file size: 5MB per document\n'
            '• Scanned documents should be clear and readable\n'
            '• Official documents may need verification',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _contactHR() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact HR Team'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in touch with our recruitment team:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('careers@homelink.gh'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('+233 (0) 30 123 4567'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('Mon-Fri: 9:00 AM - 5:00 PM'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Our HR team typically responds within 24-48 hours during business days.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In production, this would open email client or phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact information copied to clipboard'),
                  backgroundColor: Color(0xFF006B3C),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Contact Now'),
          ),
        ],
      ),
    );
  }
}

// Job Details Screen
class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job['title']),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['department'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(job['location']),
                        const SizedBox(width: 20),
                        Icon(Icons.attach_money, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('₵${job['salaryRange']}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Job description sections
            _buildSection('Job Summary', job['summary']),
            _buildSection('Key Responsibilities', job['responsibilities']),
            _buildSection('Requirements', job['requirements']),
            _buildSection('Benefits', job['benefits']),
            _buildSection('Application Process', job['applicationProcess']),
            
            const SizedBox(height: 24),
            
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationScreen(job: job),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Apply for This Position',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3C),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Job Application Screen
class JobApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobApplicationScreen({super.key, required this.job});

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coverLetterController = TextEditingController();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Application'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Application header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applying for: ${widget.job['title']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.job['department'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Application form
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _coverLetterController,
                decoration: const InputDecoration(
                  labelText: 'Cover Letter *',
                  hintText: 'Tell us why you\'re perfect for this role...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write a cover letter';
                  }
                  if (value.length < 100) {
                    return 'Cover letter should be at least 100 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Document upload section
              const Text(
                'Required Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              const SizedBox(height: 12),
              
              _buildDocumentUpload('CV/Resume', Icons.description),
              _buildDocumentUpload('Certificates', Icons.school),
              _buildDocumentUpload('Portfolio (if applicable)', Icons.work),
              
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting Application...'),
                          ],
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF006B3C)),
        title: Text(title),
        subtitle: const Text('Tap to upload document'),
        trailing: const Icon(Icons.upload_file),
        onTap: () {
          // In production, this would open file picker
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload $title functionality would be implemented here'),
              backgroundColor: const Color(0xFF006B3C),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Submit application
      final result = await JobService.submitApplication(
        jobId: widget.job['id'],
        applicantName: _nameController.text,
        applicantEmail: _emailController.text,
        applicantPhone: _phoneController.text,
        coverLetter: _coverLetterController.text,
      );

      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Application Submitted!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your application for ${widget.job['title']} has been submitted successfully!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Application ID: ${result['applicationId']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'ll receive an email confirmation shortly and we\'ll be in touch within 3-5 business days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to job details
                  Navigator.pop(context); // Go back to job portal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}