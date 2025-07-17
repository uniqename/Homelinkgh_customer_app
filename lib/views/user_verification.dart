import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserVerificationScreen extends StatefulWidget {
  final String userType; // 'provider' or 'customer'
  
  const UserVerificationScreen({
    super.key,
    required this.userType,
  });

  @override
  State<UserVerificationScreen> createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen> {
  int currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyNameController = TextEditingController();
  
  // Verification status
  Map<String, bool> verificationStatus = {
    'identity': false,
    'address': false,
    'background': false,
    'skills': false,
    'training': false,
  };
  
  // Documents
  Map<String, String?> documents = {
    'idFront': null,
    'idBack': null,
    'proofOfAddress': null,
    'skillsCertificate': null,
    'profilePhoto': null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userType.toUpperCase()} Verification'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006B3C), Color(0xFF228B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Account Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.userType == 'provider' 
                      ? 'Complete verification to start earning'
                      : 'Verify your account for better security',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(),
              ],
            ),
          ),
          
          // Steps Content
          Expanded(
            child: Stepper(
              currentStep: currentStep,
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    if (details.stepIndex < _getSteps().length - 1)
                      ElevatedButton(
                        onPressed: () {
                          if (currentStep < _getSteps().length - 1) {
                            setState(() {
                              currentStep++;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006B3C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Next'),
                      ),
                    const SizedBox(width: 8),
                    if (details.stepIndex > 0)
                      TextButton(
                        onPressed: () {
                          if (currentStep > 0) {
                            setState(() {
                              currentStep--;
                            });
                          }
                        },
                        child: const Text('Previous'),
                      ),
                    if (details.stepIndex == _getSteps().length - 1)
                      ElevatedButton(
                        onPressed: () => _submitVerification(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006B3C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Submit'),
                      ),
                  ],
                );
              },
              steps: _getSteps(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final totalSteps = _getSteps().length;
    final progress = (currentStep + 1) / totalSteps;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFCD116)),
        ),
      ],
    );
  }

  List<Step> _getSteps() {
    List<Step> steps = [
      Step(
        title: const Text('Personal Information'),
        content: _buildPersonalInfoStep(),
        isActive: currentStep == 0,
      ),
      Step(
        title: const Text('Identity Verification'),
        content: _buildIdentityStep(),
        isActive: currentStep == 1,
      ),
      Step(
        title: const Text('Address Verification'),
        content: _buildAddressStep(),
        isActive: currentStep == 2,
      ),
    ];

    if (widget.userType == 'provider') {
      steps.addAll([
        Step(
          title: const Text('Skills & Certificates'),
          content: _buildSkillsStep(),
          isActive: currentStep == 3,
        ),
        Step(
          title: const Text('Background Check'),
          content: _buildBackgroundStep(),
          isActive: currentStep == 4,
        ),
        Step(
          title: const Text('Diaspora Training'),
          content: _buildTrainingStep(),
          isActive: currentStep == 5,
        ),
      ]);
    }

    return steps;
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Please provide your personal information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Profile Photo
        Center(
          child: GestureDetector(
            onTap: () => _pickImage('profilePhoto'),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF006B3C), width: 3),
                color: Colors.grey[200],
              ),
              child: documents['profilePhoto'] != null
                  ? const Icon(Icons.check_circle, size: 60, color: Color(0xFF006B3C))
                  : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Tap to add profile photo',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Name Fields
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixText: '+233 ',
          ),
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 16),
        
        // Emergency Contact
        TextFormField(
          controller: _emergencyNameController,
          decoration: const InputDecoration(
            labelText: 'Emergency Contact Name',
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _emergencyContactController,
          decoration: const InputDecoration(
            labelText: 'Emergency Contact Phone',
            border: OutlineInputBorder(),
            prefixText: '+233 ',
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload a valid government-issued ID',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        const Text(
          'Accepted Documents:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const Text('• Ghana Card (National ID)'),
        const Text('• Passport'),
        const Text('• Driver\'s License'),
        const Text('• Voter ID'),
        
        const SizedBox(height: 24),
        
        // ID Front
        _buildDocumentUpload(
          'ID Front Side',
          'idFront',
          'Clear photo of the front of your ID',
        ),
        
        const SizedBox(height: 16),
        
        // ID Back
        _buildDocumentUpload(
          'ID Back Side',
          'idBack',
          'Clear photo of the back of your ID',
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📋 Photo Requirements',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Text('• Well-lit, clear photo'),
              Text('• All text and details visible'),
              Text('• No glare or shadows'),
              Text('• Document must be valid and not expired'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify your current address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Full Address',
            border: OutlineInputBorder(),
            hintText: 'House number, street, area, city, region',
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildDocumentUpload(
          'Proof of Address',
          'proofOfAddress',
          'Utility bill, bank statement, or rental agreement (within 3 months)',
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📍 Accepted Proof of Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text('• ECG (electricity) bill'),
              Text('• Ghana Water Company bill'),
              Text('• Bank statement'),
              Text('• Rental agreement'),
              Text('• Council/Property tax bill'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills & Certifications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        const Text(
          'Upload relevant certificates or proof of skills for services you want to provide:',
        ),
        
        const SizedBox(height: 16),
        
        _buildDocumentUpload(
          'Skills Certificate',
          'skillsCertificate',
          'Trade certificate, diploma, or other relevant qualification',
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎓 Skill Verification Examples',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text('• Plumbing: NVTI certificate'),
              Text('• Electrical: Licensed electrician certificate'),
              Text('• Cleaning: Training or experience letter'),
              Text('• Cooking: Culinary certificate or experience'),
              Text('• General: 2+ references from previous clients'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background Check',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔍 Background Check Process',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Text('1. Criminal background check with Ghana Police'),
              Text('2. Reference verification (2-3 contacts)'),
              Text('3. Previous employer verification (if applicable)'),
              Text('4. Social media and online presence review'),
              Text('5. Credit check for financial responsibility'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'By proceeding, you consent to HomeLinkGH conducting background checks as outlined above.',
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⏱️ Processing Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text('• Standard background check: 3-5 business days'),
              Text('• You\'ll receive email updates on progress'),
              Text('• Can start training while check is in progress'),
              Text('• Account activation after successful completion'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diaspora Cultural Training',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCD116).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFCD116)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🇬🇭 Diaspora Training Modules',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              SizedBox(height: 8),
              Text('1. Understanding diaspora expectations'),
              Text('2. Cultural sensitivity and communication'),
              Text('3. International payment handling'),
              Text('4. Emergency and safety protocols'),
              Text('5. Customer service excellence'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Training Benefits:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Higher booking priority'),
        const Text('• Premium rates (up to 25% more)'),
        const Text('• "Diaspora Friendly" badge'),
        const Text('• Access to international customers'),
        const Text('• Ongoing cultural competency updates'),
        
        const SizedBox(height: 16),
        
        ElevatedButton(
          onPressed: () => _startTraining(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006B3C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text('Start Training (45 mins)'),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String title, String key, String description) {
    final isUploaded = documents[key] != null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUploaded ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isUploaded ? Colors.green.withOpacity(0.1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isUploaded)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _pickImage(key),
            icon: Icon(isUploaded ? Icons.edit : Icons.upload_file),
            label: Text(isUploaded ? 'Change Document' : 'Upload Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded ? Colors.orange : const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(String key) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        documents[key] = image.path;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _startTraining() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Diaspora Training'),
        content: const Text(
          'This will open the training module in your browser. Complete all 5 modules to earn your Diaspora Friendly badge.',
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
                verificationStatus['training'] = true;
              });
            },
            child: const Text('Start Training'),
          ),
        ],
      ),
    );
  }

  void _submitVerification() {
    // Check completion
    bool isComplete = _firstNameController.text.isNotEmpty &&
                     _lastNameController.text.isNotEmpty &&
                     _phoneController.text.isNotEmpty &&
                     documents['idFront'] != null &&
                     documents['idBack'] != null &&
                     documents['proofOfAddress'] != null;

    if (widget.userType == 'provider') {
      isComplete = isComplete &&
                  documents['skillsCertificate'] != null &&
                  verificationStatus['training'] == true;
    }

    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit verification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Submitted'),
        content: Text(
          widget.userType == 'provider'
              ? 'Your provider verification has been submitted. You\'ll receive an email update within 3-5 business days.'
              : 'Your account verification has been submitted. You\'ll receive an email update within 24 hours.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}