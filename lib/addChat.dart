import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'sharedFunctions.dart';
import 'main.dart';

class AddChat extends StatefulWidget {
  @override
  _AddChatState createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future _updateDatabase(BuildContext context) async {
    if (_messageController.text.isNotEmpty) {
      Uuid _uuid = new Uuid();
      String _id = _uuid.v1();

      String _username = await getUserDetail('username', savedKey);

      Firestore.instance.collection('chats').document().setData({
        'messageID': _id,
        'sender': _username,
        'message': _messageController.text,
        'dateSent': Timestamp.now(),
        'userID': savedKey,
        'likes': [],
      });
      Navigator.pop(context);
    } else {
      errorDialog(context, missingFieldError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Message"),
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
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Message',
                          alignLabelWithHint: true
                      ),
                      controller: _messageController,
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
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        RaisedButton(
                          onPressed: () {
                            _updateDatabase(context);
                          },
                          color: Theme.of(context).primaryColorLight,
                          disabledColor: Colors.grey,
                          child: Text(
                            "Post",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
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
      ),
    );
  }
}
