import 'package:emergency_help/createAccount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: CreateAccount()));

//    Check header is present
    expect(find.text('Create Account'), findsOneWidget);
  });
}