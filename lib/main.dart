import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'views/guest_home.dart';
import 'views/role_selection.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting HomeLinkGH in production mode...');
  
  // Initialize Firebase for production use
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('App will run in offline mode');
  }
  
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
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading HomeLinkGH...'),
                  ],
                ),
              ),
            );
          }

          // User is signed in - redirect to role selection or user-specific home
          if (snapshot.hasData) {
            return const RoleSelectionScreen();
          }

          // User is not signed in - show guest home
          return const GuestHomeScreen();
        },
      ),
    );
  }
}