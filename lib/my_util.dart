class MyUtil {
  static String doubleToString(double value, {int fractionDigits = 1}) {
    return value.toStringAsFixed(
        value.truncateToDouble() == value ? 0 : fractionDigits);
  }

  // MM:SS 형식으로 리턴
  static String durationToString(Duration d) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    if (d.inMicroseconds < 0) {
      return "-${-d}";
    }

    String twoDigitMinutes = twoDigits(d.inMinutes);
    String twoDigitSeconds =
        twoDigits(d.inSeconds.remainder(Duration.secondsPerMinute));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
