package com.bigsmall.rnshaker;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import android.content.Context;
import android.hardware.SensorManager;
import android.app.Activity;
import android.net.Uri;
import android.os.Build;
import android.view.View;
import android.graphics.Bitmap;
import java.io.File;
import java.io.FileOutputStream;

public class ShakerModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private final CustomShakeDetector mShakeDetector;

    public ShakerModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        mShakeDetector = new CustomShakeDetector(new CustomShakeDetector.ShakeListener() {
            @Override
            public void onShake() {
                sendEvent(reactContext, "ShakerShakeEvent", null);
            }
        }, 1);

        mShakeDetector.start((SensorManager) reactContext.getSystemService(Context.SENSOR_SERVICE));

    }

    @Override
    public String getName() {
        return "Shaker";
    }

    private void sendEvent(ReactContext reactContext, String eventName, WritableMap params) {
        if (reactContext.hasActiveCatalystInstance()) {
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
        }
    }

    @ReactMethod
    public void takeScreenshot(Promise promise) {
        try {
            final Activity activity = getCurrentActivity();
            View v = activity.getWindow().getDecorView().findViewById(android.R.id.content);
            File temp = File.createTempFile("screenshot", "jpg");

            temp.deleteOnExit();

            v.setDrawingCacheEnabled(true);
            v.buildDrawingCache(true);

            Bitmap b = Bitmap.createBitmap(v.getDrawingCache());
            v.setDrawingCacheEnabled(false);

            FileOutputStream stream = new FileOutputStream(temp);

            b.compress(Bitmap.CompressFormat.JPEG, 70, stream);

            stream.close();

            String manufacturer = Build.MANUFACTURER;
            String model = Build.MODEL;

            int[] location = new int[2];
            v.getLocationOnScreen(location);

            WritableMap map = Arguments.createMap();

            map.putString("uri", Uri.fromFile(temp).toString());
            map.putString("manufacturer", manufacturer);
            map.putString("model", model);
            map.putInt("positionScreenX", location[0]);
            map.putInt("positionScreenY", location[1]);

            promise.resolve(map);
        } catch (final Throwable ex) {
            promise.reject("FAILED_SCREENSHOT", "Error screenshoting.");
        }
    }
}
