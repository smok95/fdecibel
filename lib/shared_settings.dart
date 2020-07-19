import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedSettings with ChangeNotifier {
  /// 테마 밝기 모드
  Future<Brightness> get brightness async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool('light-mode') ?? false;
    return Future<Brightness>(
        () => isLight ? Brightness.light : Brightness.dark);
  }

  void changeBrightness(Brightness value) {
    final key = 'light-mode';
    SharedPreferences.getInstance().then((prefs) {
      final isLightMode = prefs.getBool(key) ?? false;
      final curBrightness = isLightMode ? Brightness.light : Brightness.dark;
      if (curBrightness == value) return;
      prefs.setBool(key, !isLightMode);
      notifyListeners();
    });
  }
}
