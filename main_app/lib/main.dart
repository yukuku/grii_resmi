import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grii_resmi/colors.dart';

import 'info.dart';
import 'pillar.dart';
import 'song.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MyApp());
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
