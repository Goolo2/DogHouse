import 'package:doghouse/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  static String tag = 'register-page';
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();
  FocusNode _focusNodeConfirmPassWord = new FocusNode();
  FocusNode _focusNodeAccountNumber = new FocusNode();

  //用户名输入框控制器，此控制器可以监听用户名输入框操作
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _accountNumberController = new TextEditingController();
  // 如果两次密码输入不一致，点即重试后要清空确认密码框
  TextEditingController _confirmPasswordController = new TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey_register = GlobalKey<FormState>();

  var _password = ''; //密码
  var _username = ''; //用户名
  var _accountNumber; //账号
  var _confirm_password = ''; //确认密码
  var _isShowConfirmPwd = false; //确认密码时是否显示密码
  var _isShowPwd = false; //是否显示密码
  var _isShowUsenameClear = false; //是否显示输入框尾部的清除按钮
  var _isShowAccountNumberClear = false;

  @override
  void initState() {
    //设置焦点监听
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    _focusNodeAccountNumber.addListener(_focusNodeListener);
    _focusNodeConfirmPassWord.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _userNameController.addListener((){
      print(_userNameController.text);

      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_userNameController.text.length > 0) {
        _isShowUsenameClear = true;
      }
      else{
        _isShowUsenameClear = false;
      }
      setState(() {

      });
    });
    //监听账号框输入变化
    _accountNumberController.addListener((){
      print(_accountNumberController.text);

      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_accountNumberController.text.length > 0) {
        _isShowAccountNumberClear = true;
      }
      else{
        _isShowAccountNumberClear = false;
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
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _focusNodeConfirmPassWord.removeListener(_focusNodeListener);
    _focusNodeAccountNumber.removeListener(_focusNodeListener);
    _userNameController.dispose();
    super.dispose();
  }

  void setDisplayUserName() async{
    FirebaseUser user;
    user = await FirebaseAuth.instance.currentUser();
    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = _username;
    user.updateProfile(userUpdateInfo);
}
  
  // 监听焦点
  Future<Null> _focusNodeListener() async{
    if(_focusNodeUserName.hasFocus){
      print("用户名框获取焦点");
      // 取消密码框和确认密码框的焦点状态
      _focusNodePassWord.unfocus();
      _focusNodeAccountNumber.unfocus();
      _focusNodeConfirmPassWord.unfocus();
    }
    if(_focusNodeAccountNumber.hasFocus){
      print("账号框获取焦点");
      // 取消密码框和确认密码框的焦点状态
      _focusNodeUserName.unfocus();
      _focusNodePassWord.unfocus();
      _focusNodeConfirmPassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框和确认密码框焦点状态
      _focusNodeConfirmPassWord.unfocus();
      _focusNodeAccountNumber.unfocus();
      _focusNodeUserName.unfocus();
    }
    if(_focusNodeConfirmPassWord.hasFocus){
      print("确认密码框获取焦点");
      // 取消密码框和用户框的焦点状态
      _focusNodePassWord.unfocus();
      _focusNodeAccountNumber.unfocus();
      _focusNodeUserName.unfocus();
    }
  }


   // 验证用户名
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

  String validateUserName(value) {
    if (value.isEmpty) {
      return '用户名不能为空';
    }
    else if (value.trim().length>18) {
      return '用户名不得长于18位';
    }
    return null;
  }
   // 验证密码
  String validatePassWord(value){
    if (value.isEmpty) {
      return '密码不能为空';
    }
    else if (value.trim().length<6){
      return '密码长度不得少于6位';
    }
    else if (value.trim().length>18) {
      return '密码长度不得长于18位';
    }
    return null;
  }

  void showAlertDialog() {
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
                  new Text('两次密码输入不一致'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('重试'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmPasswordController.clear();
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(RegisterPage.tag);
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
        key: _formKey_register,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextFormField(
              controller: _userNameController,
              focusNode: _focusNodeUserName,
              //设置键盘类型
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入用户名",
                prefixIcon: Icon(Icons.person),
                //尾部添加清除按钮
                suffixIcon:(_isShowUsenameClear)
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: (){
                    // 清空输入框内容
                    _userNameController.clear();
                  },
                )
                    : null ,
              ),
              validator: validateUserName,
              //保存数据
              onSaved: (String value){
                _username = value;
              },
            ),
            new TextFormField(
              controller: _accountNumberController,
              focusNode: _focusNodeAccountNumber,
              //设置键盘类型
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "账号",
                hintText: "请输入邮箱",
                prefixIcon: Icon(Icons.person),
                //尾部添加清除按钮
                suffixIcon:(_isShowAccountNumberClear)
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: (){
                    // 清空输入框内容
                    _accountNumberController.clear();
                  },
                )
                    : null ,
              ),
              //验证账号
              validator: validateAccountNumber,
              //保存数据
              onSaved: (String value){
                _accountNumber = value;
              },
            ),
            new TextFormField(
              focusNode: _focusNodePassWord,
              decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "请输入密码",
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
                _password = value;
              },
            ),
            new TextFormField(
              controller: _confirmPasswordController,
              focusNode: _focusNodeConfirmPassWord,
              decoration: InputDecoration(
                  labelText: "确认密码",
                  hintText: "请再次输入密码",
                  prefixIcon: Icon(Icons.lock),
                  // 是否显示密码
                  suffixIcon: IconButton(
                    icon: Icon((_isShowConfirmPwd) ? Icons.visibility : Icons.visibility_off),
                    // 点击改变显示或隐藏密码
                    onPressed: (){
                      setState(() {
                        _isShowConfirmPwd = !_isShowConfirmPwd;
                      });
                    },
                  )
              ),
              obscureText: !_isShowConfirmPwd,
              //密码验证
              validator:validatePassWord,
              //保存数据
              onSaved: (String value){
                _confirm_password = value;
              },
            ),
          ],
        ),
      ),
    );

    // 注册按钮区域
    Widget registerButtonArea = new Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      height: 45.0,
      child: new RaisedButton(
        color: Colors.blue[300],
        child: Text(
          "注册",
          style: Theme.of(context).primaryTextTheme.headline,
        ),
        // 设置按钮圆角
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (){
          //点击注册按钮，解除焦点，回收键盘
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
          _focusNodeConfirmPassWord.unfocus();
          _focusNodeAccountNumber.unfocus();

          if (_formKey_register.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey_register.currentState.save();
            // 注册操作，先验证密码与确认密码是否一致，不一致弹出警告框
            if(_password == _confirm_password) {
              // connect database
              print('Account number: $_accountNumber');
              Property.coins = 0;
              Property.dogsIdSet.add(1);
              Property.friends.add(_accountNumber.toString());
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                    email: _accountNumber, password: _password)
                  .then((currentUser) => Firestore.instance
                    .collection("users")
                    .document(_accountNumber)
                    .setData({
                      "uid": currentUser.uid,
                      "username": _username,
                      "accountNumber": _accountNumber,
                      "coins": Property.coins,
                      "dogsIdSet": Property.dogsIdSet,
                      "friends": Property.friends,
              }).then((result) => setDisplayUserName()
//              {
//                setDisplayUserName();
//                Firestore.instance.collection("times").document(currentUser.uid).setData({});
//                Navigator.of(context).pushNamed(HomePage.tag);
//              }
              ).then((value) => Firestore.instance.collection("times").document(_accountNumber).setData({}))
                  .then((value) => FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                  email: _accountNumber, password: _password)).then((value) => Navigator.of(context).pushNamed(HomePage.tag)));
            }
            else
              showAlertDialog();
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
          _focusNodeUserName.unfocus();
          _focusNodeConfirmPassWord.unfocus();
          _focusNodeAccountNumber.unfocus();
        },
        child: new ListView(
          children: <Widget>[
            new SizedBox(height: ScreenUtil().setHeight(80),),
            logoImageArea,
            new SizedBox(height: ScreenUtil().setHeight(70),),
            inputTextArea,
            new SizedBox(height: ScreenUtil().setHeight(80),),
            registerButtonArea,
          ],
        ),
      ),
    );
  }
}
