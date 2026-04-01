import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customer_home.dart';
import 'provider_dashboard.dart';
import 'admin_login.dart';
import 'dynamic_home.dart';
import 'staff_login.dart';
import 'jobs_careers.dart';
import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final String? savedRole;
  
  const RoleSelectionScreen({super.key, this.savedRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040D08),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [Color(0x99006B3C), Color(0xFF040D08)],
            stops: [0.0, 0.65],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Logo with glow
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006B3C), Color(0xFF003D1F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006B3C).withValues(alpha: 0.65),
                        blurRadius: 40,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF006B3C).withValues(alpha: 0.25),
                        blurRadius: 80,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Testing features temporarily disabled')),
                    );
                  },
                  child: const Text(
                    'HomeLinkGH',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Connecting Ghana\'s Diaspora',
                  style: TextStyle(fontSize: 15, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCD116).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFCD116).withValues(alpha: 0.45)),
                  ),
                  child: const Text(
                    '🇬🇭  Akwaba! Welcome Home',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFCD116),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (savedRole != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF006B3C).withValues(alpha: 0.20),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome back! 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Continue as ${savedRole == 'customer' ? 'Customer' : savedRole == 'diaspora' ? 'Diaspora Customer' : savedRole?.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _navigateToRole(context, savedRole!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFCD116),
                                  foregroundColor: const Color(0xFF006B3C),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Continue'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showRoleSwitchDialog(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Switch Role'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Or choose a different role:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'How can we help you today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                // Role Selection Cards
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleCard(
                        context,
                        icon: Icons.home_filled,
                        title: 'I Need Home Services',
                        subtitle: 'Whether visiting, living in Ghana, or helping family - book trusted services',
                        color: const Color(0xFF1E88E5),
                        badge: 'ALL-IN-ONE',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(userType: 'customer'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.verified,
                        title: 'I\'m a Trusted Provider',
                        subtitle: 'Serving Ghana\'s diaspora with excellence',
                        color: const Color(0xFF2E7D32),
                        badge: 'DIASPORA FRIENDLY',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(userType: 'provider'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.work_outline,
                        title: 'I Want to Work',
                        subtitle: 'Join our team or provider network',
                        color: const Color(0xFFF57C00),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JobsCareersScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.admin_panel_settings,
                        title: 'I am an Admin',
                        subtitle: 'Managing the platform',
                        color: Colors.red,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.business_center,
                        title: 'I am HomeLinkGH Staff',
                        subtitle: 'Access employee dashboard',
                        color: const Color(0xFF006B3C),
                        badge: 'STAFF PORTAL',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StaffLoginScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connecting communities through trusted services',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.13), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, size: 28, color: color),
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
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCD116).withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFCD116).withValues(alpha: 0.50)),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFCD116),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white30,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRole(BuildContext context, String role) async {
    switch (role) {
      case 'customer':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerHomeScreen(),
          ),
        );
        break;
      case 'diaspora':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DynamicHomeScreen(
              userId: 'diaspora_user_001',
              userType: 'diaspora_customer',
            ),
          ),
        );
        break;
      case 'provider':
        // Check if provider is verified
        final prefs = await SharedPreferences.getInstance();
        final isVerified = prefs.getBool('provider_verified') ?? false;
        
        if (isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProviderDashboard(),
            ),
          );
        } else {
          // Provider not verified yet, show pending verification message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your provider application is under review. You\'ll receive confirmation once approved.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        break;
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminLoginScreen(),
          ),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerHomeScreen(),
          ),
        );
    }
  }

  void _showRoleSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Role'),
        content: const Text(
          'This will log you out of your current role. You can always switch back later without entering a password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear saved role but keep user logged in for switching
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_role');
              
              if (context.mounted) {
                Navigator.pop(context);
                // Refresh the screen to show role selection
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch Role'),
          ),
        ],
      ),
    );
  }
}