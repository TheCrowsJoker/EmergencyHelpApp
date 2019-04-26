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
                  // todo: Change this to the app logo when its been created
                  child: Text("App logo will be here eventually\n"
                      "For now, enjoy this poem extract by E.A. Poe:\n\n"
                      "Years of love have been forgot,\n"
                      "in the hatred of a minute"),
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
                  title: Text('Chat'),
                  onTap: () {},
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
                            onTap: () {},
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
      Navigator.pushNamed(context, page);
    } else {
      Navigator.of(context).pop();
    }
  }
}
