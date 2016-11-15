//
//  UIWindow+Util.h
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import <UIKit/UIKit.h>

@interface UIWindow (Util)

/// `nil` if not applicable.
@property (nonatomic, readonly) UINavigationController *rootNavigationController;

@property (nonatomic, readonly) UIViewController *topMostViewController;

@end
