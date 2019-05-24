import 'package:emergency_help/replies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Replies Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Replies("")));

//    Check header is present
    expect(find.text("Reply"), findsWidgets);
  });
}