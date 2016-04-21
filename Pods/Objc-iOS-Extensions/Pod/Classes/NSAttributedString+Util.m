//
//  NSAttributedString+Util.h
//  Luna
//
//  Created by Tanner on 3/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSAttributedString+Util.h"

@implementation NSAttributedString (Util)

- (NSAttributedString *)attributedStringByReplacingOccurencesOfAttribute:(id)oldAttribute withAttribute:(id)newAttribute newValue:(id)value {
    NSMutableAttributedString *mutableSelf = self.mutableCopy;
    [mutableSelf enumerateAttributesInRange:NSMakeRange(0, mutableSelf.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        id oldValue = attrs[oldAttribute];
        if (oldValue) {
            id newValue = value ?: oldValue;
            [mutableSelf removeAttribute:oldAttribute range:range];
            [mutableSelf addAttribute:newAttribute value:newValue range:range];
        }
    }];
    
    return mutableSelf.copy;
}

@end
