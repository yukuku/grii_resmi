import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import 'calendar.dart';
import 'song.dart';

final SentryClient sentry = SentryClient(dsn: 'https://4d1de035fe314db8b219e2f701a2181c:ec106d4c1ff34a229b2329ff249ec4df@sentry.io/223245');

main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details);
    final resp = await sentry.captureException(exception: details.exception, stackTrace: details.stack);
    print("sending crash from FlutterError: ${resp.isSuccessful}");
  };

  try {
    runApp(MyApp());
  } catch (error, stackTrace) {
    final resp = await sentry.captureException(exception: error, stackTrace: stackTrace);
    print("sending crash from try-catch: ${resp.isSuccessful}");
  }
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
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Aplikasi GRII',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Yuku',
        ),
      ],
    ),
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
