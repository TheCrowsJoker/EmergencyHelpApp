import 'package:emergency_help/login.dart';
import 'package:emergency_help/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Login()));

//    Check header is preset
    expect(find.text(appName), findsOneWidget);
//    Check text fields are preset
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone number'), findsOneWidget);
//    Check button is present
    expect(find.widgetWithText(RaisedButton, 'Login'), findsOneWidget);
  });
}