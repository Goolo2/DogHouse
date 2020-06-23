import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'home_page.dart';


class DataPage extends StatefulWidget {
  static String tag = 'data-page';
  @override
  systemPagerState createState() => systemPagerState();
}

//柱状图
class Barsales {
  String day;
  int time;
  Barsales(this.day, this.time);
}
//饼状图
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class systemPagerState extends State<DataPage> {
  bool animate;
  List<Widget> widgetList = List();

  @override
  void initState() {
    super.initState();
    if (HomePage.times != null){
      loadChartData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
//  画图
//  1.0 折线图
  static List<charts.Series<TimeEntry, DateTime>> createSampleData0() {
    final data = HomePage.times;
    return [
      new charts.Series<TimeEntry, DateTime>(
        id: 'time',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeEntry time, _) => time.date,
        measureFn: (TimeEntry time, _) => time.time,
        data: data,
      ),
    ];
  }
//  2.0 柱状图
  static List<charts.Series<Barsales, String>>  getData() {

    List<Barsales> StudyData = List();
    List<Barsales> RelaxData = List();
    List<Barsales> OtherData = List();
//    for (TimeEntry time in HomePage.times){
//      if (time.tag == 'study'){
//        StudyData.add(new Barsales(time.date.day.toString(), time.time));
//      }else if (time.tag == 'relax'){
//        RelaxData.add(new Barsales(time.date.day.toString(), time.time));
//      }else{
//        OtherData.add(new Barsales(time.date.day.toString(), time.time));
//      }
//    }

    int study=0;
    int relax=0;
    int other=0;
    String date;
    for (TimeEntry time in HomePage.times){
      date = time.date.day.toString();
      if (time.tag == 'study'){
        study += time.time;
      }else if (time.tag == 'relax'){
        relax += time.time;
      }else{
        other += time.time;
      }
    }
    if (study > 0){
      StudyData.add(new Barsales(date, study));
    }
    if (relax > 0){
      RelaxData.add(new Barsales(date, relax));
    }
    if (other > 0){
      OtherData.add(new Barsales(date, other));
    }

    return [
      new charts.Series<Barsales, String>(
        id: 'Study',
        domainFn: (Barsales time, _) => time.day,
        measureFn: (Barsales time, _) => time.time,
        data: StudyData,
      ),
      new charts.Series<Barsales, String>(
        id: 'Relax',
        domainFn: (Barsales time, _) => time.day,
        measureFn: (Barsales time, _) => time.time,
        data: RelaxData,
      ),
      new charts.Series<Barsales, String>(
        id: 'Other',
        domainFn: (Barsales time, _) => time.day,
        measureFn: (Barsales time, _) => time.time,
        data: OtherData,
      ),
    ];
  }
//  3.0 饼状图
  static List<charts.Series<LinearSales, int>> createSampleData1() {
    int study=0;
    int relax=0;
    int other=0;
    for (TimeEntry time in HomePage.times){
      if (time.tag == 'study'){
        study += time.time;
      }else if (time.tag == 'relax'){
        relax += time.time;
      }else{
        other += time.time;
      }
    }
//    print(study);
//    print(relax);
//    print(other);
    final data = [
      new LinearSales(0, study),
      new LinearSales(1, relax),
      new LinearSales(2, other),
    ];
    return [
      new charts.Series<LinearSales, int>(
        id: 'time',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
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
              title: const Text('数据统计'),
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



  void loadChartData() async {
    //1.折线图
    widgetList.add(
      new charts.TimeSeriesChart(
//        ChartFlutterBean.createSampleData0(),
        createSampleData0(),
        animate: animate,
        // Optionally pass in a [DateTimeFactory] used by the chart. The factory
        // should create the same type of [DateTime] as the data provided. If none
        // specified, the default creates local date time.
        dateTimeFactory: new charts.LocalDateTimeFactory(),
      ),
    );
    //2.饼状图
    widgetList.add(
      new charts.PieChart(
        createSampleData1(),
        animate: animate,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        defaultRenderer: new charts.ArcRendererConfig(arcWidth: 60),
      ),
    );
    //3.柱状图
    widgetList.add(
      new charts.BarChart(
        getData(),
        animate: animate,
        behaviors: [
          new charts.SeriesLegend(
              position: charts.BehaviorPosition.end, desiredMaxRows: 2),
        ],
      ),
    );
  }
}
