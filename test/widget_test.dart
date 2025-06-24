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
  testWidgets('App launches and shows role selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeLinkGHApp());

    expect(find.text('HomeLinkGH'), findsOneWidget);
    expect(find.text('Connecting Ghana\'s Diaspora'), findsOneWidget);
    expect(find.text('How can we help you today?'), findsOneWidget);
    expect(find.text('I\'m Visiting Ghana'), findsOneWidget);
    expect(find.text('I\'m Helping Family'), findsOneWidget);
    expect(find.text('I\'m a Trusted Provider'), findsOneWidget);
    expect(find.text('I Want to Work'), findsOneWidget);
  });
}
