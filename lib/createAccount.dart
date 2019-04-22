import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

class CreateAccount extends StatelessWidget {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
      ),
      body: Container(
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
                controller: _usernameController,
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
                        if (_usernameController.text.isNotEmpty) {
//                          Create unique id for user
                          Uuid uuid = new Uuid();
                          String id = uuid.v1();

                          Firestore.instance
                              .collection('users')
                              .document()
                              .setData({
                            'id': id,
                            'username': _usernameController.text,
                            'dateJoined': Timestamp.now(),
                          });

                          writeKey(id);

                          Navigator.pushReplacementNamed(context, '/');
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
    );
  }
}
