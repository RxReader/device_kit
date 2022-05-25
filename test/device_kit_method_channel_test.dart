import 'package:device_kit/src/device_kit_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final MethodChannelDeviceKit platform = MethodChannelDeviceKit();
  const MethodChannel channel = MethodChannel('v7lin.github.io/device_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isCharging':
          return false;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('isCharging', () async {
    expect(await platform.isCharging(), false);
  });
}
