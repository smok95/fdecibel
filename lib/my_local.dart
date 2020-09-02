import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyLocal {
  MyLocal(this.locale);
  final Locale locale;

  static MyLocal of(BuildContext context) {
    return Localizations.of<MyLocal>(context, MyLocal);
  }

  static Map<String, Map<String, String>> _values = {
    'en': {
      'app info': 'About this app',
      'average': 'AVG',
      'copy': 'Copy',
      'dark mode': 'Dark Mode',
      'decibel0 example': 'Threshold of hearing',
      'decibel10 example': 'Breathing',
      'decibel20 example': 'Leaves rustling',
      'decibel30 example': 'Whisper',
      'decibel40 example': 'Quiet library',
      'decibel50 example': 'Moderate rainfall',
      'decibel60 example': 'Normal conversation',
      'decibel70 example': 'Traffic, Vacuums',
      'decibel80 example': 'Alarm clocks',
      'decibel90 example': 'Hair dryers, Lawnmowers',
      'decibel100 example': 'Subway train',
      'decibel110 example': 'Car horns, Concerts',
      'decibel120 example': 'Jet planes(during take off)',
      'error': 'Error',
      'flashlight': 'Flashlight',
      'google url': 'www.google.com',
      'keep the device awake': 'Keep the device awake',
      'keep the screen on': 'Keep the screen on',
      'maximum': 'MAX',
      'minimum': 'MIN',
      'more apps': 'More apps',
      'open': 'OPEN',
      'open settings': 'OPEN SETTINGS',
      'pause': 'Pause',
      'permission denied': 'Permission denied',
      'please allow permission':
          'Necessary permissions are denied. Please allow in Settings.',
      'rate review': 'Rate 5 stars',
      'resume': 'Resume',
      'reset': 'Reset',
      'scan result': 'Scan Result',
      'screenshot': 'Screenshot',
      'screenshot saved': 'Screenshot saved',
      'search': 'Search',
      'settings': 'Settings',
      'share': 'Share',
      'share app': 'Share App',
      'show example noise level': 'Show the example noise level',
      'title': 'Sound Meter',
      'vibrate': 'Vibrate',
    },
    'ko': {
      'app info': '앱 정보',
      'average': '평균',
      'copy': '복사',
      'dark mode': '야간 모드',
      'decibel0 example': '가청한계',
      'decibel10 example': '',
      'decibel20 example': '낙엽 스치는 소리',
      'decibel30 example': '속삭이는 소리',
      'decibel40 example': '조용한 도서관',
      'decibel50 example': '비내리는 소리, 조용한 대화',
      'decibel60 example': '일반적인 사무실 또는 대화소리',
      'decibel70 example': '전화벨, 시끄러운 사무실',
      'decibel80 example': '지하철의 차내소음, 피아노 소리',
      'decibel90 example': '고함소리, 소음이 심한 공장',
      'decibel100 example': '열차 통화시 철도변 소음, 공장내부',
      'decibel110 example': '자동차의 경적소음, 사이렌소리',
      'decibel120 example': '전투기의 이착륙소음, 폭죽소리',
      'error': '오류',
      'flashlight': '손전등',
      'google url': 'www.google.co.kr',
      'keep the device awake': '기기를 켜진 상태로 유지',
      'keep the screen on': '화면을 켜진 상태로 유지',
      'maximum': '최대',
      'minimum': '최소',
      'more apps': '다른 앱 보기',
      'open': '열기',
      'open settings': '설정 열기',
      'pause': '일시정지',
      'permission denied': '권한 없음',
      'please allow permission': '권한이 없어 해당 기능을 사용할 수 없습니다. 앱 설정에서 권한을 허용해주세요.',
      'rate review': '별점주기',
      'resume': '재시작',
      'reset': '초기화',
      'scan result': '스캔 결과',
      'screenshot': '화면캡쳐',
      'screenshot saved': '화면캡쳐 성공',
      'search': '검색',
      'settings': '설정',
      'share': '공유',
      'share app': '앱 공유하기',
      'show example noise level': '소음수준 비교정보 표시',
      'title': '소음 측정기',
      'vibrate': '진동 알림',
    },
  };

  String text(String name) {
    return _values[locale.languageCode][name];
  }
}

class MyLocalDelegate extends LocalizationsDelegate<MyLocal> {
  const MyLocalDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<MyLocal> load(Locale locale) {
    // Returunig a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of MyLocal.
    return SynchronousFuture<MyLocal>(MyLocal(locale));
  }

  @override
  bool shouldReload(MyLocalDelegate old) => false;
}
