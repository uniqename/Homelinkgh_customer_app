import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider.dart';
import '../models/booking.dart';
import '../services/local_data_service.dart';
import '../services/smart_selection_service.dart';
import 'role_selection.dart';

class SmartBookingFlowScreen extends StatefulWidget {
  final String serviceType;
  final bool isGuestUser;
  final Provider? selectedProvider;

  const SmartBookingFlowScreen({
    super.key,
    required this.serviceType,
    this.isGuestUser = false,
    this.selectedProvider,
  });

  @override
  State<SmartBookingFlowScreen> createState() => _SmartBookingFlowScreenState();
}

class _SmartBookingFlowScreenState extends State<SmartBookingFlowScreen> {
  final PageController _pageController = PageController();
  final LocalDataService _localData = LocalDataService();
  
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Booking details
  String _description = '';
  String _address = '';
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  double _estimatedPrice = 150.0;
  
  // User details (collected during booking)
  String _userName = '';
  String _userPhone = '';
  String _userEmail = '';
  String _selectedRole = 'customer';
  
  List<Provider> _recommendedProviders = [];
  Provider? _selectedProvider;
  bool _isLoadingProviders = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.selectedProvider;
    if (_selectedProvider == null) {
      _loadRecommendedProviders();
    }
  }

  Future<void> _loadRecommendedProviders() async {
    setState(() => _isLoadingProviders = true);
    
    try {
      final providers = await _localData.getProvidersByService(widget.serviceType);
      setState(() {
        _recommendedProviders = providers;
        _isLoadingProviders = false;
      });
    } catch (e) {
      setState(() => _isLoadingProviders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.serviceType}'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildServiceDetailsStep(),
                _buildProviderSelectionStep(),
                _buildUserDetailsStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Details', 'Provider', 'Your Info', 'Confirm'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isActive = index <= _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isActive ? const Color(0xFF006B3C) : Colors.grey[300],
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF006B3C) : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    height: 1,
                    width: 8,
                    color: isActive ? const Color(0xFF006B3C) : Colors.grey[300],
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about your ${widget.serviceType} needs',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what you need...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your service needs';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Service Address',
                hintText: 'Where should the service be provided?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide the service address';
                }
                return null;
              },
              onSaved: (value) => _address = value!,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Preferred Date & Time'),
              subtitle: Text(_scheduledDate.toString().split('.')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF006B3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF006B3C)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estimated price: GH₵${_estimatedPrice.toStringAsFixed(0)}\\n'
                      'Final price will be confirmed by your selected provider.',
                      style: const TextStyle(fontSize: 14),
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

  Widget _buildProviderSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Provider',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectedProvider != null 
                ? 'Pre-selected provider:'
                : 'Recommended providers for ${widget.serviceType}:',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (_isLoadingProviders)
            const Center(child: CircularProgressIndicator())
          else if (widget.selectedProvider != null)
            _buildProviderCard(widget.selectedProvider!, isSelected: true)
          else
            Expanded(
              child: ListView.builder(
                itemCount: _recommendedProviders.length,
                itemBuilder: (context, index) {
                  final provider = _recommendedProviders[index];
                  return _buildProviderCard(
                    provider,
                    isSelected: _selectedProvider?.id == provider.id,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Provider provider, {bool isSelected = false}) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF006B3C) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.selectedProvider == null ? () {
          setState(() => _selectedProvider = provider);
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF006B3C),
                child: Text(
                  provider.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.orange[400],
                        ),
                        const SizedBox(width: 4),
                        Text('${provider.rating} (${provider.completedJobs} jobs)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Response time: ~${provider.averageResponseTime} min',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
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
      ),
    );
  }

  Widget _buildUserDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This creates your HomeLinkGH account so you can track your booking and use the app.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onSaved: (value) => _userName = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+233 XX XXX XXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onSaved: (value) => _userPhone = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _userEmail = value!,
            ),
            const SizedBox(height: 20),
            const Text(
              'Account Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can always add more roles later (like becoming a provider).',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _buildRoleCard(
              'customer',
              'Customer',
              'Book services and manage your orders',
              Icons.shopping_cart,
              Colors.blue,
            ),
            _buildRoleCard(
              'diaspora',
              'Diaspora Customer',
              'Book services for family/friends in Ghana',
              Icons.flight,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String title, String description, IconData icon, Color color) {
    final isSelected = _selectedRole == role;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _selectedRole = role);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
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
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'What happens next?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Your account will be created automatically\\n'
                    '2. Your provider will be notified of your booking\\n'
                    '3. You\'ll receive SMS and email confirmations\\n'
                    '4. Your provider will contact you to confirm details\\n'
                    '5. No password needed - you\'ll auto-login next time!',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Service', widget.serviceType),
            _buildSummaryRow('Description', _description),
            _buildSummaryRow('Address', _address),
            _buildSummaryRow('Date & Time', _scheduledDate.toString().split('.')[0]),
            _buildSummaryRow('Provider', _selectedProvider?.name ?? 'Not selected'),
            _buildSummaryRow('Your Name', _userName),
            _buildSummaryRow('Phone', _userPhone),
            _buildSummaryRow('Email', _userEmail),
            const Divider(),
            _buildSummaryRow(
              'Estimated Total',
              'GH₵${_estimatedPrice.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFF006B3C) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_getNextButtonText()),
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
        return 'Confirm Booking';
      default:
        return 'Next';
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    } else if (_currentStep == 1) {
      if (_selectedProvider != null || widget.selectedProvider != null) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a provider')),
        );
      }
    } else if (_currentStep == 2) {
      if (_validateUserForm()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    } else if (_currentStep == 3) {
      _confirmBooking();
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _validateUserForm() {
    if (_userName.isEmpty || _userPhone.isEmpty || _userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return false;
    }
    return true;
  }

  Future<void> _confirmBooking() async {
    try {
      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', _selectedRole);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_phone', _userPhone);
      await prefs.setString('user_email', _userEmail);

      // Create booking
      final booking = Booking(
        customerId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        providerId: _selectedProvider!.id,
        serviceType: widget.serviceType,
        description: _description,
        scheduledDate: _scheduledDate,
        address: _address,
        price: _estimatedPrice,
        status: 'pending',
      );

      final bookingId = await _localData.createBooking(booking);

      // Show success and navigate
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Booking ID: ${bookingId.substring(0, 8)}\\n\\n'
                  'Your account has been created and you\'re now logged in!\\n\\n'
                  '${_selectedProvider!.name} will contact you soon.',
                  textAlign: TextAlign.center,
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
                      builder: (context) => RoleSelectionScreen(savedRole: _selectedRole),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue to App'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate != null && mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate),
      );

      if (selectedTime != null) {
        setState(() {
          _scheduledDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }
}