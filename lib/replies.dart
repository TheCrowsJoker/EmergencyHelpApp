import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

import 'sharedFunctions.dart';
import 'main.dart';

class Replies extends StatefulWidget {
  final _id;

  Replies(this._id);

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
        body: GestureDetector(
          onTap: () {
            // call this method here to hide soft keyboard
            FocusScope.of(context).requestFocus(new FocusNode());
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('chats')
                            .where('messageID', isEqualTo: widget._id)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.documents.length > 0) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot _docSnap =
                                        snapshot.data.documents[index];
                                    return Column(
                                      children: <Widget>[
                                        Card(
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
                                                      _docSnap['sender'],
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      formatDateOptions(
                                                          _docSnap['dateSent']),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _docSnap['message'],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                      _docSnap['likes']
                                                              .length
                                                              .toString() +
                                                          " Likes",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 13.0,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: _docSnap['likes']
                                                              .contains(
                                                                  savedKey)
                                                          ? Icon(
                                                              FontAwesomeIcons
                                                                  .solidHeart)
                                                          : Icon(
                                                              FontAwesomeIcons
                                                                  .heart),
                                                      onPressed: () {
                                                        likeMessage(_docSnap[
                                                            'messageID']);
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            onTap: () {
                                              // Close keyboard
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            },
                                            onLongPress: () {
                                              moreOptions(
                                                  context,
                                                  _docSnap['userID'],
                                                  _docSnap['messageID'],
                                                  _docSnap['replyID'],
                                                  _docSnap['sender'],
                                                  _docSnap['message'],
                                                  _docSnap['dateSent'],
                                                  _docSnap['likes']);
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 10.0),
                                          child: ButtonTheme(
                                            minWidth: double.infinity,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            height: 50.0,
                                            child: OutlineButton(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              child: Text(
                                                "View Replies",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              onPressed: () {
                                                _viewReplies(context);
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            } else {
                              return Center(
                                  child: Text(
                                "No Message",
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
                                borderSide: BorderSide(
                                    color: Colors.purple, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.purple, width: 1.0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  _sendReply();
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
              )),
        ));
  }

  Future _sendReply() async {
    String _username = await getUserDetail('username', savedKey);

    Uuid _uuid = new Uuid();
    String _id = _uuid.v1();

    Firestore.instance.collection('replies').document().setData({
      'replyID': _id,
      'messageID': widget._id,
      'sender': _username,
      'message': _messageController.text,
      'dateSent': Timestamp.now(),
      'userID': savedKey,
    });

    _messageController.clear();
  }

  void _viewReplies(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                  ),
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('replies')
                          .where('messageID', isEqualTo: widget._id)
                          .orderBy('dateSent', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length > 0) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot _docSnap =
                                      snapshot.data.documents[index];
                                  return Card(
                                    color: Colors.purple[200],
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
                                              _docSnap['message'],
                                            ),
                                          ),
                                        ],
                                      ),
                                      onLongPress: () {
                                        moreOptions(
                                            context,
                                            _docSnap['userID'],
                                            _docSnap['messageID'],
                                            _docSnap['replyID'],
                                            _docSnap['sender'],
                                            _docSnap['message'],
                                            _docSnap['dateSent'],
                                            null);
                                      },
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple[300],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Replies",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              )
            ],
          );
        });
  }
}
