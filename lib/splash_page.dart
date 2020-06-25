import 'package:doghouse/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doghouse/home_page.dart';

class SplashPage extends StatefulWidget {
  static String tag = "splash-page";
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  initState() {
    FirebaseAuth.instance
        .currentUser()
        .then((currentUser) => {
      if (currentUser == null)
        {Navigator.of(context).pushNamed(LoginPage.tag)}
      else
        {
          Firestore.instance
              .collection("users")
              .document(currentUser.email)
              .get()
              .then((DocumentSnapshot result) =>
              Navigator.of(context).pushNamed(HomePage.tag)
              .catchError((err) => print(err)))
          }
    })
        .catchError((err) => print(err));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}