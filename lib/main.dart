import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'views/guest_home.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/pricing_api_service.dart';
import 'services/push_notification_service.dart';
import 'services/payment_service.dart';

/// Firebase Cloud Messaging background handler
/// Handles notifications when app is in background or terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background notification received: ${message.messageId}');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  // Message is automatically displayed by FCM when app is in background
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting HomeLinkGH - Production Ready v4.1.0');
  print('📱 Initializing advanced services...');

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded');
  } catch (e) {
    print('⚠️  No .env file found, payment features may not work: $e');
  }

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Backend service initialized successfully');
  } catch (e) {
    print('⚠️  Backend service initialization failed, using local mode: $e');
  }
  
  // Initialize advanced services
  try {
    // Initialize Firebase Cloud Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize push notifications with real FCM
    await PushNotificationService().initialize();
    print('✅ Firebase Cloud Messaging initialized');

    // Initialize legacy notifications (backward compatibility)
    await NotificationService().initializePushNotifications();
    print('✅ Notification services initialized');

    // Initialize pricing API
    PricingApiService().initialize();
    print('✅ Pricing API service initialized');

    await PaymentService().initialize();
    print('✅ Payment service initialized');

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
        scaffoldBackgroundColor: const Color(0xFF040D08),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B3C),
          brightness: Brightness.dark,
          primary: const Color(0xFF006B3C),
          secondary: const Color(0xFFFCD116),
          tertiary: const Color(0xFF2E8B57),
          surface: const Color(0xFF0D1F14),
          onPrimary: Colors.white,
          onSecondary: const Color(0xFF040D08),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF040D08),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withValues(alpha: 0.08),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0A1A0F),
          indicatorColor: const Color(0xFF006B3C).withValues(alpha: 0.30),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: Colors.white54, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF4CAF50));
            }
            return const IconThemeData(color: Colors.white54);
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white30),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
          bodySmall: TextStyle(color: Colors.white54),
        ),
        dividerTheme: const DividerThemeData(color: Colors.white12),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF006B3C), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
      routes: {
        '/': (context) => const GuestHomeScreen(),
        '/guest': (context) => const GuestHomeScreen(),
      },
    );
  }
}