import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../my_util.dart';

/// 데시벨 게이지 위젯
/// 데시벨 게이지를 사용하려면 Syncfusion 라이선스가 있어야함.
/// 개인개발자는 무료버전 Community license 발급받아 사용가능
/// 아래와 같이 초기화 단계에서 라이선스 등록을 해줘야함.
/// ```
/// SyncfusionLicense.registerLicense(
///   '발급받은license-key');
/// ```

class DecibelGauge extends StatelessWidget {
  const DecibelGauge(this.decibel,
      {Key key, this.maximum = 110.0, this.animationDuration = 250});

  final double decibel;
  final double maximum;
  final double animationDuration;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width < size.height ? size.width : size.height;

    return Container(
      color: Colors.transparent,
      child: SizedBox(
        width: width * 0.8,
        height: width * 0.8,
        child: _buildGauge(context, decibel),
      ),
    );
  }

  Widget _buildGauge(BuildContext context, final double decibel) {
    final String text = MyUtil.doubleToString(decibel) + ' dB';
    final axisLabelColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return SfRadialGauge(
      enableLoadingAnimation: true,
      axes: [
        RadialAxis(
            startAngle: 130,
            endAngle: 50,
            minimum: 0,
            maximum: maximum,
            showAxisLine: true,
            labelOffset: 0.1,
            tickOffset: 0.1,
            offsetUnit: GaugeSizeUnit.factor,
            axisLabelStyle: GaugeTextStyle(color: axisLabelColor),
            ranges: [
              GaugeRange(
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
                gradient: SweepGradient(colors: [
                  Colors.lightGreen,
                  Colors.lightGreen,
                  Colors.lightGreen,
                  Colors.lightGreen,
                  Colors.yellow,
                  Colors.orange,
                  Colors.red
                ]),
                startValue: 0,
                endValue: maximum,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.85,
                  widget: Container(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
                  ))
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                  value: decibel,
                  enableAnimation: true,
                  animationType: AnimationType.linear,
                  animationDuration: animationDuration,
                  needleLength: 0.75,
                  needleStartWidth: 1.5,
                  needleColor: Colors.red)
            ])
      ],
    );
  }
}
