import 'package:fdecibel/decibel_stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_local.dart';
import 'decibel_bar.dart';
import 'decibel_chart.dart';
import 'decibel_gauge.dart';

class DecibelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<DecibelStats>();
    final lo = MyLocal.of(context);
    final decibelBar = DecibelBar(stats.min, stats.max, stats.avg,
        minTitle: lo.text('minimum'),
        maxTitle: lo.text('maximum'),
        avgTitle: lo.text('average'),
        duration: stats.duration);

    return Column(children: [
      DecibelGauge(stats.decibel),
      decibelBar,
      SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: stats.startTime == null
              ? null
              : DecibelChart(stats.chartData,
                  start: stats.startTime, end: stats.endTime))
    ]);
  }
}
