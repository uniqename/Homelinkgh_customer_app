import 'package:flutter/material.dart';

class JobApplicationScreen extends StatefulWidget {
  final String jobTitle;
  final bool isProviderRole;

  const JobApplicationScreen({
    super.key,
    required this.jobTitle,
    this.isProviderRole = false,
  });

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;
  
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  
  // File uploads
  String? _resumeFileName;
  String? _portfolioFileName;
  List<String> _certificateFileNames = [];
  
  // Availability
  Map<String, bool> _weeklyAvailability = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  
  // Emergency contact
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _emergencyRelationController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.jobTitle}'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Documents'),
            Tab(text: 'Availability'),
            Tab(text: 'Review'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoTab(),
          _buildDocumentsTab(),
          _buildAvailabilityTab(),
          _buildReviewTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_tabController.index > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(_tabController.index - 1);
                  },
                  child: const Text('Previous'),
                ),
              ),
            if (_tabController.index > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _tabController.index == 3 ? _submitApplication : () {
                  _tabController.animateTo(_tabController.index + 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_tabController.index == 3 ? 'Submit Application' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
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
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '+233 XX XXX XXXX',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
                hintText: 'Enter your address in Ghana',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _experienceController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Relevant Experience *',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
                hintText: 'Describe your relevant work experience...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your experience';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _motivationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Why are you interested in this position? *',
                prefixIcon: Icon(Icons.psychology),
                border: OutlineInputBorder(),
                hintText: 'Tell us what motivates you...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please tell us why you\'re interested';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Emergency Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _emergencyNameController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Name *',
                prefixIcon: Icon(Icons.contact_emergency),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter emergency contact name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emergencyPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Phone *',
                prefixIcon: Icon(Icons.phone_in_talk),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter emergency contact phone';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emergencyRelationController,
              decoration: const InputDecoration(
                labelText: 'Relationship *',
                prefixIcon: Icon(Icons.family_restroom),
                border: OutlineInputBorder(),
                hintText: 'e.g., Parent, Spouse, Sibling',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter relationship';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Documents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 20),
          
          // Resume Upload
          _buildFileUploadSection(
            title: 'Resume/CV *',
            description: 'Upload your current resume (PDF or DOC)',
            fileName: _resumeFileName,
            onUpload: () => _pickFile('resume'),
            icon: Icons.description,
            required: true,
          ),
          
          if (widget.isProviderRole) ...[
            const SizedBox(height: 20),
            // Portfolio Upload
            _buildFileUploadSection(
              title: 'Portfolio (Optional)',
              description: 'Upload work samples or portfolio (PDF, images)',
              fileName: _portfolioFileName,
              onUpload: () => _pickFile('portfolio'),
              icon: Icons.work_history,
            ),
            
            const SizedBox(height: 20),
            // Certificates Upload
            _buildMultiFileUploadSection(
              title: 'Certifications/Licenses',
              description: 'Upload relevant certificates or licenses',
              fileNames: _certificateFileNames,
              onUpload: () => _pickFile('certificates'),
              icon: Icons.verified,
            ),
          ],
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Document Guidelines',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Maximum file size: 10MB per file\n'
                  '• Supported formats: PDF, DOC, DOCX, JPG, PNG\n'
                  '• Ensure all documents are clear and readable\n'
                  '• All personal information will be kept confidential',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection({
    required String title,
    required String description,
    required String? fileName,
    required VoidCallback onUpload,
    required IconData icon,
    bool required = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF006B3C)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            if (fileName != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: onUpload,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: Text('Upload ${title.replaceAll(' *', '')}'),
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

  Widget _buildMultiFileUploadSection({
    required String title,
    required String description,
    required List<String> fileNames,
    required VoidCallback onUpload,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF006B3C)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            if (fileNames.isNotEmpty) ...[
              ...fileNames.map((fileName) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          fileNames.remove(fileName);
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.add),
              label: Text(fileNames.isEmpty ? 'Upload $title' : 'Add More'),
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

  Widget _buildAvailabilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Availability',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Which days are you available to work?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _weeklyAvailability.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.key),
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _weeklyAvailability[entry.key] = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF006B3C),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Preferred Working Hours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Start Time'),
                          subtitle: Text(_startTime.format(context)),
                          leading: const Icon(Icons.access_time),
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('End Time'),
                          subtitle: Text(_endTime.format(context)),
                          leading: const Icon(Icons.access_time_filled),
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          TextFormField(
            controller: _additionalInfoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Additional Information (Optional)',
              prefixIcon: Icon(Icons.info_outline),
              border: OutlineInputBorder(),
              hintText: 'Any additional information about your availability or special requirements...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Application',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildReviewSection(
            'Personal Information',
            [
              'Name: ${_fullNameController.text}',
              'Email: ${_emailController.text}',
              'Phone: ${_phoneController.text}',
              'Address: ${_addressController.text}',
              'Emergency Contact: ${_emergencyNameController.text} (${_emergencyRelationController.text})',
            ],
          ),
          
          _buildReviewSection(
            'Documents',
            [
              'Resume: ${_resumeFileName ?? 'Not uploaded'}',
              if (widget.isProviderRole) 'Portfolio: ${_portfolioFileName ?? 'Not uploaded'}',
              if (widget.isProviderRole) 'Certificates: ${_certificateFileNames.isEmpty ? 'None' : _certificateFileNames.join(', ')}',
            ],
          ),
          
          _buildReviewSection(
            'Availability',
            [
              'Available Days: ${_weeklyAvailability.entries.where((e) => e.value).map((e) => e.key).join(', ')}',
              'Working Hours: ${_startTime.format(context)} - ${_endTime.format(context)}',
            ],
          ),
          
          _buildReviewSection(
            'Experience & Motivation',
            [
              'Experience: ${_experienceController.text}',
              'Motivation: ${_motivationController.text}',
              if (_additionalInfoController.text.isNotEmpty) 'Additional Info: ${_additionalInfoController.text}',
            ],
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Application Ready',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Your application is complete and ready to submit. We will review it within 24-48 hours and contact you for the next steps.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickFile(String type) async {
    // Simulate file picker for demo purposes
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      if (type == 'resume') {
        _resumeFileName = 'My_Resume.pdf';
      } else if (type == 'portfolio') {
        _portfolioFileName = 'Portfolio_${DateTime.now().millisecondsSinceEpoch}.pdf';
      } else if (type == 'certificates') {
        _certificateFileNames.add('Certificate_${DateTime.now().millisecondsSinceEpoch}.pdf');
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File uploaded successfully for $type'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    if (_resumeFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your resume'),
          backgroundColor: Colors.red,
        ),
      );
      _tabController.animateTo(1);
      return;
    }

    if (!_weeklyAvailability.values.any((available) => available)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one available day'),
          backgroundColor: Colors.red,
        ),
      );
      _tabController.animateTo(2);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Application Submitted!'),
            ],
          ),
          content: const Text(
            'Thank you for your application! We have received it and will review it within 24-48 hours. You will receive an email confirmation shortly.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close application screen
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
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _motivationController.dispose();
    _additionalInfoController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }
}