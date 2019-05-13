import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Menu extends StatelessWidget {
  bool isNewRouteSameAsCurrent = false;

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
                  title: Text('Home'),
                  onTap: () {
                    openPage(context, '/');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text('Contacts'),
                  onTap: () {
                    openPage(context, '/contacts');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map / List'),
                  onTap: () {
                    openPage(context, '/resources');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Chatroom'),
                  onTap: () {
                    openPage(context, '/chatroom');
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
                          openPage(context, '/profile');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About'),
                        onTap: () {
                          openPage(context, '/about');
                        },
                      )
                    ],
                  ))))
        ],
      ),
    );
  }

  void openPage(BuildContext context, String page) {
    Navigator.popUntil(context, (route) {
      if (route.settings.name == page) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, page);
    } else {
      Navigator.of(context).pop();
    }
  }
}
