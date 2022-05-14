//
//  AppDelegate.m
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTWelcomeViewController.h"
#import "TBAlertController+Anywhere.h"
#import "TTCache.h"
#import <FLEX.h>
@import UserNotifications;
@import Firebase;

#define kYYLat 31.534173
#define kYYLong -97.123863

@interface TTAppDelegate ()
@end

@implementation TTAppDelegate

+ (void)load {
    FLEXMethod *bundleID = [NSBundle flex_methodNamed:@"bundleIdentifier"];
    IMP orig = bundleID.implementation;
    bundleID.implementation = imp_implementationWithBlock(^(NSBundle *bundle) {
        NSString *identifier = ((NSString *(*)(id, SEL))orig)(bundle, @selector(bundleIdentifier));
        if (bundle == NSBundle.mainBundle) {
            return @"com.yikyak.2";
        }
        
        return identifier;
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Window
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    
    // Appearance
    [self customizeAppearance];
    
    // Default preferences
    NSString *defaultsPath = [NSBundle.mainBundle pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    [NSUserDefaults.standardUserDefaults registerDefaults:defaults];
    
    [FIRApp configure];
    
    // Login / get current user
    NSString *userIdentifier = NSUserDefaults.currentUserIdentifier;
    if (userIdentifier) {
        YYClient.sharedClient.userIdentifier = userIdentifier;
        YYClient.sharedClient.location = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
        
        self.window.rootViewController = [TTTabBarController new];
        [self.tabBarController notifyUserIsReady];
    } else {
        self.window.rootViewController = [TTWelcomeViewController new];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:FLEXManager.sharedManager action:@selector(showExplorer)
    ];
    tap.numberOfTouchesRequired = 3;
    [self.window addGestureRecognizer:tap];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
        completionHandler:^(BOOL granted, NSError *error) {
    }];
    
    return YES;
}

#pragma mark Notifications

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = @(*((NSUInteger *)deviceToken.bytes)).stringValue;
//    NSString *title = @"Did Register with APNS";
//    [[TBAlertController simpleOKAlertWithTitle:title message:token] showNow];
    NSLog(@"🟦 Did Register with APNS: %@", token);
    
    [[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeProd];
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)notification {
//    NSString *title = @"Did Receive Push Notification";
//    [[TBAlertController simpleOKAlertWithTitle:title message:notification.description] showNow];
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)notification
                                               fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completion {
//    NSString *title = @"Did Receive Background Notification";
//    [[TBAlertController simpleOKAlertWithTitle:title message:notification.description] showNow];
    
    if ([FIRAuth.auth canHandleNotification:notification]) {
        completion(UIBackgroundFetchResultNoData);
        return;
    }
}

//- (void)userNotificationCenter:(UNUserNotificationCenter *)center
//       willPresentNotification:(UNNotification *)notification
//         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(14.0)) {
//    NSString *title = @"Did Receive Push Notification";
//    [[TBAlertController simpleOKAlertWithTitle:title message:notification.request.content.title] showNow];
//    completionHandler(UNNotificationPresentationOptionBanner);
//}

#pragma mark Other events

- (void)applicationWillTerminate:(UIApplication *)application {
    [TTCache maybeSaveAllComments];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [TTCache maybeSaveAllComments];
}

- (void)customizeAppearance {
    self.window.tintColor = UIColor.themeColor;
//    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    UINavigationBar.appearance.barTintColor = UIColor.themeColor;
    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
    UINavigationBar.appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
}

- (TTTabBarController *)tabBarController {
    if ([NSUserDefaults currentUserIdentifier]) {
        return (id)self.window.rootViewController;
    }
    
    // New vc if no registered user
    return [TTTabBarController new];
}

- (void)setupNewUser:(YYVoidBlock)completion {

}

@end
