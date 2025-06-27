import 'package:flutter/material.dart';

class AvailableJobsScreen extends StatefulWidget {
  final List<String> providerServices;
  
  const AvailableJobsScreen({super.key, required this.providerServices});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Available Jobs'),
          Text('Browse and accept new job opportunities'),
        ],
      ),
    );
  }
}
