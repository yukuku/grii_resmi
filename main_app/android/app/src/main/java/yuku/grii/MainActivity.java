package yuku.grii;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.net.Uri;
import android.util.Log;
import androidx.annotation.NonNull;
import com.thnkld.kidung.app.RenderedImageCache;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterMain;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

public class MainActivity extends FlutterActivity {
	static final String TAG = MainActivity.class.getSimpleName();
	private static final String CHANNEL = "com.thnkld.kidung.app/externalImageOpener";

	@Override
	public void configureFlutterEngine(@NonNull final FlutterEngine flutterEngine) {
		super.configureFlutterEngine(flutterEngine);

		new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
			if (call.method.equals("openImageExternally")) {
				final String assetName = call.argument("assetName");
				if (assetName == null) {
					result.error("no assetName", null, null);
					return;
				}

				final String assetLookupKey = FlutterMain.getLookupKeyForAsset(assetName);

				try (final InputStream is = getAssets().open(assetLookupKey)) {
					final Bitmap ink = BitmapFactory.decodeStream(is);

					// make white canvas and draw and share
					final Bitmap bitmap = Bitmap.createBitmap(ink.getWidth(), ink.getHeight(), Bitmap.Config.RGB_565);
					final Canvas canvas = new Canvas(bitmap);

					canvas.drawColor(Color.WHITE);
					canvas.drawBitmap(ink, 0, 0, null);

					Log.d(TAG, "Encoding");
					final ByteArrayOutputStream buf = new ByteArrayOutputStream(100000);
					bitmap.compress(Bitmap.CompressFormat.PNG, 100, buf);

					final String key = UUID.randomUUID().toString();
					RenderedImageCache.INSTANCE.put(key, buf.toByteArray());

					final Uri uri = Uri.parse("content://com.thnkld.kidung.external_image_opener_provider/" + key);
					final Intent intent = new Intent(Intent.ACTION_VIEW)
						.setDataAndType(uri, "image/png");

					Log.d(TAG, "Opening uri " + uri);
					startActivity(Intent.createChooser(intent, "Open using"));

				} catch (IOException e) {
					result.error("EXCEPTION", e.getClass().getSimpleName(), e);
				}

				Log.d(TAG, "Hore!!!");
				result.success("Hore");
			} else {
				result.notImplemented();
			}
		});
	}
}
