//
//  UIColor+TicTac.m
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "UIColor+TicTac.h"


@implementation UIColor (TicTac)

/// #7242E7
+ (instancetype)themeColor {
    return UIColor.systemPurpleColor;
//    return [UIColor colorWithRed:0.448 green:0.261 blue:0.909 alpha:1.000];
}

+ (UIColor *)welcomeHairlineColor {
    return UIColor.systemGray3Color;
}

+ (UIColor *)welcomeButtonSubtitleTextColor {
    return UIColor.tertiaryLabelColor;
}

+ (UIColor *)welcomeButtonSubtitleSelectedTextColor {
    return UIColor.tertiaryLabelColor;
}

+ (UIColor *)upvoteColor {
    return [UIColor colorWithRed:1.000 green:0.200 blue:0.000 alpha:1.000];
}

+ (UIColor *)downvoteColor {
    return [UIColor colorWithRed:0.200 green:0.200 blue:1.000 alpha:1.000];
}

+ (UIColor *)noVoteColor {
    return UIColor.secondaryLabelColor;
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

+ (UIColor *)colorWithHexString:(NSString *)hex {
    NSString *colorString = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""].uppercaseString;
    CGFloat alpha, red, blue, green;
    
    switch (colorString.length) {
        // #RGB
        case 3: {
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            
            break;
        }
        // #ARGB
        case 4: {
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];
            
            break;
        }
        // #RRGGBB
        case 6: {
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            
            break;
        }
        // #AARRGGBB
        case 8: {
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            
            break;
        }
            
        default: {
            @throw NSInternalInconsistencyException;
            break;
        }
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substr = [string substringWithRange: NSMakeRange(start, length)];
    NSString *hex = length == 2 ? substr : [NSString stringWithFormat: @"%@%@", substr, substr];
    unsigned hexComponent;
    [[NSScanner scannerWithString:hex] scanHexInt:&hexComponent];
    
    return hexComponent / 255.0;
}

@end
