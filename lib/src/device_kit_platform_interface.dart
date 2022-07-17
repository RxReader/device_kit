import 'package:device_kit/src/device_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class DeviceKitPlatform extends PlatformInterface {
  /// Constructs a DeviceKitPlatform.
  DeviceKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceKitPlatform _instance = MethodChannelDeviceKit();

  /// The default instance of [DeviceKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceKit].
  static DeviceKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DeviceKitPlatform] when
  /// they register themselves.
  static set instance(DeviceKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getDeviceId() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  Future<String?> getMac() {
    throw UnimplementedError('getMac() has not been implemented.');
  }

  Future<bool> isCharging() {
    throw UnimplementedError('isCharging() has not been implemented.');
  }

  Future<bool> isSimMounted() {
    throw UnimplementedError('isSimMounted() has not been implemented.');
  }

  Future<bool> isVPNOn() {
    throw UnimplementedError('isVPNOn() has not been implemented.');
  }

  Future<String?> getProxy() {
    throw UnimplementedError('getProxy() has not been implemented.');
  }

  Future<double> getBrightness() {
    throw UnimplementedError('getBrightness() has not been implemented.');
  }

  Future<void> setBrightness(double brightness) {
    throw UnimplementedError(
        'setBrightness(brightness) has not been implemented.');
  }
}
