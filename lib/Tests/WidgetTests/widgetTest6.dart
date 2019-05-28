import 'package:emergency_help/replies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets('Replies Widget', (WidgetTester tester) async {
//    Set up widget
    await tester.pumpWidget(MaterialApp(
        home: Replies("mid1234")));

//    Check header is present
    expect(find.text("Reply"), findsWidgets);

    //    Check for home button
    expect(find.widgetWithIcon(FloatingActionButton, Icons.home), findsOneWidget);

    //    Check page is loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //    Run twice to make sure firebase data is loaded
    await tester.pump();
    await tester.pump();

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

    await tester.tap(find.text("Test message"));
    await tester.pump();

    await tester.tap(find.text("View Replies"));
    await tester.pumpWidget(BottomSheet(onClosing: () {},));
    await tester.pump();

    //    Open more options dialog
    await tester.longPress(find.text("Test reply"));
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
    
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
  });
}