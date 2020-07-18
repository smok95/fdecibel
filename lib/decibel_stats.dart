import 'package:flutter/foundation.dart';

import 'decibel_view/decibel_chart.dart';

class DecibelStats with ChangeNotifier {
  DecibelStats() {
    reset();
  }

  void update(double decibel, int maxDuration) {
    final now = DateTime.now();

    _data.add(LinearDecibels(
        now, decibel == double.negativeInfinity ? null : decibel));

    final duration = now.difference(_data[0].time);
    if (duration.inMilliseconds > (maxDuration * 1000)) {
      _data.removeAt(0);
    }

    // 다른 앱에서 마이크를 사용하면 -Infinity 값이 들어옴.
    if (decibel == double.negativeInfinity) {
      _stopwatch?.stop();
      return;
    }

    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }

    // 현재 데시벨값 갱신
    _current = decibel;

    // 최소값 갱신
    if (_min == 0.0 || _min > decibel) _min = decibel;

    // 최대값 갱신
    if (_max == 0.0 || _max < decibel) _max = decibel;

    // 평균값 갱신
    _updateCount++;
    _accumulated += decibel;
    _avg = _accumulated / _updateCount;

    notifyListeners();
  }

  /// 통계데이터 초기화
  void reset() {
    _current = _min = _max = _avg = 0.0;
    _updateCount = 0;
    _accumulated = 0.0;

    _stopwatch.stop();
    _stopwatch.reset();

    _data.clear();
  }

  /// 현재 데시벨값
  double get decibel => _current;

  /// 측정된 데시벨 최대값
  double get min => _min;

  /// 측정된 데시벨 최소값
  double get max => _max;

  /// 측정된 데시벨 평균값
  double get avg => _avg;

  /// 측정시간
  Duration get duration {
    return _stopwatch.elapsed;
  }

  DateTime get startTime => _data.length > 0 ? _data[0].time : null;
  DateTime get endTime => startTime?.add(Duration(seconds: _duration)) ?? null;

  List<LinearDecibels> get chartData => _data;

  /// 현재 데시벨 값
  double _current;

  /// 최소값
  double _min;

  /// 최대값
  double _max;

  /// 평균값
  double _avg;

  /// 업데이트 횟수, [_avg] 평균값을 구하기 위해 사용
  double _updateCount;
  double _accumulated = 0.0;

  /// 차트에 표시될 구간값(단위:초)
  int _duration = 60;

  /// 측정시간
  Stopwatch _stopwatch = Stopwatch();

  List<LinearDecibels> _data = List<LinearDecibels>();
}
