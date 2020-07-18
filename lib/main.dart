import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'my_admob.dart';
import 'my_local.dart';
import 'ticker_clock.dart';
import 'decibel_stats.dart';
import 'my_themedata.dart';
import 'decibel_view/decibel_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;

  SyncfusionLicense.registerLicense(
      'NT8mJyc2IWhia31ifWN9ZmpoYmF8YGJ8ampqanNiYmlmamlmanMDHmg3Yz0pIGNjPRM0PjI6P30wPD4=');

  /// AdMob  초기화
  MyAdmob.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Prevent device orientation changes.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
        onGenerateTitle: (BuildContext context) =>
            MyLocal.of(context).text('title'),
        localizationsDelegates: [
          const MyLocalDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en', ''), const Locale('ko', '')],
        theme: MyThemeData.dark(),
        home: MultiProvider(
            providers: [ChangeNotifierProvider(create: (_) => DecibelStats())],
            child: MyHomePage()));
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
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backColor = _checkIfDarkModeEnabled() ? Colors.black : null;
    final lo = MyLocal.of(context);

    return Scaffold(
      backgroundColor: backColor,
      //appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: Screenshot(
            controller: _screenshotController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                TickerClock(),
                Spacer(),
                DecibelView(),
                MyAdmob.createAdmobBanner(),
                Spacer(flex: 5),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final lo = MyLocal.of(context);
    final labelBackColor =
        _checkIfDarkModeEnabled() ? Colors.grey[800] : Colors.white;
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      overlayColor: Colors.black,
      children: [
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.autorenew),
            label: lo.text('reset'),
            onTap: _onPressedReset),
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.photo_camera),
            label: lo.text('screenshot'),
            onTap: _onPressedScreenshot),
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

  bool _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    return theme?.brightness == Brightness.dark;
  }

  void _saveImage(File image) async {
    final result = await ImageGallerySaver.saveImage(image.readAsBytesSync());
    print('capture ok, ${result}');
    final lo = MyLocal.of(context);
    String filePath = Uri.decodeComponent(result);
    filePath = filePath.replaceAll('file://', '');

    final title = lo.text('screenshot saved');
    Get.snackbar(title, filePath,
        mainButton: FlatButton(
            onPressed: () {
              OpenFile.open(filePath);
            },
            child: Text(lo.text('open'))));
  }

  /// 저장소 접근권한 체크 및 요청
  Future<PermissionStatus> _checkStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      return await Permission.storage.request();
    }

    return status;
  }

  void _onPressedScreenshot() async {
    final lo = MyLocal.of(context);
    final status = await _checkStoragePermission();
    if (!status.isGranted) {
      Get.snackbar(
          lo.text('permission denied'), lo.text('please allow permission'),
          mainButton: FlatButton(
              onPressed: () {
                AppSettings.openAppSettings();
              },
              child: Text(lo.text('open settings'))));
      return;
    }

    print('do screenshot');

    _screenshotController
        .capture(
            pixelRatio: window.devicePixelRatio,
            delay: Duration(milliseconds: 10))
        .then((value) {
      _saveImage(value);
    }).catchError((error) {
      Get.snackbar('Error', error.toString());
    });
  }

  void _onPressedReset() {
    context.read<DecibelStats>().reset();
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
}
