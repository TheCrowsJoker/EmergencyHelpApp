import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

class CreateAccount extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  void dispose() {
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
                TextFormField( // todo add password
                  decoration: InputDecoration(
                    labelText: 'Password (Currently unused)',
                  ),
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
//                          Create unique id for user
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

                            doesUserHaveAccount = true;
                            Navigator.pushNamed(context, '/contacts');
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
}
