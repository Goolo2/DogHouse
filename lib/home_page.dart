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
import 'package:doghouse/store/dogmodel.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  int currentDogId;
  TimeEntry(this.date, this.time, this.tag, this.coins, this.currentDogId);
  toJson(){
    return{
      "date": date,
      "time": time,
      "tag": tag,
      "coins": coins,
      "id": currentDogId,
    };
  }
}

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  static List<TimeEntry> times = List();
  static String username;
  static String email = '';
  static List<Product> products = [
    Product(
        id: 1,
        title: "dog1",
        price: 0,
        imgUrl: "images/store/dog1.png",
        qty: 1),
  ];
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
  String dogurl;
  // 设置默认时长
  int _workSessionValue = 25;
  // 保存所有购买的狗

  Future<String> loadAsset() async {
    var a = await rootBundle.loadString('images/store/dogs.txt');
    return a;
  }

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
    //初始化store dogs
    int index = 2;
    int price = 800;
    if (HomePage.products.length == 1) {
      loadAsset().then((value) {
        for (String dogName in value.toString().split('\n')) {
          HomePage.products.add(Product(
              id: index,
              title: "dog" + index.toString(),
              price: price,
              imgUrl: dogName.trimRight(),
              qty: 1
          ));
          index = index + 1;
          price = price + 200;
        }
      });
    }
    setState(() {});
    HomePage.username = user.displayName;
    HomePage.email = user.email;
  }

  @override
  void initState() {
    super.initState();
    this._name.text = null; // 设置初始值
    //默认狗
    this.dogurl = HomePage.products[0].imgUrl;
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
      TimeEntry t = TimeEntry(date, time, tag, coins, ChooseDog.selectDog);
      Firestore.instance.collection("times").document(user.email).updateData({
        "${len}": t.toJson(),
      });
      Property.coins = Property.coins + coins;
//      print("添加后："); print(Property.coins);
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
      HomePage.times.add(TimeEntry(result[key]["date"].toDate(), result[key]["time"], result[key]["tag"], result[key]["coins"], result[key]["id"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result != null ){
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

    Widget coin=Container(
      child: new Row(
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Image.asset('images/coin.png'),
                Text("${Property.coins}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),),
              ],
            ),
            IconButton(
              icon:Icon(Icons.chat_bubble,size: 30,),
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
            ),
          ]
      ),
    );

    Widget startbutton=Container(
      padding: const EdgeInsets.fromLTRB(135,80,135,20.0),
      child: new RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(TimerScreen.tag, arguments:_workSessionValue ).then((value) {
//                          print("当前coins:"); print(Property.coins);
                          setState(() {});
                      });
//                      Navigator.of(context).pushNamed(TimerScreen.tag, arguments:_workSessionValue ).then((value) => setState(() {}));

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
      padding: const EdgeInsets.fromLTRB(120,50,120,30),
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
      padding: const EdgeInsets.fromLTRB(0,30,0,0),
      width:300,
      height: 300,
      child:MaterialButton(
        // onPressed: () {},
        onPressed: () async{
          bool confirm=await _dialogCall(context);
          if(confirm==null){
            print("nothing");
          }
          else{
            print(ChooseDog.selectDog);
            setState(() {
              this.dogurl=HomePage.products[ChooseDog.selectDog-1].imgUrl;
            });
          }
          },
        ),
      decoration: BoxDecoration(
    	shape: BoxShape.circle, //可以设置角度，BoxShape.circle直接圆形
        // borderRadius: BorderRadius.circular(5.0),
        image: DecorationImage(
        	fit: BoxFit.fill,
             image: AssetImage(
             	this.dogurl,
             ),
   		 )
    ),
    );
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          // IconButton(
          //   icon: Image.asset('images/coin.png'),
          //   iconSize: 20,
          //   tooltip: "yes",
          //   onPressed: () {}
          // ),
          Row(
            children: <Widget>[
              FlatButton(
              child: 
                Row(
                  children: <Widget>[
                    Container(
                      height:35,
                      width:35,
                      decoration: new BoxDecoration(
                        image:new DecorationImage(
                          image: AssetImage('images/coin.png'),
                          ),
                      ),
                    ),
                    Text("${Property.coins}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),),
                  ],
                ),
              onPressed: (){},
            ),
              
            SizedBox(width: 80,),
              
            IconButton(
                icon:Icon(Icons.chat_bubble,size: 30,),
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
              ),
          ],)
          
        ],
        // title: new Text("DogHouse"),
      ),
      backgroundColor: Color.fromRGBO(50, 71, 85, 1),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child:Column(
              mainAxisAlignment:MainAxisAlignment.center ,
              children: <Widget>[
                // coin,
                showtime,
                thedog,
                startbutton,
              ],
            ),
            )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            userHeader, // 可在这里替换自定义的header
//            ListTile(title: Text('自习室'),
//              leading: new CircleAvatar(child: new Icon(Icons.school),),
//              onTap: () {
//                Navigator.pop(context);
//              },),
            ListTile(title: Text('我的狗窝'),
              leading: new CircleAvatar(child: new Icon(Icons.sd_storage),),
              onTap: () {
                Navigator.of(context).pushNamed(GouPage.tag).then((value) => setState(() {
                }));
              },),
            ListTile(title: Text('数据统计'),
              leading: new CircleAvatar(
                child: new Icon(Icons.data_usage),),
              onTap: () {
                // Navigator.pop(context);
                Navigator.of(context).pushNamed(DataPage.tag).then((value) => setState(() {
                }));
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
  // 弹出选狗界面
  Future<bool> _dialogCall(BuildContext context){
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context){
        return ChooseDog();
        // 用下面的压栈会报错
        // Navigator.of(context).pushNamed(ChooseDog.tag).then((value){
        //   print(value);
        // });
      }
      );
  }
}

class ChooseDog extends StatefulWidget{
  static String tag = 'Choose-Dog';
  static int selectDog = 1;

_ChooseDogState createState() => new _ChooseDogState();

}

class _ChooseDogState extends State<ChooseDog>{
  List<Widget> doglist = List();
  // num selectdog=0;

  void initState() {
    super.initState();
    if (HomePage.times != null){
      loadDogs();
    }
  }

  void loadDogs() async{
    for (num id in Property.dogsIdSet){
        Widget c=Container(
                  height:120,
                  width: 100,
                  child: ConstrainedBox(
                      constraints: BoxConstraints.expand(),
                      child: FlatButton(
                              onPressed: (){
                                ChooseDog.selectDog = id;
                              },
                              padding: EdgeInsets.all(0.0),
                               child: Image.asset(HomePage.products[id-1].imgUrl)
//                              child:Image.network(_mydogs[id-1].imgUrl),
                              )
                            )
                          );
      doglist.add(c);
    }
  }
  Widget build(BuildContext context){
    return AlertDialog(
        title: Text("选只狗吧"),
        content: new Container(
            height: 200,
            width: 100,
            child: GridView.builder(
            itemCount: doglist.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.8),
            itemBuilder: (context, index){
            return Card( 
              child: 
              Column( 
                children: <Widget>[
                  doglist[index]
                  // Image.network(_mydogs[index].imgUrl),
                  // Image.network(_mydogs[index].imgUrl, height: 120, width: 120,),
                ]
              )
            );
            }
          ),
        ),
        // ),
        actions: [
          FlatButton(
            child: Text("取消"),
            onPressed: () => Navigator.of(context).pop(), // 关闭对话框
          ),
          FlatButton(
            child: Text("确定"),
            onPressed: () {
              //关闭对话框并返回true
              Navigator.of(context).pop(true);
              // 返回狗的id
              // Navigator.of(context).pop(selectdog);
            },
          ),
        ],
      );
    }
}