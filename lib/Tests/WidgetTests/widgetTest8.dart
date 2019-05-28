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

    //    Run twice to make sure firebase data is loaded
    await tester.pump();
    await tester.pump();

//    Should see the question but not the answer
    expect(find.widgetWithText(ExpansionTile, "Test question"), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, "Test answer"), findsNothing);

//    Tap on the expansion tile
    await tester.tap(find.widgetWithText(ExpansionTile, "Test question"));
    await tester.pump();

//    Should see the answer
    expect(find.widgetWithText(ExpansionTile, "Test answer"), findsOneWidget);
  });
}