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
                              DocumentSnapshot _docSnap =
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
                                        _docSnap['name'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      _docSnap['desc'] != null
                                          ? Text(
                                              _docSnap['desc'],
                                              textAlign: TextAlign.center,
                                            )
                                          : IgnorePointer(),
                                      _docSnap['locationString'] != null
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
                                      _docSnap['locationString'] != null
                                          ? Text(
                                              _docSnap['locationString'],
                                              textAlign: TextAlign.center,
                                            )
                                          : IgnorePointer(),
                                      !(_docSnap['phone1'] == null &&
                                              _docSnap['phone2'] == null &&
                                              _docSnap['phone3'] == null)
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
                                      _docSnap['phone1'] != null
                                          ? Text(
                                              _docSnap['phone1'],
                                            )
                                          : IgnorePointer(),
                                      _docSnap['phone2'] != null
                                          ? Text(
                                              _docSnap['phone2'],
                                            )
                                          : IgnorePointer(),
                                      _docSnap['phone3'] != null
                                          ? Text(
                                              _docSnap['phone3'],
                                            )
                                          : IgnorePointer(),
                                      _docSnap['fax'] != null
                                          ? Text(
                                              "Fax: " + _docSnap['fax'],
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
                                      _docSnap['email'] != null
                                          ? Text(
                                              _docSnap['email'],
                                              textAlign: TextAlign.center,
                                            )
                                          : IgnorePointer(),
                                      _docSnap['website'] != null
                                          ? FlatButton(
                                              child: Text(
                                                "Open website",
                                                textAlign: TextAlign.center,
                                              ),
                                              onPressed: () {
                                                launch(_docSnap['website']);
                                              },
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
                                    GeoPoint _geopoint = _docSnap['location'];
                                    _moreOptions(
                                        context,
                                        _docSnap['id'],
                                        _docSnap['phone1'],
                                        _docSnap['phone2'],
                                        _docSnap['email'],
                                        _docSnap['website'],
                                        _geopoint);
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

  void _moreOptions(BuildContext context, String id, String phone1,
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
                          String _url = "https://maps.google.com/maps/?q=" +
                              geopoint.latitude.toString() +
                              "," +
                              geopoint.longitude.toString();
                          launch(_url);
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
