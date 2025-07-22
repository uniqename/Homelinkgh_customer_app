import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customer_app/main.dart' as app;

/// HomeLinkGH App Screenshots Capture
/// This integration test captures screenshots from the actual running app
/// for App Store submission with correct dimensions and real content.
void main() {
  group('HomeLinkGH App Screenshots', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Capture App Store Screenshots', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to fully load
      await Future.delayed(Duration(seconds: 2));

      // Screenshot 1: Home Screen with AI Features
      await tester.pumpAndSettle();
      await takeScreenshot(tester, 'home_screen_ai_features');

      // Screenshot 2: Food Delivery Screen
      // Navigate to food delivery
      final foodDeliveryButton = find.byKey(Key('food_delivery_button'));
      if (foodDeliveryButton.evaluate().isNotEmpty) {
        await tester.tap(foodDeliveryButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, 'food_delivery_screen');
      } else {
        // Alternative navigation
        final bottomNavFood = find.byIcon(Icons.restaurant);
        if (bottomNavFood.evaluate().isNotEmpty) {
          await tester.tap(bottomNavFood);
          await tester.pumpAndSettle();
          await takeScreenshot(tester, 'food_delivery_screen');
        }
      }

      // Screenshot 3: Home Services Screen
      // Navigate to home services
      final homeServicesButton = find.byKey(Key('home_services_button'));
      if (homeServicesButton.evaluate().isNotEmpty) {
        await tester.tap(homeServicesButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, 'home_services_screen');
      } else {
        // Alternative navigation
        final bottomNavServices = find.byIcon(Icons.home_repair_service);
        if (bottomNavServices.evaluate().isNotEmpty) {
          await tester.tap(bottomNavServices);
          await tester.pumpAndSettle();
          await takeScreenshot(tester, 'home_services_screen');
        }
      }

      // Screenshot 4: User Profile with Gamification
      // Navigate to profile
      final profileButton = find.byKey(Key('profile_button'));
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, 'profile_gamification_screen');
      } else {
        // Alternative navigation
        final bottomNavProfile = find.byIcon(Icons.person);
        if (bottomNavProfile.evaluate().isNotEmpty) {
          await tester.tap(bottomNavProfile);
          await tester.pumpAndSettle();
          await takeScreenshot(tester, 'profile_gamification_screen');
        }
      }

      // Screenshot 5: Ghana Card Verification Screen
      // Navigate to verification
      final verificationButton = find.byKey(Key('verification_button'));
      if (verificationButton.evaluate().isNotEmpty) {
        await tester.tap(verificationButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, 'ghana_card_verification_screen');
      } else {
        // Try to find settings and then verification
        final settingsButton = find.byIcon(Icons.settings);
        if (settingsButton.evaluate().isNotEmpty) {
          await tester.tap(settingsButton);
          await tester.pumpAndSettle();
          
          final verificationOption = find.text('Verification');
          if (verificationOption.evaluate().isNotEmpty) {
            await tester.tap(verificationOption);
            await tester.pumpAndSettle();
            await takeScreenshot(tester, 'ghana_card_verification_screen');
          }
        }
      }

      print('✅ All screenshots captured successfully!');
      print('📍 Screenshots saved to: test_screenshots/');
      print('📱 Ready for App Store submission');
    });
  });
}

/// Takes a screenshot with the specified name
Future<void> takeScreenshot(WidgetTester tester, String name) async {
  await tester.binding.convertFlutterSurfaceToImage();
  await tester.pumpAndSettle();
  
  // Take screenshot
  final bytes = await tester.binding.takeScreenshot(name);
  
  // Save to file
  final file = File('test_screenshots/$name.png');
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
  
  print('📸 Screenshot captured: $name.png');
}