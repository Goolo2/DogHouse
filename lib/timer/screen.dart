import 'dart:async';

import 'package:flutter/material.dart';
import 'package:doghouse/timer/neu_digital_clock.dart';
import 'package:doghouse/timer/neu_hamburger_button.dart';
import 'package:doghouse/timer/neu_progress_pie_bar.dart';
import 'package:doghouse/timer/neu_reset_button.dart';
import 'package:provider/provider.dart';
import 'package:doghouse/home_page.dart';

class TimerScreen extends StatelessWidget {
  static String tag = 'timer-page';
  // 下面这种传参数的方式不知道为什么没用
  // const TimerScreen({
  //   Key key,
  //   @required this.arguments,
  // }) : super(key: key);
  // 这种也没用，佛了
  // // final num countdown;
  // final arguments;
  // TimerScreen({this.arguments});
  // 获取路由参数
  bool flag = false;
  @override
  Widget build(BuildContext context) {
    // 只有在build里这样传才有用
    var arguments=ModalRoute.of(context).settings.arguments;
//    print(arguments);
//    Database().update_datebase(arguments, 'study');
    HomePageState().update_datebase(arguments, 'study', flag);
    flag = !flag;
    final timeService = TimerService();
    return ChangeNotifierProvider<TimerService>(
      create: (_) => timeService,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).viewPadding.top + 50),
              // TimerTitle(),
              SizedBox(height: 30),
              NeuDigitalClock(),
              SizedBox(height: 10),
              NeuProgressPieBar(timeset:arguments!=null?arguments:60),
              SizedBox(height: 5),
              NeuResetButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerTitle extends StatelessWidget {
  const TimerTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Timer',
          style: Theme.of(context).textTheme.headline2,
        ),
        Spacer(),
        NeuHamburgerButton()
      ],
    );
  }
}

class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;

    // notify all listening widgets
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }
  // source: https://stackoverflow.com/questions/53228993/how-to-implement-persistent-stopwatch-in-flutter
}
