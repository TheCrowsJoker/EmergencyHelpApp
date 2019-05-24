import 'package:emergency_help/createAccount.dart';
import 'package:emergency_help/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Create Account Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: CreateAccount()));


//    Check header is preset
    expect(find.text(appName), findsOneWidget);
//    Check text fields are preset
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone number'), findsOneWidget);
//    Check button is present
    expect(find.widgetWithText(RaisedButton, 'Create Account'), findsOneWidget);
  });
}