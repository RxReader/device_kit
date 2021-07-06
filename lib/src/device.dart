import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Device {
  const Device._();

  static const MethodChannel _channel =
      MethodChannel('v7lin.github.io/device_kit');

  static Future<String?> getDeviceId() {
    assert(Platform.isAndroid);
    return _channel.invokeMethod<String>('getDeviceId');
  }

  static Future<String?> getMac() {
    assert(Platform.isAndroid);
    return _channel.invokeMethod<String>('getMac');
  }

  static Future<bool> isCharging() async {
    return await _channel.invokeMethod<bool>('isCharging') ?? false;
  }

  static Future<bool> isSimMounted() async {
    return await _channel.invokeMethod<bool>('isSimMounted') ?? false;
  }

  static Future<bool> isVPNOn() async {
    return await _channel.invokeMethod<bool>('isVPNOn') ?? false;
  }
}
