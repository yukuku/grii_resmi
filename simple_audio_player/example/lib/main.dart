import 'package:flutter/material.dart';
import 'package:simple_audio_player/simple_audio_player.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _statusbar = 'Unknown';

  @override
  initState() {
    super.initState();

    SimpleAudioPlayer.statusNotifier.addListener(somethingChanged);
    SimpleAudioPlayer.durationNotifier.addListener(somethingChanged);
    SimpleAudioPlayer.positionNotifier.addListener(somethingChanged);
    SimpleAudioPlayer.completeNotifier.addListener(somethingChanged);
    SimpleAudioPlayer.errorNotifier.addListener(somethingChanged);
  }


  @override
  dispose() {
    super.dispose();

    SimpleAudioPlayer.statusNotifier.removeListener(somethingChanged);
    SimpleAudioPlayer.durationNotifier.removeListener(somethingChanged);
    SimpleAudioPlayer.positionNotifier.removeListener(somethingChanged);
    SimpleAudioPlayer.completeNotifier.removeListener(somethingChanged);
    SimpleAudioPlayer.errorNotifier.removeListener(somethingChanged);
  }

  somethingChanged() {
    setState(() {
      _statusbar = "${SimpleAudioPlayer.statusNotifier.value.toString()} ${SimpleAudioPlayer.positionNotifier.value}/${SimpleAudioPlayer.durationNotifier.value} ${SimpleAudioPlayer.completeNotifier.value} ${SimpleAudioPlayer.errorNotifier.value}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.purple),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Column(
          children: <Widget>[
            new Text(_statusbar),
            
            new FlatButton(onPressed: () {
              SimpleAudioPlayer.setDataSourceUrl("http://files.bibleforandroid.com/addon/audio/songs/v2/JB_22.mp3");
            }, child: new Text("setDataSourceUrl")),

            new FlatButton(onPressed: () {
              SimpleAudioPlayer.play();
            }, child: new Text("play")),

            new FlatButton(onPressed: () {
              SimpleAudioPlayer.pause();
            }, child: new Text("pause")),

            new FlatButton(onPressed: () {
              SimpleAudioPlayer.resume();
            }, child: new Text("resume")),

            new FlatButton(onPressed: () {
              SimpleAudioPlayer.dispose();
            }, child: new Text("dispose")),

            new FlatButton(onPressed: () {
              SimpleAudioPlayer.tell().then((now) {
                print("now is: $now");
                SimpleAudioPlayer.seek(now + const Duration(seconds: 5));
              });
            }, child: new Text("seek +5")),
          ],
        ),
      ),
    );
  }
}
