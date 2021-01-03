import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class StopWatch extends StatefulWidget {
  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  String minutesStr = '00';
  String secondsStr = '00';
  var _vibrateTimer;
  bool condition = false;
  int _interval = 35;
  var seconds = [10, 35, 60, 180, 300, 600];

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer _watchTimer;
    Duration timeInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (_watchTimer != null) {
        _watchTimer.cancel();
        _watchTimer = null;
        counter = 0;
        streamController.close();
        setState(() => condition = false);
        _vibrateTimer.cancel();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
    }

    void startTimer() {
      _watchTimer = Timer.periodic(timeInterval, tick);
      _vibrateTimer = Timer.periodic(
          Duration(seconds: _interval), (Timer t) => Vibration.vibrate());
      setState(() => condition = true);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StretchTimer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: _interval,
              items: seconds.map((int value) {
                return new DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '${value.toString()}秒ごと',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int val) {
                setState(() => _interval = val);
              },
            ),
            Text(
              "$minutesStr:$secondsStr",
              style: TextStyle(
                fontSize: 80.0,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: condition ? null : _start,
                  color: Colors.green,
                  child: Text(
                    'START',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
                SizedBox(width: 40.0),
                RaisedButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: condition ? _stop : null,
                  color: Colors.red,
                  child: Text(
                    'STOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _start() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream.listen((int newTick) {
      setState(() {
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
    });
  }

  void _stop() {
    timerSubscription.cancel();
    timerStream = null;
    setState(() {
      minutesStr = '00';
      secondsStr = '00';
    });
  }
}
