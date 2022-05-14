//
//  YYComment+Util.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "YYComment+Util.h"
#import "UIColor+TicTac.h"

static NSDictionary *colorDescriptions;
static NSDictionary *iconDescriptions;
@implementation YYComment (Util)

- (NSString *)authorText {
    NSString *color = [UIColor colorWithHexString:self.colorHex].accessibilityName;
    NSString *icon  = self.emoji;
    
    return [NSString stringWithFormat:@"%@ %@", color, icon];
}

@end
