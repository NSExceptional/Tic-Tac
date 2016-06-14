//
//  NSNumber+Score.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/14/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSNumber+Score.h"


//@interface NSMutableAttributedString (AppendString)
//- (void)appendString:(NSString *)str;
//@end
//
//@implementation NSMutableAttributedString (AppendString)
//- (void)appendString:(NSString *)str {
//    NSDictionary *attrs = [self attributesAtIndex:self.length-1 effectiveRange:nil];
//    [self replaceCharactersInRange:NSMakeRange(self.length, 0) withString:str];
//}
//@end

@implementation NSNumber (Score)

- (NSAttributedString *)scoreStringForVote:(YYVoteStatus)status {
    NSInteger value = self.integerValue;
    UIColor *mainColor = [UIColor colorForVote:YYVoteStatusNone];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@(value).stringValue attributes:nil];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorForVote:status] range:NSMakeRange(0, string.length)];
    [string.mutableString appendString:@" point"];
    [string setAttributes:@{NSForegroundColorAttributeName: mainColor} range:NSMakeRange(string.length-6, 6)];
    
    if (value != 1) {
        [string.mutableString appendString:@"s"];
    }
    
    return string.copy;
}

- (NSString *)scoreString {
    NSInteger value = self.integerValue;
    if (value == 1) {
        return @"1 point";
    }
    
    return [NSString stringWithFormat:@"%@ points", @(value)];
}

- (NSAttributedString *)scoreStringWithComma {
    NSMutableAttributedString *string = self.scoreString.mutableCopy;
    [string.mutableString appendString:@","];
    return string.copy;
}

@end
