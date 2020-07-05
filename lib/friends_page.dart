import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:doghouse/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendsPage extends StatefulWidget {
  static String tag = "friends-page";

  FriendsPage({Key key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();

}

class _FriendsPageState extends State<FriendsPage> {
  List data = [];
  var isLoading = false;
  TextEditingController _friend = TextEditingController();

  //Function to parse JSON
  Future getJson() async {
    setState(() {
      isLoading = true;
    });
    data.clear();
    for (String friend in Property.friends) {
      print("朋友: $friend");
      DocumentSnapshot frinedTimes = await Firestore.instance.collection(
          "times").document(friend).get();
      DocumentSnapshot friendProperty = await Firestore.instance.collection(
          "users").document(friend).get();
      String friendName = friendProperty.data["username"];
      int friendCoins = friendProperty.data["coins"];
//      List friendDogsIdSet = [];
//      for (dynamic id in friendProperty.data["dogsIdSet"]) {
//        friendDogsIdSet.add(id as int);
//      }
//      int friendUnlockedDogsNumber = friendDogsIdSet.length;
      int friendUnlockedDogsNumber = friendProperty.data["dogsIdSet"].length;
      int friendTotalRaiseTimes = 0;
      int friendRaiseNumbers = 0;
      for (String key in frinedTimes.data.keys) {
        friendTotalRaiseTimes =
            friendTotalRaiseTimes + frinedTimes[key]["time"];
        friendRaiseNumbers = friendRaiseNumbers + 1;
      }
      data.add({
        "email": friend,
        "username": friendName,
        "totalTime": friendTotalRaiseTimes,
        "totalNumbers": friendRaiseNumbers,
        "coins": friendCoins,
        "dogs": friendUnlockedDogsNumber,
      });
    }
    data.sort((a, b) => b["totalTime"].compareTo(a["totalTime"]));
    //data.sort((a, b) => a.totalTime.compareTo(b.totalTime));
    print(data);

    setState(() {
      isLoading = false;
    });

  }

  @override
  void dispose() {
    // 移除焦点监听
    _friend.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(50, 71, 85, 1),
        title: Text(
         "好友",
          // style: TextStyle(
          //   color: Colors.lightBlue,
          // ),
        ),
        // centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon:Icon(
                Icons.person_add,
                color: Color.fromRGBO(217, 125, 84, 1),
              ),
              onPressed: () async {
                bool add = await _addFriendDialog();
                if (add == null) {
                  this._friend.text=null;
                  this._friend.clear();
                  print("取消");
                } else {
                  if (validateAccountNumber(_friend.text) == "请输入正确的邮箱") {
                    this._friend.clear();
                    friendDoesNotExistAlert("邮箱账号不合法，请重新输入！");
                  } else if (validateAccountNumber(_friend.text) == "账号不能为空") {
                    this._friend.clear();
                    friendDoesNotExistAlert("邮箱账号不能为空，请重新输入！");
                  } else {
                    DocumentSnapshot friendProperty = await Firestore.instance
                        .collection("users").document(this._friend.text).get();
                    if (friendProperty.data == null) {
                      this._friend.clear();
                      friendDoesNotExistAlert("该账号尚未注册，请重新输入！");
                    } else {
                      print(this._friend.text);
                      Property.friends.add(this._friend.text);
                      List friendFriends = [];
                      friendFriends = friendProperty.data["friends"];
                      print(friendFriends);
                      friendFriends.add(HomePage.email);print(friendFriends);
                      Firestore.instance.collection("users")
                          .document(HomePage.email).updateData(
                          {"friends": Property.friends});
                      Firestore.instance.collection("users")
                          .document(_friend.text).updateData(
                          {"friends": friendFriends});
                      // 读取完清除值
                      this._friend.clear();
                      setState(() {

                      });
                      //Navigator.of(context).pushNamed(FriendsPage.tag);
                      //Navigator.of(context).pop();
                      setState(() {
                        getJson();
                      });
                      print("确认");
                    }
                  }
                }
              }
          )

        ],
      ),

      //Body
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
        ),
      )
          :Center(
        child: ListView.builder(
          itemCount: data == null ? 1 : data.length * 2 + 1,
          padding: EdgeInsets.all(24.0),
          itemBuilder: (BuildContext context, int position) {
            print("位置 $position");
            if (position==0) {
              return Text(
                "排行榜: ",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  // color: Colors.indigo,
                ),
              );
            } else if (position.isOdd) {
              return Divider(height: 15, thickness: 3,);
            } else {
              final index = (position/2).round() -1;
              final rank = index + 1;
              String username = data[index]['username'];
              String email = data[index]['email'];
              int totalTimes = data[index]["totalTime"];
              int totalNumber = data[index]["totalNumbers"];
              // print("总时：$totalTimes\n$totalNumber");
              double averageTime = (totalTimes/totalNumber).toDouble();
              int coins = data[index]["coins"];
              int dogs = data[index]["dogs"];
              String message = "Email: $email \n总饲养次数: $totalNumber\n总饲养时长: $totalTimes\n平均饲养时长: $averageTime\n总金币数: $coins\n解锁小狗数量: $dogs";
              return ListTile(
                title: Text("$username"),
                subtitle: Text("$email\n总时长： $totalTimes"),
                leading: CircleAvatar(
                  backgroundColor: Color.fromRGBO(217, 125, 84, 1),
                  child: Text(
                    "$rank",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900
                    ),
                  ),
                ),
                onTap: () {
                  _showFriendConcreteMessage(context, username, message);
                },
              );
            }
          },
        ),
      ),

    );
  }

  //Function to Show Alert Dialog for showing messages
  void _showFriendConcreteMessage(BuildContext context, String title, String message){
    var alert = new AlertDialog(
      title: Text("$title"),
      content: Text("$message"),
      actions: <Widget>[
        FlatButton(
          onPressed: (){Navigator.pop(context);},
          child: Text("OK"),
        )
      ],
    );

    showDialog(context: context, builder: (context)=> alert);
  }

  void friendDoesNotExistAlert(String error) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('提示'),
            //可滑动
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(error),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ],
          );
        });
  }

  //Function to Show Alert Dialog for showing app details
  Future<bool> _addFriendDialog(){
    return showCupertinoDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('添加好友'),
            content: Card(
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  // Text('this is a message'),
                  new TextFormField(
                    controller: _friend,
                    //设置键盘类型
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "账号",
                      hintText: "请输入好友邮箱",
                      prefixIcon: Icon(Icons.person),
                    ),
                    //保存数据
                    onSaved: (String value){
                      this.setState(() {
                        this._friend.text = value;
                        _friend.clear();
                      });
                    },
                  )
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

  String validateAccountNumber(value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return '请输入正确的邮箱';
    }
    else if (value.isEmpty){
      return '账号不能为空';
    }
    else {
      return null;
    }
  }
}