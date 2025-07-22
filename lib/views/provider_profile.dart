import 'package:flutter/material.dart';
import '../constants/service_types.dart';

class ProviderProfile extends StatefulWidget {
  const ProviderProfile({super.key});

  @override
  State<ProviderProfile> createState() => _ProviderProfileState();
}

class _ProviderProfileState extends State<ProviderProfile> {
  bool _isEditing = false;
  
  // Mock provider data
  final TextEditingController _nameController = TextEditingController(text: 'Kwame Asante');
  final TextEditingController _emailController = TextEditingController(text: 'kwame.asante@homelinkgh.com');
  final TextEditingController _phoneController = TextEditingController(text: '+233 24 123 4567');
  final TextEditingController _addressController = TextEditingController(text: 'East Legon, Accra');
  final TextEditingController _bioController = TextEditingController(text: 'Experienced home service provider with 5+ years in cleaning and maintenance services.');
  
  List<String> _selectedServices = ['House Cleaning', 'Plumbing', 'Electrical Services'];
  final List<String> _availableServices = [
    'House Cleaning',
    'Plumbing',
    'Electrical Services',
    'HVAC',
    'Landscaping',
    'Painting',
    'Carpentry',
    'Food Delivery',
    'Transportation',
  ];
  
  double _rating = 4.8;
  int _completedJobs = 127;
  bool _isVerified = true;
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // Personal Information
          _buildPersonalInfoSection(),
          const SizedBox(height: 24),
          
          // Services Section
          _buildServicesSection(),
          const SizedBox(height: 24),
          
          // Statistics Section
          _buildStatsSection(),
          const SizedBox(height: 24),
          
          // Settings Section
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF006B3C),
                      child: Text(
                        _nameController.text.isNotEmpty 
                            ? _nameController.text[0].toUpperCase() 
                            : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _nameController.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            icon: Icon(_isEditing ? Icons.save : Icons.edit),
                            color: const Color(0xFF006B3C),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' $_rating'),
                          const SizedBox(width: 16),
                          Text('$_completedJobs jobs completed'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isAvailable ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isAvailable ? 'Available' : 'Unavailable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField('Full Name', _nameController, Icons.person),
            const SizedBox(height: 12),
            _buildEditableField('Email', _emailController, Icons.email),
            const SizedBox(height: 12),
            _buildEditableField('Phone', _phoneController, Icons.phone),
            const SizedBox(height: 12),
            _buildEditableField('Address', _addressController, Icons.location_on),
            const SizedBox(height: 12),
            _buildEditableField('Bio', _bioController, Icons.info, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
            filled: !_isEditing,
            fillColor: _isEditing ? null : Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Specialties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isEditing)
                  TextButton(
                    onPressed: _showServiceSelector,
                    child: const Text('Edit Services'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedServices.map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF006B3C).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ServiceTypes.getIconForService(service)),
                      const SizedBox(width: 4),
                      Text(service),
                      if (_isEditing) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedServices.remove(service);
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Rating', '$_rating ⭐', Colors.amber),
                ),
                Expanded(
                  child: _buildStatItem('Jobs Completed', '$_completedJobs', Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('Response Time', '< 2 hrs', Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Available for Jobs'),
              subtitle: const Text('Accept new job requests'),
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showNotificationSettings,
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Privacy & Security'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showPrivacySettings,
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showHelpSupport,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF006B3C)),
              title: const Text('Switch to Customer'),
              subtitle: const Text('Access customer services'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _switchToCustomer,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showDeleteAccountOptions,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Sign Out'),
              subtitle: const Text('Sign out of your account'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Services'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _availableServices.map((service) {
              final isSelected = _selectedServices.contains(service);
              return CheckboxListTile(
                title: Row(
                  children: [
                    Text(ServiceTypes.getIconForService(service)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(service)),
                  ],
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedServices.add(service);
                    } else {
                      _selectedServices.remove(service);
                    }
                  });
                  Navigator.pop(context);
                  _showServiceSelector(); // Refresh dialog
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings would open here'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings would open here'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _showHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & support would open here'),
        backgroundColor: Color(0xFF006B3C),
      ),
    );
  }

  void _switchToCustomer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch to Customer'),
        content: const Text('Do you want to switch to customer mode? You can switch back to provider mode anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to customer dashboard
              Navigator.pushReplacementNamed(context, '/customer-dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose what you want to delete:'),
            SizedBox(height: 16),
            Text('⚠️ Warning: These actions cannot be undone!', 
                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteData();
            },
            child: const Text('Delete Data Only', style: TextStyle(color: Colors.orange)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Personal Data'),
        content: const Text(
          'This will delete your personal data, job history, and earnings data while keeping your account active. You can continue providing services but will lose all historical information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDataDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Data'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account Permanently'),
        content: const Text(
          'This will permanently delete your account, all data, job history, and earnings. You will not be able to recover this information or provide services on HomeLinkGH.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performAccountDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _performDataDeletion() {
    // Simulate data deletion process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deleting your personal data...'),
          ],
        ),
      ),
    );

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Remove loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Deleted'),
          content: const Text('Your personal data has been successfully deleted. Your account remains active for providing services.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Refresh profile data
                setState(() {
                  _nameController.text = 'Provider';
                  _emailController.text = '';
                  _phoneController.text = '';
                  _addressController.text = '';
                  _bioController.text = '';
                  _completedJobs = 0;
                  _rating = 0.0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _performAccountDeletion() {
    // Simulate account deletion process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deleting your account...'),
          ],
        ),
      ),
    );

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Remove loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Account Deleted'),
          content: const Text('Your account has been permanently deleted. Thank you for using HomeLinkGH.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to login/welcome screen
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear any stored authentication data here
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully signed out'),
                  backgroundColor: Color(0xFF006B3C),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
