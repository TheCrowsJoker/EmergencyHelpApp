import 'dart:async';
import 'dart:io';
import 'package:emergency_help/splash.dart';
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
import 'resources.dart';
import 'chatroom.dart';
import 'addChat.dart';
import 'replies.dart';
import 'profile.dart';
import 'about.dart';

// Global variables that need to be accessed from other files
String appName = "code:PURPLE";
String savedKey;
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
  int _timerValue = 10;
  bool _timerRunning = false;

//  Set up values for messages
  Timestamp _date;
  String _username;
  double _latitude;
  double _longitude;
  String _locationString;
  String _message;
  String _url;

//  SMS values
  SmsSender _sender;
  List<String> _addresses;

  int _numMessagesToSend;
  int _numMessagesLeftToSend;
  String _tempMessage;
  int _charLimit;

//  Error messages
  String noContactsSelectedError = "You have not selected any contacts, "
      "this alert wont get sent to anyone";

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
//    _checkKey().then((result) => setState(() {
//          doesUserHaveAccount = result;
//        }));
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
    _username = await getUserDetail("username", savedKey);
    _latitude = _currentLocation['latitude'];
    _longitude = _currentLocation['longitude'];
    _locationString = _latitude.toString() + "," + _longitude.toString();
    _url = "maps.google.com/maps/?q=" + _locationString;
    _message = "$_username has contacted you for help.\n"
        "They are at this location: $_url";

    Firestore.instance.collection('message').document().setData({
      'userID': savedKey,
      'date': _date,
      'location': GeoPoint(_latitude, _longitude),
      'mapsURL': _url,
      'message': _message,
    });

    _addresses = await getSelectedContactDetails("phoneNumber");
    _sender = new SmsSender();

    for (var address in _addresses)
      _sender.sendSms(new SmsMessage(address, _message));
  }

  void sendMoreInfoMessages() async {
    _addresses = await getSelectedContactDetails("phoneNumber");

    _message = _controller.text;
    _sender = new SmsSender();
    _charLimit = 150;

//    Split message into small messages so they can be sent via sms
    if (_message.length >= _charLimit) {
      _numMessagesToSend = (_message.length / _charLimit).ceil();
      _numMessagesLeftToSend = _numMessagesToSend;
      for (int i = 0; i <= _message.length; i += _charLimit) {
        _tempMessage = "(" +
            ((_numMessagesToSend - _numMessagesLeftToSend) + 1).toString() +
            "/" +
            _numMessagesToSend.toString() +
            ") ";
        if (_numMessagesLeftToSend != 1.0)
          _tempMessage += _message.substring(i, i + _charLimit);
        else
          _tempMessage += _message.substring(i);

        for (var address in _addresses) {
          _sender.sendSms(new SmsMessage(address, _tempMessage));
        }

        _numMessagesLeftToSend--;
      }
    } else {
      _tempMessage = _message;
      for (var address in _addresses) {
        _sender.sendSms(new SmsMessage(address, _tempMessage));
      }
    }

//    Store message in database too
    Firestore.instance.collection('moreInfoMessages').document().setData({
      'userID': savedKey,
      'date': _date,
      // we dont reset the date so it is the same as the last message that was sent
      'message': _message,
    });
  }

  void startTimer(BuildContext context) {
    setState(() {
      _timerRunning = true;
    });
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
    setState(() {
      _timerRunning = false;
    });
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
                  decoration: InputDecoration(
                      labelText: 'Message', alignLabelWithHint: true),
                  controller: _controller,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
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
      doesUserHaveAccount = true;
    } else {
      doesUserHaveAccount = false;
    }
    return doesUserHaveAccount;
  }

  Future<List> getSelectedContactDetails(String detail) async {
    List<String> list = [];
    await Firestore.instance
        .collection('contacts')
        .where('userID', isEqualTo: savedKey)
        .where('selected', isEqualTo: true)
        .getDocuments()
        .then((querySnapshot) {
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
          '/home': (context) => MyApp(),
          '/createAccount': (context) => CreateAccount(),
          '/contacts': (context) => Contacts(),
          '/addContact': (context) => AddContact(),
          '/resources': (context) => Resources(),
          '/chatroom': (context) => Chatroom(),
          '/addChat': (context) => AddChat(),
          '/profile': (context) => Profile(),
          '/about': (context) => About(),
        },
        home: FutureBuilder(
          future: _checkKey(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (doesUserHaveAccount == true) {
                  return Scaffold(
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
                                  if (!_timerRunning) {
                                    selectedContacts().then((anyContacts) {
                                      if (anyContacts == true)
                                        startTimer(context);
                                      else
                                        errorDialog(
                                            context, noContactsSelectedError);
                                    });
                                  } else
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
                                      !_timerRunning
                                          ? "More Help..."
                                          : "Send now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    onPressed: () {
                                      !_timerRunning
                                          ? Navigator.pushNamed(
                                              context, '/resources')
                                          : _timerValue =
                                              0; // Used to send message straight away
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                } else {
                  return Splash();
                }
              }
            } else {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                ),
                child: Center(
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              );
            }
          },
        ));
  }

  Future<bool> selectedContacts() async {
    List list = await getSelectedContactDetails("contactID");
    if (list.length == 0)
      return false;
    else
      return true;
  }
}

Future<String> getUserDetail(String detail, String id) async {
  String field;
  await Firestore.instance
      .collection('users')
      .where('id', isEqualTo: id)
      .limit(1)
      .getDocuments()
      .then((doc) {
    field = doc.documents.first[detail];
  });

  return field;
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

void errorDialog(BuildContext context, String string) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Center(child: Text("Error!")),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(string),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
//                        Close dialog
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        );
      });
}
