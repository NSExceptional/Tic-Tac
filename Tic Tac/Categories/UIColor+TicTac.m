//
//  UIColor+TicTac.m
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "UIColor+TicTac.h"


@implementation UIColor (TicTac)

+ (instancetype)themeColor {
    return [UIColor colorWithRed:0.400 green:0.200 blue:1.000 alpha:1.000];
}

+ (UIColor *)welcomeHairlineColor {
    return [UIColor colorWithWhite:0.777 alpha:1.000];
}

+ (UIColor *)welcomeButtonSubtitleTextColor {
    return [UIColor colorWithWhite:0.359 alpha:1.000];
}

+ (UIColor *)welcomeButtonSubtitleSelectedTextColor {
    return [UIColor colorWithWhite:1.000 alpha:0.500];
}

@end
