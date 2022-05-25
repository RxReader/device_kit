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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Device Kit'),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text('getDeviceId'),
              onTap: () async {
                if (kDebugMode) {
                  print('Device Id: ${await Device.instance.getDeviceId()}');
                }
              },
            ),
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
          ],
        ),
      ),
    );
  }
}
