import 'package:flutter/material.dart';
import 'views/dynamic_home.dart';

void main() {
  runApp(const HomeLinkGHTestApp());
}

class HomeLinkGHTestApp extends StatelessWidget {
  const HomeLinkGHTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLinkGH - Food Delivery Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B57), // Warmer sea green
          primary: const Color(0xFF2E8B57), // Sea green - more welcoming
          secondary: const Color(0xFFFF6B35), // Warm orange
          tertiary: const Color(0xFFFFA500), // Golden orange
          surface: const Color(0xFFFFFDF7), // Warm white
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // Go directly to dynamic home to see new features
      home: const DynamicHomeScreen(
        userId: 'test_user_food_demo',
        userType: 'diaspora_customer',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}