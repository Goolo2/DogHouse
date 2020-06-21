import 'package:doghouse/home_page.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/settings/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  var _isShowPwd = false; //是否显示密码
  var _isShowNewPwd = false;

  @override
  void initState() {
    //设置焦点监听
    _focusNodePassWord.addListener(_focusNodeListener);
    _focusNodeNewPassWord.addListener(_focusNodeListener);
    super.initState();
  }

  @override
  void dispose() {
    // 移除焦点监听
    _focusNodePassWord.removeListener(_focusNodeListener);
    super.dispose();
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async{
    if (_focusNodePassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框焦点状态
      _focusNodeNewPassWord.unfocus();
    }
    if (_focusNodeNewPassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框焦点状态
      _focusNodePassWord.unfocus();
    }
  }

  void passwordErrorAlertDialog(var err) {
    print(err);
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('错误'),
            //可滑动
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('原密码错误'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('重试'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _passwordController.clear();
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


  void confirmChangePasswordDialog(String oldPassword, String passsword) {
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
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                      email: HomePage.email, password: oldPassword).then((currentUser)
                  {
                    currentUser.updatePassword(passsword);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(SettingsPage.tag);})
                      .catchError((err) => passwordErrorAlertDialog(err));
//                  FirebaseAuth.instance.currentUser().then((currentUser) {
//                    currentUser.updatePassword(passsword);
//                    Navigator.of(context).pop();
//                    Navigator.of(context).pushNamed(LoginPage.tag);});
//                  //FirebaseAuth.instance.currentUser().then((currentUser) {print(currentUser.uid);Firestore.instance.collection("users").document(currentUser.uid).updateData({"username": "scdcscdfwes"});});
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

  void oldNewPasswordSameAlertDialog() {
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
                  new Text('新旧密码不得一致'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _newPasswordController.clear();
                },
              ),

            ],
          );
        });
  }



  // 验证密码

  String validatePassWord(value){
    if (value.isEmpty) {
      return '密码不能为空';
    }
    else if(value.trim().length<6){
      return '密码长度不得少于6位';
    }
    else if(value.trim().length>18) {
      return '密码长度不得长于18位';
    }
    return null;
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
              focusNode: _focusNodePassWord,
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: "原密码",
                  hintText: "请输入原密码",
                  prefixIcon: Icon(Icons.lock),
                  // 是否显示密码
                  suffixIcon: IconButton(
                    icon: Icon((_isShowPwd) ? Icons.visibility : Icons.visibility_off),
                    // 点击改变显示或隐藏密码
                    onPressed: (){
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  )
              ),
              obscureText: !_isShowPwd,
              //密码验证
              validator:validatePassWord,
              //保存数据
              onSaved: (String value){
                _old_password = value;
              },
            ),
            new TextFormField(
              focusNode: _focusNodeNewPassWord,
              controller: _newPasswordController,
              decoration: InputDecoration(
                  labelText: "新密码",
                  hintText: "请输入新密码",
                  prefixIcon: Icon(Icons.lock),
                  // 是否显示密码
                  suffixIcon: IconButton(
                    icon: Icon((_isShowNewPwd) ? Icons.visibility : Icons.visibility_off),
                    // 点击改变显示或隐藏密码
                    onPressed: (){
                      setState(() {
                        _isShowNewPwd = !_isShowNewPwd;
                      });
                    },
                  )
              ),
              obscureText: !_isShowNewPwd,
              //密码验证
              validator:validatePassWord,
              //保存数据
              onSaved: (String value){
                _newPassword = value;
              },
            ),
          ],
        ),
      ),
    );

    // 登录按钮区域
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
          _focusNodePassWord.unfocus();
          _focusNodeNewPassWord.unfocus();

          if (_formKey.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey.currentState.save();
            //登录操作
            // connect database
            if (_old_password == _newPassword) oldNewPasswordSameAlertDialog();
            else
              confirmChangePasswordDialog(_old_password, _newPassword);
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
          _focusNodePassWord.unfocus();
          _focusNodeNewPassWord.unfocus();
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
