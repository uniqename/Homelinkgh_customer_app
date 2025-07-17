import 'package:flutter/material.dart';
import 'provider_dashboard.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _aboutController = TextEditingController();
  
  // Form data
  List<String> selectedServices = [];
  String? idDocumentPath;
  String? certificationPath;
  String? portfolioPath;

  final List<Map<String, dynamic>> availableServices = [
    {'name': 'Food Delivery', 'icon': Icons.delivery_dining, 'category': 'Delivery'},
    {'name': 'Grocery Shopping', 'icon': Icons.shopping_cart, 'category': 'Delivery'},
    {'name': 'House Cleaning', 'icon': Icons.cleaning_services, 'category': 'Home'},
    {'name': 'Laundry Service', 'icon': Icons.local_laundry_service, 'category': 'Home'},
    {'name': 'Nail Tech', 'icon': Icons.face_retouching_natural, 'category': 'Beauty'},
    {'name': 'Makeup Artist', 'icon': Icons.brush, 'category': 'Beauty'},
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'category': 'Trade'},
    {'name': 'Electrical Work', 'icon': Icons.electrical_services, 'category': 'Trade'},
    {'name': 'HVAC Services', 'icon': Icons.hvac, 'category': 'Trade'},
    {'name': 'Painting', 'icon': Icons.format_paint, 'category': 'Trade'},
    {'name': 'Carpentry', 'icon': Icons.handyman, 'category': 'Trade'},
    {'name': 'Landscaping', 'icon': Icons.grass, 'category': 'Trade'},
    {'name': 'Babysitting', 'icon': Icons.child_care, 'category': 'Care'},
    {'name': 'Elder Care', 'icon': Icons.elderly, 'category': 'Care'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Provider'),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        foregroundColor: Colors.green,
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
            title: const Text('Services Offered'),
            content: _buildServicesStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : 
                   _currentStep == 1 ? StepState.indexed : StepState.disabled,
          ),
          Step(
            title: const Text('Experience & Portfolio'),
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
            title: const Text('Verification'),
            content: _buildVerificationStep(),
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
        children: [
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
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesStep() {
    final servicesByCategory = <String, List<Map<String, dynamic>>>{};
    for (var service in availableServices) {
      final category = service['category'] as String;
      servicesByCategory.putIfAbsent(category, () => []).add(service);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the services you can provide:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...servicesByCategory.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((service) {
                  final serviceName = service['name'] as String;
                  final isSelected = selectedServices.contains(serviceName);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(service['icon'] as IconData, size: 16),
                        const SizedBox(width: 4),
                        Text(serviceName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedServices.add(serviceName);
                        } else {
                          selectedServices.remove(serviceName);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
        if (selectedServices.isNotEmpty) ...[
          const SizedBox(height: 16),
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
                  'Selected Services:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(selectedServices.join(', ')),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExperienceStep() {
    return Column(
      children: [
        TextFormField(
          controller: _experienceController,
          decoration: const InputDecoration(
            labelText: 'Years of Experience *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_history),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your years of experience';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _aboutController,
          decoration: const InputDecoration(
            labelText: 'About Your Services *',
            hintText: 'Describe your skills, specializations, and what makes you unique',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please describe your services';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portfolio (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload photos of your previous work to showcase your skills.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Simulate file upload
                    setState(() {
                      portfolioPath = 'portfolio_images.zip';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Portfolio uploaded successfully!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(portfolioPath ?? 'Upload Portfolio'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: [
        const Text(
          'Please upload the required documents for verification:',
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
                  'Identity Document *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a clear photo of your National ID, Passport, or Driver\'s License.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      idDocumentPath = 'national_id.jpg';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID document uploaded!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(idDocumentPath ?? 'Upload ID Document'),
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
                  'Professional Certifications (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload any relevant certifications, licenses, or training certificates.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      certificationPath = 'certifications.pdf';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Certifications uploaded!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(certificationPath ?? 'Upload Certifications'),
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
            border: Border.all(color: Colors.blue),
          ),
          child: const Column(
            children: [
              Icon(Icons.security, color: Colors.blue, size: 32),
              SizedBox(height: 8),
              Text(
                'Document Security',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'All documents are encrypted and securely stored. They will only be used for verification purposes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Application Submitted Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for applying to become a Blazer service provider. Our team will review your application and get back to you within 2-3 business days.',
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
                  'What happens next?',
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
                  title: Text('Document Verification'),
                  subtitle: Text('We\'ll verify your identity and certifications'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text('2', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Background Check'),
                  subtitle: Text('Quick background verification for customer safety'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('3', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Account Activation'),
                  subtitle: Text('Once approved, you can start receiving job requests'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderDashboard(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Dashboard'),
          ),
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (selectedServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one service')),
          );
          return false;
        }
        return true;
      case 2:
        return _experienceController.text.isNotEmpty && _aboutController.text.isNotEmpty;
      case 3:
        if (idDocumentPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload your ID document')),
          );
          return false;
        }
        return true;
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
        content: Text('Application submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}