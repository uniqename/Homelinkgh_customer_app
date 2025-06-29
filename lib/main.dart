import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/guest_home.dart';
import 'views/role_selection.dart';
import 'views/login.dart';
import 'services/auth_service.dart';
import 'services/real_firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  bool isFirebaseReady = false;
  
  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp();
    
    // Initialize collections
    final firebaseService = RealFirebaseService();
    await firebaseService.initializeCollections();
    
    isFirebaseReady = true;
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('App will run in offline mode');
  }
  
  runApp(HomeLinkGHAppWrapper(isFirebaseReady: isFirebaseReady));
}

/// Main app widget with Firebase authentication integration
class HomeLinkGHAppWrapper extends StatelessWidget {
  final bool isFirebaseReady;
  
  const HomeLinkGHAppWrapper({
    super.key,
    required this.isFirebaseReady,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseReady) {
      return MaterialApp(
        title: 'HomeLinkGH',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Connecting to HomeLinkGH...'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Restart the app in offline mode
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuestHomeScreen(),
                      ),
                    );
                  },
                  child: const Text('Continue Offline'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'HomeLinkGH',
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF006B3C),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 60,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'HomeLinkGH',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connecting Ghana\'s Diaspora',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData) {
          return HomeLinkGHApp(
            initialRoute: '/role_selection',
            isFirebaseReady: isFirebaseReady,
          );
        }

        // User is not signed in
        return HomeLinkGHApp(
          initialRoute: '/guest',
          isFirebaseReady: isFirebaseReady,
        );
      },
    );
  }
}

class HomeLinkGHApp extends StatelessWidget {
  final String initialRoute;
  final String? savedRole;
  final bool isFirebaseReady;
  
  const HomeLinkGHApp({
    super.key,
    required this.initialRoute,
    this.savedRole,
    required this.isFirebaseReady,
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