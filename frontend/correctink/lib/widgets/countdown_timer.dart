import 'package:flutter/material.dart';
class CountDownTimer extends StatefulWidget {
  final int secondsRemaining;
  final Function whenTimeExpires;
  final Function? countDownFormatter;
  final TextStyle countDownTimerStyle;

  const CountDownTimer({super.key, required this.secondsRemaining, required this.whenTimeExpires, required this.countDownTimerStyle, this.countDownFormatter,});

  @override
  State createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Duration duration;

  String get timerDisplayString {
    Duration duration = _controller.duration! * _controller.value;
    return widget.countDownFormatter != null
        ? widget.countDownFormatter!(duration.inSeconds)
        : formatMMSS(duration.inSeconds);
  }

@override
void initState() {
  super.initState();
  duration = Duration(seconds: widget.secondsRemaining);
  _controller = AnimationController(
    vsync: this,
    duration: duration,
  );
  _controller.reverse(from: widget.secondsRemaining.toDouble());
  _controller.addStatusListener((status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      widget.whenTimeExpires();
    }
  });
}

@override
void didUpdateWidget(CountDownTimer oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.secondsRemaining != oldWidget.secondsRemaining) {
    setState(() {
      duration = Duration(seconds: widget.secondsRemaining);
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: duration,
      );
      _controller.reverse(from: widget.secondsRemaining.toDouble());
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.whenTimeExpires();
        }
      });
    });
  }
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Center(
    child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      return Text(
        timerDisplayString,
        style: widget.countDownTimerStyle,
      );
  }));
}

  String formatMMSS(int inSeconds) {
    int minutes = (inSeconds % 3600) ~/ 60;
    int remainingSeconds = inSeconds % 60;

    String formattedMinutes = minutes < 10 ? '0$minutes' : '$minutes';
    String formattedSeconds = remainingSeconds < 10 ? '0$remainingSeconds' : '$remainingSeconds';

    return '$formattedMinutes:$formattedSeconds';
  }
}