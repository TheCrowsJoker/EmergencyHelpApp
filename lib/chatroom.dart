import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'sharedFunctions.dart';
import 'main.dart';
import 'replies.dart';

class Chatroom extends StatefulWidget {
  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatroom"),
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
                      .collection('chats')
                      .orderBy('dateSent', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length > 0) {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot _docSnap =
                                  snapshot.data.documents[index];
                              return Card(
                                color: Colors.purple[100],
                                elevation: 5.0,
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Replies(
                                                _docSnap['messageID'],
                                              )),
                                    );
                                  },
                                  title: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            _docSnap['sender'].length < 10.0
                                                ? _docSnap['sender']
                                                : _docSnap['sender']
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
                                                _docSnap['dateSent']),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _docSnap['message'].length < 50
                                              ? _docSnap['message']
                                              : _docSnap['message']
                                                      .substring(0, 50) +
                                                  "...",
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            _docSnap['likes'].length.toString() +
                                                " Likes",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                          IconButton(
                                            icon: _docSnap['likes']
                                                    .contains(savedKey)
                                                ? Icon(
                                                    FontAwesomeIcons.solidHeart)
                                                : Icon(FontAwesomeIcons.heart),
                                            onPressed: () {
                                              likeMessage(_docSnap['messageID']);
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  onLongPress: () {
                                    moreOptions(
                                        context,
                                        _docSnap['userID'],
                                        _docSnap['messageID'],
                                        null,
                                        _docSnap['sender'],
                                        _docSnap['message'],
                                        _docSnap['dateSent'],
                                        _docSnap['likes']);
                                  },
                                ),
                              );
                            });
                      } else {
                        return Center(
                            child: Text(
                          "No messages yet",
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
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  heroTag: 'addBtn',
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addChat');
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