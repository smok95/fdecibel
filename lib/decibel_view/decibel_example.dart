import 'package:fdecibel/my_local.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../decibel_stats.dart';

class DecibelExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<DecibelStats>();
    return Container(
        padding: EdgeInsets.only(left: 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _decibelToExample(context, stats.decibel),
              textAlign: TextAlign.left,
            )));
  }

  String _decibelToExample(BuildContext context, double v) {
    final lo = MyLocal.of(context).text;

    /// sources
    /// https://audiology-web.s3.amazonaws.com/migrated/NoiseChart_Poster-%208.5x11.pdf_5399b289427535.32730330.pdf
    ///
    int level = 0;
    if (v < 10) {
      level = 0;
    } else if (10 <= v && v < 20) {
      level = 10;
    } else if (20 <= v && v < 30) {
      level = 20;
    } else if (30 <= v && v < 40) {
      level = 30;
    } else if (40 <= v && v < 50) {
      level = 40;
    } else if (50 <= v && v < 60) {
      level = 50;
    } else if (60 <= v && v < 70) {
      level = 60;
    } else if (70 <= v && v < 80) {
      level = 70;
    } else if (80 <= v && v < 90) {
      level = 80;
    } else if (90 <= v && v < 100) {
      level = 90;
    } else if (100 <= v && v < 110) {
      level = 100;
    } else if (110 <= v && v < 120) {
      level = 110;
    } else if (120 <= v) {
      level = 120;
    }

    return '$level dB : ${lo('decibel$level example')}';
  }
}
