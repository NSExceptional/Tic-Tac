//
//  NSString+SplitUp.m
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSString+SplitUp.h"


@implementation NSString (SplitUp)

- (NSArray<NSString*> *)brokenUpByCharacterLimit:(NSUInteger)limit {
    if (self.length < limit) return @[self];
    
    NSUInteger idx = limit;
    char c;
    do {
        c = [self characterAtIndex:idx--];
    } while (c != ' ' && idx > 0);
    
    if (idx == 0) {
        NSString *next = [@"…" stringByAppendingString:[self substringWithRange:NSMakeRange(limit-1, self.length - limit-1)]];
        return [@[[[self substringToIndex:limit-1] stringByAppendingString:@"…"]] arrayByAddingObjectsFromArray:[next brokenUpByCharacterLimit:limit]];
    } else {
        NSString *next = [self substringWithRange:NSMakeRange(idx+2, self.length - idx-2)];
        return [@[[self substringToIndex:idx+1]] arrayByAddingObjectsFromArray:[next brokenUpByCharacterLimit:limit]];
    }
}

@end
