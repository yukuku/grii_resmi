import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grii_resmi/colors.dart';
import 'package:package_info/package_info.dart';

import 'http_override.dart';
import 'info.dart';
import 'pillar.dart';
import 'song.dart';

Future<void> _setupHttpOverrides() async {
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();

  var useProxy = false;
  bool? isAndroid;

  if (!kIsWeb && Platform.isAndroid) {
    isAndroid = true;
    final androidInfo = await deviceInfo.androidInfo;
    if (kDebugMode) {
      print('Android MODEL is ${androidInfo.model}');
    }
    if (androidInfo.model == 'AOSP on IA Emulator' || androidInfo.model == 'Android SDK built for x86') {
      print('Will use proxy');
      useProxy = true;
    }
  }

  if (!kIsWeb && Platform.isIOS) {
    isAndroid = false;
    final iosInfo = await deviceInfo.iosInfo;
    if (kDebugMode) {
      print('Ios MODEL is ${iosInfo.name}');
    }
    if (iosInfo.isPhysicalDevice != true) {
      print('Will use proxy');
      useProxy = true;
    }
  }

  HttpOverrides.global = YukuHttpOverrides(packageInfo.version, useProxy, isAndroid);
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await runZonedGuarded<Future<void>>(() async {
    await _setupHttpOverrides();

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    runApp(MyApp());
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRII',
      theme: griiThemeLight,
      darkTheme: griiThemeDark,
      themeMode: ThemeMode.dark,
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  MainWidget({Key? key}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Container(),
    SongsHome(),
    PillarHome(),
    InfoHome(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.video, size: 20),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.music, size: 20),
            label: 'KRI',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bookReader, size: 20),
            label: 'PILLAR',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.info, size: 20),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}

void recordGenericError(dynamic error, {StackTrace? stack, String? reason}) {
  FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: reason ?? 'Generic error',
    printDetails: true,
  );
}
