import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Help App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Emergency Help App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(

            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Contacts'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map / List'),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
            ),
            Divider(),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings')
            ),
            ListTile(
                leading: Icon(Icons.info),
                title: Text('About')
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Help"),
              onPressed: () {

              },
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child:
              FlatButton(
                child: Text("Test"),
                onPressed: () {

                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
