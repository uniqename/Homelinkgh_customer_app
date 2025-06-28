import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'firebase_options.dart';
import 'views/role_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with timeout
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    
    // Initialize Firebase services in background
    FirebaseService.initialize().then((_) {
      // Initialize service data in background
      FirebaseService.initializeServices().catchError((e) {
        print('Services initialization error: $e');
      });
    }).catchError((e) {
      print('Firebase service initialization error: $e');
    });
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue app startup even if Firebase fails
  }
  
  runApp(const HomeLinkGHApp());
}

class HomeLinkGHApp extends StatelessWidget {
  const HomeLinkGHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLinkGH - Connecting Ghana\'s Diaspora',
      debugShowCheckedModeBanner: false, // Remove debug banner
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
        fontFamily: 'Inter', // Modern, clean font
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}