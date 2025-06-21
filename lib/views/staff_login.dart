import 'package:flutter/material.dart';
import 'staff_dashboard.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedRole;
  bool isLoading = false;

  final List<Map<String, dynamic>> staffRoles = [
    {
      'id': 'customer_support',
      'title': 'Customer Support Representative',
      'description': 'Handle customer inquiries and support',
      'icon': Icons.support_agent,
      'color': Colors.blue,
    },
    {
      'id': 'provider_verification',
      'title': 'Provider Onboarding & Verification Officer',
      'description': 'Verify and onboard service providers',
      'icon': Icons.verified_user,
      'color': Colors.green,
    },
    {
      'id': 'app_coordinator',
      'title': 'Mobile App Project Coordinator',
      'description': 'Coordinate app development and updates',
      'icon': Icons.phone_android,
      'color': Colors.purple,
    },
    {
      'id': 'operations_manager',
      'title': 'Operations Manager',
      'description': 'Oversee all operational activities',
      'icon': Icons.business_center,
      'color': Colors.orange,
    },
    {
      'id': 'general_manager',
      'title': 'General Manager',
      'description': 'Executive oversight and strategic management',
      'icon': Icons.account_balance,
      'color': Colors.red,
    },
    {
      'id': 'marketing_manager',
      'title': 'Marketing & Social Media Manager',
      'description': 'Manage marketing campaigns and social media',
      'icon': Icons.campaign,
      'color': Colors.pink,
    },
    {
      'id': 'finance_assistant',
      'title': 'Finance & Payments Assistant',
      'description': 'Handle financial operations and payments',
      'icon': Icons.account_balance_wallet,
      'color': Colors.teal,
    },
    {
      'id': 'field_supervisor',
      'title': 'Field Supervisor',
      'description': 'Supervise field operations across Ghana',
      'icon': Icons.location_on,
      'color': Colors.brown,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeLinkGH Staff Login'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.business,
                      size: 80,
                      color: Color(0xFF006B3C),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Staff Portal',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Access your HomeLinkGH work dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Role Selection
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    hintText: 'Choose your position...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your role';
                    }
                    return null;
                  },
                  items: staffRoles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role['id'],
                      child: Row(
                        children: [
                          Icon(
                            role['icon'],
                            color: role['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  role['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  role['description'],
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Work Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your work email';
                  }
                  if (!value.contains('@homelink.gh') && !value.contains('@gmail.com')) {
                    return 'Please use your official work email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
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
                            Text('Signing In...'),
                          ],
                        )
                      : const Text(
                          'Sign In to Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Help Links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _showForgotPassword(),
                    child: const Text('Forgot Password?'),
                  ),
                  TextButton(
                    onPressed: () => _showContactIT(),
                    child: const Text('Contact IT Support'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Role Information
              if (selectedRole != null) _buildRoleInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleInfo() {
    final role = staffRoles.firstWhere((r) => r['id'] == selectedRole);
    
    return Card(
      color: role['color'].withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  role['icon'],
                  color: role['color'],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    role['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              role['description'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Dashboard Access: ${_getDashboardAccess(selectedRole!)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDashboardAccess(String roleId) {
    switch (roleId) {
      case 'general_manager':
        return 'Full system access, executive reports, business intelligence';
      case 'operations_manager':
        return 'Operations oversight, performance metrics, resource management';
      case 'customer_support':
        return 'Customer tickets, live chat, knowledge base, dispute resolution';
      case 'provider_verification':
        return 'Provider onboarding, verification workflows, compliance tracking';
      case 'app_coordinator':
        return 'App metrics, user feedback, technical coordination, testing tools';
      case 'marketing_manager':
        return 'Campaign management, social media, analytics, content creation';
      case 'finance_assistant':
        return 'Payment processing, financial reports, exchange rates, reconciliation';
      case 'field_supervisor':
        return 'Field operations, site inspections, team coordination, quality control';
      default:
        return 'Standard dashboard access';
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));
      
      // In production, validate credentials with backend
      final isValidLogin = _validateCredentials(_emailController.text, _passwordController.text);
      
      if (isValidLogin) {
        final staffName = _getStaffName(_emailController.text);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDashboardScreen(
              staffRole: selectedRole!,
              staffName: staffName,
              staffId: 'staff_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateCredentials(String email, String password) {
    // Demo validation - in production, validate with backend
    final demoCredentials = {
      'support@homelink.gh': 'support123',
      'verification@homelink.gh': 'verify123',
      'coordinator@homelink.gh': 'coord123',
      'operations@homelink.gh': 'ops123',
      'manager@homelink.gh': 'mgr123',
      'marketing@homelink.gh': 'market123',
      'finance@homelink.gh': 'finance123',
      'field@homelink.gh': 'field123',
    };
    
    return demoCredentials[email] == password;
  }

  String _getStaffName(String email) {
    final nameMap = {
      'support@homelink.gh': 'Akosua Mensah',
      'verification@homelink.gh': 'Kwame Asante',
      'coordinator@homelink.gh': 'Ama Osei',
      'operations@homelink.gh': 'Kofi Adjei',
      'manager@homelink.gh': 'Abena Darko',
      'marketing@homelink.gh': 'Yaw Boateng',
      'finance@homelink.gh': 'Efua Amoah',
      'field@homelink.gh': 'Kwaku Owusu',
    };
    
    return nameMap[email] ?? 'Staff Member';
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To reset your password, please contact:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('it-support@homelink.gh'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('+233 (0) 30 123 4567 ext. 101'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'IT Support Hours: Monday - Friday, 8:00 AM - 6:00 PM',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showContactIT() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IT Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need technical assistance?'),
            SizedBox(height: 16),
            Text(
              'IT Support Team',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('it-support@homelink.gh'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('+233 (0) 30 123 4567 ext. 101'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.chat, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text('Internal Chat: #it-help'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Common Issues:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Password reset'),
            Text('• Account access problems'),
            Text('• Dashboard technical issues'),
            Text('• System performance problems'),
            SizedBox(height: 8),
            Text(
              'Response time: Within 2 hours during business hours',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('IT support request submitted'),
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