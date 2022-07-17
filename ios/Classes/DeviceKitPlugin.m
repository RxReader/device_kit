#import "DeviceKitPlugin.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <ifaddrs.h>

@implementation DeviceKitPlugin {
    FlutterEventSink _brightnessChangedEventSink;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"v7lin.github.io/device_kit"
              binaryMessenger:[registrar messenger]];
    DeviceKitPlugin *instance = [[DeviceKitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];

    FlutterEventChannel *brightnessChangedEventChannel = [FlutterEventChannel eventChannelWithName:@"v7lin.github.io/device_kit#brightness_changed_event" binaryMessenger:[registrar messenger]];
    DeviceKitBrightnessObserver *brightnessObserver = [[DeviceKitBrightnessObserver alloc] init];
    [brightnessChangedEventChannel setStreamHandler:brightnessObserver];

    FlutterEventChannel *takeScreenshotEventChannel = [FlutterEventChannel eventChannelWithName:@"v7lin.github.io/device_kit#take_screenshot_event" binaryMessenger:[registrar messenger]];
    DeviceKitTakeScreenshotObserver *takeScreenshotObserver = [[DeviceKitTakeScreenshotObserver alloc] init];
    [takeScreenshotEventChannel setStreamHandler:takeScreenshotObserver];

    FlutterEventChannel *capturedChangedEventChannel = [FlutterEventChannel eventChannelWithName:@"v7lin.github.io/device_kit#captured_changed_event" binaryMessenger:[registrar messenger]];
    DeviceKitCapturedObserver *capturedObserver = [[DeviceKitCapturedObserver alloc] init];
    [capturedChangedEventChannel setStreamHandler:capturedObserver];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"isCharging" isEqualToString:call.method]) {
        UIDevice *device = [UIDevice currentDevice];
        [device setBatteryMonitoringEnabled:YES];
        BOOL isCharging = device.batteryState == UIDeviceBatteryStateCharging || device.batteryState == UIDeviceBatteryStateFull;
        result([NSNumber numberWithBool:isCharging]);
    } else if ([@"isSimMounted" isEqualToString:call.method]) {
        BOOL isSimMounted = NO;
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        if (@available(iOS 12.0, *)) {
            NSDictionary *dict = networkInfo.serviceSubscriberCellularProviders;
            for (CTCarrier *carrier in dict.allValues) {
                if (carrier.isoCountryCode) {
                    isSimMounted = YES;
                    break;
                }
            }
        } else {
            CTCarrier *carrier = [networkInfo subscriberCellularProvider];
            if (carrier.isoCountryCode) {
                isSimMounted = YES;
            }
        }
        result([NSNumber numberWithBool:isSimMounted]);
    } else if ([@"isVPNOn" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[self isVPNOn]]);
    } else if ([@"getProxy" isEqualToString:call.method]) {
        CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
        NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;
        //是否开启了http代理
        if ([[dictProxy objectForKey:@"HTTPEnable"] boolValue]) {
            NSString *proxyHost = [dictProxy objectForKey:@"HTTPProxy"];     //代理地址
            int proxyPort = [[dictProxy objectForKey:@"HTTPPort"] intValue]; //代理端口号
            result([NSString stringWithFormat:@"%@:%d", proxyHost, proxyPort]);
        } else {
            result(nil);
        }
    } else if ([@"getBrightness" isEqualToString:call.method]) {
        result([NSNumber numberWithFloat:[UIScreen mainScreen].brightness]);
    } else if ([@"setBrightness" isEqualToString:call.method]) {
        NSNumber *brightness = call.arguments[@"brightness"];
        [[UIScreen mainScreen] setBrightness:brightness.floatValue];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)isVPNOn {
    BOOL flag = NO;
    // need two ways to judge this.
    if (@available(iOS 9.0, *)) {
        NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
        NSArray *keys = [dict[@"__SCOPED__"] allKeys];
        for (NSString *key in keys) {
            if ([key rangeOfString:@"tap"].location != NSNotFound ||
                [key rangeOfString:@"tun"].location != NSNotFound ||
                [key rangeOfString:@"ipsec"].location != NSNotFound ||
                [key rangeOfString:@"ppp"].location != NSNotFound) {
                flag = YES;
                break;
            }
        }
    } else {
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;

        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while (temp_addr != NULL) {
                NSString *string = [NSString stringWithFormat:@"%s", temp_addr->ifa_name];
                if ([string rangeOfString:@"tap"].location != NSNotFound ||
                    [string rangeOfString:@"tun"].location != NSNotFound ||
                    [string rangeOfString:@"ipsec"].location != NSNotFound ||
                    [string rangeOfString:@"ppp"].location != NSNotFound) {
                    flag = YES;
                    break;
                }
                temp_addr = temp_addr->ifa_next;
            }
        }

        // Free memory
        freeifaddrs(interfaces);
    }
    return flag;
}

@end

@implementation DeviceKitBrightnessObserver {
    FlutterEventSink _events;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    if (_events != nil) {
        return nil;
    }
    _events = events;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brightnessDidChange) name:UIScreenBrightnessDidChangeNotification object:nil];
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments;
{
    if (_events == nil) {
        return nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _events = nil;
    return nil;
}

- (void)brightnessDidChange {
    if (_events != nil) {
        _events([NSNumber numberWithFloat:[UIScreen mainScreen].brightness]);
    }
}

@end

@implementation DeviceKitTakeScreenshotObserver {
    FlutterEventSink _events;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    if (_events != nil) {
        return nil;
    }
    _events = events;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments;
{
    if (_events == nil) {
        return nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _events = nil;
    return nil;
}

- (void)takeScreenshot {
    if (_events != nil) {
        _events(@"takeScreenshot");
    }
}

@end

@implementation DeviceKitCapturedObserver {
    FlutterEventSink _events;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    if (_events != nil) {
        return nil;
    }
    _events = events;
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(capturedDidChange) name:UIScreenCapturedDidChangeNotification object:nil];
    }
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments;
{
    if (_events == nil) {
        return nil;
    }
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    _events = nil;
    return nil;
}

- (void)capturedDidChange {
    if (_events != nil) {
        _events(@"captured");
    }
}

@end
