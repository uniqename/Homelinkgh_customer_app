import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Demo Account Service for App Store Review
/// Provides a fully functional demo account with all features accessible
class DemoAccountService {
  static const String demoEmail = 'appstore@homelinkgh.com';
  static const String demoPassword = 'AppStore2025!';
  static const String demoUserId = 'demo_user_appstore_review';
  
  /// Create demo user for App Store review
  static AppUser createDemoUser() {
    return AppUser(
      id: demoUserId,
      email: demoEmail,
      displayName: 'App Store Reviewer',
      phoneNumber: '+233 24 123 4567',
      userType: UserType.survivor, // Using existing enum
      isAnonymous: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
      currentLocation: 'East Legon, Accra, Ghana',
      hasActiveCases: false,
      emergencyContact: 'HomeLinkGH Support',
      emergencyContactPhone: '+233 30 123 4567',
    );
  }

  /// Auto-login with demo credentials
  static Future<AppUser?> autoLoginDemo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Set demo mode flag
      await prefs.setBool('is_demo_mode', true);
      await prefs.setString('demo_user_id', demoUserId);
      await prefs.setString('demo_user_email', demoEmail);
      
      // Create and return demo user
      final demoUser = createDemoUser();
      
      // Save demo user data locally
      await prefs.setString('user_id', demoUser.id);
      await prefs.setString('user_name', demoUser.displayName ?? 'App Store Reviewer');
      await prefs.setString('user_email', demoUser.email);
      await prefs.setString('user_phone', demoUser.phoneNumber ?? '+233 24 123 4567');
      await prefs.setString('user_address', demoUser.currentLocation ?? 'East Legon, Accra, Ghana');
      await prefs.setBool('user_verified', true);
      await prefs.setBool('ghana_card_verified', true);
      await prefs.setDouble('trust_score', 95.0);
      
      return demoUser;
    } catch (e) {
      print('Error auto-logging demo user: $e');
      return null;
    }
  }

  /// Check if currently in demo mode
  static Future<bool> isDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_demo_mode') ?? false;
  }

  /// Get demo booking data for demonstration
  static List<Map<String, dynamic>> getDemoBookings() {
    return [
      {
        'id': 'demo_booking_1',
        'service': 'House Cleaning',
        'provider': {
          'name': 'Akosua Mensah',
          'rating': 4.8,
          'phone': '+233 24 987 6543',
          'image': 'https://via.placeholder.com/100/2E8B57/FFFFFF?text=AM',
        },
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'amount': 150.0,
        'currency': 'GHS',
        'location': 'East Legon, Accra',
        'notes': 'Excellent service, very thorough cleaning',
        'rating': 5,
      },
      {
        'id': 'demo_booking_2',
        'service': 'Food Delivery',
        'provider': {
          'name': 'Kwame\'s Kitchen',
          'rating': 4.6,
          'phone': '+233 50 123 4567',
          'image': 'https://via.placeholder.com/100/FF6B35/FFFFFF?text=KK',
        },
        'status': 'in_progress',
        'date': DateTime.now(),
        'amount': 85.0,
        'currency': 'GHS',
        'location': 'Airport Residential, Accra',
        'items': ['Jollof Rice', 'Grilled Chicken', 'Kelewele'],
        'estimatedDelivery': DateTime.now().add(const Duration(minutes: 25)),
      },
      {
        'id': 'demo_booking_3',
        'service': 'Beauty Services',
        'provider': {
          'name': 'Ama\'s Beauty Studio',
          'rating': 4.9,
          'phone': '+233 26 789 0123',
          'image': 'https://via.placeholder.com/100/FFA500/FFFFFF?text=ABS',
        },
        'status': 'scheduled',
        'date': DateTime.now().add(const Duration(days: 2)),
        'amount': 200.0,
        'currency': 'GHS',
        'location': 'Dzorwulu, Accra',
        'services': ['Makeup', 'Hair Styling'],
        'notes': 'Wedding preparation',
      },
    ];
  }

  /// Get demo providers for demonstration
  static List<Map<String, dynamic>> getDemoProviders() {
    return [
      {
        'id': 'demo_provider_1',
        'name': 'Akosua Mensah',
        'service': 'House Cleaning',
        'rating': 4.8,
        'reviews': 156,
        'image': 'https://via.placeholder.com/150/2E8B57/FFFFFF?text=AM',
        'verified': true,
        'ghana_card_verified': true,
        'experience': '5 years',
        'location': 'East Legon area',
        'price_range': '₵100 - ₵300',
        'availability': 'Available',
        'specialties': ['Deep cleaning', 'Office cleaning', 'Move-in/out cleaning'],
      },
      {
        'id': 'demo_provider_2',
        'name': 'Kwame Asante',
        'service': 'Food Delivery',
        'rating': 4.6,
        'reviews': 89,
        'image': 'https://via.placeholder.com/150/FF6B35/FFFFFF?text=KA',
        'verified': true,
        'ghana_card_verified': true,
        'experience': '3 years',
        'location': 'Airport Residential',
        'price_range': '₵50 - ₵200',
        'availability': 'Available',
        'specialties': ['Local dishes', 'Fast delivery', 'Continental food'],
      },
      {
        'id': 'demo_provider_3',
        'name': 'Ama Osei',
        'service': 'Beauty Services',
        'rating': 4.9,
        'reviews': 234,
        'image': 'https://via.placeholder.com/150/FFA500/FFFFFF?text=AO',
        'verified': true,
        'ghana_card_verified': true,
        'experience': '8 years',
        'location': 'Dzorwulu',
        'price_range': '₵80 - ₵500',
        'availability': 'Available',
        'specialties': ['Bridal makeup', 'Hair styling', 'Nail art'],
        'portfolio': [
          'https://via.placeholder.com/200x200/FFA500/FFFFFF?text=Work1',
          'https://via.placeholder.com/200x200/FFA500/FFFFFF?text=Work2',
          'https://via.placeholder.com/200x200/FFA500/FFFFFF?text=Work3',
        ],
        'social_media': {
          'instagram': '@ama_beauty_accra',
          'facebook': 'Ama Beauty Studio',
          'tiktok': '@amabeauty_gh',
        },
      },
    ];
  }

  /// Simulate payment for demo bookings
  static Future<Map<String, dynamic>> processDemoPayment({
    required double amount,
    required String service,
    required String provider,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'transaction_id': 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'currency': 'GHS',
      'payment_method': 'PayStack (Demo)',
      'status': 'completed',
      'timestamp': DateTime.now().toIso8601String(),
      'reference': 'DEMO_REF_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  /// Get demo notifications
  static List<Map<String, dynamic>> getDemoNotifications() {
    return [
      {
        'id': 'demo_notif_1',
        'title': 'Booking Confirmed',
        'message': 'Your beauty appointment with Ama\'s Beauty Studio has been confirmed for tomorrow at 2:00 PM',
        'type': 'booking',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'read': false,
        'icon': 'calendar',
      },
      {
        'id': 'demo_notif_2',
        'title': 'Food Delivery Update',
        'message': 'Your order from Kwame\'s Kitchen is being prepared and will be delivered in 25 minutes',
        'type': 'delivery',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'read': false,
        'icon': 'delivery',
      },
      {
        'id': 'demo_notif_3',
        'title': 'Service Completed',
        'message': 'Great job! Please rate your experience with Akosua\'s cleaning service',
        'type': 'rating',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
        'icon': 'star',
      },
    ];
  }

  /// Clear demo mode
  static Future<void> exitDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_demo_mode');
    await prefs.remove('demo_user_id');
    await prefs.remove('demo_user_email');
  }

  /// Demo credentials for App Store Connect
  static Map<String, String> getDemoCredentials() {
    return {
      'email': demoEmail,
      'password': demoPassword,
      'notes': '''
Demo Account Features:
• Full access to all app features
• Ghana Card verification enabled
• Sample bookings and providers
• Payment simulation (no real charges)
• All services available for testing
• Location: Accra, Ghana
• Trust Score: 95/100

Test Scenarios:
1. Browse and book services
2. View booking history
3. Test Ghana Card verification
4. Try food delivery with maps
5. Check beauty services profiles
6. Test payment flow (simulated)
''',
    };
  }
}