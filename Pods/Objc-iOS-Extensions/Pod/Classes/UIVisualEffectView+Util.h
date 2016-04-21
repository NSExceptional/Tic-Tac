//
//  UIVisualEffectView+Util.h
//  Luna
//
//  Created by Tanner on 4/17/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIVisualEffectView (Util)

+ (instancetype)extraLightBlurView;
+ (instancetype)lightBlurView;
+ (instancetype)darkBlurView;

+ (instancetype)extraLightBlurViewVibrancy;
+ (instancetype)lightBlurViewVibrancy;
+ (instancetype)darkBlurViewVibrancy;

@end
