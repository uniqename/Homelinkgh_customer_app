import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../services/firebase_service.dart';
import '../services/local_data_service.dart';
import '../services/ghana_card_verification_service.dart';
import 'role_selection.dart';

/// Provider Onboarding Screen for HomeLinkGH
/// Handles the complete provider registration and verification process
class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final PageController _pageController = PageController();
  final FirebaseService _firebaseService = FirebaseService();
  final LocalDataService _localDataService = LocalDataService();
  final ImagePicker _imagePicker = ImagePicker();
  
  int _currentStep = 0;
  final _formKeys = List.generate(5, (index) => GlobalKey<FormState>());
  
  // Provider data
  String _fullName = '';
  String _phoneNumber = '';
  String _email = '';
  String _idNumber = '';
  String _address = '';
  String _bio = '';
  String _experience = '';
  double _hourlyRate = 50.0;
  
  List<String> _selectedServices = [];
  List<String> _languages = [];
  List<String> _certificationPaths = [];
  String? _profileImagePath;
  List<String> _portfolioImagePaths = [];
  
  // Ghana Card verification fields
  String _ghanaCardNumber = '';
  String _dateOfBirth = '';
  XFile? _ghanaCardFrontImage;
  XFile? _ghanaCardBackImage;
  XFile? _selfieImage;
  bool _isVerificationSubmitted = false;
  String? _verificationId;
  VerificationStatus _verificationStatus = VerificationStatus.unverified;
  
  final List<String> _availableServices = [
    'Food Delivery',
    'House Cleaning',
    'Beauty Services',
    'Transportation',
    'Home Services',
    'Plumbing',
    'Electrical Work',
    'Landscaping',
    'Laundry Services',
    'Grocery Shopping',
    'Elderly Care',
    'Childcare',
    'Tutoring',
    'Photography',
    'Event Planning',
  ];
  
  final List<String> _availableLanguages = [
    'English',
    'Akan/Twi',
    'Ga',
    'Ewe',
    'Hausa',
    'Fante',
    'Dagbani',
    'French',
  ];
  
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Provider'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildPersonalInfoStep(),
                _buildServicesStep(),
                _buildExperienceStep(),
                _buildVerificationStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Personal Info', 'Services', 'Experience', 'Verification'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF006B3C),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isCompleted 
                          ? Colors.green 
                          : isActive 
                              ? Colors.white 
                              : Colors.white.withValues(alpha: 0.3),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? const Color(0xFF006B3C) : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: isCompleted 
                              ? Colors.green 
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            steps[_currentStep],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tell us about yourself to get started as a provider.'),
            const SizedBox(height: 24),
            
            // Profile Photo
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: const Color(0xFF006B3C), width: 2),
                  ),
                  child: _profileImagePath != null
                      ? ClipOval(
                          child: Image.asset(
                            _profileImagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 50, color: Colors.grey);
                            },
                          ),
                        )
                      : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Tap to add profile photo', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
              onSaved: (value) => _fullName = value!,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '+233 XX XXX XXXX',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your phone number';
                if (!value!.startsWith('+233') && !value.startsWith('0')) {
                  return 'Please enter a valid Ghana phone number';
                }
                return null;
              },
              onSaved: (value) => _phoneNumber = value!,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your email';
                if (!value!.contains('@')) return 'Please enter a valid email';
                return null;
              },
              onSaved: (value) => _email = value!,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ghana Card / ID Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
                hintText: 'GHA-XXXXXXXXX-X',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your ID number' : null,
              onSaved: (value) => _idNumber = value!,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Your current address in Ghana',
              ),
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
              onSaved: (value) => _address = value!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services You Offer',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Select the services you can provide to customers.'),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableServices.map((service) {
              final isSelected = _selectedServices.contains(service);
              return FilterChip(
                selected: isSelected,
                label: Text(service),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedServices.add(service);
                    } else {
                      _selectedServices.remove(service);
                    }
                  });
                },
                selectedColor: const Color(0xFF006B3C).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF006B3C),
              );
            }).toList(),
          ),
          
          if (_selectedServices.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please select at least one service you can provide.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Languages You Speak',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableLanguages.map((language) {
              final isSelected = _languages.contains(language);
              return FilterChip(
                selected: isSelected,
                label: Text(language),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _languages.add(language);
                    } else {
                      _languages.remove(language);
                    }
                  });
                },
                selectedColor: const Color(0xFF006B3C).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF006B3C),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Your Hourly Rate',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hourly Rate:'),
                    Text(
                      'GH₵${_hourlyRate.toStringAsFixed(0)}/hour',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _hourlyRate,
                  min: 20,
                  max: 200,
                  divisions: 18,
                  activeColor: const Color(0xFF006B3C),
                  onChanged: (value) {
                    setState(() => _hourlyRate = value);
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GH₵20', style: TextStyle(fontSize: 12)),
                    Text('GH₵200', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experience & Portfolio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tell us about your experience and showcase your work.'),
            const SizedBox(height: 24),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'About You',
                border: OutlineInputBorder(),
                hintText: 'Describe your background and what makes you a great provider...',
              ),
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Please tell us about yourself' : null,
              onSaved: (value) => _bio = value!,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Years of Experience',
                border: OutlineInputBorder(),
                hintText: 'e.g., 5 years in house cleaning services',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your experience' : null,
              onSaved: (value) => _experience = value!,
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portfolio Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _addPortfolioImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_portfolioImagePaths.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.photo_library, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Add photos of your work'),
                    const SizedBox(height: 4),
                    Text(
                      'Show potential customers examples of your quality work',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _portfolioImagePaths.length + 1,
                itemBuilder: (context, index) {
                  if (index == _portfolioImagePaths.length) {
                    return GestureDetector(
                      onTap: _addPortfolioImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.grey),
                            Text('Add Photo', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(_portfolioImagePaths[index]),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {},
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePortfolioImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghana Card Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Verify your identity with your Ghana Card for trusted service provision.'),
            const SizedBox(height: 24),
            
            // Ghana Card Number
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ghana Card Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
                hintText: 'GHA-XXXXXXXXX-X',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z\-]')),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your Ghana Card number';
                if (!RegExp(r'^GHA-\d{9}-\d$').hasMatch(value!)) {
                  return 'Please enter a valid Ghana Card number (GHA-XXXXXXXXX-X)';
                }
                return null;
              },
              onSaved: (value) => _ghanaCardNumber = value!,
            ),
            const SizedBox(height: 16),
            
            // Date of Birth
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date of Birth *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'DD/MM/YYYY',
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your date of birth';
                if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value!)) {
                  return 'Please enter date in DD/MM/YYYY format';
                }
                return null;
              },
              onSaved: (value) => _dateOfBirth = value!,
            ),
            const SizedBox(height: 24),
            
            // Ghana Card Front Image
            _buildImageUploadSection(
              'Ghana Card Front',
              'Upload a clear photo of the front of your Ghana Card',
              Icons.credit_card,
              _ghanaCardFrontImage,
              () => _pickGhanaCardImage('front'),
            ),
            
            const SizedBox(height: 16),
            
            // Ghana Card Back Image
            _buildImageUploadSection(
              'Ghana Card Back',
              'Upload a clear photo of the back of your Ghana Card',
              Icons.credit_card,
              _ghanaCardBackImage,
              () => _pickGhanaCardImage('back'),
            ),
            
            const SizedBox(height: 16),
            
            // Selfie Image
            _buildImageUploadSection(
              'Selfie Verification',
              'Take a clear selfie for identity verification',
              Icons.face,
              _selfieImage,
              () => _pickGhanaCardImage('selfie'),
            ),
            
            const SizedBox(height: 24),
            
            // Verification Status
            if (_isVerificationSubmitted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getVerificationStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getVerificationStatusColor().withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getVerificationStatusIcon(), color: _getVerificationStatusColor()),
                        const SizedBox(width: 8),
                        Text(
                          'Verification Status: ${_verificationStatus.name.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getVerificationStatusColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getVerificationStatusMessage(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )
            else
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
                          'Ghana Card Verification Benefits',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Build trust with customers\n'
                      '• Access to premium features\n'
                      '• Higher booking priority\n'
                      '• Increased earning potential\n'
                      '• Professional credibility',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Certifications Section
            _buildDocumentSection(
              'Certifications (Optional)',
              'Upload any relevant certificates or qualifications',
              Icons.school,
              () => _pickDocument('certification'),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF006B3C),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms and Conditions and Privacy Policy of HomeLinkGH',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection(String title, String description, IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF006B3C)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF006B3C),
                side: const BorderSide(color: Color(0xFF006B3C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
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
                        SizedBox(width: 8),
                        Text('Submitting...'),
                      ],
                    )
                  : Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continue';
      case 1:
        return 'Continue';
      case 2:
        return 'Continue';
      case 3:
        return 'Submit Application';
      default:
        return 'Next';
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKeys[0].currentState!.validate()) {
        _formKeys[0].currentState!.save();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    } else if (_currentStep == 1) {
      if (_selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one service')),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentStep == 2) {
      if (_formKeys[2].currentState!.validate()) {
        _formKeys[2].currentState!.save();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    } else if (_currentStep == 3) {
      _submitApplication();
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _addPortfolioImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _portfolioImagePaths.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding portfolio image: $e')),
      );
    }
  }

  void _removePortfolioImage(int index) {
    setState(() {
      _portfolioImagePaths.removeAt(index);
    });
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _certificationPaths.add(file.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${documentType.replaceAll('_', ' ')} uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    }
  }

  Future<void> _pickGhanaCardImage(String imageType) async {
    try {
      final ImageSource source = imageType == 'selfie' 
          ? ImageSource.camera 
          : ImageSource.gallery;
      
      final XFile? file = await _imagePicker.pickImage(source: source);
      if (file != null) {
        setState(() {
          switch (imageType) {
            case 'front':
              _ghanaCardFrontImage = file;
              break;
            case 'back':
              _ghanaCardBackImage = file;
              break;
            case 'selfie':
              _selfieImage = file;
              break;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$imageType image uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading $imageType image: $e')),
      );
    }
  }

  Widget _buildImageUploadSection(String title, String description, IconData icon, XFile? imageFile, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF006B3C)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          
          if (imageFile != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageFile.path,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Image uploaded', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (title.contains('Front')) {
                            _ghanaCardFrontImage = null;
                          } else if (title.contains('Back')) {
                            _ghanaCardBackImage = null;
                          } else if (title.contains('Selfie')) {
                            _selfieImage = null;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.camera_alt),
                label: Text(title.contains('Selfie') ? 'Take Photo' : 'Upload Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF006B3C),
                  side: const BorderSide(color: Color(0xFF006B3C)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getVerificationStatusColor() {
    switch (_verificationStatus) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.suspended:
        return Colors.red;
      case VerificationStatus.underReview:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getVerificationStatusIcon() {
    switch (_verificationStatus) {
      case VerificationStatus.verified:
        return Icons.check_circle;
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.suspended:
        return Icons.block;
      case VerificationStatus.underReview:
        return Icons.visibility;
      default:
        return Icons.help;
    }
  }

  String _getVerificationStatusMessage() {
    switch (_verificationStatus) {
      case VerificationStatus.verified:
        return 'Your Ghana Card has been verified. You can now start accepting bookings.';
      case VerificationStatus.pending:
        return 'Your Ghana Card verification is being processed. This typically takes 24-48 hours.';
      case VerificationStatus.rejected:
        return 'Your Ghana Card verification was rejected. Please check your documents and try again.';
      case VerificationStatus.suspended:
        return 'Your verification has been suspended. Please contact support for assistance.';
      case VerificationStatus.underReview:
        return 'Your Ghana Card is under manual review. We may contact you for additional information.';
      default:
        return 'Ghana Card verification not started.';
    }
  }

  Future<void> _submitApplication() async {
    // Validate verification form first
    if (!_formKeys[3].currentState!.validate()) {
      return;
    }
    
    // Check if all required images are uploaded
    if (_ghanaCardFrontImage == null || _ghanaCardBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both front and back images of your Ghana Card')),
      );
      return;
    }
    
    _formKeys[3].currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final String providerId = 'provider_${DateTime.now().millisecondsSinceEpoch}';
      
      // Submit Ghana Card verification
      final verificationResult = await GhanaCardVerificationService.submitGhanaCardVerification(
        userId: providerId,
        fullName: _fullName,
        ghanaCardNumber: _ghanaCardNumber,
        dateOfBirth: _dateOfBirth,
        phoneNumber: _phoneNumber,
        frontImageFile: _ghanaCardFrontImage!,
        backImageFile: _ghanaCardBackImage!,
        selfieImageFile: _selfieImage,
        userType: 'provider',
        additionalData: {
          'email': _email,
          'services': _selectedServices,
          'hourly_rate': _hourlyRate,
          'languages': _languages,
          'application_date': DateTime.now().toIso8601String(),
        },
      );

      if (verificationResult['success']) {
        setState(() {
          _isVerificationSubmitted = true;
          _verificationId = verificationResult['verification_id'];
          _verificationStatus = VerificationStatus.pending;
        });

        // Create provider profile
        final provider = Provider(
          id: providerId,
          name: _fullName,
          email: _email,
          phone: _phoneNumber,
          rating: 0.0,
          totalRatings: 0,
          completedJobs: 0,
          services: _selectedServices,
          location: const LatLng(5.6037, -0.1870), // Default Accra location
          address: _address,
          bio: _bio,
          isVerified: false, // Will be set to true after verification
          isActive: false,
          profileImageUrl: _profileImagePath ?? '',
          certifications: _certificationPaths,
          availability: {},
        );

        // Try to save to Firebase first, fallback to local if needed
        try {
          await _firebaseService.createProvider(provider);
          print('Provider application saved to Firebase');
        } catch (e) {
          print('Firebase save failed, attempting local save: $e');
          // For now, we'll just log the error since local provider creation isn't implemented
          // In a full implementation, this would save to local storage
        }

        // Save user session as provider
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'provider');
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_name', _fullName);
        await prefs.setString('user_phone', _phoneNumber);
        await prefs.setString('user_email', _email);
        await prefs.setString('provider_id', providerId);
        await prefs.setBool('provider_verified', false); // Pending verification
        await prefs.setString('verification_id', _verificationId ?? '');

        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${verificationResult['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submission failed: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Application Submitted!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your provider application has been submitted successfully.'),
            SizedBox(height: 12),
            Text('What happens next:'),
            SizedBox(height: 8),
            Text('• We will review your application within 24-48 hours'),
            Text('• Our team may contact you for additional information'),
            Text('• You will receive an email confirmation upon approval'),
            Text('• Once approved, you can start accepting bookings'),
            SizedBox(height: 12),
            Text(
              'Thank you for joining HomeLinkGH!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(savedRole: 'provider'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

