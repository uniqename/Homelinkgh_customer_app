import 'package:flutter/material.dart';

void main() {
  runApp(const HomeLinkGHApp());
}

class HomeLinkGHApp extends StatelessWidget {
  const HomeLinkGHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLinkGH - Connecting Ghana\'s Diaspora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B3C), // Ghana Green
          primary: const Color(0xFF006B3C),
          secondary: const Color(0xFFFCD116), // Ghana Gold
          tertiary: const Color(0xFFCE1126), // Ghana Red
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF006B3C),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeLinkGH'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work,
              size: 100,
              color: Color(0xFF006B3C),
            ),
            SizedBox(height: 20),
            Text(
              'HomeLinkGH',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Connecting Ghana\'s Diaspora',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ready for TestFlight Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFCD116),
              ),
            ),
          ],
        ),
      ),
    );
  }
}