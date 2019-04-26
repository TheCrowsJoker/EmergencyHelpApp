import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'menu.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About (FAQs)"),
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
            stream: Firestore.instance.collection('faqs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot docSnap = snapshot.data.documents[index];
                      return Card(
                        color: Colors.purple[100],
                        elevation: 5.0,
                        margin: new EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: ExpansionTile(
                          title: Text(
                            docSnap['question'],
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                docSnap['answer'],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}