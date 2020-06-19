import 'package:doghouse/register_page.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/home_page.dart';
import 'package:doghouse/splash_page.dart';
import 'package:doghouse/login_page.dart';
import 'package:doghouse/data.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  //routes需要Map<String, WidgetBuilder>类型参数，所以这里定义了一个这个类型的常量，将刚才两个页面添加进去
  final routes = <String, WidgetBuilder> {
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    DataPage.tag: (context) => DataPage(),
    RegisterPage.tag: (content) => RegisterPage(),
    SplashPage.tag: (content) => SplashPage(),
//>>>>>>> 67fc8ba108620095078302ce9376c34fb5fbaece
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '登录Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: SplashPage(),
      routes: routes,
    );
  }
}