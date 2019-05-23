import 'package:emergency_help/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Contacts()));

//    await tester.pump(Duration.zero);

//    Check header is present
    expect(find.text("Contacts"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration.zero);

    expect(find.text("No contacts added yet"), findsOneWidget);
  });
}