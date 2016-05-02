//
//  AppDelegate.m
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTWelcomeViewController.h"

#define kYYLat 31.534173
#define kYYLong -97.123863

@interface TTAppDelegate ()
@end

@implementation TTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.tintColor = [UIColor whiteColor];
    
    [self customizeAppearance];
    
    [[FLEXManager sharedManager] showExplorer];
    
    NSString *userIdentifier = [NSUserDefaults currentUserIdentifier];
    if (userIdentifier) {
        [YYClient sharedClient].userIdentifier = userIdentifier;
        [YYClient sharedClient].location = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
        [[YYClient sharedClient] updateUser:nil];
        
        self.window.rootViewController = [TTTabBarController new];
        [self.tabBarController notifyUserIsReady];
    } else {
        self.window.rootViewController = [TTWelcomeViewController new];
    }
    
    return YES;
}

- (void)customizeAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UINavigationBar appearance].barTintColor = [UIColor themeColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (TTTabBarController *)tabBarController {
    if ([NSUserDefaults currentUserIdentifier]) {
        return (id)self.window.rootViewController;
    }
    
    return nil;
}

- (void)setupNewUser:(VoidBlock)completion {
    
}

@end
