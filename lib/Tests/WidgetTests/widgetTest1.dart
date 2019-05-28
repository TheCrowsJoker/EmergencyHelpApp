import 'package:emergency_help/main.dart';
import 'package:emergency_help/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Main Widget', (WidgetTester tester) async {
    //    Set up widget
    await tester.pumpWidget(MyAppTest());

    await tester.pump();

    expect(find.text(appName), findsOneWidget);
    expect(find.text("Send location by clicking help"), findsOneWidget);
    expect(find.text("Help"), findsOneWidget);
    expect(find.text("More Help..."), findsOneWidget);

    await tester.tap(find.text("Help"));
    await tester.pump();

    expect(find.text("Touch button again to cancel"), findsOneWidget);
    expect(find.text("Sent"), findsOneWidget);
    expect(find.text("Send now"), findsOneWidget);

    await tester.tap(find.text("Sent"));
    await tester.pump();

    expect(find.text("Send location by clicking help"), findsOneWidget);
    expect(find.text("Help"), findsOneWidget);
    expect(find.text("More Help..."), findsOneWidget);
  });
}

class MyAppTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppTestState();
}

class _MyAppTestState extends State<MyAppTest>{
  bool _timerRunning = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(appName),
          ),
          drawer: Menu(),
          body: Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.purple[400], Colors.purple[100]],
              ),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 50.0, horizontal: 20.0),
                      child: Center(
                        child: Text(
                          !_timerRunning
                              ? "Send location by clicking help"
                              : "Touch button again to cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: OutlineButton(
                    shape: CircleBorder(),
                    color: Theme.of(context).backgroundColor,
                    onPressed: () {
                      setState(() {
                        _timerRunning == false ? _timerRunning = true : _timerRunning = false;
                      });
                    },
                    child: Center(
                      child: Text(
                        !_timerRunning
                            ? "Help"
                            : "Sent",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10.0)),
                      height: 50.0,
                      child: OutlineButton(
                        color: Theme.of(context).backgroundColor,
                        child: Text(
                          !_timerRunning
                              ? "More Help..."
                              : "Send now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        onPressed: () {

                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

}