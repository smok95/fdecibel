import 'package:flutter/material.dart';
import '../my_label.dart';
import '../my_util.dart';

class DecibelBar extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final double avgValue;

  /// 측정시간
  final Duration duration;
  final String minTitle, maxTitle, avgTitle;
  DecibelBar(this.minValue, this.maxValue, this.avgValue,
      {this.duration,
      this.minTitle = 'MIN',
      this.maxTitle = 'MAX',
      this.avgTitle = 'AVG'});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();
    children.add(MyLabel(MyUtil.doubleToString(minValue) + ' dB', minTitle));
    children.add(MyLabel(MyUtil.doubleToString(avgValue) + ' dB', avgTitle));
    children.add(MyLabel(MyUtil.doubleToString(maxValue) + ' dB', maxTitle));
    if (duration != null) {
      children.add(MyLabel(MyUtil.durationToString(duration), ''));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}
