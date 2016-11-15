//
//  NSIndexSet+Util.m
//  Luna
//
//  Created by Tanner on 1/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSIndexSet+Util.h"

@implementation NSIndexSet (Util)

+ (instancetype)indexSetByInvertingRange:(NSRange)range withLength:(NSUInteger)length {
    
    NSRange firstHalf  = NSMakeRange(0, range.location);
    NSRange secondHalf = NSMakeRange(NSMaxRange(range), length-NSMaxRange(range));
    
    NSMutableIndexSet *ivnerted = [NSMutableIndexSet indexSet];
    [ivnerted addIndexesInRange:firstHalf];
    [ivnerted addIndexesInRange:secondHalf];
    
    return ivnerted;
}

+ (instancetype)indexSetWithoutIndexes:(NSIndexSet *)indexes inRange:(NSRange)range {
    NSParameterAssert(indexes);
    NSMutableIndexSet *set = [NSMutableIndexSet new];
    
    for (NSUInteger i = range.location; i < range.location + range.length; i++)
        if (![indexes containsIndex:i])
            [set addIndex:i];
    
    return set.copy;
}

+ (instancetype)indexPathsInFirstSectionInCollection:(NSArray *)collection {
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    
    for (NSIndexPath *ip in collection)
        if (ip.section == 0)
            [indexes addIndex:ip.row];
    
    return indexes.copy;
}

@end
