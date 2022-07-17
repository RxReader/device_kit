#import <Flutter/Flutter.h>

@interface DeviceKitPlugin : NSObject <FlutterPlugin>
@end

@interface DeviceKitBrightnessObserver : NSObject <FlutterStreamHandler>
@end

@interface DeviceKitTakeScreenshotObserver : NSObject <FlutterStreamHandler>

@end

@interface DeviceKitCapturedObserver : NSObject <FlutterStreamHandler>

@end
