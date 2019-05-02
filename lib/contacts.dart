import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_help/autoScrollText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class Contacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
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
                      .collection('contacts')
                      .where('userID', isEqualTo: savedKey)
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
                                  title: Row(
                                    children: <Widget>[
                                      Text(
                                        docSnap['name'],
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        " | " + docSnap['phoneNumber'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: docSnap['selected'] == false
                                      ? Icon(Icons.check_box_outline_blank)
                                      : Icon(Icons.check_box),
                                  onTap: () {
                                    selectContact(context, docSnap['contactID'],
                                        docSnap['selected']);
                                  },
                                  onLongPress: () {
                                    showContactMenu(
                                        context,
                                        docSnap['contactID'],
                                        docSnap['name'],
                                        docSnap['phoneNumber'],
                                        docSnap['dateAdded'],
                                        docSnap['selected']);
                                  },
                                ),
                              );
                            });
                      } else {
                        return Center(
                            child: Text(
                          "No contacts added yet",
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
                    Navigator.pushNamed(context, '/addContact');
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

  void showContactMenu(BuildContext context, String id, String name,
      String phoneNumber, DateTime date, bool selected) {
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
                    contactDetails(
                        context, id, name, phoneNumber, date, selected);
                  },
                ),
                FlatButton(
                  child: Text("Edit"),
                  onPressed: () {
                    editContact(context, id, name, phoneNumber);
                  },
                ),
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () {
                    deleteContact(context, id, name);
                  },
                )
              ]);
        });
  }

  void deleteContact(BuildContext context, String id, String name) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                "Are you sure you want to delete " + name,
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
                              .collection('contacts')
                              .where('contactID', isEqualTo: id)
                              .limit(1)
                              .getDocuments()
                              .then((doc) {
                            if (doc.documents.length > 0)
                              Firestore.instance
                                  .collection('contacts')
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

  void editContact(
      BuildContext context, String id, String name, String phoneNumber) {
    _nameController.text = name;
    _phoneNumberController.text = phoneNumber;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                "Edit " + name,
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: _nameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.numberWithOptions(),
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
                        child: Text("Save"),
                        onPressed: () {
                          Firestore.instance
                              .collection('contacts')
                              .where('contactID', isEqualTo: id)
                              .limit(1)
                              .getDocuments()
                              .then((doc) {
                            if (doc.documents.length > 0)
                              Firestore.instance
                                  .collection('contacts')
                                  .document(doc.documents[0].documentID)
                                  .updateData({
                                'name': _nameController.text,
                                'phoneNumber': _phoneNumberController.text,
                              });
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

  void selectContact(BuildContext context, String id, bool selected) {
    Firestore.instance
        .collection('contacts')
        .where('contactID', isEqualTo: id)
        .limit(1)
        .getDocuments()
        .then((doc) {
      if (doc.documents.length > 0)
        Firestore.instance
            .collection('contacts')
            .document(doc.documents[0].documentID)
            .updateData({
          'selected': selected == false ? true : false,
        });
      else {
        print("error, no docs found");
      }
    });
  }

  void contactDetails(BuildContext context, String id, String name,
      String phoneNumber, DateTime date, bool selected) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                name,
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "ID: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoScrollText(
                            items: <Widget>[
                              Text(
                                id,
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Name: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(name),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Phone Number: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(phoneNumber),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Date added: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(date.toString()),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Selected: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(selected.toString()),
                        ],
                      ),
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
}
