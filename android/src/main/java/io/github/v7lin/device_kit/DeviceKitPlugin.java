package io.github.v7lin.device_kit;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.database.ContentObserver;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresPermission;
import androidx.core.content.ContextCompat;

import java.net.NetworkInterface;
import java.util.Enumeration;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * DeviceKitPlugin
 */
public class DeviceKitPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
    private static final String FAKE_MAC_ADDRESS = "02:00:00:00:00:00";

    private Context applicationContext;
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private BrightnessObserver brightnessObserver;
    private EventChannel brightnessChangedEventChannel;
    private Activity activity;

    // --- FlutterPlugin

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "v7lin.github.io/device_kit");
        channel.setMethodCallHandler(this);
        brightnessChangedEventChannel = new EventChannel(binding.getBinaryMessenger(), "v7lin.github.io/device_kit#brightness_changed_event");
        brightnessObserver = new BrightnessObserver(binding.getApplicationContext());
        brightnessChangedEventChannel.setStreamHandler(brightnessObserver);
        applicationContext = binding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        brightnessChangedEventChannel.setStreamHandler(null);
        brightnessChangedEventChannel = null;
        if (brightnessObserver != null) {
            brightnessObserver.dispose();
            brightnessObserver = null;
        }
        applicationContext = null;
    }

    private static class BrightnessObserver implements EventChannel.StreamHandler {
        private final Context applicationContext;
        private final Handler mainHandler;
        private ContentObserver observer;

        public BrightnessObserver(Context applicationContext) {
            this.applicationContext = applicationContext;
            this.mainHandler = new Handler(Looper.getMainLooper());
        }
        // --- StreamHandler

        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            if (observer != null) {
                return;
            }
            observer = new ContentObserver(mainHandler) {
                @Override
                public void onChange(boolean selfChange) {
                    super.onChange(selfChange);
                    try {
                        final float brightness = Settings.System.getInt(applicationContext.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS) / 255.0f;
                        if (events != null) {
                            events.success(brightness);
                        }
                    } catch (Settings.SettingNotFoundException e) {
                        // ignore
                    }
                }
            };
            applicationContext.getContentResolver().registerContentObserver(Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS), false, observer);
        }

        @Override
        public void onCancel(Object arguments) {
            if (observer == null) {
                return;
            }
            applicationContext.getContentResolver().unregisterContentObserver(observer);
            observer = null;
        }

        public void dispose() {
            if (observer != null) {
                applicationContext.getContentResolver().unregisterContentObserver(observer);
                observer = null;
            }
            mainHandler.removeCallbacksAndMessages(null);
        }
    }

    // --- ActivityAware

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    // --- MethodCallHandler

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("getDeviceId".equals(call.method)) {
            String deviceId = null;
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                deviceId = getDeviceId();
            }
            if (TextUtils.isEmpty(deviceId)) {
                deviceId = null;
            }
            result.success(deviceId);
        } else if ("getMac".equals(call.method)) {
            String mac = null;
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                mac = getMacBySystemInterface();
                if (TextUtils.isEmpty(mac) || TextUtils.equals(mac, FAKE_MAC_ADDRESS)) {
                    mac = getMacByJavaAPI();
                }
            } else {
                mac = getMacByJavaAPI();
            }
            if (TextUtils.isEmpty(mac) || TextUtils.equals(mac, FAKE_MAC_ADDRESS)) {
                mac = null;
            }
            result.success(mac);
        } else if ("isCharging".equals(call.method)) {
            final Result resultRef = result;
            //noinspection deprecation
            new AsyncTask<String, String, Boolean>() {
                @Override
                protected Boolean doInBackground(String... strings) {
                    boolean isCharging = false;
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            final BatteryManager bm = (BatteryManager) applicationContext.getSystemService(Context.BATTERY_SERVICE);
                            isCharging = bm != null && bm.isCharging();
                        } catch (Throwable tr) {
                            // ignore
                        }
                    } else {
                        final Intent batteryBroadcast = applicationContext.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
                        final int batteryStatus = batteryBroadcast.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
                        isCharging = batteryStatus == BatteryManager.BATTERY_STATUS_CHARGING || batteryStatus == BatteryManager.BATTERY_STATUS_FULL;
//                        // 0 means we are discharging, anything else means charging
//                        isCharging = batteryBroadcast.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) != 0;
                    }
                    return Boolean.valueOf(isCharging);
                }

                @Override
                protected void onPostExecute(Boolean isCharging) {
                    super.onPostExecute(isCharging);
                    if (resultRef != null) {
                        resultRef.success(isCharging.booleanValue());
                    }
                }
            }.execute();
        } else if ("isSimMounted".equals(call.method)) {
            try {
                final TelephonyManager tm = (TelephonyManager) applicationContext.getSystemService(Context.TELEPHONY_SERVICE);
                final boolean isSimMounted = tm != null && tm.getSimState() != TelephonyManager.SIM_STATE_ABSENT;
                result.success(isSimMounted);
            } catch (Throwable tr) {
                result.success(false);
            }
        } else if ("isVPNOn".equals(call.method)) {
            try {
                boolean isVPNOn = false;
                final ConnectivityManager cm = (ConnectivityManager) applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE);
                if (cm != null) {
                    for (Network network : cm.getAllNetworks()) {
                        final NetworkCapabilities capabilities = cm.getNetworkCapabilities(network);
                        if (capabilities != null && capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                            isVPNOn = true;
                            break;
                        }
                    }
                }
                result.success(isVPNOn);
            } catch (Throwable tr) {
                result.success(false);
            }
        } else if ("getProxy".equals(call.method)) {
            final String proxyHost = System.getProperty("http.proxyHost");
            final String proxyPort = System.getProperty("http.proxyPort");
            if (!TextUtils.isEmpty(proxyHost)
                    && !TextUtils.isEmpty(proxyPort) && TextUtils.isDigitsOnly(proxyPort) && Integer.parseInt(proxyPort) > -1) {
                result.success(String.format("%1$s:%2$d", proxyHost, Integer.parseInt(proxyPort)));
            } else {
                result.success(null);
            }
        } else if ("getBrightness".equals(call.method)) {
            if (activity != null) {
                float brightness = activity.getWindow().getAttributes().screenBrightness;
                if (brightness < 0) { // the application is using the system brightness
                    try {
                        brightness = Settings.System.getInt(applicationContext.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS) / 255.0f;
                    } catch (Settings.SettingNotFoundException e) {
                        brightness = 1.0f;
                    }
                }
                result.success(brightness);
            } else {
                result.error("FAILED", "Activity is null.", null);
            }
        } else if ("setBrightness".equals(call.method)) {
            final double brightness = call.argument("brightness");
            if (activity != null) {
                final WindowManager.LayoutParams layoutParams = activity.getWindow().getAttributes();
                layoutParams.screenBrightness = (float)brightness;
                activity.getWindow().setAttributes(layoutParams);
                result.success(null);
            } else {
                result.error("FAILED", "Activity is null.", null);
            }
        } else if ("setSecureScreen".equals(call.method)) {
            final boolean secure = call.argument("secure");
            if (activity != null) {
                if (secure) {
                    activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
                } else {
                    activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
                }
                result.success(null);
            } else {
                result.error("FAILED", "Activity is null.", null);
            }
        } else {
            result.notImplemented();
        }
    }

    @SuppressLint({"HardwareIds", "MissingPermission"})
    @RequiresPermission(Manifest.permission.READ_PHONE_STATE)
    private String getDeviceId() {
        try {
            if (ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                TelephonyManager tm = (TelephonyManager) applicationContext.getSystemService(Context.TELEPHONY_SERVICE);
                return tm != null ? tm.getDeviceId() : null;
            }
        } catch (Throwable tr) {
            // ignore
        }
        return null;
    }

    @SuppressLint({"HardwareIds", "MissingPermission"})
    @RequiresPermission(Manifest.permission.ACCESS_WIFI_STATE)
    private String getMacBySystemInterface() {
        try {
            if (ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.ACCESS_WIFI_STATE) == PackageManager.PERMISSION_GRANTED) {
                final WifiManager wifi = (WifiManager) applicationContext.getSystemService(Context.WIFI_SERVICE);
                if (wifi != null) {
                    WifiInfo info = wifi.getConnectionInfo();
                    return info != null ? info.getMacAddress() : null;
                }
            }
        } catch (Throwable tr) {
            // ignore
        }
        return null;
    }

    @RequiresPermission(Manifest.permission.INTERNET)
    private String getMacByJavaAPI() {
        try {
            if (ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.ACCESS_WIFI_STATE) == PackageManager.PERMISSION_GRANTED) {
                Enumeration<NetworkInterface> nifs = NetworkInterface.getNetworkInterfaces();
                while (nifs.hasMoreElements()) {
                    NetworkInterface nif = nifs.nextElement();
                    if ("wlan0".equals(nif.getName()) || "eth0".equals(nif.getName())) {
                        byte[] addr = nif.getHardwareAddress();
                        if (addr != null && addr.length > 0) {
                            StringBuilder builder = new StringBuilder();
                            for (byte b : addr) {
                                builder.append(String.format("%02X:", b));
                            }
                            if (builder.length() > 0) {
                                builder.deleteCharAt(builder.length() - 1);
                            }
                            return builder.toString();
                        }
                    }
                }
            }
        } catch (Throwable tr) {
            // ignore
        }
        return null;
    }
}
