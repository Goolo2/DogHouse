import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'home_page.dart';
import 'package:flutter/services.dart' show rootBundle;

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
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(50, 71, 85, 1),
        title: Text("我的狗窝"),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            // title:Text('Demo'),
            automaticallyImplyLeading: false,
            centerTitle: true,
            pinned: true,
            //是否固定。
            backgroundColor: Colors.white,
            expandedHeight: 125.0,
            flexibleSpace: new FlexibleSpaceBar(
              background: Image.asset(
                'images/bar.png',
                fit: BoxFit.cover,
              ),
              centerTitle: true,
//              title: const Text('我的狗窝'),
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

  Future<String> loadAsset() async {
    var a = await rootBundle.loadString('images/store/dogs.txt');
    return a;
  }

  void loadData() async{
    for (TimeEntry time in HomePage.times){
//      String img = await loadAsset();
//      int index = 2;
//      String name;
//      for (String dogName in img.split('\n')) {
//        if (index==time.currentDogId){
//          name = dogName;
//          break;
//        }
//        index = index + 1;
//      }
      FlipCard c = new FlipCard(
        front: Container(
          height: 200,
          width: 345,
          margin: EdgeInsets.all(10),
          color: Color.fromRGBO(135, 188, 191, 1),
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
          color: Color.fromRGBO(217, 125, 84, 1),
          padding: EdgeInsets.all(10),
//          child: Center(
//            child: Text(time.tag.toString()+' for '+time.time.toString()+'min'
//                ,style: TextStyle(
//                  color: Colors.white,
//                  fontSize:40,
//                )),
//          )
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
          Text(time.tag.toString()+' for '+time.time.toString()+'min'
                ,style: TextStyle(
                  color: Colors.white,
                  fontSize:20,
                )),
            Image.asset('images/store/dog'+time.currentDogId.toString()+'.png'),
//            Image.asset('images/store'+name+'.png'),
          ],
        ),
        ),
      );
      widgetList.add(c);
    }
  }
}