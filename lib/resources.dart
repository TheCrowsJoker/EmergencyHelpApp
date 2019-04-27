import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Resources extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Resources"),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.map,
                      ),
                    ),
                    Text("Map"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.list,
                      ),
                    ),
                    Text("List"),
                  ],
                ),
              ),
            ],
          ),
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
              TabBarView(
                children: [
                  map(context),
                  list(context),
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

  Widget map(BuildContext context) {
    return Icon(Icons.map);
  }

  Widget list(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('resources').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length > 0) {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot docSnap = snapshot.data.documents[index];
                    return Card(
                      color: Colors.purple[100],
                      elevation: 5.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: ListTile(
                        title: Column(
                          children: <Widget>[
                            Text(
                              docSnap['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            docSnap['locationString'] != null ? Text(
                              docSnap['locationString'],
                              textAlign: TextAlign.center,
                            ) : IgnorePointer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Phone Numbers:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            docSnap['phone1'] != null
                                ? Text(
                                    docSnap['phone1'],
                                  )
                                : IgnorePointer(),
                            docSnap['phone2'] != null
                                ? Text(
                                    docSnap['phone2'],
                                  )
                                : IgnorePointer(),
                            docSnap['phone3'] != null
                                ? Text(
                              docSnap['phone3'],
                            )
                                : IgnorePointer(),
                            docSnap['fax'] != null
                                ? Text(
                                    "Fax: " + docSnap['fax'],
                                  )
                                : IgnorePointer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Online:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            docSnap['email'] != null
                                ? Text(
                                    docSnap['email'],
                                    textAlign: TextAlign.center,
                                  )
                                : IgnorePointer(),
                            docSnap['website'] != null ? Text(
                              docSnap['website'],
                              textAlign: TextAlign.center,
                            ): IgnorePointer(),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Tap to email, long press to call",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          docSnap['email'] != null
                              ? launch("mailto:" + docSnap['email'])
                              : null;
                        },
                        onLongPress: () {
                          docSnap['phone1'] != null
                              ? launch("tel:" + docSnap['phone1'])
                              : null;
                        },
                      ),
                    );
                  });
            } else {
              return Center(
                  child: Text(
                "No resources found",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ));
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
