import 'package:flutter/material.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Staff Dashboard'),
            Text('Employee portal and tools'),
          ],
        ),
      ),
    );
  }
}
