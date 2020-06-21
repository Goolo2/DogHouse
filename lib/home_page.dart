import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/data.dart';
import 'package:doghouse/settings/setting_page.dart';
import 'package:doghouse/timer.dart';
import 'package:doghouse/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:doghouse/timer/screen.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:doghouse/timer/neumorphic_bar.dart';

class TimeEntry{
  DateTime date;
  int time;
  String tag;
  TimeEntry(this.date, this.time, this.tag);
  toJson(){
    return{
      "date": date,
      "time": time,
      "tag": tag
    };
  }
}

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  static List<TimeEntry> times = List();
  static String username = '';
  static String email = '';
  @override
  State<StatefulWidget> createState()  => HomePageState();
}

//class Database{
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//  DocumentSnapshot result;
//  FirebaseUser user;
//
//  void update_datebase(int _time, String _tag) async {
//    user = await _auth.currentUser();
//    result = await Firestore.instance.collection("times").document(user.uid).get() as DocumentSnapshot;
//    DateTime date = new DateTime.now();
//    int time = _time;
//    String tag = _tag;
//    String len = result.data.length.toString()??0;
//    TimeEntry t = TimeEntry(date, time, tag);
//    Firestore.instance.collection("times").document(user.uid).updateData({
//      "${len}": t.toJson(),
//    });
//    init_database();
//  }
//
//  void init_database() async {
//    user = await _auth.currentUser();
//    result = await Firestore.instance.collection("times").document(user.uid).get() as DocumentSnapshot;
//    HomePage.times.clear();
//    for (String key in result.data.keys){
//      HomePage.times.add(TimeEntry(result[key]["date"].toDate(), result[key]["time"], result[key]["tag"]));
//    }
//  }
//}

class HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot result;
  FirebaseUser user;
  void fresh() {
    setState(() {

    });
  }
  initUser() async {
    user = await _auth.currentUser();
    result = await Firestore.instance.collection("times").document(user.uid).get() as DocumentSnapshot;
    setState(() {});
    HomePage.username = user.displayName;
    HomePage.email = user.email;
  }
  @override
  void initState() {
    super.initState();
    initUser();
  }

  void update_datebase(int _time, String _tag, bool flag) async {
    if(flag==false){
      return;
    }
    else{
      user = await _auth.currentUser();
      result = await Firestore.instance.collection("times").document(user.uid).get() as DocumentSnapshot;
      DateTime date = new DateTime.now();
      int time = _time;
      String tag = _tag;
      String len = result.data.length.toString()??0;
      TimeEntry t = TimeEntry(date, time, tag);
      Firestore.instance.collection("times").document(user.uid).updateData({
        "${len}": t.toJson(),
      });
      await init_database();
    }
  }

  void init_database() async {
    user = await _auth.currentUser();
    result = await Firestore.instance.collection("times").document(user.uid).get() as DocumentSnapshot;
    HomePage.times.clear();
    for (String key in result.data.keys){
      HomePage.times.add(TimeEntry(result[key]["date"].toDate(), result[key]["time"], result[key]["tag"]));
    }
  }

  NumberPicker integerNumberPicker;
  // 设置时间
  int _workSessionValue = 25;


  @override
  Widget build(BuildContext context) {
    if (result != null ){
//      Database().init_database();
      init_database();
    }
//    update_datebase(10, 'study');
    Widget userHeader =  UserAccountsDrawerHeader(
      accountName: new Text("${user?.displayName}"),
      accountEmail: new Text("${user?.email}"),
      currentAccountPicture: new CircleAvatar(
        backgroundImage: AssetImage('images/logo.png'), radius: 35.0,),);

    // 计时页面相关设置
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;


    return  Scaffold(appBar: AppBar(title: Text("Home"),),
      body:
        new Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                    width: 60,
                    height: 10,
                    child:new RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(TimerScreen.tag, arguments:_workSessionValue );
                      // Navigator.of(context).pushNamed('Neumor', arguments: {width: 50,height: 100,value: 0.5,text: 'Mon',});
                    },
                    shape:RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(35))),
                    color: Colors.red,
                    // child: new Text("开始饲养"),
                    // highlightColor: Colors.lightBlue,
                    child: Container(
                      alignment:Alignment.center ,
                      height: 48,
                      width: MediaQuery.of(context).size.width * .2,
                      child: Text('开始饲养'),
                      ),
                  ),
                ),
                flex:1, 
              ),
              Expanded(
                child: Container(
                  width: 30,
                  height: 30,
                  child: RawMaterialButton(
                    shape: new CircleBorder(),
                    onPressed: _showWorkSessionDialog,
                    fillColor: (isDark)
                        ? Color.fromRGBO(92, 211, 62, 1)
                        : Color.fromRGBO(242, 62, 60, 1),
                    elevation: 0,
                    child: Text(
                      "$_workSessionValue",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                flex: 1,
              ),
            ],
          )
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
              leading: new CircleAvatar(child: new Icon(Icons.sd_storage),),
              onTap: () {
                Navigator.pop(context);
              },),
            ListTile(title: Text('数据统计'),
              leading: new CircleAvatar(
                child: new Icon(Icons.data_usage),),
              onTap: () {
                // Navigator.pop(context);
                Navigator.of(context).pushNamed(DataPage.tag);
              },),
            ListTile(title: Text('好友'),
              leading: new CircleAvatar(
                child: new Icon(Icons.people),),
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
                child: new Icon(Icons.settings),),
              onTap: () {
                Navigator.of(context).pushNamed(SettingsPage.tag);
                setState(() {
                  initState(); build(context);
                });
              },),
          ],
        ),
      ),);
  }
    _handleWorkValueChangedExternally(num value) {
    if (value != null) {
      setState(() {
        _workSessionValue = value;
      });
      integerNumberPicker.animateInt(value);
    }
  }
  _showWorkSessionDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 50,
          initialIntegerValue: _workSessionValue,
          title: Text("Select a minute"),
        );
      },
    ).then(_handleWorkValueChangedExternally);
  }
}