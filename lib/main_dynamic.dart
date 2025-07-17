import 'package:flutter/material.dart';
import 'views/dynamic_home.dart';

void main() {
  runApp(const HomeLinkGHDynamicApp());
}

class HomeLinkGHDynamicApp extends StatelessWidget {
  const HomeLinkGHDynamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLinkGH - Smart Recommendations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B3C), // Ghana Green
          primary: const Color(0xFF006B3C),
          secondary: const Color(0xFFCE1126), // Ghana Red
          tertiary: const Color(0xFFFCD116), // Ghana Gold
        ),
        useMaterial3: true,
      ),
      home: const DynamicHomeScreen(
        userId: 'demo_user_diaspora',
        userType: 'diaspora_customer',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}