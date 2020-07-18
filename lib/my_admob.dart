import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:admob_flutter/admob_flutter.dart';

class MyAdmob {
  /// {@template firebase_admob.testAdUnitId}
  /// A platform-specific AdMob test ad unit ID. This ad unit
  /// has been specially configured to always return test ads, and developers
  /// are encouraged to use it while building and testing their apps.
  /// {@endtemplate}
  /// {@macro firebase_admob.testAdUnitId}
  /// [package:firebase_admob/firebase_admob.dart]에서 발췌함.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get appId => "ca-app-pub-0843163070431190~6462477826";
  static String get unitId {    
    return Foundation.kDebugMode
        ? testAdUnitId
        : 'ca-app-pub-0843163070431190/5733873607';
  }

  /// Admob 배너 생성
  static AdmobBanner createAdmobBanner() {
    return AdmobBanner(
      adUnitId: unitId,
      adSize: AdmobBannerSize.LARGE_BANNER,
    );
  }

  static void initialize() {
    Admob.initialize(appId);
  }

  /// 화면크기에 맞는 배너 높이값을 구한다.
  double getSmartBannerHeight(BuildContext context) {
    // 참고페이지 : https://stackoverflow.com/questions/50935918/how-to-get-banner-size-of-smart-banner

    MediaQueryData mediaScreen = MediaQuery.of(context);
    double deviceHeight = mediaScreen.orientation == Orientation.portrait
        ? mediaScreen.size.height
        : mediaScreen.size.width;

    if (deviceHeight <= 400.0) {
      return 32.0;
    } else if (deviceHeight > 720.0) {
      return 90.0;
    } else {
      return 50.0;
    }
  }
}
