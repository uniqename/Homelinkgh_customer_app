import 'package:flutter/material.dart';

void main() {
  runApp(const HomeLinkGHApp());
}

class HomeLinkGHApp extends StatelessWidget {
  const HomeLinkGHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLink Ghana',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B3C)),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

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
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Logo
                Container(
                  width: 100,
                  height: 100,
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
                    size: 50,
                    color: Color(0xFF006B3C),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'HomeLink Ghana',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Connecting Ghana\'s Diaspora',
                  style: TextStyle(
                    fontSize: 18,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006B3C),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  'How can we help you today?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleCard(
                        context,
                        icon: Icons.flight_land,
                        title: 'I\'m Visiting Ghana',
                        subtitle: 'Book services before you land',
                        color: const Color(0xFF1E88E5),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.family_restroom,
                        title: 'I\'m Helping Family',
                        subtitle: 'Book services for loved ones',
                        color: const Color(0xFFCE1126),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.verified,
                        title: 'I\'m a Provider',
                        subtitle: 'Serve Ghana\'s diaspora',
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        icon: Icons.work_outline,
                        title: 'I Want to Work',
                        subtitle: 'Join our team',
                        color: const Color(0xFFF57C00),
                      ),
                    ],
                  ),
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
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: $title')),
          );
        },
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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