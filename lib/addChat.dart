import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_help/main.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  Future updateDatabase(BuildContext context) async {
    Uuid uuid = new Uuid();
    String id = uuid.v1();

    String username = await getUserDetail('username', savedKey);

    Firestore.instance.collection('chats').document().setData({
      'messageID': id,
      'sender': username,
      'message': _messageController.text,
      'dateSent': Timestamp.now(),
      'userID': savedKey,
      'likes': [],
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Message"),
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
                          updateDatabase(context);
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
    );
  }
}
