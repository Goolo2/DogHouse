import 'package:flutter/material.dart';
import 'package:doghouse/timer/neu_progress_painter.dart';
import 'package:doghouse/timer/screen.dart';
import 'package:provider/provider.dart';
import 'package:doghouse/home_page.dart';

class NeuProgressPieBar extends StatelessWidget {
  final num timeset;
  const NeuProgressPieBar({
    Key key,
    @required this.timeset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    // percentage是当前经过的时间占1分钟的比例
    final percentage =
        Provider.of<TimerService>(context).currentDuration.inSeconds / timeset * 100;
    return Container(
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(225, 234, 244, 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(-5, -5),
            color: Colors.white,
          ),
          BoxShadow(
            blurRadius: 15,
            offset: Offset(10.5, 10.5),
            color: Color.fromRGBO(214, 223, 230, 1),
          )
        ],
        border: Border.all(
          width: 15,
          color: Theme.of(context).backgroundColor,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: SizedBox(
              height: 250,
              child: CustomPaint(
                painter: NeuProgressPainter(
                  circleWidth: 60,
                  completedPercentage: percentage,
                  defaultCircleColor: Colors.transparent,
                ),
                child: Center(),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0.0),
                    Colors.black54,
                  ],
                  stops: [0.95, 1.0],
                ),
                border: Border.all(
                  width: 15,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
              child: Center(child: NeuStartButton(timeset: timeset)),
            ),
          ),
        ],
      ),
    );
  }
}

class NeuStartButton extends StatefulWidget {
  final double bevel;
  final Offset blurOffset;
  final num timeset;

  NeuStartButton({
    Key key,
    this.bevel = 10.0,
    this.timeset,
  })  : this.blurOffset = Offset(bevel / 2, bevel / 2),
        super(key: key);

  
  @override
  _NeuStartButtonState createState() => _NeuStartButtonState();
}

class _NeuStartButtonState extends State<NeuStartButton> {
  bool _isPressed = false;
  bool _isRunning = false;
  
  void _onPointerDown() {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // build在每一秒都会更新
    // 一定要放在build里来读取currentduration
    final currentDuration = Provider.of<TimerService>(context).currentDuration;
    var plustime;
    bool flag = true;
    return Listener(
      // Listener监听触摸事件
      onPointerDown: (_) {
        _onPointerDown();
        Provider.of<TimerService>(context, listen: false).stop();
        // _isRunning
        // // 利用Provider，根据isRunning的状态来调用TimerService中的函数
        // // https://flutter.cn/docs/development/data-and-backend/state-mgmt/simple
        //     ? Provider.of<TimerService>(context, listen: false).stop()
        //     : Provider.of<TimerService>(context, listen: false).start();
        setState(() => _isRunning = !_isRunning);
        // 打印当前经过的时间
        // print("currentDuration="+currentDuration.toString());
        print("currentDuration in seconds="+currentDuration.inSeconds.toString());
        print("received timeset="+widget.timeset.toString());
        if (currentDuration.inSeconds>=widget.timeset){
          plustime=currentDuration.inSeconds-widget.timeset;
          int coins = (widget.timeset + plustime * 1.2).round();
          int beyondTwoHour = currentDuration.inSeconds - 120;
          coins = (beyondTwoHour > 0)?(coins - beyondTwoHour*1.2).round():coins;
          if (HomePage.tagg != ""){
            HomePageState().update_datebase(currentDuration.inSeconds, HomePage.tagg, coins, flag);
          }
          else{
            HomePageState().update_datebase(currentDuration.inSeconds, 'study', coins, flag);
          }
          Navigator.of(context).pop('加时'+plustime.toString()+'s');
        }
        else{
          Navigator.of(context).pop('提前结束');
        }
      },
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 95,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white70,
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: -widget.blurOffset,
                    color: Colors.white,
                  ),
                  BoxShadow(
                    blurRadius: 15,
                    offset: Offset(10.5, 10.5),
                    color: Color.fromRGBO(214, 223, 230, 1),
                  )
                ],
        ),
        child: Center(
            child: Icon(
          // 改变图标，开始/暂停
          Icons.stop,
          // _isRunning ? Icons.stop : Icons.play_arrow,
          size: 60,
          color: Colors.redAccent.shade400
          // color: _isRunning
          //     ? Colors.redAccent.shade400
          //     : Colors.greenAccent.shade400,
        )),
      ),
    );
  }
}

extension ColorUtils on Color {
  Color mix(Color another, double amount) {
    return Color.lerp(this, another, amount);
  }
}
