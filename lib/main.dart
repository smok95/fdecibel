import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:admob_flutter/admob_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jk/flutter_jk.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'decibel_view/decibel_example.dart';
import 'shared_settings.dart';
import 'my_admob.dart';
import 'ticker_clock.dart';
import 'decibel_stats.dart';
import 'my_themedata.dart';
import 'decibel_view/decibel_view.dart';
import 'settings_page.dart';
import 'my_private_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;

  SyncfusionLicense.registerLicense(MyPrivateData.syncFusionLicense);

  /// AdMob  초기화
  MyAdmob.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final sharedSettings = SharedSettings();

    // Prevent device orientation changes.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final messages = GetxMessages();
    messages.add('en_US', 'title', 'Sound Meter');
    messages.add('ko_KR', 'title', '소음 측정기');
    messages.add('pl_PL', 'title', 'miernik dźwięku');

    return FutureBuilder<Brightness>(
        future: sharedSettings.brightness,
        initialData: Brightness.dark,
        builder: (BuildContext context, AsyncSnapshot<Brightness> snapshot) {
          final brightness = snapshot.hasData ? snapshot.data : Brightness.dark;
          final theme = brightness == Brightness.dark
              ? MyThemeData.dark()
              : MyThemeData.light();

          final currentLocale = ui.window.locale;
          return GetMaterialApp(
              translations: messages,
              locale: currentLocale,
              fallbackLocale: Locale('en', 'US'),
              theme: theme,
              home: MultiProvider(providers: [
                ChangeNotifierProvider(create: (_) => DecibelStats()),
                ChangeNotifierProvider(create: (_) => SharedSettings()),
              ], child: MyHomePage()));
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _admobBanner = MyAdmob.createAdmobBanner();
    _start();

    SharedSettings().showExampleNoiseLevel.then((value) {
      print('showExampleNoiseLevel value=$value');
      if (_showExampleNoiseLevel != value) {
        setState(() {
          _showExampleNoiseLevel = value;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    print('build call');

    return Scaffold(
      backgroundColor: backColor,
      //appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: Screenshot(
            controller: _screenshotController,

            /// Card로 warp한 이유는 screencapture시 light theme에서 배경이 검은색으로 표시되어
            /// 제대로된 캡쳐가 되지 않아 Card로 감쌈.
            /// https://github.com/SachinGanesh/screenshot/issues/17
            child: Card(
                color: backColor,
                shadowColor: backColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _admobBanner,
                    Spacer(),
                    TickerClock(languageCode: Get.locale?.languageCode),
                    Spacer(),
                    DecibelView(),
                    _showExampleNoiseLevel
                        ? Flexible(child: _buildDecibelLevelInfo(), flex: 5)
                        : Spacer(flex: 5),
                  ],
                )),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildDecibelLevelInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: DecibelExample()),
        SizedBox(width: 90, height: double.infinity)
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final labelBackColor = Get.isDarkMode ? Colors.grey[800] : Colors.white;
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      overlayColor: Colors.black,
      children: [
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.settings),
            label: 'settings'.tr,
            onTap: _onTapSettings),
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.autorenew),
            label: 'reset'.tr,
            onTap: _onTapReset),
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.photo_camera),
            label: 'screenshot'.tr,
            onTap: _onTapScreenshot),
      ],
    );
  }

  void onData(NoiseReading noiseReading) {
    //if (!_isAppRunning) return;

    final decibel = noiseReading.meanDecibel;

    final now = DateTime.now();

    // 0.2초 간격으로 기록
    if (_lastMeasureTime == null ||
        now.difference(_lastMeasureTime).inMilliseconds > _interval) {
      _lastMeasureTime = now;
    } else {
      return;
    }

    context.read<DecibelStats>().update(decibel, _duration);
  }

  void _start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);

      final screenOn = await SharedSettings().keepTheScreenOn;
      Screen.keepOn(screenOn);
    } catch (exception) {
      print(exception);
    }
  }

  void _stop() {
    if (_noiseSubscription != null) {
      _noiseSubscription.cancel();
      _noiseSubscription = null;
    }
  }

  void _saveImage(File image) async {
    final result = await ImageGallerySaver.saveImage(image.readAsBytesSync());
    print('capture ok, ${result}');
    String filePath = Uri.decodeComponent(result);
    filePath = filePath.replaceAll('file://', '');

    Get.snackbar('screenshot saved'.tr, filePath,
        snackPosition: SnackPosition.BOTTOM,
        mainButton: FlatButton(
            onPressed: () {
              OpenFile.open(filePath);
            },
            child: Text('open'.tr)));
  }

  /// 저장소 접근권한 체크 및 요청
  Future<PermissionStatus> _checkStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      return await Permission.storage.request();
    }

    return status;
  }

  void _onTapScreenshot() async {
    final status = await _checkStoragePermission();
    if (!status.isGranted) {
      Get.snackbar('permission denied'.tr, 'please allow permission'.tr,
          snackPosition: SnackPosition.BOTTOM,
          mainButton: FlatButton(
              onPressed: () {
                AppSettings.openAppSettings();
              },
              child: Text('open settings'.tr)));
      return;
    }

    print('do screenshot');

    _screenshotController
        .capture(
            pixelRatio: ui.window.devicePixelRatio,
            delay: Duration(milliseconds: 10))
        .then((value) {
      _saveImage(value);
    }).catchError((error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  void _onTapReset() {
    context.read<DecibelStats>().reset();
  }

  void _onTapSettings() async {
    Get.to(SettingsPage(
      keepTheScreenOn: await Screen.isKeptOn,
      showExampleNoiseLevel: _showExampleNoiseLevel,
      onToggleDarkMode: (darkMode) {
        final theme = darkMode ? MyThemeData.dark() : MyThemeData.light();
        context
            .read<SharedSettings>()
            .changeBrightness(darkMode ? Brightness.dark : Brightness.light);

        Get.changeThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
        Get.changeTheme(theme);

        Future.delayed(Duration(milliseconds: 500), () {
          //setState(() {});
          Get.forceAppUpdate();
        });
      },
      onSettingChange: (name, value) async {
        if (name == 'keep the screen on') {
          final screenOn = value as bool;

          final current = await Screen.isKeptOn;

          if (screenOn != current) {
            Screen.keepOn(screenOn);

            context.read<SharedSettings>().changeKeepTheScreenOn(screenOn);
          }
        } else if (name == 'show example noise level') {
          final newValue = value as bool;

          if (newValue == _showExampleNoiseLevel) return;

          context.read<SharedSettings>().changeShowExampleNoiseLevel(newValue);
          setState(() {
            _showExampleNoiseLevel = newValue;
          });
        }
      },
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppRunning = state == AppLifecycleState.resumed;
    print('state = $state');

    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  bool _isRecoding = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter = NoiseMeter();

  // 측정 간격(msec)
  final int _interval = 200;

  // 라인차트 표시 구간 (단위:초)
  int _duration = 60;

  // 마지막 측정 시각
  DateTime _lastMeasureTime;

  bool _isAppRunning = true;

  ScreenshotController _screenshotController = ScreenshotController();
  AdmobBanner _admobBanner;
  bool _showExampleNoiseLevel = false;
}
