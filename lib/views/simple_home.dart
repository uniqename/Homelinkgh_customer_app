import 'package:flutter/material.dart';
import 'food_delivery_screen.dart';
import 'admin_monitoring_screen.dart';

class SimpleHomeScreen extends StatelessWidget {
  final String userType;
  
  const SimpleHomeScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006B3C), Color(0xFF228B22)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _getIcon(),
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getWelcomeMessage(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSubtitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _getActionCards(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (userType) {
      case 'diaspora_customer':
        return 'Diaspora Dashboard';
      case 'family_helper':
        return 'Family Helper';
      case 'provider':
        return 'Provider Dashboard';
      default:
        return 'Customer Dashboard';
    }
  }

  IconData _getIcon() {
    switch (userType) {
      case 'diaspora_customer':
        return Icons.flight_land;
      case 'family_helper':
        return Icons.family_restroom;
      case 'provider':
        return Icons.work;
      default:
        return Icons.person;
    }
  }

  String _getWelcomeMessage() {
    switch (userType) {
      case 'diaspora_customer':
        return 'Akwaba! Welcome Home 🇬🇭';
      case 'family_helper':
        return 'Caring from Afar ❤️';
      case 'provider':
        return 'Ready to Serve 💪';
      default:
        return 'Welcome Back!';
    }
  }

  String _getSubtitle() {
    switch (userType) {
      case 'diaspora_customer':
        return 'Plan your trip, we\'ll prep your house';
      case 'family_helper':
        return 'Support your loved ones in Ghana';
      case 'provider':
        return 'Connecting with Ghana\'s diaspora';
      default:
        return 'Your local services marketplace';
    }
  }

  List<Widget> _getActionCards(BuildContext context) {
    final List<Map<String, dynamic>> actions;
    
    switch (userType) {
      case 'diaspora_customer':
        actions = [
          {'title': 'Book Services', 'icon': Icons.calendar_today, 'color': Colors.blue},
          {'title': 'House Prep', 'icon': Icons.home, 'color': Colors.green},
          {'title': 'Transportation', 'icon': Icons.directions_car, 'color': Colors.orange},
          {'title': 'Emergency Help', 'icon': Icons.emergency, 'color': Colors.red},
        ];
        break;
      case 'family_helper':
        actions = [
          {'title': 'Family Services', 'icon': Icons.family_restroom, 'color': Colors.pink},
          {'title': 'Health Care', 'icon': Icons.medical_services, 'color': Colors.red},
          {'title': 'Education', 'icon': Icons.school, 'color': Colors.blue},
          {'title': 'Utilities', 'icon': Icons.electrical_services, 'color': Colors.amber},
        ];
        break;
      case 'provider':
        actions = [
          {'title': 'Active Jobs', 'icon': Icons.work, 'color': Colors.green},
          {'title': 'Schedule', 'icon': Icons.schedule, 'color': Colors.blue},
          {'title': 'Earnings', 'icon': Icons.attach_money, 'color': Colors.orange},
          {'title': 'Reviews', 'icon': Icons.star, 'color': Colors.purple},
        ];
        break;
      default:
        actions = [
          {'title': 'Book Service', 'icon': Icons.calendar_today, 'color': Colors.blue},
          {'title': 'My Bookings', 'icon': Icons.list, 'color': Colors.green},
          {'title': 'Favorites', 'icon': Icons.favorite, 'color': Colors.red},
          {'title': 'Support', 'icon': Icons.help, 'color': Colors.orange},
        ];
    }

    return actions.map((action) => _buildActionCard(
      context,
      action['title'],
      action['icon'],
      action['color'],
    )).toList();
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _handleActionTap(context, title);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActionTap(BuildContext context, String title) {
    switch (title) {
      case 'Book Service':
      case 'Book Services':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FoodDeliveryScreen(),
          ),
        );
        break;
      case 'Active Jobs':
        if (userType == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminMonitoringScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature coming soon!')),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title feature coming soon!')),
        );
    }
  }
}