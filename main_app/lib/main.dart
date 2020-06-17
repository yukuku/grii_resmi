import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'calendar.dart';
import 'flavors.dart';
import 'song.dart';

main() async {
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
    CalendarHome(),
    SongsHome(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Jadwal'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            title: Text('Lagu'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text('Tentang'),
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
