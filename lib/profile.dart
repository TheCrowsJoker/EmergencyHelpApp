import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';

import 'main.dart';
import 'sharedFunctions.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _editing = false;
  bool _onlyOnce = true;

  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Used to make updating fields easier
  String _username;
  String _phoneNumber;

//  Used to show which info was deleted
  List _resultList = [];

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.purple[400], Colors.purple[100]],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .where('id', isEqualTo: savedKey)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        DocumentSnapshot _docSnap = snapshot.data.documents[0];
                        _username = _docSnap['username'];
                        _phoneNumber = _docSnap['phoneNumber'];
//                      Only set the controllers once to use as initial values
                        if (_onlyOnce == true) {
                          _usernameController.text = _username;
                          _phoneNumberController.text = _phoneNumber;
                          _onlyOnce = false;
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration:
                                InputDecoration(labelText: 'Username'),
                                enabled: _editing,
                                controller: _usernameController,
                                textCapitalization: TextCapitalization.words,
                              ),
                              TextFormField(
                                decoration:
                                InputDecoration(labelText: 'Phone Number'),
                                enabled: _editing,
                                keyboardType: TextInputType.numberWithOptions(),
                                controller: _phoneNumberController,
                              ),
                              TextFormField(
                                initialValue: formatDate(_docSnap['dateJoined'], [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]),
                                decoration:
                                InputDecoration(labelText: 'Date Joined'),
                                enabled: false,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    ButtonTheme(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0)),
                                      height: 50.0,
                                      child: OutlineButton(
                                        child: Text(
                                          "Logout",
                                        ),
                                        onPressed: () {
                                          _logout(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    ButtonTheme(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0)),
                                      height: 50.0,
                                      child: _editing ?
                                      OutlineButton(
                                        child: Text(
                                          "Delete Info",
                                        ),
                                        onPressed: () {
                                          _deleteMessages(context);
                                        },
                                      ) :
                                      IgnorePointer(),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    ButtonTheme(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0)),
                                      height: 50.0,
                                      child: _editing ?
                                      OutlineButton(
                                        child: Text(
                                          "Delete Account",
                                        ),
                                        onPressed: () {
                                          _deleteAccountDialog(context);
                                        },
                                      ) :
                                      IgnorePointer(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                    icon: Icon(Icons.edit),
                    label: Text(_editing == true ? "Stop Editing" : "Edit"),
                    onPressed: () {
                      setState(() {
                        _editing == true ? _editing = false : _editing = true;
                      });
                      if (_username != _usernameController.text ||
                          _phoneNumber != _phoneNumberController.text) {
                        Firestore.instance
                            .collection('users')
                            .where('id', isEqualTo: savedKey)
                            .limit(1)
                            .getDocuments()
                            .then((doc) {
                          if (doc.documents.length > 0)
                            Firestore.instance
                                .collection('users')
                                .document(doc.documents[0].documentID)
                                .updateData({
                              'username': _usernameController.text,
                              'phoneNumber': _phoneNumberController.text,
                            });
                          else {
                            print("error, no docs found");
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    heroTag: 'homeBtn',
                    child: Icon(Icons.home),
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAccountDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                "Are you sure you want to delete your account?",
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("You may want to delete your information first. Account deleteion cannot be undone"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: Text("Yes"),
                        onPressed: () {
                          setState(() {
                            Firestore.instance
                                .collection('users')
                                .where('id', isEqualTo: savedKey)
                                .limit(1)
                                .getDocuments()
                                .then((doc) {
                              if (doc.documents.length > 0)
                                Firestore.instance
                                    .collection('users')
                                    .document(doc.documents[0].documentID)
                                    .delete();
                              else {
                                print("error, no docs found");
                              }
                            });
                          });

                          writeKey('0');
                          doesUserHaveAccount = false;

                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      )
                    ],
                  ),
                ),
              ]);
        });
  }

  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: Text("Yes"),
                        onPressed: () {
                          setState(() {
                            writeKey('0');
                            doesUserHaveAccount = false;
                          });
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      )
                    ],
                  ),
                ),
              ]);
        }
    );
  }

  void _deleteMessages(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
              title: Text(
                "Would you like to delete all information associated with this account?",
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                      RaisedButton(
                        child: Text("Yes"),
                        onPressed: () {
                          _resultList.clear(); // clear resultlist
                          // messages
                          _deleteInfo('message');
                          // chats
                          _deleteInfo('chats');
                          // replies
                          _deleteInfo('replies');
                          // moreinfomessages
                          _deleteInfo('moreInfoMessages');
                          // contacts
                          _deleteInfo('contacts');

                          Navigator.pop(dialogContext);

                          final snackBar = SnackBar(
                            content: Text('Info Deleted'),
                            action: SnackBarAction(
                              label: 'Details',
                              onPressed: () {
                                _deletionResults(context);
                              },
                            ),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        },
                      )
                    ],
                  ),
                ),
              ]);
        }
    );
  }

  void _deleteInfo(String db) {
    String _string;
    Firestore.instance
        .collection(db)
        .where("userID", isEqualTo: savedKey)
        .getDocuments()
        .then((doc) {
      if (doc.documents.length > 0) {
        for (int i = 0; i < doc.documents.length; i++) {
          Firestore.instance
              .collection(db)
              .document(doc.documents[i].documentID)
              .delete();
        }
        _string = db + ": Deleted " + doc.documents.length.toString() + " documents";
      } else {
        _string = db + ": Nothing found";
        print("error, no docs found in " + db);
      }
      _resultList.add(_string);
    });
  }

  void _deletionResults(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
              title: Text(
                "Results",
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(shrinkWrap: true,
                      itemCount: _resultList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Text(_resultList[index]);
                      }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      OutlineButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  ),
                ),
              ]);
        }
    );
  }
}