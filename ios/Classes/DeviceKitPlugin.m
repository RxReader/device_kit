#import "DeviceKitPlugin.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <ifaddrs.h>

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
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL) isVPNOn {
    BOOL flag = NO;
    // need two ways to judge this.
    if (@available(iOS 9.0, *)) {
        NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
        NSArray *keys = [dict[@"__SCOPED__"] allKeys];
        for (NSString *key in keys) {
            if ([key rangeOfString:@"tap"].location != NSNotFound ||
                [key rangeOfString:@"tun"].location != NSNotFound ||
                [key rangeOfString:@"ipsec"].location != NSNotFound ||
                [key rangeOfString:@"ppp"].location != NSNotFound){
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
        if (success == 0){
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while (temp_addr != NULL){
                NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
                if ([string rangeOfString:@"tap"].location != NSNotFound ||
                    [string rangeOfString:@"tun"].location != NSNotFound ||
                    [string rangeOfString:@"ipsec"].location != NSNotFound ||
                    [string rangeOfString:@"ppp"].location != NSNotFound){
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
