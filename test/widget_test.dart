// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homelink_ghana/main.dart';

void main() {
  testWidgets('App launches and shows guest home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeLinkGHApp(initialRoute: '/guest'));

    // Wait for the app to load (initial render)
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Check that the guest home screen loads with key elements
    expect(find.text('HomeLinkGH'), findsOneWidget);
    expect(find.text('Welcome to Ghana! 🇬🇭'), findsOneWidget);
    
    // The smart features may still be loading, so we just check basic UI
  });
}
