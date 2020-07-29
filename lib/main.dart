import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:fdecibel/shared_settings.dart';
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
import 'package:share/share.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:url_launcher/url_launcher.dart';

import 'my_admob.dart';
import 'my_local.dart';
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

    return FutureBuilder<Brightness>(
        future: sharedSettings.brightness,
        initialData: Brightness.dark,
        builder: (BuildContext context, AsyncSnapshot<Brightness> snapshot) {
          final brightness = snapshot.hasData ? snapshot.data : Brightness.dark;
          final theme = brightness == Brightness.dark
              ? MyThemeData.dark()
              : MyThemeData.light();

          return GetMaterialApp(
              onGenerateTitle: (BuildContext context) =>
                  MyLocal.of(context).text('title'),
              localizationsDelegates: [
                const MyLocalDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en', ''),
                const Locale('ko', '')
              ],
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
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backColor = Get.isDarkMode ? Colors.black : Colors.white;
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
                    Spacer(),
                    TickerClock(),
                    Spacer(),
                    DecibelView(),
                    MyAdmob.createAdmobBanner(),
                    Spacer(flex: 5),
                  ],
                )),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final lo = MyLocal.of(context);
    final labelBackColor = Get.isDarkMode ? Colors.grey[800] : Colors.white;
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      overlayColor: Colors.black,
      children: [
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.settings),
            label: lo.text('settings'),
            onTap: _onTapSettings),
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.autorenew),
            label: lo.text('reset'),
            onTap: _onTapReset),
        SpeedDialChild(
            labelBackgroundColor: labelBackColor,
            child: Icon(Icons.photo_camera),
            label: lo.text('screenshot'),
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

  void _onTapScreenshot() async {
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

  void _onTapReset() {
    context.read<DecibelStats>().reset();
  }

  void _onTapSettings() {
    Get.to(SettingsPage(
      onToggleDarkMode: (darkMode) {
        final darkMode = !Get.isDarkMode;
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
        if (name == 'share app') {
          Share.share(MyPrivateData.playStoreUrl);
        } else if (name == 'rate review') {
          final playstoreUrl = MyPrivateData.playStoreUrl;
          if (await canLaunch(playstoreUrl)) {
            await launch(playstoreUrl);
          }
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
}
