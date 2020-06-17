import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'calendar.dart';
import 'flavors.dart';
import 'notice.dart';
import 'song.dart';

main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRII',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  MainWidget({Key key}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    NoticesHome(),
    CalendarHome(),
    SongsHome(),
    AboutHome(),
    AboutHome(),
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
            icon: Icon(Icons.rss_feed),
            title: Text('Berita'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Kegiatan'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            title: Text('Lagu'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            title: Text('Pillar'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text('Info'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}

class AboutHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Aplikasi GRII',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text('Yuku'),
        SizedBox(height: 32.0),
        RaisedButton(
          onPressed: () async {
            var version = '';
            if (!kIsWeb) {
              final pi = await PackageInfo.fromPlatform();
              version = "${pi.version} (${pi.buildNumber})";
            }
            version += ' $FLAVOR';

            showAboutDialog(
              context: context,
              applicationIcon: Image(image: AssetImage('assets/drawable/ic_launcher.png')),
              applicationVersion: version,
            );
          },
          child: Text('Info versi'),
        )
      ],
    );
  }
}
