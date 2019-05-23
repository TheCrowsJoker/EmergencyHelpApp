import 'package:emergency_help/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a Text Widget', (WidgetTester tester) async {
//    Used to find the scaffold by the tester
    final scaffoldKey = GlobalKey<ScaffoldState>();

//    Set up widget
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        drawer: Menu(),
      ),
    ));

//    Open drawer
    scaffoldKey.currentState.openDrawer();
    await tester.pump();

//    Check all items are in the list
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Map / List'), findsOneWidget);
    expect(find.text('Chatroom'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });
}