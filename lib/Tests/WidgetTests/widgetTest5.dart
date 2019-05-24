import 'package:emergency_help/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets('Chat Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Chatroom()));

//    Check header is present
    expect(find.text("Chatroom"), findsOneWidget);

    //    Check for home button
    expect(find.widgetWithIcon(FloatingActionButton, Icons.home), findsOneWidget);

    //    Check for add button
    expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);

    //    Check page is loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

//    Run twice to make sure firebase data is loaded
    await tester.pump();
    await tester.pump();

//    Find test card
    expect(find.widgetWithText(Card, "Test message"), findsOneWidget);
    expect(find.byIcon(FontAwesomeIcons.heart), findsWidgets);

//    Open more options dialog
    await tester.longPress(find.text("Test message"));
    await tester.pump();

//    Find more options dialog
    expect(find.text("More Options..."), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Details"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "Report"), findsOneWidget);

//    Open details dialog
    await tester.tap(find.text("Details"));
    await tester.pump();

//    Check details dialog fields
    expect(find.text("Sender: "), findsOneWidget);
    expect(find.text("Date sent: "), findsOneWidget);
    expect(find.text("Likes: "), findsOneWidget);
    expect(find.text("Message: "), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Close"), findsOneWidget);

//    Close details dialog
    await tester.tap(find.text("Close"));
    await tester.pump();

//    Open report dialog
    await tester.tap(find.text("Report"));
    await tester.pump();

//    Check report dialog fields
    expect(find.text("Are you sure you want to report this message?"), findsOneWidget);
    expect(find.widgetWithText(FlatButton, "No"), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Yes"), findsOneWidget);

//    Close report dialog
    await tester.tap(find.text("No"));
    await tester.pump();
  });
}