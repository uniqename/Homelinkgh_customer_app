import 'package:flutter/material.dart';

class AppConstants {
  // Website and Contact Information
  static const String websiteUrl = 'https://beaconnewbeginnings.org'; // Update this to your actual domain
  static const String organizationName = 'Beacon of New Beginnings';
  static const String organizationEmail = 'info@beaconnewbeginnings.org';
  static const String emergencyContactGhana = '191'; // Ghana Police Emergency
  static const String supportEmail = 'support@beaconnewbeginnings.org';
  
  // App Information
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Providing safety, healing, and empowerment to survivors of abuse and homelessness';
  
  // Emergency Contacts (Ghana)
  static const Map<String, String> emergencyContacts = {
    'Police': '191',
    'Fire Service': '192',
    'Ambulance': '193',
    'Domestic Violence Hotline': '055 123 4567', // Replace with actual hotline
    'Crisis Support': '024 567 8901', // Replace with actual crisis line
  };
  
  // Default Resource Categories
  static const List<String> resourceCategories = [
    'Shelter',
    'Legal Aid',
    'Counseling',
    'Healthcare',
    'Job Training',
    'Education',
    'Food & Clothing',
    'Financial Support',
  ];
  
  // Privacy and Security
  static const String privacyPolicyUrl = 'https://beaconnewbeginnings.org/privacy';
  static const String termsOfServiceUrl = 'https://beaconnewbeginnings.org/terms';
  
  // Colors
  static const int primaryColorValue = 0xFF00796B;
  static const int accentColorValue = 0xFF4CAF50;
  static const int emergencyColorValue = 0xFFE53935;

  // ── Premium Dark Design Tokens ──────────────────────────────────────
  // Ghana Green brand palette on near-black
  static const darkBackground = Color(0xFF040D08);
  static const darkSurface = Color(0xFF0D1F14);
  static const darkCard = Color(0xFF0A1A0F);

  // Brand colors
  static const ghanaGreen = Color(0xFF006B3C);
  static const ghanaGreenLight = Color(0xFF2E8B57);
  static const ghanaGold = Color(0xFFFCD116);

  // Glass card decoration
  static const glassCardLight = Color(0x1AFFFFFF);   // 10% white
  static const glassCardDark = Color(0x0DFFFFFF);    // 5% white
  static const glassCardBorder = Color(0x26FFFFFF);  // 15% white
  static const glassCardGlow = Color(0xFF006B3C);

  // Gradient helpers
  static const LinearGradient heroGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF006B3C), Color(0xFF040D08)],
    stops: [0.0, 0.6],
  );

  static const RadialGradient brandRadialGlow = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [Color(0x59006B3C), Color(0xFF040D08)],  // 35% → solid dark
    stops: [0.0, 0.7],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF006B3C), Color(0xFF003D1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}