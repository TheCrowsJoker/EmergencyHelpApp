import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sharedFunctions.dart';
import 'main.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _doesntExist = "No account exists with this username and phone number";
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
                          "Login",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty && _phoneNumberController.text.isNotEmpty) {
                            _accountLogin();
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

  Future _accountLogin() async {
    await Firestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: _phoneNumberController.text)
        .where('username', isEqualTo: _usernameController.text)
        .limit(1)
        .getDocuments()
        .then((doc) {
      if (doc.documents.length > 0) {
        writeKey(doc.documents.first['id']);
        readKey().then((result) => savedKey = result);

        doesUserHaveAccount = true;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        errorDialog(context, _doesntExist);
      }
    });
  }
}