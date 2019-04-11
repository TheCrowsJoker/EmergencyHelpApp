import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/sms.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

String appName = "Emergency Help App";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  // todo: Change this to the app logo when its been created
                  child: Text("App logo will be here eventually\n"
                      "For now, enjoy this poem extract by E.A. Poe:\n\n"
                      "Years of love have been forgot,\n"
                      "in the hatred of a minute"),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text('Contacts'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map / List'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Chat'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Container(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About'),
                        onTap: () {},
                      )
                    ],
                  ))))
        ],
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
//  Timer values
  Timer _timer;
  int _timerValue = 5;
  bool _timerRunning = false;

//  Set up values for messages
  DateTime _date;
  double _latitude;
  double _longitude;
  String _locationString;
  String _message;
  String _url;

//  SMS values
  String _address;

//  Location values
  Map<String, double> _currentLocation = new Map();
  // ignore: cancel_subscriptions, unused_field
  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();

  // ignore: unused_field
  String _error;

  @override
  void initState() {
    super.initState();

    _currentLocation['latitude'] = 0.0;
    _currentLocation['longitude'] = 0.0;

    initPlatformState();
    _locationSubscription =
        _location.onLocationChanged().listen((Map<String, double> _result) {
      setState(() {
        _currentLocation = _result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appName,
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(appName),
          ),
          drawer: _Menu(),
          body: Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
//              Theme.of(context).backgroundColor,
                  Colors.purple[300],
                  Theme.of(context).primaryColorLight
                ],
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
                          !_timerRunning ?
                          "Send location by clicking help" :
                          "Touch button again to cancel",
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
                      if (!_timerRunning)
                        startTimer();
                      else
                        stopTimer();
                    },
                    child: Center(
                      child: Text(
                        !_timerRunning ?
                        "Help" :
                          _timerValue == -1 ?
                          "Sent" :
                          _timerValue.toString() ,
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
                          borderRadius: BorderRadius.circular(10.0)),
                      height: 50.0,
                      child: OutlineButton(
                        color: Theme.of(context).backgroundColor,
                        child: Text(
                          "More Help...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void initPlatformState() async {
    Map<String, double> _my_location;
    try {
      _my_location = await _location.getLocation();
      _error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED')
        _error = 'Permission denied';
      else if (e.code == "PERMISSION_DENIED_NEVER_ASK")
        _error =
            "Permission denied - please ask the user to enable it from the app settings";
      _my_location = null;
    }
    setState(() {
      _currentLocation = _my_location;
    });
  }

  void sendMessages() {
    _date = new DateTime.now();
    _latitude = _currentLocation['latitude'];
    _longitude = _currentLocation['longitude'];
    _locationString = _latitude.toString() + "," + _longitude.toString();
    _url = "https://www.google.com/maps/?q=$_locationString";
    _message = "{User} has contacted you for help.\n"
        "They are at this location: $_url.\n"
        "This was sent at: $_date";

    Firestore.instance.collection('message').document().setData({
      'date': _date,
      'location': GeoPoint(_latitude, _longitude),
      'mapsURL': _url,
      'message': _message,
    });

    SmsSender sender = new SmsSender();
    _address = "mobile number"; // todo Replace with mobile number
    sender.sendSms(new SmsMessage(_address, _message));
  }

  void startTimer() {
    _timerRunning = true;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
            (Timer timer) => setState(() {
          if (_timerValue < 0) {
            stopTimer();
            sendMessages();
          } else {
            _timerValue = _timerValue - 1;
          }
        }));
  }

  void stopTimer() {
    _timer.cancel();
    _timerRunning = false;
    _timerValue = 10;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
