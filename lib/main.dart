import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/sms.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'createAccount.dart';
import 'menu.dart';
import 'contacts.dart';
import 'addContact.dart';

String appName = "Emergency Help App";
String savedKey; // Keep global so can be accessed from all files
bool doesUserHaveAccount;


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//  Account key
  String _key;

//  Timer values
  Timer _timer;
  int _timerValue = 5; // todo replace with 10 seconds
  bool _timerRunning = false;

//  Set up values for messages
  Timestamp _date;
  double _latitude;
  double _longitude;
  String _locationString;
  String _message;
  String _url;

//  SMS values
  SmsSender sender;
  List<String> addresses;

  int numMessagesToSend;
  int numMessagesLeftToSend;
  String tempMessage;
  int charLimit;

//  Location values
  Map<String, double> _currentLocation = new Map();

  // ignore: cancel_subscriptions, unused_field
  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();

  // ignore: unused_field
  String _error;

  final _controller = TextEditingController();

//  Used for location and setting up an account
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

//    Check if user has a key
    _checkKey().then((result) => setState(() {
          doesUserHaveAccount = result;
        }));
//    Save key to variable for quicker reading
    readKey().then((result) => setState(() {
          savedKey = result;
        }));
  }

//  Also used for location
  void initPlatformState() async {
    Map<String, double> _myLocation;
    try {
      _myLocation = await _location.getLocation();
      _error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED')
        _error = 'Permission denied';
      else if (e.code == "PERMISSION_DENIED_NEVER_ASK")
        _error =
            "Permission denied - please ask the user to enable it from the app settings";
      _myLocation = null;
    }
    setState(() {
      _currentLocation = _myLocation;
    });
  }

  void sendMessages() async {
    _date = new Timestamp.now();
    _latitude = _currentLocation['latitude'];
    _longitude = _currentLocation['longitude'];
    _locationString = _latitude.toString() + "," + _longitude.toString();
    _url = "maps.google.com/maps/?q=" + _locationString;
    _message = "{User} has contacted you for help.\n"
        "They are at this location: $_url";

    Firestore.instance.collection('message').document().setData({
      'userID': savedKey,
      'date': _date,
      'location': GeoPoint(_latitude, _longitude),
      'mapsURL': _url,
      'message': _message,
    });

    addresses = await getSelectedContactDetails("phoneNumber");
    sender = new SmsSender();

    for (var address in addresses)
      sender.sendSms(new SmsMessage(address, _message));
  }

  void sendMoreInfoMessages() async {
    addresses = await getSelectedContactDetails("phoneNumber");
    print(addresses[0]);

    _message = _controller.text;
    print(_message);
    sender = new SmsSender();
    charLimit = 150;

    if (_message.length >= charLimit) {
      numMessagesToSend =
          (_message.length / charLimit).ceil();
      numMessagesLeftToSend = numMessagesToSend;
      for (int i = 0;
      i <= _message.length;
      i += charLimit) {
        tempMessage = "(" +
            ((numMessagesToSend - numMessagesLeftToSend) + 1)
                .toString() +
            "/" +
            numMessagesToSend.toString() +
            ") ";
        if (numMessagesLeftToSend != 1.0)
          tempMessage += _message.substring(i, i + charLimit);
        else
          tempMessage += _message.substring(i);

        for (var address in addresses) {
          sender.sendSms(new SmsMessage(address, tempMessage));
        }

        numMessagesLeftToSend--;
      }
    } else {
      tempMessage = _message;
      for (var address in addresses) {
        sender.sendSms(new SmsMessage(address, tempMessage));
      }
    }
  }

  void startTimer(BuildContext context) {
    _timerRunning = true;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_timerValue < 0) {
                stopTimer();
                sendMessages();
                _moreInfoDialog(context);
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

//  Used for the timer
  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _moreInfoDialog(BuildContext context) {
//    Clear the text from the dialog window before opening
    _controller.clear();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Can you provide more information?"),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Message'),
                  controller: _controller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
//                        Close dialog
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        sendMoreInfoMessages();

//                        Close dialog
                        Navigator.pop(context);
                      },
                      color: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future<bool> _checkKey() async {
    _key = await readKey();

    if (_key != "0") {
      return true;
    } else {
      return false;
    }
  }

  Future<List> getSelectedContactDetails(String detail) async {
    List<String> list = [];
    await Firestore.instance
        .collection('contacts')
        .where('userID', isEqualTo: savedKey)
        .where('selected', isEqualTo: true)
        .getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((i) {
        list.add(i.data[detail]);
      });
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        title: appName,
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        routes: {
          '/contacts': (context) => Contacts(),
          '/addContact': (context) => AddContact(),
        },
        home: doesUserHaveAccount == true
            ? // If the user doesnt have an account, let them create one
            Scaffold(
                appBar: AppBar(
                  title: Text(appName),
                ),
                drawer: Menu(),
                body: Builder(
                  builder: (context) => Container(
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
                                  if (!_timerRunning)
                                    startTimer(context);
                                  else
                                    stopTimer();
                                },
                                child: Center(
                                  child: Text(
                                    !_timerRunning
                                        ? "Help"
                                        : _timerValue == -1
                                            ? "Sent"
                                            : _timerValue.toString(),
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
                                      "More Help...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    onPressed: () {
                                      writeKey("0");
//                                      getSelectedContactDetails("phoneNumber");
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ))
            : CreateAccount());
  }
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/key.txt');
}

Future<File> writeKey(String key) async {
  final file = await _localFile;

  // Write the file
  return file.writeAsString('$key');
}

Future<String> readKey() async {
  try {
    final file = await _localFile;

    // Read the file
    String contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "0";
  }
}
