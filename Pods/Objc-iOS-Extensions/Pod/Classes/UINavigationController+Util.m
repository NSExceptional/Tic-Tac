//
//  UINavigationController+Util.m
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import "UINavigationController+Util.h"
#import "UIViewController+Util.h"

@implementation UINavigationController (Util)

- (UIViewController *)topmostViewController {
    if (self.presentedViewController) {
        return self.presentedViewController.topmostViewController;
    }
    
    return self.viewControllers.lastObject.topmostViewController ?: self;
}

@end
