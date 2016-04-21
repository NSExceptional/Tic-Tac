//
//  UIWindow+Util.m
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import "UIWindow+Util.h"
#import "UIViewController+Util.h"

@implementation UIWindow (Util)

- (UINavigationController *)rootNavigationController {
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        return (id)self.rootViewController;
    }
    
    return nil;
}

- (UIViewController *)topMostViewController {
    return self.rootViewController.topmostViewController;
}

@end
