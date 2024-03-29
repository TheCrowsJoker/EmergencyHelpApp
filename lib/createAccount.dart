import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'sharedFunctions.dart';
import 'main.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String _accountExistsError = "An account with this phone number already exists";

  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
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
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  inputFormatters:[
                    LengthLimitingTextInputFormatter(10),
                  ],
                  controller: _usernameController,
                  textCapitalization: TextCapitalization.words,
                ),
                TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                  ),
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.numberWithOptions(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        color: Theme.of(context).primaryColorLight,
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty && _phoneNumberController.text.isNotEmpty) {
                            _setupAccount();
                          } else {
                            errorDialog(context, missingFieldError);
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _setupAccount() async {
    await Firestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: _phoneNumberController.text)
        .limit(1)
        .getDocuments()
        .then((doc) {
      if (doc.documents.length == 0) {
//        Create unique id for user
        Uuid uuid = new Uuid();
        String id = uuid.v1();

        Firestore.instance
            .collection('users')
            .document()
            .setData({
          'id': id,
          'username': _usernameController.text,
          'phoneNumber': _phoneNumberController.text,
          'dateJoined': Timestamp.now(),
        });

        writeKey(id);

        readKey().then((result) => savedKey = result);

        doesUserHaveAccount = true;

        Navigator.pushNamed(context, '/contacts');
      } else
        errorDialog(context, _accountExistsError);
    });
  }
}
