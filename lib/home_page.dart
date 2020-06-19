import 'package:flutter/material.dart';
//登录后的主界面
import 'data.dart';
class HomePage extends StatelessWidget{
  static String tag="home-page";

  @override
  Widget build(BuildContext context) {
    final user=Hero(
      tag: "用户名",
      child: Padding(
        padding: EdgeInsets.all(20.0),//所有方向均填充20像素空白
        child: CircleAvatar(
          radius: 72.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage("assets/timg.jpg"),
        ),
      ),
    );

    final welcome=Padding(//欢迎文字提示
      padding: EdgeInsets.all(8.0),
      child: Text(
        '欢迎你',
        style: new TextStyle(color: Colors.white, fontSize: 20.0),
      ),
    );

    final info=Padding(//其他文字提示
      padding: EdgeInsets.all(8.0),
      child: Text(
        "登录界面就是这么简单简单哦！",
        style: new TextStyle(color: Colors.white, fontSize: 20.0),
      ),
    );

    final body=Container(//body主要内容
      width: MediaQuery.of(context).size.width,//设置为屏幕宽度
      padding: EdgeInsets.all(28.0),//上下左右各填充28空白像素
      decoration: BoxDecoration(//装饰器，博主前面的渐变色介绍过
          gradient: LinearGradient(//线性渐变
              colors: [
                Colors.green,//蓝
                Colors.lightGreenAccent//绿偏黄的颜色
              ]
          )
      ),
//      child: Column(children: <Widget>[//将上面定义的子空间全部添加进去
//        user, welcome, info,
//      ],),
      alignment: Alignment.center,
      child: Container(
        child: RaisedButton(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0), //padding
            child: new Text(
              'Data',
              style: new TextStyle(
                fontSize: 18.0, //textsize
                color: Colors.white,// textcolor
              ),
            ),
            color: Theme.of(context).accentColor,
            elevation: 4.0,  //shadow
            splashColor: Colors.blueGrey,
            onPressed: () {
              //click event: show a snack bar
              Navigator.of(context).pushNamed(DataPage.tag);
            }
        ),
    ));
//      child: RaisedButton(
//          child: Text('Data Page'),
//          onPressed: () {
//            Navigator.of(context).pushNamed(DataPage.tag);
//          }),
    return Scaffold(
      body: body,
    );
  }

}