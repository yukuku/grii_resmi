import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum Status {
  stopped,
  loading,
  playing,
  paused,
  error,
}

class SimpleAudioPlayer {
  static MethodChannel _channel = new MethodChannel('simple_audio_player')
    ..setMethodCallHandler(callHandler);

  static final durationNotifier = new ValueNotifier<Duration>(null);
  static final positionNotifier = new ValueNotifier<Duration>(null);
  static final completeNotifier = new ValueNotifier<bool>(false);
  static final errorNotifier = new ValueNotifier<String>(null);
  static final statusNotifier = new ValueNotifier<Status>(Status.stopped);

  static Future<bool> setDataSourceUrl(String url) async {
    final res = await _channel.invokeMethod("setDataSourceUrl", url);
    if (res) {
      statusNotifier.value = Status.loading;
    }
    return res;
  }

  static Future<bool> setDataSourceLocal(String path) async {
    final res = await _channel.invokeMethod("setDataSourceLocal", path);
    if (res) {
      statusNotifier.value = Status.loading;
    }
    return res;
  }

  static Future<bool> play() async {
    final res = await _channel.invokeMethod("play");
    if (res) {
      statusNotifier.value = Status.playing;
    }
    return res;
  }

  static Future<bool> pause() async {
    final res = await _channel.invokeMethod('pause');
    if (res) {
      statusNotifier.value = Status.paused;
    }
    return res;
  }

  static Future<bool> resume() async {
    final res = await _channel.invokeMethod('resume');
    if (res) {
      statusNotifier.value = Status.playing;
    }
    return res;
  }

  static Future<bool> stop() async {
    final res = await _channel.invokeMethod('stop');
    if (res) {
      statusNotifier.value = Status.stopped;
    }
    return res;
  }

  static Future<bool> dispose() async {
    final res = await _channel.invokeMethod('dispose');
    if (res) {
      statusNotifier.value = Status.stopped;
    }
    return res;
  }

  static Future<bool> seek(Duration duration) async {
    return _channel.invokeMethod('seek', duration.inMilliseconds);
  }

  static Future<Duration> tell() async {
    final int ms = await _channel.invokeMethod('tell');
    return new Duration(milliseconds: ms);
  }

  static Future<dynamic> callHandler(MethodCall call) async {
    switch (call.method) {
      case "onStatus":
        final String name = call.arguments;
        statusNotifier.value = Status.values.singleWhere((v) => v.toString().endsWith(".$name"));
        break;

      case "onDuration":
        final duration = new Duration(milliseconds: call.arguments);
        durationNotifier.value = duration;
        break;

      case "onPosition":
        final duration = new Duration(milliseconds: call.arguments);
        positionNotifier.value = duration;
        break;

      case "onComplete":
        completeNotifier.value = call.arguments;
        break;

      case "onError":
        errorNotifier.value = call.arguments;
        break;

      default:
        print("Unknown method ${call.method}");
    }
  }
}
