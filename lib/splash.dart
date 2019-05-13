import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.purple[400], Colors.purple[100]],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage("assets/logo.png"),
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: RaisedButton(
              child: Text("Create Account"),
              onPressed: () {
                Navigator.pushNamed(context, '/createAccount');
              },
            ),
          ),
          FlatButton(
            child: Text("Already Have an Account"),
            onPressed: () {},
          )
        ],
      ),
    );
  }

}
