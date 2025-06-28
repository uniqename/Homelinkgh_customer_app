import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/guest_home.dart';
import 'views/role_selection.dart';
import 'services/firebase_initialization_service.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user has a saved session
  final prefs = await SharedPreferences.getInstance();
  final savedRole = prefs.getString('user_role');
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  
  print('HomeLinkGH starting...');
  print('Saved role: $savedRole, Logged in: $isLoggedIn');
  
  // Initialize Firebase for production use
  final firebaseInit = FirebaseInitializationService();
  bool isFirebaseReady = false;
  
  try {
    print('Attempting Firebase initialization...');
    isFirebaseReady = await firebaseInit.initializeForProduction();
    
    if (isFirebaseReady) {
      print('✅ Firebase initialized - Running in PRODUCTION mode');
      await firebaseInit.setupInitialData();
    } else {
      print('⚠️ Firebase not available - Running in LOCAL mode');
    }
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('Falling back to local mode...');
  }
  
  runApp(HomeLinkGHApp(
    initialRoute: isLoggedIn && savedRole != null ? '/role_selection' : '/guest',
    savedRole: savedRole,
    isFirebaseReady: isFirebaseReady,
  ));
}

class HomeLinkGHApp extends StatelessWidget {
  final String initialRoute;
  final String? savedRole;
  final bool isFirebaseReady;
  
  const HomeLinkGHApp({
    super.key,
    required this.initialRoute,
    this.savedRole,
    this.isFirebaseReady = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLinkGH - Connecting Ghana\'s Diaspora',
      debugShowCheckedModeBanner: false,
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
      home: initialRoute == '/guest' 
          ? const GuestHomeScreen() 
          : RoleSelectionScreen(savedRole: savedRole),
    );
  }
}