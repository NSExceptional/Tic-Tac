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
    return [UIColor colorWithRed:0.448 green:0.261 blue:0.909 alpha:1.000];
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

+ (UIColor *)upvoteColor {
    return [UIColor colorWithRed:1.000 green:0.200 blue:0.000 alpha:1.000];
}

+ (UIColor *)downvoteColor {
    return [UIColor colorWithRed:0.200 green:0.200 blue:1.000 alpha:1.000];
}

+ (UIColor *)noVoteColor {
    return [UIColor colorWithWhite:0.000 alpha:0.500];
}

+ (UIColor *)replyColor {
    return [self themeColor];
}

+ (UIColor *)colorForVote:(YYVoteStatus)vote {
    switch (vote) {
        case YYVoteStatusDownvoted: {
            return [self downvoteColor];
        }
        case YYVoteStatusNone: {
            return [self noVoteColor];
        }
        case YYVoteStatusUpvoted: {
            return [self upvoteColor];
        }
    }
}

@end
