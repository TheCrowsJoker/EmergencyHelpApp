import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_help/chatroom.dart';
import 'package:emergency_help/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Replies extends StatefulWidget {
  final id;

  Replies(this.id);

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Reply"),
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
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('replies')
                            .where('messageID', isEqualTo: widget.id)
                            .orderBy('dateSent')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.documents.length > 0) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot docSnap =
                                        snapshot.data.documents[index];
                                    return Card(
                                      color: Colors.purple[100],
                                      elevation: 5.0,
                                      margin: new EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 6.0),
                                      child: ListTile(
                                        title: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                              Text(
                                                docSnap['sender'].length < 10.0
                                                    ? docSnap['sender']
                                                    : docSnap['sender']
                                                            .toString()
                                                            .substring(0, 10) +
                                                        "...",
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                                Text(
                                                  formatDateOptions(
                                                      docSnap['dateSent']),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                docSnap['message'],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            } else {
                              return Center(
                                  child: Text(
                                "No Replies",
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ));
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        }),
                  ),
                ),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('chats')
                        .where('messageID', isEqualTo: widget.id)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length > 0) {
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot docSnap =
                                    snapshot.data.documents[index];
                                return Card(
                                  color: Colors.purple[100],
                                  elevation: 5.0,
                                  margin: new EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 6.0),
                                  child: ListTile(
                                    title: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              docSnap['sender'],
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              formatDateOptions(
                                                  docSnap['dateSent']),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            docSnap['message'],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              docSnap['likes'].length.toString() +
                                                  " Likes",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                            IconButton(
                                              icon: docSnap['likes']
                                                  .contains(savedKey)
                                                  ? Icon(
                                                  FontAwesomeIcons.solidHeart)
                                                  : Icon(FontAwesomeIcons.heart),
                                              onPressed: () {
                                                likeMessage(docSnap['messageID']);
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        } else {
                          return Center(
                              child: Text(
                            "Error",
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ));
                        }
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Reply',
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.purple, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.purple, width: 1.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                sendReply();
                              },
                            )),
                        textCapitalization: TextCapitalization.sentences,
                        controller: _messageController,
                      ),
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
            )));
  }

  Future sendReply() async {
    String username = await getUserDetail('username', savedKey);

    Firestore.instance.collection('replies').document().setData({
      'messageID': widget.id,
      'sender': username,
      'message': _messageController.text,
      'dateSent': Timestamp.now(),
      'userID': savedKey,
    });

    _messageController.clear();
  }
}
