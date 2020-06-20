import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/data.dart';
import 'package:doghouse/timer.dart';
import 'package:doghouse/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimeEntry{
  DateTime date;
  int time;
  String tag;
  TimeEntry(this.date, this.time, this.tag);
}


class HomePage extends StatefulWidget {

  static String tag = 'home-page';
  static List<TimeEntry> times = List();
  @override
  State<StatefulWidget> createState()  => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot result;
  FirebaseUser user;
  initUser() async {
    user = await _auth.currentUser();
    result = await Firestore.instance.collection("users").document(user.uid).get() as DocumentSnapshot;
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  Widget build(BuildContext context) {
//
    if (result != null){
      for (String key in result["time"].keys){
        HomePage.times.add(TimeEntry(result["time"][key]["date"].toDate(), result["time"][key]["time"], result["time"][key]["tag"]));
      }
    }

    Widget userHeader =  UserAccountsDrawerHeader(
      accountName: new Text("${user?.displayName}"),
      accountEmail: new Text("${user?.email}"),
      currentAccountPicture: new CircleAvatar(
        backgroundImage: AssetImage('images/logo.png'), radius: 35.0,),);

    return  Scaffold(appBar: AppBar(title: Text("Home"),),
      body:
        new Center(
          child: new RaisedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(TimerPage.tag);
            },
            child: new Text("点我跳转"),
            color: Colors.blue,
            highlightColor: Colors.lightBlue,
          ),
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            userHeader, // 可在这里替换自定义的header
            ListTile(title: Text('自习室'),
              leading: new CircleAvatar(child: new Icon(Icons.school),),
              onTap: () {
                Navigator.pop(context);
              },),
            ListTile(title: Text('我的狗窝'),
              leading: new CircleAvatar(child: new Text('B2'),),
              onTap: () {
                Navigator.pop(context);
              },),
            ListTile(title: Text('数据统计'),
              leading: new CircleAvatar(
                child: new Icon(Icons.list),),
              onTap: () {
                // Navigator.pop(context);
                Navigator.of(context).pushNamed(DataPage.tag);
              },),
            ListTile(title: Text('好友'),
              leading: new CircleAvatar(
                child: new Icon(Icons.list),),
              onTap: () {
                Navigator.pop(context);
              },),
            ListTile(title: Text('商店'),
              leading: new CircleAvatar(
                child: new Icon(Icons.list),),
              onTap: () {
                Navigator.pop(context);
              },),
            ListTile(title: Text('设置'),
              leading: new CircleAvatar(
                child: new Icon(Icons.list),),
              onTap: () {
                Navigator.pop(context);
              },),
          ],
        ),
      ),);
  }
}