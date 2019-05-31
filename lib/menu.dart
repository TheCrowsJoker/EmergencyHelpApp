import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Menu extends StatelessWidget {
  bool _isNewRouteSameAsCurrent = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                          ),
                        ),
                      ),
                    ),
                  )
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('I Need Help'),
                  onTap: () {
                    _openPage(context, '/');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text('My Contacts List'),
                  onTap: () {
                    _openPage(context, '/contacts');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Help Centers'),
                  onTap: () {
                    _openPage(context, '/resources');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Chatroom'),
                  onTap: () {
                    _openPage(context, '/chatroom');
                  },
                ),
              ],
            ),
          ),
          Container(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Profile'),
                        onTap: () {
                          _openPage(context, '/profile');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('FAQ'),
                        onTap: () {
                          _openPage(context, '/about');
                        },
                      )
                    ],
                  ))))
        ],
      ),
    );
  }

  void _openPage(BuildContext context, String page) {
    Navigator.popUntil(context, (route) {
      if (route.settings.name == page) {
        _isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!_isNewRouteSameAsCurrent) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, page);
    } else {
      Navigator.of(context).pop();
    }
  }
}
