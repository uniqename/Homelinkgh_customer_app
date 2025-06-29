import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/real_firebase_service.dart';
import 'real_login_screen.dart';
import 'customer_home.dart';
import 'provider_dashboard.dart';
import 'diaspora_home.dart';

/// Signup screen for creating new HomeLinkGH accounts
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final RealFirebaseService _firebaseService = RealFirebaseService();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ghanaCardController = TextEditingController();
  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _ghanaLocationController = TextEditingController();
  final TextEditingController _ghanaContactController = TextEditingController();
  
  String _selectedUserType = 'customer';
  List<String> _selectedServices = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  int _currentPage = 0;

  final List<String> _availableServices = [
    'House Cleaning',
    'Food Delivery',
    'Transportation',
    'Beauty Services',
    'Plumbing',
    'Electrical Work',
    'Gardening',
    'Childcare',
    'Elderly Care',
    'Laundry Service',
    'Tutoring',
    'Photography',
    'Event Planning',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _businessNameController.dispose();
    _ghanaCardController.dispose();
    _currentLocationController.dispose();
    _ghanaLocationController.dispose();
    _ghanaContactController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildUserTypeSelection(),
                _buildAccountDetailsForm(),
                _buildAdditionalDetailsForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentPage ? const Color(0xFF006B3C) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 2) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose Your Account Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildUserTypeCard(
            'customer',
            'Customer',
            'Book services for your home in Ghana',
            Icons.home,
          ),
          const SizedBox(height: 16),
          _buildUserTypeCard(
            'provider',
            'Service Provider',
            'Offer your services to customers',
            Icons.work,
          ),
          const SizedBox(height: 16),
          _buildUserTypeCard(
            'diaspora_customer',
            'Diaspora Customer',
            'Book services for family in Ghana from abroad',
            Icons.public,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _nextPage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard(String type, String title, String description, IconData icon) {
    final isSelected = _selectedUserType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006B3C).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF006B3C) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF006B3C) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF006B3C) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF006B3C),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Account Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _previousPage(),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _nextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_selectedUserType == 'customer') ..._buildCustomerFields(),
            if (_selectedUserType == 'provider') ..._buildProviderFields(),
            if (_selectedUserType == 'diaspora_customer') ..._buildDiasporaFields(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _previousPage(),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3C),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCustomerFields() {
    return [
      _buildTextField(
        controller: _locationController,
        label: 'Location in Ghana',
        icon: Icons.location_on,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your location';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildProviderFields() {
    return [
      _buildTextField(
        controller: _businessNameController,
        label: 'Business Name',
        icon: Icons.business,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your business name';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _locationController,
        label: 'Service Location in Ghana',
        icon: Icons.location_on,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your service location';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _ghanaCardController,
        label: 'Ghana Card Number (Optional)',
        icon: Icons.credit_card,
      ),
      const SizedBox(height: 16),
      _buildServicesSelection(),
    ];
  }

  List<Widget> _buildDiasporaFields() {
    return [
      _buildTextField(
        controller: _currentLocationController,
        label: 'Your Current Country/City',
        icon: Icons.public,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your current location';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _ghanaLocationController,
        label: 'Family Location in Ghana',
        icon: Icons.location_on,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your family location in Ghana';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _ghanaContactController,
        label: 'Ghana Contact Person (Optional)',
        icon: Icons.contact_phone,
      ),
    ];
  }

  Widget _buildServicesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services You Offer:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableServices.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
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
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one service',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006B3C), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006B3C), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006B3C), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    setState(() {
      _currentPage--;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSignUp() async {
    // Validate additional fields
    if (_selectedUserType == 'provider' && _selectedServices.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one service you offer';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      late UserCredential credential;

      switch (_selectedUserType) {
        case 'customer':
          credential = await _authService.createCustomerAccount(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            location: _locationController.text.trim(),
          );
          break;

        case 'provider':
          credential = await _authService.createProviderAccount(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            businessName: _businessNameController.text.trim(),
            services: _selectedServices,
            location: _locationController.text.trim(),
            ghanaCardNumber: _ghanaCardController.text.trim(),
          );
          break;

        case 'diaspora_customer':
          credential = await _authService.createDiasporaAccount(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            currentLocation: _currentLocationController.text.trim(),
            ghanaLocation: _ghanaLocationController.text.trim(),
            ghanaContact: _ghanaContactController.text.trim(),
          );
          break;
      }

      if (mounted) {
        // Navigate to appropriate home screen
        Widget homeScreen;
        
        switch (_selectedUserType) {
          case 'provider':
            homeScreen = const ProviderDashboard();
            break;
          case 'diaspora_customer':
            homeScreen = const DiasporaHomeScreen();
            break;
          case 'customer':
          default:
            homeScreen = const CustomerHomeScreen();
            break;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => homeScreen),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Welcome to HomeLinkGH!'),
            backgroundColor: Color(0xFF006B3C),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}