import 'package:emergency_help/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('About Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
      home: About()));

//    Check header is present
    expect(find.text('About (FAQs)'), findsOneWidget);
//    Check home button is present
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}