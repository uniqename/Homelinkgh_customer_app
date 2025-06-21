import 'package:flutter/material.dart';
import 'provider_onboarding.dart';

class JobSeekerOnboardingScreen extends StatefulWidget {
  const JobSeekerOnboardingScreen({super.key});

  @override
  State<JobSeekerOnboardingScreen> createState() => _JobSeekerOnboardingScreenState();
}

class _JobSeekerOnboardingScreenState extends State<JobSeekerOnboardingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Form data
  List<String> interestedServices = [];
  String? experienceLevel;
  String? availability;
  String? cvPath;
  String? referencePath;
  bool hasTransportation = false;
  bool willingToTravel = false;

  final List<String> availableServices = [
    'Food Delivery',
    'Grocery Shopping',
    'House Cleaning',
    'Laundry Service',
    'Nail Tech',
    'Makeup Artist',
    'Plumbing',
    'Electrical Work',
    'HVAC Services',
    'Painting',
    'Carpentry',
    'Landscaping',
    'Babysitting',
    'Elder Care',
  ];

  final List<String> experienceLevels = [
    'No Experience',
    'Some Experience (1-2 years)',
    'Experienced (3-5 years)',
    'Very Experienced (5+ years)',
  ];

  final List<String> availabilityOptions = [
    'Full-time (40+ hours/week)',
    'Part-time (20-30 hours/week)',
    'Weekends only',
    'Evenings only',
    'Flexible hours',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join as Job Seeker'),
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        foregroundColor: Colors.orange,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (details.stepIndex < 4)
                ElevatedButton(
                  onPressed: () {
                    if (_validateCurrentStep()) {
                      if (_currentStep == 3) {
                        _submitApplication();
                      } else {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(details.stepIndex == 3 ? 'Submit Application' : 'Next'),
                ),
              const SizedBox(width: 8),
              if (details.stepIndex > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: const Text('Back'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Personal Information'),
            content: _buildPersonalInfoStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Service Interests'),
            content: _buildServiceInterestsStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : 
                   _currentStep == 1 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: const Text('Experience & Availability'),
            content: _buildExperienceStep(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : 
                   _currentStep == 2 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: const Text('Documents'),
            content: _buildDocumentsStep(),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : 
                   _currentStep == 3 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: const Text('Application Review'),
            content: _buildApplicationReviewStep(),
            isActive: _currentStep >= 4,
            state: _currentStep == 4 ? StepState.complete : StepState.disabled,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.work_outline,
                  size: 48,
                  color: Colors.orange,
                ),
                SizedBox(height: 8),
                Text(
                  'Ready to Start Your Career?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Join our platform and get trained to become a certified service provider',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
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
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
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
              prefixIcon: Icon(Icons.phone),
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
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Current Location *',
              hintText: 'City, Region',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What services are you interested in providing?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select all that apply. We\'ll provide training for your chosen services.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableServices.map((service) {
            final isSelected = interestedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              selectedColor: Colors.orange.withValues(alpha: 0.3),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    interestedServices.add(service);
                  } else {
                    interestedServices.remove(service);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (interestedServices.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Services:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(interestedServices.join(', ')),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        CheckboxListTile(
          title: const Text('I have my own transportation'),
          subtitle: const Text('Car, motorcycle, or bicycle'),
          value: hasTransportation,
          onChanged: (value) {
            setState(() {
              hasTransportation = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('I\'m willing to travel for work'),
          subtitle: const Text('Within reasonable distance from my location'),
          value: willingToTravel,
          onChanged: (value) {
            setState(() {
              willingToTravel = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Experience Level *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_history),
          ),
          value: experienceLevel,
          items: experienceLevels.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Text(level),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              experienceLevel = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select your experience level';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Availability *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.schedule),
          ),
          value: availability,
          items: availabilityOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              availability = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select your availability';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue),
          ),
          child: const Column(
            children: [
              Icon(Icons.school, color: Colors.blue, size: 32),
              SizedBox(height: 8),
              Text(
                'Training & Certification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Don\'t worry if you\'re new! We provide comprehensive training programs and certification for all our service providers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: [
        const Text(
          'Upload your documents to complete your application:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CV/Resume (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload your CV or resume if you have one. This helps us understand your background better.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      cvPath = 'my_cv.pdf';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CV uploaded successfully!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(cvPath ?? 'Upload CV/Resume'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'References (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provide contact information for 2-3 references who can vouch for your character and work ethic.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      referencePath = 'references.pdf';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('References uploaded!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(referencePath ?? 'Upload References'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: const Column(
            children: [
              Icon(Icons.info, color: Colors.green, size: 32),
              SizedBox(height: 8),
              Text(
                'No Documents Required!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'As a job seeker, you can apply even without formal documents. We\'ll help you build your profile and qualifications through our training programs.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationReviewStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.send,
                color: Colors.orange,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for your interest in joining Blazer! We\'ll review your application and contact you within 1-2 business days.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Next Steps:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('1', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Application Review'),
                  subtitle: Text('Our team will review your application'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text('2', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Interview/Screening'),
                  subtitle: Text('Brief interview to understand your goals'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text('3', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Training Program'),
                  subtitle: Text('Complete training for your selected services'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('4', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Certification & Activation'),
                  subtitle: Text('Get certified and start receiving jobs!'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interested in becoming a provider now?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'If you already have experience and want to skip the training, you can apply directly as a provider.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderOnboardingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply as Provider'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (interestedServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one service')),
          );
          return false;
        }
        return true;
      case 2:
        return experienceLevel != null && availability != null;
      case 3:
        return true; // Documents are optional for job seekers
      default:
        return true;
    }
  }

  void _submitApplication() {
    setState(() {
      _currentStep = 4;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job seeker application submitted successfully!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}