#import "Shaker.h"

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>

#import <sys/utsname.h>

static NSString *const RCTShowDevMenuNotification = @"RCTShowDevMenuNotification";

#if !RCT_DEV

@implementation UIWindow (Shaker)

- (void)handleShakerShakeEvent:(__unused UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RCTShowDevMenuNotification object:nil];
    }
}

@end

@implementation Shaker

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

+ (void)initialize
{
    RCTSwapInstanceMethods([UIWindow class], @selector(motionEnded:withEvent:), @selector(handleShakerShakeEvent:withEvent:));
}

- (instancetype)init
{
    if ((self = [super init])) {
        RCTLogInfo(@"Shaker: started in debug mode");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(motionEnded:)
                                                     name:RCTShowDevMenuNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)motionEnded:(NSNotification *)notification
{
    [_bridge.eventDispatcher sendDeviceEventWithName:@"ShakerShakeEvent"
                                                body:nil];
}


RCT_REMAP_METHOD(takeScreenshot,
                 takeScreenshotWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSError *error = nil;

        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];


        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [keyWindow bounds];
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext:context];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSString *uuidString = [[NSProcessInfo processInfo] globallyUniqueString];
        NSData *data = UIImageJPEGRepresentation(img, 0.8);

        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:uuidString];

        if (tempPath && !error) {
          if ([data writeToFile:tempPath options:(NSDataWritingOptions)0 error:&error]) {

            NSDictionary *response = @{
              @"uri": tempPath,
              @"manufacturer": @"apple",
              @"model": machineName
            };

            resolve(response);
          }
        }

        if (error) reject(@"error", error.localizedDescription, error);
    //    return img;
    } @catch (NSException *exception) {
        reject(@"error", @"error", nil);
    }
}

@end

#else

@implementation Shaker

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(motionEnded:)
                                                     name:RCTShowDevMenuNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)motionEnded:(NSNotification *)notification
{
    [_bridge.eventDispatcher sendDeviceEventWithName:@"ShakerShakeEvent"
                                                body:nil];
}


RCT_REMAP_METHOD(takeScreenshot,
                 takeScreenshotWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSError *error = nil;

        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];


        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [keyWindow bounds];
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext:context];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSString *uuidString = [[NSProcessInfo processInfo] globallyUniqueString];
        NSData *data = UIImageJPEGRepresentation(img, 0.8);

        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:uuidString];

        if (tempPath && !error) {
          if ([data writeToFile:tempPath options:(NSDataWritingOptions)0 error:&error]) {

            NSDictionary *response = @{
              @"uri": tempPath,
              @"manufacturer": @"apple",
              @"model": machineName
            };

            resolve(response);
          }
        }

        if (error) reject(@"error", error.localizedDescription, error);
    //    return img;
    } @catch (NSException *exception) {
        reject(@"error", @"error", nil);
    }
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}
@end

#endif
