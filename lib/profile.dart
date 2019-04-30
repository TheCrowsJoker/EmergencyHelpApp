import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editing = false;
  bool onlyOnce = true;

  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Used to make updating fields easier
  String _username;
  String _phoneNumber;

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
      body: Container(
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
                      DocumentSnapshot docSnap = snapshot.data.documents[0];
                      _username = docSnap['username'];
                      _phoneNumber = docSnap['phoneNumber'];
//                      Only set the controllers once to use as initial values
                      if (onlyOnce == true) {
                        _usernameController.text = _username;
                        _phoneNumberController.text = _phoneNumber;
                        onlyOnce = false;
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              initialValue: docSnap['id'],
                              decoration: InputDecoration(labelText: 'ID'),
                              enabled: false,
                            ),
                            TextFormField(
//                              initialValue: _username,
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                              enabled: editing,
                              controller: _usernameController,
                              textCapitalization: TextCapitalization.words,
                            ),
                            TextFormField(
//                              initialValue: _phoneNumber,
                              decoration:
                                  InputDecoration(labelText: 'Phone Number'),
                              enabled: editing,
                              keyboardType: TextInputType.numberWithOptions(),
                              controller: _phoneNumberController,
                            ),
                            TextFormField(
                              initialValue: docSnap['dateJoined'].toString(),
                              decoration:
                                  InputDecoration(labelText: 'Date Joined'),
                              enabled: false,
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
                  label: Text(editing == true ? "Stop Editing" : "Edit"),
                  onPressed: () {
                    setState(() {
                      editing == true ? editing = false : editing = true;
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
    );
  }
}
