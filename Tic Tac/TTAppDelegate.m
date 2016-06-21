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
@import LayerKit;


#define kYYLat 31.534173
#define kYYLong -97.123863

@interface TTAppDelegate ()
@end

@implementation TTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    // Appearance
    [self customizeAppearance];
    [[FLEXManager sharedManager] showExplorer];
    
    // Default preferences
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    
    // Setup layer client (will connect in the view controller
    NSURL *production = [NSURL URLWithString:@"layer:///apps/production/18426d48-f4eb-11e5-9d56-61d800001f29"];
    LYRClient *layer = [LYRClient clientWithAppID:production];
    [YYClient sharedClient].layerClient = layer;
    
    // Login / get current user
    NSString *userIdentifier = [NSUserDefaults currentUserIdentifier];
    if (userIdentifier) {
        [YYClient sharedClient].userIdentifier = userIdentifier;
        [YYClient sharedClient].location = [[CLLocation alloc] initWithLatitude:kYYLat longitude:kYYLong];
        
        self.window.rootViewController = [TTTabBarController new];
        [self.tabBarController notifyUserIsReady];
    } else {
        self.window.rootViewController = [TTWelcomeViewController new];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[FLEXManager sharedManager] action:@selector(showExplorer)];
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
    
    MKMethod *layoutSubviews = [MKMethod methodForSelector:@selector(layoutSubviews) class:[UILabel class]];
    IMP old = layoutSubviews.implementation;
    [UILabel replaceImplementationOfMethod:layoutSubviews with:imp_implementationWithBlock(^(UILabel *me) {
        me.preferredMaxLayoutWidth = CGRectGetWidth(me.frame);
        ((void(*)(id, SEL))old)(me, @selector(layoutSubviews));
    })];
    
    MKMethod *statusBar = [MKMethod methodForSelector:@selector(preferredStatusBarStyle) class:[UINavigationController class]];
    [UINavigationController replaceImplementationOfMethod:statusBar with:imp_implementationWithBlock(^(UINavigationController *me) {
        return UIStatusBarStyleLightContent;
    })];
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
