import 'dart:async';
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
  @visibleForTesting
  final EventChannel brightnessChangedEventChannel =
      const EventChannel('v7lin.github.io/device_kit#brightness_changed_event');
  @visibleForTesting
  final EventChannel takeScreenshotEventChannel =
      const EventChannel('v7lin.github.io/device_kit#take_screenshot_event');
  @visibleForTesting
  final EventChannel capturedChangedEventChannel =
      const EventChannel('v7lin.github.io/device_kit#captured_changed_event');

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

  Stream<double>? _onBrightnessChangedStream;

  @override
  Stream<double> brightnessChangedStream() {
    _onBrightnessChangedStream ??= brightnessChangedEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      return event as double;
    });
    return _onBrightnessChangedStream!;
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

  @override
  Future<void> setSecureScreen(bool secure) {
    assert(Platform.isAndroid);
    return methodChannel.invokeMethod(
      'setSecureScreen',
      <String, dynamic>{
        'secure': secure,
      },
    );
  }

  Stream<String>? _onTakeScreenshotStream;

  @override
  Stream<String> takeScreenshotStream() {
    assert(Platform.isIOS);
    _onTakeScreenshotStream ??= takeScreenshotEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      return event as String;
    });
    return _onTakeScreenshotStream!;
  }

  Stream<String>? _onCapturedChangedStream;

  @override
  Stream<String> capturedChangedStream() {
    assert(Platform.isIOS);
    _onCapturedChangedStream ??= capturedChangedEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      return event as String;
    });
    return _onCapturedChangedStream!;
  }
}
