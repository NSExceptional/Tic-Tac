//
//  AppDelegate.m
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTWelcomeViewController.h"
#import "TTCache.h"


#define kYYLat 31.534173
#define kYYLong -97.123863

@interface TTAppDelegate ()
@end

@implementation TTAppDelegate

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
    
    // Login / get current user
    NSString *userIdentifier = NSUserDefaults.currentUserIdentifier;
    if (userIdentifier) {
        [YYClient sharedClient].userIdentifier = userIdentifier;
        [YYClient sharedClient].location = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
        
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
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [TTCache maybeSaveAllComments];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [TTCache maybeSaveAllComments];
}

- (void)customizeAppearance {
    self.window.tintColor = [UIColor themeColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UINavigationBar appearance].barTintColor = [UIColor themeColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
//    MKMethod *statusBar = [MKMethod methodForSelector:@selector(preferredStatusBarStyle)
//                                                class:[UINavigationController class] instance:YES];
//    [UINavigationController replaceImplementationOfMethod:statusBar with:imp_implementationWithBlock(^(UINavigationController *me) {
//        return UIStatusBarStyleLightContent;
//    }) useInstance:YES];
}

- (TTTabBarController *)tabBarController {
    if ([NSUserDefaults currentUserIdentifier]) {
        return (id)self.window.rootViewController;
    }
    
    // New vc if no registered user
    return [TTTabBarController new];
}

- (void)setupNewUser:(VoidBlock)completion {
    
}

@end
