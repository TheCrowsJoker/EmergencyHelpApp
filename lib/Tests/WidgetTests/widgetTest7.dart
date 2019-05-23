import 'package:emergency_help/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Profile()));

//    Check header is present
    expect(find.text('Profile'), findsOneWidget);
  });
}