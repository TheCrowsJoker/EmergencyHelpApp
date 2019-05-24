import 'package:emergency_help/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Resources()));

//    Check header is present
    expect(find.text("Resources"), findsOneWidget);

    //    Check page is loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

//    Run twice to make sure firebase data is loaded
    await tester.pump();
    await tester.pump();

//    Find test card
    expect(find.widgetWithText(Card, "Test"), findsOneWidget);

//    Open more options dialog
    await tester.longPress(find.text("Test"));
    await tester.pump();

//    Check all fields are present
    expect(find.text("More Options..."), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Show on map"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Call phone 1"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Call phone 2"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Email"), findsOneWidget);
    // this is findsWidgets because there are multiple 'Open website' buttons on the page
    expect(find.widgetWithText(FlatButton, "Open website"), findsWidgets);
  });
}