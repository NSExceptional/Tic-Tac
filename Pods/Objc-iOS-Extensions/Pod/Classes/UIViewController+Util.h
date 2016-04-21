//
//  UIViewController.h
//  Luna
//
//  Created by Tanner on 1/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Util)

@property (nonatomic, readonly) UIViewController *topmostViewController;

- (void)dismissAnimated;
- (void)launchLinkInBrowser:(NSString *)urlString;

@end
