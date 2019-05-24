import 'package:emergency_help/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Contacts()));

//    Check header is present
    expect(find.text("Contacts"), findsOneWidget);

//    Check page is loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

//    Run twice to make sure firebase data is loaded
    await tester.pump();
    await tester.pump();

//    Check for contact and make sure they are not selected
    expect(find.text("Test"), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);

//    Open More options dialog
    await tester.longPress(find.text("Test"));
    await tester.pump();

//    Check more options fields are present
    expect(find.text("More Options..."), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Details"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Edit"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Delete"), findsOneWidget);

//    Open details dialog
    await tester.tap(find.text("Details"));
    await tester.pump();

//    Find contact details
    expect(find.text("Test"), findsWidgets);
    expect(find.text("Name: "), findsOneWidget);
    expect(find.text("Phone Number: "), findsOneWidget);
    expect(find.text("Date added: "), findsOneWidget);
    expect(find.text("Selected: "), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Close"), findsOneWidget);

//    Close dialog
    await tester.tap(find.text("Close"));
    await tester.pump();

//    Open edit dialog
    await tester.tap(find.text("Edit"));
    await tester.pump();

//    Find edit fields
    expect(find.text("Edit Test"), findsWidgets);
    expect(find.widgetWithText(TextFormField, "Test"), findsOneWidget);
    expect(find.widgetWithText(TextFormField, "0"), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Save"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Cancel"), findsOneWidget);

//    Close dialog
    await tester.tap(find.text("Cancel"));
    await tester.pump();

//    Open delete dialog
    await tester.tap(find.text("Delete"));
    await tester.pump();

//    Check delete fields are present
    expect(find.text("Are you sure you want to delete Test"), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Yes"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "No"), findsOneWidget);

//    Close dialog
    await tester.tap(find.text("No"));
    await tester.pump();
  });
}