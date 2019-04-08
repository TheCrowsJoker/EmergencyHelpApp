import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Help App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

class _Menu extends StatelessWidget {
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
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text('Contacts'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map / List'),
                  onTap: () {},
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
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About'),
                        onTap: () {},
                      )
                    ],
                  ))))
        ],
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Help App"),
      ),
      drawer: _Menu(),
      body: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
//              Theme.of(context).backgroundColor,
              Colors.purple[300],
              Theme.of(context).primaryColorLight
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 50.0,
                      horizontal: 20.0
                  ),
                  child: Center(
                    child: Text(
                      "Send location by clicking help",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: OutlineButton(
                shape: CircleBorder(),
                color: Theme.of(context).backgroundColor,
                onPressed: () {},
                child: Center(
                  child: Text(
                    "Help",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ButtonTheme(
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  height: 50.0,
                  child: OutlineButton(
                    color: Theme.of(context).backgroundColor,
                    child: Text(
                      "More Help...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
