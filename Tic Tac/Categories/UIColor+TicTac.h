//
//  UIColor+TicTac.h
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (TicTac)

+ (instancetype)themeColor;

+ (UIColor *)welcomeHairlineColor;
+ (UIColor *)welcomeButtonSubtitleTextColor;
+ (UIColor *)welcomeButtonSubtitleSelectedTextColor;

+ (UIColor *)upvoteColor;
+ (UIColor *)downvoteColor;
+ (UIColor *)noVoteColor;

@end
