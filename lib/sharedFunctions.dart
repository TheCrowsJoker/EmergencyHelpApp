import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:date_format/date_format.dart';
import 'autoScrollText.dart';
import 'package:sms/sms.dart';

import 'main.dart';

String missingFieldError = "All fields should be filled";

Future<String> getUserDetail(String detail, String id) async {
  String field;
  await Firestore.instance
      .collection('users')
      .where('id', isEqualTo: id)
      .limit(1)
      .getDocuments()
      .then((doc) {
    field = doc.documents.first[detail];
  });

  return field;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/key.txt');
}

Future<File> writeKey(String key) async {
  final file = await _localFile;

  // Write the file
  return file.writeAsString('$key');
}

Future<String> readKey() async {
  try {
    final file = await _localFile;

    // Read the file
    String contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "0";
  }
}

void errorDialog(BuildContext context, String string) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Center(child: Text("Error!")),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(string),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
//                        Close dialog
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        );
      });
}


void moreOptions(
    BuildContext context,
    String userID,
    String messageID,
    String replyID,
    String sender,
    String message,
    DateTime dateSent,
    List likes) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(
              "More Options...",
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              FlatButton(
                child: Text("Details"),
                onPressed: () {
                  messageDetails(context, messageID, userID, replyID, sender,
                      message, dateSent, likes);
                },
              ),
              userID != savedKey ?
              FlatButton(
                child: Text("Report"),
                onPressed: () {
                  reportMessage(context, messageID, userID, dateSent);
                },
              ) : IgnorePointer(),
              userID == savedKey
                  ? FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  deleteMessage(
                      context, "chats", "messageID", userID, messageID);
                },
              )
                  : IgnorePointer(),
            ]);
      });
}

void messageDetails(
    BuildContext context,
    String messageID,
    String userID,
    String replyID,
    String sender,
    String message,
    DateTime dateSent,
    List likes) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(
              "Message Details",
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    sender != null
                        ? Row(
                      children: <Widget>[
                        Text(
                          "Sender: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(sender),
                      ],
                    )
                        : IgnorePointer(),
                    dateSent != null
                        ? Row(
                      children: <Widget>[
                        Text(
                          "Date sent: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(formatDate(dateSent, [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn])),
                      ],
                    )
                        : IgnorePointer(),
                    likes != null
                        ? Row(
                      children: <Widget>[
                        Text(
                          "Likes: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(likes.length.toString()),
                      ],
                    )
                        : IgnorePointer(),
                    message != null
                        ? Row(
                      children: <Widget>[
                        Text(
                          "Message: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        message.length > 30
                            ? AutoScrollText(
                          items: <Widget>[
                            Text(
                              message,
                            ),
                          ],
                        )
                            : Text(message),
                      ],
                    )
                        : IgnorePointer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]);
      });
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

void deleteMessage(BuildContext context, String db, String id, String userID,
    String messageID) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(
              "Are you sure you want to delete this message?",
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      child: Text("Yes"),
                      onPressed: () {
                        Firestore.instance
                            .collection(db)
                            .where('userID', isEqualTo: userID)
                            .where(id, isEqualTo: messageID)
                            .limit(1)
                            .getDocuments()
                            .then((doc) {
                          if (doc.documents.length > 0)
                            Firestore.instance
                                .collection(db)
                                .document(doc.documents[0].documentID)
                                .delete();
                          else {
                            print("error, no docs found");
                          }
                        });
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ]);
      });
}

Future reportMessage(BuildContext context, String messageID, String userID,
    DateTime dateSent) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text(
              "Are you sure you want to report this message?",
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      child: Text("Yes"),
                      onPressed: () async {
                        String phoneNumber =
                        await getUserDetail("phoneNumber", userID);
                        String _message =
                            "A user has reported your message sent at: " +
                                dateSent.toString() +
                                " to be inappropriate. Please review this message and remove or edit it.";

                        SmsSender _sender = new SmsSender();
                        _sender.sendSms(new SmsMessage(phoneNumber, _message));

                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ]);
      });
}
