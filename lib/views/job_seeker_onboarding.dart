import 'package:flutter/material.dart';

class JobSeekerOnboardingScreen extends StatefulWidget {
  const JobSeekerOnboardingScreen({super.key});

  @override
  State<JobSeekerOnboardingScreen> createState() => _JobSeekerOnboardingScreenState();
}

class _JobSeekerOnboardingScreenState extends State<JobSeekerOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Seeker Portal'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Job Seeker Onboarding'),
            Text('Welcome to the job opportunities portal'),
          ],
        ),
      ),
    );
  }
}