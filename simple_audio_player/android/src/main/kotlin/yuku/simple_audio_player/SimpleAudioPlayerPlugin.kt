package yuku.simple_audio_player

import android.media.MediaPlayer
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException

private const val TAG = "SimpleAudioPlayerPlugin"

class SimpleAudioPlayerPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    val handler = Handler()

    private val prepared = MediaPlayer.OnPreparedListener { mp ->
        channel.invokeMethod("onStatus", "paused")
        channel.invokeMethod("onDuration", mp.duration)
        channel.invokeMethod("onPosition", 0)
        channel.invokeMethod("onComplete", false)
        channel.invokeMethod("onError", null)
        handler.post(handlerCallback)
    }

    private val completed = MediaPlayer.OnCompletionListener {
        channel.invokeMethod("onStatus", "paused")
        channel.invokeMethod("onComplete", true)
    }

    private val error = MediaPlayer.OnErrorListener { _, what, extra ->
        channel.invokeMethod("onStatus", "error")
        channel.invokeMethod("onError", "$what/$extra")
        true
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "simple_audio_player")
        channel.setMethodCallHandler(this)
    }

    var mp = MediaPlayer()
    private val handlerCallback = object : Runnable {
        override fun run() {
            channel.invokeMethod("onPosition", mp.currentPosition)
            handler.removeCallbacks(this)
            handler.postDelayed(this, 100)
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setDataSourceUrl", "setDataSourceLocal" -> try {
                handler.removeCallbacks(handlerCallback)
                mp.release()
                ////////////
                mp = MediaPlayer()
                mp.setOnPreparedListener(prepared)
                mp.setOnCompletionListener(completed)
                mp.setOnErrorListener(error)
                mp.setDataSource(call.arguments<String>())
                mp.prepareAsync()
                result.success(true)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "setDataSourceUrl() illegal state", e)
                result.success(false)
            } catch (e: IOException) {
                Log.e(TAG, "setDataSourceUrl() io exc", e)
                result.success(false)
            }
            "play" -> try {
                mp.start()
                result.success(true)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "play() illegal state", e)
                result.success(false)
            }
            "pause" -> try {
                mp.pause()
                result.success(true)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "pause() illegal state", e)
                result.success(false)
            }
            "resume" -> try {
                mp.start()
                result.success(true)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "resume() illegal state", e)
                result.success(false)
            }
            "stop" -> try {
                mp.stop()
                result.success(true)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "stop() illegal state", e)
                result.success(false)
            }
            "dispose" -> {
                handler.removeCallbacks(handlerCallback)
                mp.release()
                result.success(true)
            }
            "seek" -> try {
                mp.seekTo(call.arguments())
                channel.invokeMethod("onComplete", false)
                result.success(true)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "seek() illegal state", e)
                result.success(false)
            }
            "tell" -> try {
                val ms = mp.currentPosition
                result.success(ms)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "tell() illegal state", e)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


}
