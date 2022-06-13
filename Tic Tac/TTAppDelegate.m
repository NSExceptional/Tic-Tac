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
#define kYYAuthToken @"eyJhbGciOiJSUzI1NiIsImtpZCI6ImJlYmYxMDBlYWRkYTMzMmVjOGZlYTU3ZjliNWJjM2E2YWIyOWY1NTUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20veWlreWFrLWIwZDZiIiwiYXVkIjoieWlreWFrLWIwZDZiIiwiYXV0aF90aW1lIjoxNjUxMTI1MDMyLCJ1c2VyX2lkIjoiSU5rcnF0Q1I1OGd3d3ZtYjluemhkM0hyYnNvMSIsInN1YiI6IklOa3JxdENSNThnd3d2bWI5bnpoZDNIcmJzbzEiLCJpYXQiOjE2NTI1MDkyMTEsImV4cCI6MTY1MjUxMjgxMSwicGhvbmVfbnVtYmVyIjoiKzEyODE5NjE5NjM1IiwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJwaG9uZSI6WyIrMTI4MTk2MTk2MzUiXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwaG9uZSJ9fQ.ok8yxcHtIRyaw1kPiDT3hA0uXghJ8-Y01K3pCYwEyAAmZOhEUqiG9tXl4D4ImAQrfxGlfG0u0efwhPV6RH1i6B-OycRfpTYhC7A8NjJBmftFuDd_58Gkx-BNA8ahA0dYpfDVB1XK51uWGsvcSwQ-WOLViwXG99nICoGVBcR_w0f4nbjtKuU-mLcVaGqhcBO7U28WyX7j_EYrxBzw4vfR0xVdnuOsqXvQpoekzqg98c4yCYRfU9j_qag3kAbYgGhxFdmL6l5cLe9k8nJ9mv7FN6ShHcukPbN3LxCr91YORUJRWwNlxVeW9rrQBiCV3POS58JtlVVyjCEU1wzIytxYUg"

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
//    NSString *userIdentifier = NSUserDefaults.currentUserIdentifier;
    
    if (UIPasteboard.generalPasteboard.string.length > 700) {
//        YYClient.sharedClient.userIdentifier = userIdentifier;
//        YYClient.sharedClient.authToken = kYYAuthToken;
        YYClient.sharedClient.location = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
        YYClient.sharedClient.authToken = UIPasteboard.generalPasteboard.string;
        
        self.window.rootViewController = self.tabBarController;
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
//    UINavigationBar.appearance.barTintColor = UIColor.themeColor;
//    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
//    UINavigationBar.appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
}

- (TTTabBarController *)tabBarController {
    static TTTabBarController *tabBarController = nil;
    if (!tabBarController) {
        tabBarController = [TTTabBarController new];
    }
    
    return tabBarController;
}

- (void)setupNewUser:(YYVoidBlock)completion {

}

@end
