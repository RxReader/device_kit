import 'dart:async';
import 'dart:io';

import 'package:device_kit/device_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<double> _brightnessChangedResp;
  StreamSubscription<String>? _takeScreenshotResp;
  StreamSubscription<String>? _capturedChangedResp;
  bool _secure = false;

  @override
  void initState() {
    super.initState();
    _brightnessChangedResp =
        Device.instance.brightnessChangedStream().listen((double event) {
      if (kDebugMode) {
        print('Brightness Changed: $event');
      }
    });
    if (Platform.isIOS) {
      _takeScreenshotResp =
          Device.instance.takeScreenshotStream().listen((String event) {
        if (kDebugMode) {
          print('Take Screenshot: $event');
        }
      });
      _capturedChangedResp =
          Device.instance.capturedChangedStream().listen((String event) {
        if (kDebugMode) {
          print('Captured Changed: $event');
        }
      });
    }
  }

  @override
  void dispose() {
    _capturedChangedResp?.cancel();
    _takeScreenshotResp?.cancel();
    _brightnessChangedResp.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Device Kit'),
        ),
        body: ListView(
          children: <Widget>[
            if (Platform.isAndroid)
              ListTile(
                title: Text('getAndroidId'),
                onTap: () async {
                  if (kDebugMode) {
                    print('Android Id: ${await Device.instance.getAndroidId()}');
                  }
                },
              ),
            if (Platform.isAndroid)
              ListTile(
                title: Text('getDeviceId'),
                onTap: () async {
                  if (kDebugMode) {
                    print('Device Id: ${await Device.instance.getDeviceId()}');
                  }
                },
              ),
            if (Platform.isAndroid)
              ListTile(
                title: Text('getMac'),
                onTap: () async {
                  if (kDebugMode) {
                    print('Mac: ${await Device.instance.getMac()}');
                  }
                },
              ),
            ListTile(
              title: Text('isCharging'),
              onTap: () async {
                if (kDebugMode) {
                  print('isCharging: ${await Device.instance.isCharging()}');
                }
              },
            ),
            ListTile(
              title: Text('isSimMounted'),
              onTap: () async {
                if (kDebugMode) {
                  print(
                      'isSimMounted: ${await Device.instance.isSimMounted()}');
                }
              },
            ),
            ListTile(
              title: Text('isVPNOn'),
              onTap: () async {
                if (kDebugMode) {
                  print('isVPNOn: ${await Device.instance.isVPNOn()}');
                }
              },
            ),
            ListTile(
              title: Text('localeName'),
              onTap: () {
                if (kDebugMode) {
                  print('localeName: ${Platform.localeName}');
                }
              },
            ),
            ListTile(
              title: Text('timeZone'),
              onTap: () {
                if (kDebugMode) {
                  print(
                      'timeZone: ${DateTime.now().timeZoneName} - ${DateTime.now().timeZoneOffset}');
                }
              },
            ),
            ListTile(
              title: Text('getProxy'),
              onTap: () async {
                if (kDebugMode) {
                  print('proxy: ${await Device.instance.getProxy()}');
                }
              },
            ),
            ListTile(
              title: Text('getBrightness'),
              onTap: () async {
                if (kDebugMode) {
                  print('brightness: ${await Device.instance.getBrightness()}');
                }
              },
            ),
            ListTile(
              title: Text('setBrightness'),
              onTap: () async {
                if (kDebugMode) {
                  await Device.instance.setBrightness(0.5);
                }
              },
            ),
            if (Platform.isAndroid)
              ListTile(
                title: Text('setSecureScreen'),
                onTap: () {
                  _secure = !_secure;
                  Device.instance.setSecureScreen(_secure);
                },
              ),
          ],
        ),
      ),
    );
  }
}
