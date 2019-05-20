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
              StreamBuilder(
                  stream:
                      Firestore.instance.collection('resources').snapshots(),
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
                                      docSnap['desc'] != null
                                          ? Text(
                                        docSnap['desc'],
                                        textAlign: TextAlign.center,
                                      )
                                          : IgnorePointer(),
                                      docSnap['locationString'] != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                "Location:",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : IgnorePointer(),
                                      docSnap['locationString'] != null
                                          ? Text(
                                              docSnap['locationString'],
                                              textAlign: TextAlign.center,
                                            )
                                          : IgnorePointer(),
                                      !(docSnap['phone1'] == null &&
                                              docSnap['phone2'] == null &&
                                              docSnap['phone3'] == null)
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                "Phone Numbers:",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : IgnorePointer(),
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
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
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
                                      docSnap['website'] != null
                                          ? Text(
                                              docSnap['website'],
                                              textAlign: TextAlign.center,
                                            )
                                          : IgnorePointer(),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Long press for options",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  onLongPress: () {
                                    GeoPoint geopoint = docSnap['location'];
                                    moreOptions(
                                        context,
                                        docSnap['id'],
                                        docSnap['phone1'],
                                        docSnap['phone2'],
                                        docSnap['email'],
                                        docSnap['website'],
                                        geopoint);
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
                  }),
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

  void moreOptions(BuildContext context, String id, String phone1,
      String phone2, String email, String website, GeoPoint geopoint) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                "More Options...",
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                geopoint != null
                    ? FlatButton(
                        child: Text("Show on map"),
                        onPressed: () {
                          String url = "https://maps.google.com/maps/?q=" +
                              geopoint.latitude.toString() +
                              "," +
                              geopoint.longitude.toString();
                          launch(url);
                        },
                      )
                    : IgnorePointer(),
                phone2 != null
                    ? FlatButton(
                        child: Text("Call phone 1"),
                        onPressed: () {
                          launch("tel:" + phone1);
                        },
                      )
                    : IgnorePointer(),
                phone2 != null
                    ? FlatButton(
                        child: Text("Call phone 2"),
                        onPressed: () {
                          launch("tel:" + phone2);
                        },
                      )
                    : IgnorePointer(),
                email != null
                    ? FlatButton(
                        child: Text("Email"),
                        onPressed: () {
                          launch("mailto:" + email);
                        },
                      )
                    : IgnorePointer(),
                website != null
                    ? FlatButton(
                        child: Text("Open website"),
                        onPressed: () {
                          launch(website);
                        },
                      )
                    : IgnorePointer(),
              ]);
        });
  }
}
