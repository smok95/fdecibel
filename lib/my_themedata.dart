import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

@immutable
class MyThemeData {
  static ThemeData dark() {
    ThemeData theme = ThemeData(brightness: Brightness.dark);

    final fab = theme.floatingActionButtonTheme.copyWith(
        backgroundColor: Colors.red[900], foregroundColor: Colors.black);

    return ThemeData(
        brightness: theme.brightness, floatingActionButtonTheme: fab);
  }

  static ThemeData light() {
    return ThemeData.light();
  }
}
