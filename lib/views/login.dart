import 'package:flutter/material.dart';
import 'customer_home.dart';
import 'provider_dashboard.dart';
import 'diaspora_home.dart';
import 'dynamic_home.dart';

class LoginScreen extends StatefulWidget {
  final String userType;
  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String title = widget.userType == 'customer' 
        ? 'Customer Login' 
        : widget.userType == 'provider'
        ? 'Provider Login'
        : widget.userType == 'diaspora_customer'
        ? 'Diaspora Mode - Login'
        : widget.userType == 'family_helper'
        ? 'Family Helper - Login'
        : 'Login';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                widget.userType == 'diaspora_customer' ? Icons.flight_land :
                widget.userType == 'family_helper' ? Icons.family_restroom :
                widget.userType == 'customer' ? Icons.person : Icons.work,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                widget.userType == 'diaspora_customer' ? 'Akwaba! Welcome Home 🇬🇭' :
                widget.userType == 'family_helper' ? 'Caring from Afar ❤️' :
                'Welcome Back!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (widget.userType == 'diaspora_customer')
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Plan your trip, we\'ll prep your house',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF006B3C),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.userType == 'customer') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicHomeScreen(
                            userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                            userType: 'local_customer',
                          ),
                        ),
                      );
                    } else if (widget.userType == 'diaspora_customer') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicHomeScreen(
                            userId: 'diaspora_${DateTime.now().millisecondsSinceEpoch}',
                            userType: 'diaspora_customer',
                          ),
                        ),
                      );
                    } else if (widget.userType == 'family_helper') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicHomeScreen(
                            userId: 'family_${DateTime.now().millisecondsSinceEpoch}',
                            userType: 'family_helper',
                          ),
                        ),
                      );
                    } else if (widget.userType == 'provider') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProviderDashboardScreen(),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
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