import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class Contacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      drawer: Menu(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.purple[400], Colors.purple[100]],
          ),
        ),
        child: StreamBuilder(
          stream: Firestore.instance.collection('contacts').snapshots(),
          builder: (context, snapshot) {
            return snapshot.hasData ?
              ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];
                return Card(
                  color: Colors.purple[100],
                  elevation: 5.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(ds['name']),
                    trailing: Icon(Icons.check_box_outline_blank),
                  ),
                );
              }
            ) : CircularProgressIndicator();
          }
        ),
      ),
    );
  }
}