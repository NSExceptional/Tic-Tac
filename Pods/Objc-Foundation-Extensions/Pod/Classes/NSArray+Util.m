//
//  NSArray.m
//  Luna
//
//  Created by Tanner on 1/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSArray+Util.h"

@implementation NSArray (Util)



- (NSArray *)objectsAtOddIndexes {
    NSParameterAssert(self);
    NSMutableArray *odd = [NSMutableArray array];
    
    for (NSUInteger i = 1; i < self.count; i += 2)
        [odd addObject:self[i]];
    
    return odd.copy;
}

- (NSArray *)objectsAtEvenIndexes {
    NSParameterAssert(self);
    NSMutableArray *even = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < self.count; i += 2)
        [even addObject:self[i]];
    
    return even.copy;
}

- (NSIndexSet *)oddIndexes {
    NSMutableIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.count)].mutableCopy;
    for (NSUInteger i = 0; i < self.count; i += 2)
        [set removeIndex:i];
    
    return set.copy;
}

- (NSIndexSet *)evenIndexes {
    NSMutableIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.count)].mutableCopy;
    for (NSUInteger i = 1; i < self.count; i += 2)
        [set removeIndex:i];
    
    return set.copy;
}

- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index {
    NSMutableArray *mutable = self.mutableCopy;
    [mutable removeObjectAtIndex:index];
    return mutable.copy;
}

- (NSArray *)filteredArrayWhereProperty:(NSString *)property equals:(id)value {
    NSParameterAssert(property); NSParameterAssert(value);
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", property, value];
    return [self filteredArrayUsingPredicate:filter];
}

- (void)writeToBinaryFile:(NSString *)path atomically:(BOOL)atomically {
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if (error)
        [NSException raise:NSInternalInconsistencyException format:@"%@", error.localizedDescription];
    [data writeToFile:path atomically:atomically];
}

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"[]";
}

@end
