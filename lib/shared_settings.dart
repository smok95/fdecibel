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

  // 화면 켜진 상태 유지
  Future<bool> get keepTheScreenOn async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('keepTheScreenOn') ?? true;
  }

  void changeKeepTheScreenOn(bool value) {
    final key = 'keepTheScreenOn';
    SharedPreferences.getInstance().then((prefs) {
      final current = prefs.getBool(key) ?? true;
      if (current == value) return;
      prefs.setBool(key, value).then((success) {
        print('"$key" save result: $success');
        if (success) notifyListeners();
      });
    });
  }

  /// 소음수준 비교정보 표시
  Future<bool> get showExampleNoiseLevel async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showExampleNoiseLevel') ?? true;
  }

  void changeShowExampleNoiseLevel(bool value) {
    final key = 'showExampleNoiseLevel';
    SharedPreferences.getInstance().then((prefs) {
      final current = prefs.getBool(key) ?? false;
      if (current == value) return;
      prefs.setBool(key, value).then((success) {
        print('"$key" save result: $success');
        if (success) notifyListeners();
      });
    });
  }
}
