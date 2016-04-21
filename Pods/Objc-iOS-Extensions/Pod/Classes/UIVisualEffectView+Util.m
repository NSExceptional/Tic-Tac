//
//  UIVisualEffectView+Util.m
//  Luna
//
//  Created by Tanner on 4/17/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UIVisualEffectView+Util.h"

@implementation UIVisualEffectView (Util)

+ (instancetype)extraLightBlurView {
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
}

+ (instancetype)lightBlurView {
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}

+ (instancetype)darkBlurView {
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
}

+ (instancetype)extraLightBlurViewVibrancy {
    return [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]]];
}

+ (instancetype)lightBlurViewVibrancy {
    return [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]];
}

+ (instancetype)darkBlurViewVibrancy {
    return [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
}

@end