
import 'package:doghouse/register_page.dart';
import 'package:flutter/material.dart';
import 'package:doghouse/home_page.dart';
import 'package:doghouse/splash_page.dart';
import 'package:doghouse/settings/change_username.dart';
import 'package:doghouse/login_page.dart';
import 'package:doghouse/data.dart';
import 'package:doghouse/settings/setting_page.dart';
import 'package:doghouse/settings/change_password.dart';
import 'package:doghouse/timer/screen.dart';
import 'package:doghouse/store/manydogs.dart';
import 'package:doghouse/gouwo.dart';
import 'package:doghouse/friends_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  //routes需要Map<String, WidgetBuilder>类型参数，所以这里定义了一个这个类型的常量，将刚才两个页面添加进去
  final routes = <String, WidgetBuilder> {
    StorePage.tag: (context) => StorePage(),
    DataPage.tag: (content) => DataPage(),
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    TimerScreen.tag: (context,{arguments}) => TimerScreen(),
    RegisterPage.tag: (content) => RegisterPage(),
    SplashPage.tag: (content) => SplashPage(),
    SettingsPage.tag: (content) => SettingsPage(),
    ChangePasswordPage.tag: (content) => ChangePasswordPage(),
    ChangeUsernamePage.tag: (content) => ChangeUsernamePage(),
    GouPage.tag: (content) => GouPage(),
    FriendsPage.tag: (content) => FriendsPage(),
    ChooseDog.tag: (context) => ChooseDog(),
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'DogHouse',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
        canvasColor:  Color.fromRGBO(220, 220, 220, 0.8),
        fontFamily: 'Georgia',

        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: SplashPage(),
      routes: routes,
    );
  }
}
