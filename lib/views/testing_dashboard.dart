import 'package:flutter/material.dart';
import '../services/test_data_service.dart';
import 'role_selection.dart';

class TestingDashboard extends StatefulWidget {
  const TestingDashboard({super.key});

  @override
  State<TestingDashboard> createState() => _TestingDashboardState();
}

class _TestingDashboardState extends State<TestingDashboard> {
  bool _isLoading = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Dashboard'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Display
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),

            // Quick Test Users Section
            _buildSection(
              'Quick Test Users',
              [
                _buildTestUserButton(
                  'Customer Test User',
                  'customer@test.com',
                  'customer',
                  Icons.person,
                  Colors.blue,
                ),
                _buildTestUserButton(
                  'Diaspora Test User',
                  'diaspora@test.com',
                  'diaspora_customer',
                  Icons.flight_land,
                  Colors.purple,
                ),
                _buildTestUserButton(
                  'Job Seeker Test User',
                  'jobseeker@test.com',
                  'job_seeker',
                  Icons.work_outline,
                  Colors.orange,
                ),
                _buildTestUserButton(
                  'Provider Test User',
                  'provider@test.com',
                  'provider',
                  Icons.verified,
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Management Section
            _buildSection(
              'Data Management',
              [
                _buildActionButton(
                  'Initialize Full Test Data',
                  'Creates comprehensive test data for all features',
                  Icons.data_object,
                  Colors.blue,
                  _initializeTestData,
                ),
                _buildActionButton(
                  'Clear Test Data',
                  'Removes all test data from Firebase',
                  Icons.delete_sweep,
                  Colors.red,
                  _clearTestData,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Navigation Section
            _buildSection(
              'Quick Navigation',
              [
                _buildNavigationButton(
                  'Go to Role Selection',
                  'Test the main app flow',
                  Icons.home,
                  Colors.green,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Testing Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('1. Initialize test data first'),
                  Text('2. Create test users with different roles'),
                  Text('3. Test login and workflows'),
                  Text('4. Use real Ghana locations and services'),
                  Text('5. Clear data when testing is complete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3C),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTestUserButton(
    String title,
    String email,
    String userType,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(email),
        trailing: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        onTap: _isLoading ? null : () => _createTestUser(email, userType, title),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }

  Widget _buildNavigationButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.navigate_next),
        onTap: onTap,
      ),
    );
  }

  Future<void> _createTestUser(String email, String userType, String name) async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test user...';
    });

    try {
      await TestDataService.createTestUser(
        email: email,
        password: 'test123456',
        name: name,
        userType: userType,
        phone: '+233244123456',
      );

      setState(() {
        _status = '✅ Created test user: $email\nPassword: test123456';
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Test User Created'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: $email'),
                const Text('Password: test123456'),
                const SizedBox(height: 8),
                const Text('You can now use these credentials to test the app.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error creating user: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Initializing comprehensive test data...';
    });

    try {
      await TestDataService.initializeTestData();
      setState(() {
        _status = '✅ Test data initialized successfully!\nYou can now test all app features with real Ghana data.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error initializing test data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearTestData() async {
    // Confirm before clearing
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Test Data'),
        content: const Text('This will delete all test data from Firebase. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _status = 'Clearing test data...';
    });

    try {
      await TestDataService.clearTestData();
      setState(() {
        _status = '✅ Test data cleared successfully!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error clearing test data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}