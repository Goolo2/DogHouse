import 'package:doghouse/home_page.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/settings/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeUsernamePage extends StatefulWidget {
  static String tag = 'changeUsername-page';
  @override
  _ChangeUsernamePageState createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {

  //焦点
  FocusNode _focusNodeNewUsername = new FocusNode();

  //用户名输入框控制器，此控制器可以监听用户名输入框操作
  TextEditingController _newUsernameController = new TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _newUsername = ''; //账号
  var _isShowClear = false;

  @override
  void initState() {
    //设置焦点监听
    _focusNodeNewUsername.addListener(_focusNodeListener);
    _newUsernameController.addListener((){
      print(_newUsernameController.text);

      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_newUsernameController.text.length > 0) {
        _isShowClear = true;
      }else{
        _isShowClear = false;
      }
      setState(() {

      });
    });
      super.initState();
  }

@override
void dispose() {
  // TODO: implement dispose
  // 移除焦点监听
  _focusNodeNewUsername.removeListener(_focusNodeListener);

  super.dispose();
}

  Future<Null> _focusNodeListener() async{
    if(_focusNodeNewUsername.hasFocus){
      print("用户名框获取焦点");
  }
}

  void changeDisplayUserName(String newUsername) async{
    FirebaseUser user;
    user = await FirebaseAuth.instance.currentUser();
    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = newUsername;
    user.updateProfile(userUpdateInfo);
  }
  
  void confirmChangeUsernameDialog(String newUsername) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('提示'),
            //可滑动
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('再确认一次！！'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确认'),
                onPressed: () {
                   FirebaseAuth.instance.currentUser()
                       .then((currentUser) => Firestore.instance.collection("users")
                       .document(currentUser.email).updateData({"username": newUsername}))
                       .then((value) => changeDisplayUserName(newUsername))
                       .then((value) => Navigator.of(context).pop())
                       .then((value) => Navigator.of(context).pop());
                   _newUsernameController.clear();
                  HomePage.username = newUsername;
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  String validateUserName(value) {
    if (value.isEmpty) {
      return '用户名不能为空';
    }
    else if (value.trim().length>18) {
      return '用户名不得长于18位';
    }
    return null;
  }

  void oldNewUsernameSameAlertDialog() {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('提示'),
            //可滑动
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('新旧用户名不得一致'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _newUsernameController.clear();
                },
              ),

            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    // ScreenUtil.instance = ScreenUtil(width:750,height:1334)..init(context);
    print(ScreenUtil().scaleHeight);

    // logo 图片区域
    Widget logoImageArea = new Container(
      alignment: Alignment.topCenter,
      // 设置图片为圆形
      child: ClipOval(
        child: Image.asset(
          "images/logo.png",
          height: 160,
          width: 140,
          fit: BoxFit.cover,
        ),
      ),
    );

    //输入文本框区域
    Widget inputTextArea = new Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white
      ),
      child: new Form(
        key: _formKey,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextFormField(
              controller: _newUsernameController,
              focusNode: _focusNodeNewUsername,
              //设置键盘类型
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入新用户名",
                prefixIcon: Icon(Icons.person),
                //尾部添加清除按钮
                suffixIcon:(_isShowClear)
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: (){
                    // 清空输入框内容
                    _newUsernameController.clear();
                  },
                )
                    : null ,
              ),
              validator: validateUserName,
              //保存数据
              onSaved: (String value){
                _newUsername = value;
              },
            ),
          ],
        ),
      ),
    );

    Widget loginButtonArea = new Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      height: 45.0,
      child: new RaisedButton(
        color: Colors.blue[300],
        child: Text(
          "确认修改",
          style: Theme.of(context).primaryTextTheme.headline,
        ),
        // 设置按钮圆角
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (){
          //点击登录按钮，解除焦点，回收键盘
          _focusNodeNewUsername.unfocus();

          if (_formKey.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey.currentState.save();
            //登录操作
            // connect database
            if (HomePage.username == _newUsername) oldNewUsernameSameAlertDialog();
            else
              confirmChangeUsernameDialog(_newUsername);setState(() {
              });
          }

        },
      ),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      // 外层添加一个手势，用于点击空白部分，回收键盘
      body: new GestureDetector(
        onTap: (){
          // 点击空白区域，回收键盘
          print("点击了空白区域");
          _focusNodeNewUsername.unfocus();
        },
        child: new ListView(
          children: <Widget>[
            new SizedBox(height: ScreenUtil().setHeight(80),),
            logoImageArea,
            new SizedBox(height: ScreenUtil().setHeight(70),),
            inputTextArea,
            new SizedBox(height: ScreenUtil().setHeight(80),),
            loginButtonArea,
//            new SizedBox(height: ScreenUtil().setHeight(60),),
//            thirdLoginArea,
            new SizedBox(height: ScreenUtil().setHeight(60),),
          ],
        ),
      ),
    );
  }
}
