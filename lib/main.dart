import 'package:flutter/material.dart';
import 'views/guest_home.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/pricing_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting HomeLinkGH - Production Ready v4.1.0');
  print('📱 Initializing advanced services...');
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Backend service initialized successfully');
  } catch (e) {
    print('⚠️  Backend service initialization failed, using local mode: $e');
  }
  
  // Initialize advanced services
  try {
    // Initialize notifications
    await NotificationService().initializePushNotifications();
    print('✅ Push notifications initialized');
    
    // Initialize pricing API
    PricingApiService().initialize();
    print('✅ Pricing API service initialized');
    
  } catch (e) {
    print('⚠️  Advanced services initialization warning: $e');
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
      routes: {
        '/': (context) => const GuestHomeScreen(),
        '/guest': (context) => const GuestHomeScreen(),
      },
    );
  }
}