import 'package:emergency_help/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Profile()));

//    Check header is present
    expect(find.text('Profile'), findsOneWidget);

//    Check for home button
    expect(find.widgetWithIcon(FloatingActionButton, Icons.home), findsOneWidget);

//    Load firebase data
    await tester.pump();
    await tester.pump();

//    Check for text fields
    expect(find.widgetWithText(TextFormField, 'TestUser'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '0'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '01/01/2019 12:00'), findsOneWidget);
    expect(find.widgetWithText(OutlineButton, 'Logout'), findsOneWidget);

//    Shouldnt see these buttons yet
    expect(find.widgetWithText(OutlineButton, 'Delete Info'), findsNothing);
    expect(find.widgetWithText(OutlineButton, 'Delete Account'), findsNothing);

//    Find edit button
    expect(find.widgetWithText(FloatingActionButton, 'Edit'), findsOneWidget);

//    Tap on edit button
    await tester.tap(find.widgetWithText(FloatingActionButton, "Edit"));
    await tester.pump();

//    Should find delete buttons
    expect(find.widgetWithText(OutlineButton, 'Delete Info'), findsOneWidget);
    expect(find.widgetWithText(OutlineButton, 'Delete Account'), findsOneWidget);

//    Tap on logout
    await tester.tap(find.widgetWithText(OutlineButton, "Logout"));
    await tester.pump();

//    Check logout fields
    expect(find.text("Are you sure you want to logout?"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'No'), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, 'Yes'), findsOneWidget);

//    Close logout dialog
    await tester.tap(find.text("No"));
    await tester.pump();

//    Tap dlete info button
    await tester.tap(find.widgetWithText(OutlineButton, "Delete Info"));
    await tester.pump();

//    Check delete info fields
    expect(find.text("Would you like to delete all information associated with this account?"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'No'), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, 'Yes'), findsOneWidget);

//    Close delete info dialog
    await tester.tap(find.text("No"));
    await tester.pump();

//    Tap Delete account button
    await tester.tap(find.widgetWithText(OutlineButton, "Delete Account"));
    await tester.pump();

//    Check delete account fields
    expect(find.text("Are you sure you want to delete your account?"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'No'), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, 'Yes'), findsOneWidget);

  });
}