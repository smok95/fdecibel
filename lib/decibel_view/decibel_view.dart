import 'package:fdecibel/decibel_stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_jk/flutter_jk.dart';

import 'decibel_bar.dart';
import 'decibel_chart.dart';
import 'decibel_gauge.dart';

class DecibelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<DecibelStats>();
    final decibelBar = DecibelBar(stats.min, stats.max, stats.avg,
        minTitle: 'minimum'.tr,
        maxTitle: 'maximum'.tr,
        avgTitle: 'average'.tr,
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
