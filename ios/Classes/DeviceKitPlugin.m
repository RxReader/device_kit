#import "DeviceKitPlugin.h"

@implementation DeviceKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"v7lin.github.io/device_kit"
              binaryMessenger:[registrar messenger]];
    DeviceKitPlugin *instance = [[DeviceKitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"isCharging" isEqualToString:call.method]) {
        UIDevice *device = [UIDevice currentDevice];
        [device setBatteryMonitoringEnabled:YES];
        BOOL isCharging = device.batteryState == UIDeviceBatteryStateCharging || device.batteryState == UIDeviceBatteryStateFull;
        result([NSNumber numberWithBool:isCharging]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
