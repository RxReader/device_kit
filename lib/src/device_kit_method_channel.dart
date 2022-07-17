import 'dart:io';

import 'package:device_kit/src/device_kit_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [DeviceKitPlatform] that uses method channels.
class MethodChannelDeviceKit extends DeviceKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('v7lin.github.io/device_kit');

  @override
  Future<String?> getDeviceId() {
    assert(Platform.isAndroid);
    return methodChannel.invokeMethod<String>('getDeviceId');
  }

  @override
  Future<String?> getMac() {
    assert(Platform.isAndroid);
    return methodChannel.invokeMethod<String>('getMac');
  }

  @override
  Future<bool> isCharging() async {
    return await methodChannel.invokeMethod<bool>('isCharging') ?? false;
  }

  @override
  Future<bool> isSimMounted() async {
    return await methodChannel.invokeMethod<bool>('isSimMounted') ?? false;
  }

  @override
  Future<bool> isVPNOn() async {
    return await methodChannel.invokeMethod<bool>('isVPNOn') ?? false;
  }

  @override
  Future<String?> getProxy() {
    return methodChannel.invokeMethod<String>('getProxy');
  }

  @override
  Future<double> getBrightness() async {
    return await methodChannel.invokeMethod<double>('getBrightness') ?? -1;
  }

  @override
  Future<void> setBrightness(double brightness) {
    return methodChannel.invokeMethod<void>(
      'setBrightness',
      <String, dynamic>{
        'brightness': brightness,
      },
    );
  }
}
