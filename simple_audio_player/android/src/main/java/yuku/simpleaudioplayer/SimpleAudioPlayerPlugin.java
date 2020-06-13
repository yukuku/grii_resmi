package yuku.simpleaudioplayer;

import android.media.MediaPlayer;
import android.os.Handler;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.IOException;

/**
 * SimpleAudioPlayerPlugin
 */
public class SimpleAudioPlayerPlugin implements MethodCallHandler {
  static final String TAG = SimpleAudioPlayerPlugin.class.getSimpleName();

  final MethodChannel channel;
  final Handler handler = new Handler();

  final MediaPlayer.OnPreparedListener prepared = new MediaPlayer.OnPreparedListener() {
    @Override
    public void onPrepared(final MediaPlayer mp) {
      channel.invokeMethod("onStatus", "paused");
      channel.invokeMethod("onDuration", mp.getDuration());
      channel.invokeMethod("onPosition", 0);
      channel.invokeMethod("onComplete", false);
      channel.invokeMethod("onError", null);

      handler.post(handlerCallback);
    }
  };

  final MediaPlayer.OnCompletionListener completed = new MediaPlayer.OnCompletionListener() {
    @Override
    public void onCompletion(final MediaPlayer mp) {
      channel.invokeMethod("onStatus", "paused");
      channel.invokeMethod("onComplete", true);
    }
  };

  final MediaPlayer.OnErrorListener error = new MediaPlayer.OnErrorListener() {
    @Override
    public boolean onError(final MediaPlayer mp, final int what, final int extra) {
      channel.invokeMethod("onStatus", "error");
      channel.invokeMethod("onError", what + "/" + extra);
      return true;
    }
  };

  public SimpleAudioPlayerPlugin(final MethodChannel channel) {
    this.channel = channel;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_audio_player");
    channel.setMethodCallHandler(new SimpleAudioPlayerPlugin(channel));
  }

  MediaPlayer mp = new MediaPlayer();
  final Runnable handlerCallback = new Runnable() {
    @Override
    public void run() {
      channel.invokeMethod("onPosition", mp.getCurrentPosition());

      handler.removeCallbacks(this);
      handler.postDelayed(this, 100);
    }
  };

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "setDataSourceUrl":
      case "setDataSourceLocal":
        try {
          handler.removeCallbacks(handlerCallback);
          mp.release();
          ////////////
          mp = new MediaPlayer();
          mp.setOnPreparedListener(prepared);
          mp.setOnCompletionListener(completed);
          mp.setOnErrorListener(error);
          mp.setDataSource(call.<String>arguments());
          mp.prepareAsync();
          result.success(true);
        } catch (IllegalStateException e) {
          Log.e(TAG, "setDataSourceUrl() illegal state", e);
          result.success(false);
        } catch (IOException e) {
          Log.e(TAG, "setDataSourceUrl() io exc", e);
          result.success(false);
        }
        break;

      case "play":
        try {
          mp.start();
          result.success(true);
        } catch (IllegalStateException e) {
          Log.e(TAG, "play() illegal state", e);
          result.success(false);
        }
        break;

      case "pause":
        try {
          mp.pause();
          result.success(true);
        } catch (IllegalStateException e) {
          Log.e(TAG, "pause() illegal state", e);
          result.success(false);
        }
        break;

      case "resume":
        try {
          mp.start();
          result.success(true);
        } catch (IllegalStateException e) {
          Log.e(TAG, "resume() illegal state", e);
          result.success(false);
        }
        break;

      case "stop":
        try {
          mp.stop();
          result.success(true);
        } catch (IllegalStateException e) {
          Log.e(TAG, "stop() illegal state", e);
          result.success(false);
        }
        break;

      case "dispose":
        handler.removeCallbacks(handlerCallback);
        mp.release();
        result.success(true);
        break;

      case "seek":
        try {
          mp.seekTo(call.<Integer>arguments());
          channel.invokeMethod("onComplete", false);
          result.success(true);
        } catch (IllegalStateException e) {
          Log.e(TAG, "seek() illegal state", e);
          result.success(false);
        }
        break;

      case "tell":
        try {
          final int ms = mp.getCurrentPosition();
          result.success(ms);
        } catch (IllegalStateException e) {
          Log.e(TAG, "tell() illegal state", e);
          result.success(null);
        }
        break;

      default:
        result.notImplemented();
        break;
    }
  }
}
