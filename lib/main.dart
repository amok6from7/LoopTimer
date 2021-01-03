import 'package:flutter/material.dart';

import 'stopwatch.dart';

void main() {
  runApp(LoopTimerApp());
}

class LoopTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StopWatch(),
    );
  }
}
