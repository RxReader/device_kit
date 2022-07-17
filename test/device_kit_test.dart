import 'package:device_kit/src/device.dart';
import 'package:device_kit/src/device_kit_method_channel.dart';
import 'package:device_kit/src/device_kit_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceKitPlatform
    with MockPlatformInterfaceMixin
    implements DeviceKitPlatform {
  @override
  Future<String?> getDeviceId() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getMac() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isCharging() {
    return Future<bool>.value(false);
  }

  @override
  Future<bool> isSimMounted() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isVPNOn() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getProxy() {
    throw UnimplementedError();
  }

  @override
  Stream<double> brightnessChangedStream() {
    throw UnimplementedError();
  }

  @override
  Future<double> getBrightness() {
    throw UnimplementedError();
  }

  @override
  Future<void> setBrightness(double brightness) {
    throw UnimplementedError();
  }

  @override
  Future<void> setSecureScreen(bool secure) {
    throw UnimplementedError();
  }
}

void main() {
  final DeviceKitPlatform initialPlatform = DeviceKitPlatform.instance;

  test('$MethodChannelDeviceKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceKit>());
  });

  test('isCharging', () async {
    final MockDeviceKitPlatform fakePlatform = MockDeviceKitPlatform();
    DeviceKitPlatform.instance = fakePlatform;

    expect(await Device.instance.isCharging(), false);
  });
}
