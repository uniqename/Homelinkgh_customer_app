import 'package:flutter/material.dart';
import 'login.dart';
import 'provider_onboarding.dart';
import 'job_seeker_onboarding.dart';
import 'admin_login.dart';
import 'job_portal.dart';
import 'staff_login.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006B3C), // Ghana Green
              Color(0xFF228B22), // Forest Green
              Color(0xFF32CD32), // Lime Green
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo and App Name
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home,
                    size: 40,
                    color: Color(0xFF006B3C),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'HomeLinkGH',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Connecting Ghana\'s Diaspora',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCD116), // Ghana Gold
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🇬🇭 Akwaba! Welcome Home',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'How can we help you today?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // Role Selection Cards
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleCard(
                        context,
                        icon: Icons.flight_land,
                        title: 'I\'m Visiting Ghana',
                        subtitle: 'Book before you land - we\'ll prep your house',
                        color: const Color(0xFF1E88E5),
                        badge: 'DIASPORA MODE',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(userType: 'diaspora_customer'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.family_restroom,
                        title: 'I\'m Helping Family',
                        subtitle: 'Book services for loved ones from abroad',
                        color: const Color(0xFFCE1126), // Ghana Red
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(userType: 'family_helper'),
                          ),
                        ),
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
                            builder: (context) => const ProviderOnboardingScreen(),
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
                            builder: (context) => const JobPortalScreen(),
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
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCD116), // Ghana Gold
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}