import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/provider_verification.dart';

class ProviderOnboardingFlow extends StatefulWidget {
  const ProviderOnboardingFlow({super.key});

  @override
  State<ProviderOnboardingFlow> createState() => _ProviderOnboardingFlowState();
}

class _ProviderOnboardingFlowState extends State<ProviderOnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form data
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _serviceFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();
  final _bankingFormKey = GlobalKey<FormState>();
  
  // Basic Info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Services
  List<String> _selectedServices = [];
  final List<Map<String, dynamic>> _availableServices = [
    {'name': 'House Cleaning', 'icon': Icons.cleaning_services, 'requiresLicense': false},
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'requiresLicense': true},
    {'name': 'Electrical', 'icon': Icons.electrical_services, 'requiresLicense': true},
    {'name': 'Beauty Services', 'icon': Icons.face_retouching_natural, 'requiresLicense': true},
    {'name': 'Transportation', 'icon': Icons.directions_car, 'requiresLicense': true},
    {'name': 'Laundry', 'icon': Icons.local_laundry_service, 'requiresLicense': false},
    {'name': 'Grocery Shopping', 'icon': Icons.shopping_cart, 'requiresLicense': false},
    {'name': 'Elder Care', 'icon': Icons.elderly, 'requiresLicense': true},
  ];
  
  // Verification documents  
  File? _idDocument;
  File? _licenseDocument;
  File? _selfiePhoto;
  
  // Service area
  String _selectedCity = 'Accra';
  List<String> _selectedNeighborhoods = [];
  double _serviceRadius = 10.0;
  
  final List<String> _cities = ['Accra', 'Kumasi', 'Tamale', 'Cape Coast', 'Takoradi'];
  final Map<String, List<String>> _neighborhoods = {
    'Accra': ['East Legon', 'Osu', 'Labone', 'Airport Residential', 'Cantonments', 'Adenta', 'Tema'],
    'Kumasi': ['Nhyiaeso', 'Adum', 'Bantama', 'Asafo', 'Suame'],
    'Tamale': ['Central', 'Kalpohin', 'Lamashegu', 'Gumbihini'],
    'Cape Coast': ['Pedu', 'Adisadel', 'University', 'Ola'],
    'Takoradi': ['Beach Road', 'Market Circle', 'New Takoradi', 'Effia-Kuma'],
  };
  
  // Availability
  final Map<String, TimeSlot> _weeklySchedule = {
    'monday': TimeSlot(startTime: '08:00', endTime: '18:00', isAvailable: true),
    'tuesday': TimeSlot(startTime: '08:00', endTime: '18:00', isAvailable: true),
    'wednesday': TimeSlot(startTime: '08:00', endTime: '18:00', isAvailable: true),
    'thursday': TimeSlot(startTime: '08:00', endTime: '18:00', isAvailable: true),
    'friday': TimeSlot(startTime: '08:00', endTime: '18:00', isAvailable: true),
    'saturday': TimeSlot(startTime: '09:00', endTime: '17:00', isAvailable: true),
    'sunday': TimeSlot(startTime: '09:00', endTime: '17:00', isAvailable: false),
  };
  
  // Banking info
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _mobileMoneyController = TextEditingController();
  String _selectedPayoutMethod = 'bank';
  String _selectedMobileProvider = 'MTN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006B3C),
              Color(0xFF228B22),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_currentStep > 0)
                          IconButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCD116),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Step ${_currentStep + 1} of 6',
                            style: const TextStyle(
                              color: Color(0xFF006B3C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress bar
                    Row(
                      children: List.generate(6, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: index <= _currentStep 
                                  ? const Color(0xFFFCD116)
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentStep = page;
                      });
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildBasicInfoPage(),
                      _buildServicesPage(),
                      _buildVerificationPage(),
                      _buildServiceAreaPage(),
                      _buildBankingPage(),
                    ],
                  ),
                ),
              ),
              
              // Navigation
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _canProceed() ? _proceedNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_getNextButtonText()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF006B3C), width: 3),
            ),
            child: const Icon(
              Icons.handshake,
              size: 60,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Join Our Provider Network',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Get clients. Get paid. Build your reputation.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF006B3C), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Connect with customers who need your services'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF006B3C), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Set your own schedule and work area'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF006B3C), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Get paid securely through the app'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF006B3C), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Build your reputation with customer reviews'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🔐 Your data is secure. Review takes 1-2 business days.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
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

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            TextFormField(
              controller: _nameController,
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
            const SizedBox(height: 20),
            
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
            const SizedBox(height: 20),
            
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
          ],
        ),
      ),
    );
  }

  Widget _buildServicesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Services You Offer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select all services you can provide',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _availableServices.length,
            itemBuilder: (context, index) {
              final service = _availableServices[index];
              final isSelected = _selectedServices.contains(service['name']);
              
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedServices.remove(service['name']);
                    } else {
                      _selectedServices.add(service['name']);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF006B3C).withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF006B3C) : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        service['icon'],
                        size: 40,
                        color: isSelected ? const Color(0xFF006B3C) : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF006B3C) : Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (service['requiresLicense'])
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'License Required',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          if (_selectedServices.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF006B3C).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedServices.length} services selected',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedServices.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Identity Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload required documents for verification',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          // ID Document
          _buildDocumentUpload(
            title: 'Government ID *',
            subtitle: 'Ghana Card, Passport, or Driver\'s License',
            icon: Icons.badge,
            file: _idDocument,
            onTap: () => _pickDocument('id'),
          ),
          
          const SizedBox(height: 24),
          
          // License (if required)
          if (_selectedServices.any((service) => 
              _availableServices.firstWhere((s) => s['name'] == service)['requiresLicense'])) ...[
            _buildDocumentUpload(
              title: 'Professional License *',
              subtitle: 'Required for selected services',
              icon: Icons.verified,
              file: _licenseDocument,
              onTap: () => _pickDocument('license'),
            ),
            const SizedBox(height: 24),
          ],
          
          // Selfie
          _buildDocumentUpload(
            title: 'Selfie Photo *',
            subtitle: 'Hold your ID next to your face',
            icon: Icons.camera_alt,
            file: _selfiePhoto,
            onTap: () => _pickDocument('selfie'),
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Verification Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Ensure documents are clear and readable\n'
                  '• All text should be visible\n'
                  '• Take photos in good lighting\n'
                  '• Your face should be clearly visible in the selfie',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAreaPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Service Area',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose where you want to work',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          // City selection
          const Text(
            'Primary City',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value!;
                _selectedNeighborhoods.clear();
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Neighborhoods
          const Text(
            'Preferred Neighborhoods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _neighborhoods[_selectedCity]!.map((neighborhood) {
              final isSelected = _selectedNeighborhoods.contains(neighborhood);
              return FilterChip(
                label: Text(neighborhood),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedNeighborhoods.add(neighborhood);
                    } else {
                      _selectedNeighborhoods.remove(neighborhood);
                    }
                  });
                },
                selectedColor: const Color(0xFF006B3C).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF006B3C),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Service radius
          const Text(
            'Service Radius',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '${_serviceRadius.round()} kilometers',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _serviceRadius,
            min: 5,
            max: 50,
            divisions: 9,
            activeColor: const Color(0xFF006B3C),
            onChanged: (value) {
              setState(() {
                _serviceRadius = value;
              });
            },
          ),
          const Text(
            'How far are you willing to travel for jobs?',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBankingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _bankingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How would you like to receive payments?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Payment method selection
            const Text(
              'Preferred Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              title: const Text('Bank Account'),
              subtitle: const Text('Direct deposit to your bank account'),
              value: 'bank',
              groupValue: _selectedPayoutMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPayoutMethod = value!;
                });
              },
              activeColor: const Color(0xFF006B3C),
            ),
            
            RadioListTile<String>(
              title: const Text('Mobile Money'),
              subtitle: const Text('MTN, Vodafone, or AirtelTigo'),
              value: 'mobile_money',
              groupValue: _selectedPayoutMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPayoutMethod = value!;
                });
              },
              activeColor: const Color(0xFF006B3C),
            ),
            
            const SizedBox(height: 24),
            
            // Bank details
            if (_selectedPayoutMethod == 'bank') ...[
              TextFormField(
                controller: _accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name *',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number *',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
            ],
            
            // Mobile money details
            if (_selectedPayoutMethod == 'mobile_money') ...[
              DropdownButtonFormField<String>(
                value: _selectedMobileProvider,
                decoration: const InputDecoration(
                  labelText: 'Mobile Money Provider *',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                ),
                items: ['MTN', 'Vodafone', 'AirtelTigo'].map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Text(provider),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMobileProvider = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _mobileMoneyController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Money Number *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '024XXXXXXX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile money number';
                  }
                  return null;
                },
              ),
            ],
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '💸 Your payment information is encrypted and secure. You\'ll receive payments within 24 hours of job completion.',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null ? const Color(0xFF006B3C) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: file != null ? const Color(0xFF006B3C).withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: file != null ? const Color(0xFF006B3C) : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                file != null ? Icons.check : icon,
                color: file != null ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? 'Document uploaded' : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: file != null ? const Color(0xFF006B3C) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.edit : Icons.camera_alt,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: return true; // Welcome
      case 1: return _nameController.text.isNotEmpty && 
                     _phoneController.text.isNotEmpty && 
                     _emailController.text.isNotEmpty; // Basic info
      case 2: return _selectedServices.isNotEmpty; // Services
      case 3: return _idDocument != null && _selfiePhoto != null && 
                     (!_requiresLicense() || _licenseDocument != null); // Verification
      case 4: return _selectedNeighborhoods.isNotEmpty; // Service area
      case 5: return _selectedPayoutMethod == 'bank' 
                     ? (_accountHolderController.text.isNotEmpty && 
                        _bankNameController.text.isNotEmpty && 
                        _accountNumberController.text.isNotEmpty)
                     : _mobileMoneyController.text.isNotEmpty; // Banking
      default: return false;
    }
  }

  bool _requiresLicense() {
    return _selectedServices.any((service) => 
        _availableServices.firstWhere((s) => s['name'] == service)['requiresLicense']);
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0: return 'Get Started';
      case 5: return 'Submit Application';
      default: return 'Continue';
    }
  }

  void _proceedNext() {
    if (_currentStep == 5) {
      _submitApplication();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickDocument(String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        switch (type) {
          case 'id':
            _idDocument = File(image.path);
            break;
          case 'license':
            _licenseDocument = File(image.path);
            break;
          case 'selfie':
            _selfiePhoto = File(image.path);
            break;
        }
      });
    }
  }

  void _submitApplication() {
    // Show submission dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF006B3C),
            ),
            const SizedBox(height: 16),
            const Text(
              'Submitting Application...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait while we process your information',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate submission
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF006B3C),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for joining HomeLinkGH! We\'ll review your application and get back to you within 1-2 business days.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to role selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose(); 
    _accountNumberController.dispose();
    _mobileMoneyController.dispose();
    super.dispose();
  }
}