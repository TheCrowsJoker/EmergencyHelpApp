import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  SmsSender _sender;
  String _message;

  String contactExistsError = "This contact already exists";

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void updateDatabase(BuildContext context) {
    checkContactExists(_phoneNumberController.text).then((result) {
      if (result != true) {
        Uuid uuid = new Uuid();
        String id = uuid.v1();

        Firestore.instance.collection('contacts').document().setData({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'dateAdded': Timestamp.now(),
          'userID': savedKey,
          'contactID': id,
          'selected': true,
        });
        Navigator.pop(context);

        sendNotificationMessage();
      } else {
        errorDialog(context, contactExistsError);

      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Contact"),
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
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: _nameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        onPressed: () {
                          _nameController.text.isNotEmpty &&
                              _phoneNumberController.text.isNotEmpty
                              ? updateDatabase(context)
                              :
                          // ignore: unnecessary_statements
                          null;
                        },
                        color: Theme
                            .of(context)
                            .primaryColorLight,
                        disabledColor: Colors.grey,
                        child: Text(
                          "Add",
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
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

  void sendNotificationMessage() async {
    String userPhoneNumber = await getUserDetail("phoneNumber");
    _message = "You have been added as a contact on " + appName + " by " +
        userPhoneNumber + ". "
        "This is an app that allows them to send you their "
        "location when they are in trouble.";
    _sender = new SmsSender();
    _sender.sendSms(new SmsMessage(_phoneNumberController.text, _message));
  }

  Future<bool> checkContactExists(String number) async {
    bool result;
    await Firestore.instance
        .collection('contacts')
        .where('userID', isEqualTo: savedKey)
        .where('phoneNumber', isEqualTo: number)
        .getDocuments()
        .then((docs) {
      docs.documents.length == 0 ? result = false : result = true;
    });

    return result;
  }
}
