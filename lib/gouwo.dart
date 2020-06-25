import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'home_page.dart';

class GouPage extends StatefulWidget {
  static String tag = 'gou-page';
  @override
  gouState createState() => gouState();
}

class gouState extends State<GouPage>{
  List<Widget> widgetList = List();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  void initState() {
    super.initState();
    if (HomePage.times != null){
      loadData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            actions: <Widget>[
              new Container(
                child: new Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )
              //只能用金泰的？
            ],
            leading: Icon(Icons.add),
            // title:Text('Demo'),
            centerTitle: true,
            pinned: true,
            //是否固定。
            backgroundColor: Colors.white,
            expandedHeight: 150.0,
            flexibleSpace: new FlexibleSpaceBar(
              background: Image.asset(
                'images/logo.png',
                fit: BoxFit.cover,
              ),
              centerTitle: true,
              title: const Text('我的狗窝'),
            ),
          ),
          new SliverFixedExtentList(
            itemExtent:150.0,
            delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return widgetList[index];
              },
              childCount: widgetList.length,
            ),
          ),
        ],
      ),
    );
  }

  void loadData() async{
    for (TimeEntry time in HomePage.times){
      FlipCard c = new FlipCard(
        front: Container(
          height: 200,
          width: 345,
          margin: EdgeInsets.all(10),
          color: Colors.blue,
          child: Center(
              child: Text(time.date.month.toString()+'月'+time.date.day.toString()+'日\n  '+time.date.hour.toString()+':'+time.date.minute.toString(),
                  style:TextStyle(
                      fontSize:20,
                      color:Colors.white
                  ))
          ),
        ),
        back: Container(
          height: 200,
          width: 345,
          margin: EdgeInsets.all(10),
          color: Colors.lightBlue,
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text(time.tag.toString()+' for '+time.time.toString()+'min'
                ,style: TextStyle(
                  color: Colors.white,
                  fontSize:40,
                )),
          )
        ),
      );
      widgetList.add(c);
    }
  }
}