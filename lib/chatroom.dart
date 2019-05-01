import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_help/main.dart';
import 'package:emergency_help/replies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                              DocumentSnapshot docSnap =
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
                                                docSnap['messageID'],
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

Future likeMessage(String id) async {
  Firestore.instance
      .collection('chats')
      .where('messageID', isEqualTo: id)
      .limit(1)
      .getDocuments()
      .then((doc) {
    if (doc.documents.length > 0)
      Firestore.instance
          .collection('chats')
          .document(doc.documents[0].documentID)
          .updateData({
        'likes': !doc.documents[0]['likes'].contains(savedKey)
            ? FieldValue.arrayUnion([savedKey])
            : FieldValue.arrayRemove([savedKey]),
      });
    else {
      print("error, no docs found");
    }
  });
}

String formatDateOptions(DateTime date) {
  String finalDate;
  DateTime now = DateTime.now();

  // else eg:
  // 23 March 19
  finalDate = formatDate(date, [dd, ' ', M, ' ', yy]);

  // if sent this year eg:
  // 12 Feb
  if (date.year == now.year) finalDate = formatDate(date, [dd, ' ', M]);

  // if less than 12 hours ago eg:
  // 3 hours
  if (now.difference(date).inHours < 24) if (now.difference(date).inHours == 1)
    finalDate = now.difference(date).inHours.toString() + " hour";
  else
    finalDate = now.difference(date).inHours.toString() + " hours";

  // if less than an hour ago eg:
  // 5 mins
  if (now.difference(date).inMinutes < 60) if (now.difference(date).inMinutes ==
      1)
    finalDate = now.difference(date).inMinutes.toString() + " min";
  else
    finalDate = now.difference(date).inMinutes.toString() + " mins";

  return finalDate;
}
