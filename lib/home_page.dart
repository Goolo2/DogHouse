import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/data.dart';
import 'package:doghouse/settings/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:doghouse/timer/screen.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:doghouse/store/manydogs.dart';
import 'package:doghouse/gouwo.dart';
import 'package:doghouse/friends_page.dart';


class Property {
  static int coins;
  static List <int> dogsIdSet = List();
  static List <String> friends = List();
}


class TimeEntry{
  DateTime date;
  int time;
  String tag;
  int coins;
  TimeEntry(this.date, this.time, this.tag, this.coins);
  toJson(){
    return{
      "date": date,
      "time": time,
      "tag": tag,
      "coins": coins,
    };
  }
}

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  static List<TimeEntry> times = List();
  static String username;
  static String email = '';
  static String tagg = '';
  @override
  State<StatefulWidget> createState()  => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot result;
  FirebaseUser user;
  NumberPicker integerNumberPicker;
  // 控制器，控制TextField文字
  TextEditingController _name = TextEditingController();
  // 设置默认时长
  int _workSessionValue = 25;


  initUser() async {
    print('初始化user');
    user = await _auth.currentUser();
    result = await Firestore.instance.collection("times").document(user.email).get();
    DocumentSnapshot propertyResult = await Firestore.instance.collection("users").document(user.email).get();
    Property.coins = propertyResult.data["coins"];
    Property.dogsIdSet.clear();
    Property.friends.clear();
    print(propertyResult.data);
    for (dynamic id in propertyResult.data["dogsIdSet"]) {
      Property.dogsIdSet.add(id as int);
    }
    for (dynamic friend in propertyResult.data["friends"]) {
      Property.friends.add(friend as String);
    }
    setState(() {});
    HomePage.username = user.displayName;
    HomePage.email = user.email;
  }
  @override
  void initState() {
    super.initState();
    this._name.text = null; // 设置初始值
    initUser();
  }

  void update_datebase(int _time, String _tag, int coins, bool flag) async {
    if(flag==false){
      return;
    }
    else{
      print('获得金币数量: $coins');
      user = await _auth.currentUser();
      result = await Firestore.instance.collection("times").document(user.email).get();
      DateTime date = new DateTime.now();
      int time = _time;
      String tag = _tag;
      String len = result.data.length.toString()??0;
      TimeEntry t = TimeEntry(date, time, tag, coins);
      Firestore.instance.collection("times").document(user.email).updateData({
        "${len}": t.toJson(),
      });
      Property.coins = Property.coins + coins;
      FirebaseAuth.instance.currentUser()
          .then((currentUser) => Firestore.instance.collection("users")
          .document(currentUser.email).updateData({"coins": Property.coins}));
      await init_database();
    }
  }

  void init_database() async {
    user = await _auth.currentUser();
    result = await Firestore.instance.collection("times").document(user.email).get();
    HomePage.times.clear();
    for (String key in result.data.keys){
      HomePage.times.add(TimeEntry(result[key]["date"].toDate(), result[key]["time"], result[key]["tag"], result[key]["coins"],));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result != null ){
//      Database().init_database();
      init_database();
    }
    print("coins: ");print(Property.coins);
    print("dogsIdSet: ");print(Property.dogsIdSet);
    print("friends: ");print(Property.friends);
    Widget userHeader =  UserAccountsDrawerHeader(
      accountName: new Text(HomePage.username == null ?("$user?.displayName"):HomePage.username),
      accountEmail: new Text("${user?.email}"),
      currentAccountPicture: new CircleAvatar(
        backgroundImage: AssetImage('images/logo.png'), radius: 35.0,),);

    // 计时页面相关设置
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;

    Widget settask=Container(
      padding: const EdgeInsets.fromLTRB(320,20,0,20.0),
      child: IconButton(
                    icon:Icon(Icons.chat_bubble,size: 30,),
                    // shape:RoundedRectangleBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(35))),
                    color: Colors.white,
                    onPressed: () async {
                      //弹出对话框并等待其关闭，异步
                      bool delete = await _showmydialog();
                      if (delete == null) {
                        this._name.text=null;
                        this._name.clear();
                        print("取消");
                      } else {
                        print(this._name.text);
                        HomePage.tagg = this._name.text;
                        // 读取完清除值
                        this._name.clear();
                        print("确认");
                        //... 删除文件
                      }
                    },
                    // fillColor: Color.fromRGBO(242, 62, 60, 1),
                    // elevation: 0,
                  ),
    );
    Widget startbutton=Container(
      padding: const EdgeInsets.fromLTRB(135,20,135,20.0),
      child: new RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(TimerScreen.tag, arguments:_workSessionValue ).then((value) {
                        if (value!=null){
                          print("=========\n"+value.toString()+"\n==========");
                        }
                      });
                      // Navigator.of(context).pushNamed(TimerScreen.tag, arguments:_workSessionValue )
                    },
                    shape:RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(35))),
                    color: Colors.white,
                    // child: new Text("开始饲养"),
                    // highlightColor: Colors.lightBlue,
                    child: Container(
                      alignment:Alignment.center ,
                      height: 48,
                      width: MediaQuery.of(context).size.width * .2,
                      child: Text('开始饲养'),
                      ),
                  )
    );
    Widget showtime=Container(
      padding: const EdgeInsets.fromLTRB(120,10,120,10),
      child: RawMaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(35))),
                    onPressed: _showWorkSessionDialog,
                    // fillColor: (isDark)
                    //     ? Color.fromRGBO(92, 211, 62, 1)
                    //     : Color.fromRGBO(242, 62, 60, 1),
                    fillColor: Color.fromRGBO(50, 71, 85, 1),
                    elevation: 0,
                    child: Text(
                      "$_workSessionValue",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
    );
    Widget thedog=Container(
      padding: const EdgeInsets.fromLTRB(45,30,45,0),
      child: CircleAvatar(
        backgroundImage: AssetImage(
          'images/logo.png',
        ),
        // maxRadius: 200,
        radius: 150,
      )
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("DogHouse"),
      ),
      backgroundColor: Color.fromRGBO(50, 71, 85, 1),
      body: ListView(
        children: [
          settask,
          showtime,
          thedog,
          startbutton,
        ],
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
                Navigator.of(context).pushNamed(GouPage.tag);
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
                Navigator.of(context).pushNamed(FriendsPage.tag).then((value) => setState(() {
                }));
              },),
            ListTile(title: Text('商店'),
              leading: new CircleAvatar(
                child: new Icon(Icons.list),),
              onTap: () {
                Navigator.of(context).pushNamed(StorePage.tag).then((value) => setState(() {
                }));
              },),
            ListTile(title: Text('设置'),
              leading: new CircleAvatar(
                child: new Icon(Icons.settings),),
              onTap: () {
                Navigator.of(context).pushNamed(SettingsPage.tag).then((value) => setState(() {
                }));
              },),
          ],
        ),
      ),
    );
  }
   _handleWorkValueChangedExternally(num value) {
    if (value != null) {
      setState(() {
        _workSessionValue = value;
      });
      // 下面这个好像是用来设置动画的，不注释掉会报错，但是依然能运行
      // integerNumberPicker.animateInt(value);
    }
  }
  _showWorkSessionDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 60,
          initialIntegerValue: _workSessionValue,
          title: Text("选择时长(s)"),
        );
      },
    ).then(_handleWorkValueChangedExternally);
  }
  Future<bool> _showmydialog(){
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('事项名称'),
          content: Card(
            elevation: 0.0,
            child: Column(
              children: <Widget>[
                // Text('this is a message'),
                TextField(
                  decoration: InputDecoration(
                      hintText: '请输入事项',
                      filled: true,
                      fillColor: Colors.grey.shade50),
                  controller: this._name,
                  onSubmitted: (value) {
                    this.setState(() {
                      this._name.text = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('确定'),
            ),
          ],
        );
      });
  }

  // 弹出式对话框
  // Future<bool> showDeleteConfirmDialog1() {
  // return showDialog<bool>(
  //   context: context,
  //   builder: (context) {
  //     return AlertDialog(
  //       title: Text("提示"),
  //       content: Text("您确定要删除当前文件吗?"),
  //       actions: <Widget>[
  //         FlatButton(
  //           child: Text("取消"),
  //           onPressed: () => Navigator.of(context).pop(), // 关闭对话框
  //         ),
  //         FlatButton(
  //           child: Text("删除"),
  //           onPressed: () {
  //             //关闭对话框并返回true
  //             Navigator.of(context).pop(true);
  //           },
  //         ),
  //       ],
  //     );
  //   },
  // );
// }
}