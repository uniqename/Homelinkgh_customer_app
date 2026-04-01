import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/standalone_service.dart';
import '../main.dart';

class SimpleLoginScreen extends StatefulWidget {
  final String userType;
  const SimpleLoginScreen({super.key, required this.userType});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
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
        : widget.userType == 'job_seeker'
        ? 'Job Seeker - Get Started'
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
                    _navigateToUserScreen();
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

  void _navigateToUserScreen() async {
    // Store user role and navigate to the appropriate full-featured screen
    final prefs = await SharedPreferences.getInstance();
    String role;
    
    switch (widget.userType) {
      case 'diaspora_customer':
      case 'family_helper':
      case 'customer':
        role = 'customer';
        break;
      case 'provider':
        role = 'provider';
        break;
      case 'admin':
        role = 'admin';
        break;
      case 'staff':
        role = 'staff';
        break;
      case 'job_seeker':
        role = 'job_seeker';
        break;
      default:
        role = 'customer';
    }
    
    await prefs.setString('userRole', role);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeLinkGHApp()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}