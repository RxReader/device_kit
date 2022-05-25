import 'package:device_kit/src/device_kit_platform_interface.dart';

class Device {
  const Device._();

  static DeviceKitPlatform get instance => DeviceKitPlatform.instance;
}
