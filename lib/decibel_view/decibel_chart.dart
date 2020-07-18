// Timeseries chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DecibelChart extends StatelessWidget {
  final bool animate;
  final List<LinearDecibels> data;
  final DateTime start;
  final DateTime end;

  DecibelChart(this.data,
      {Key key, this.animate = false, this.start, this.end});

  @override
  Widget build(BuildContext context) {
    final List<charts.Series> seriesList = _getSeries();
    final fontColor = charts.ColorUtil.fromDartColor(
        Theme.of(context).textTheme.caption.color);
    final lineColor =
        charts.ColorUtil.fromDartColor(Theme.of(context).dividerColor);

    final primaryAxisMeasureTickFormatter =
        charts.BasicNumericTickFormatterSpec((num value) {
      if (value == 0.0) return '';
      return '${value.toInt()} dB';
    });

    return charts.TimeSeriesChart(
      seriesList,
      defaultRenderer: charts.LineRendererConfig(strokeWidthPx: 1),
      animate: animate,
      behaviors: [
        charts.RangeAnnotation([
          // 차트 y axis 범위 지정(0 ~ 100 dB)
          charts.RangeAnnotationSegment(
              0, 100, charts.RangeAnnotationAxisType.measure,
              color: charts.MaterialPalette.transparent),
          charts.RangeAnnotationSegment(
              start, end, charts.RangeAnnotationAxisType.domain,
              color: charts.MaterialPalette.transparent)
        ])
      ],
      domainAxis:
          charts.EndPointsTimeAxisSpec(renderSpec: charts.NoneRenderSpec()),
      // 차트 y axis 구분 라인수 지정
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickFormatterSpec: primaryAxisMeasureTickFormatter,
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
          renderSpec: charts.GridlineRendererSpec(
              // Tick and Label styling here.
              labelStyle: charts.TextStyleSpec(color: fontColor),
              // Change the line colors to match text color.
              lineStyle: charts.LineStyleSpec(color: lineColor))),
    );
  }

  List<charts.Series<LinearDecibels, DateTime>> _getSeries() {
    return [
      charts.Series<LinearDecibels, DateTime>(
          data: data,
          id: 'decibels',
          seriesColor: charts.ColorUtil.fromDartColor(Colors.red[900]),
          domainFn: (LinearDecibels decibels, _) => decibels.time,
          measureFn: (LinearDecibels decibels, _) => decibels.decibel),
    ];
  }
}

class LinearDecibels {
  final DateTime time;
  final double decibel;

  LinearDecibels(this.time, this.decibel);
}
