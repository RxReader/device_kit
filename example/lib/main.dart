import 'package:device_kit/device_kit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device Kit'),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('getDeviceId'),
              onTap: () async {
                print('Device Id: ${await Device.getDeviceId()}');
              },
            ),
            ListTile(
              title: const Text('getMac'),
              onTap: () async {
                print('Mac: ${await Device.getMac()}');
              },
            ),
            ListTile(
              title: const Text('isCharging'),
              onTap: () async {
                print('isCharging: ${await Device.isCharging()}');
              },
            ),
            ListTile(
              title: const Text('isSimMounted'),
              onTap: () async {
                print('isSimMounted: ${await Device.isSimMounted()}');
              },
            ),
            ListTile(
              title: const Text('isVPNOn'),
              onTap: () async {
                print('isVPNOn: ${await Device.isVPNOn()}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
