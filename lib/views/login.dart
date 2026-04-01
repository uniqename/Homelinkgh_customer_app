import 'package:flutter/material.dart';
import 'package:homelinkgh_customer/services/biometric_auth_service.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _bioAuth = BiometricAuthService();
  bool _canUseBiometric = false;
  bool _biometricEnabled = false;
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final canUse = await _bioAuth.canUseBiometrics();
    final enabled = await _bioAuth.isBiometricLoginEnabled();
    final bioType = await _bioAuth.getBiometricTypeName();
    setState(() {
      _canUseBiometric = canUse;
      _biometricEnabled = enabled;
      _biometricType = bioType;
    });

    // Auto-attempt biometric login if enabled
    if (enabled && canUse) {
      _attemptBiometricLogin();
    }
  }

  Future<void> _attemptBiometricLogin() async {
    final credentials = await _bioAuth.biometricLogin();
    if (credentials != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProviderDashboard(),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Simulate login success - in real app, validate with backend
      final email = _emailController.text;

      // Ask user if they want to enable biometric login
      if (_canUseBiometric && !_biometricEnabled && mounted) {
        final enableBio = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Enable $_biometricType?'),
            content: Text('Would you like to use $_biometricType for quick login next time?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enable'),
              ),
            ],
          ),
        );

        if (enableBio == true) {
          await _bioAuth.setupBiometricLogin(
            email: email,
            userId: email, // In real app, use actual user ID
          );
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProviderDashboard(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Portal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_outline,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Provider Login',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your services and bookings',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Provider Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login to Dashboard'),
                ),
              ),
              if (_canUseBiometric && _biometricEnabled) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _attemptBiometricLogin,
                  icon: Icon(
                    _biometricType == 'Face ID' ? Icons.face : Icons.fingerprint,
                  ),
                  label: Text('Login with $_biometricType'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}