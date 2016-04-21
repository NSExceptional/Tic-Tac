//
//  NSArray.h
//  Luna
//
//  Created by Tanner on 1/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Util)

- (NSArray *)objectsAtOddIndexes;
- (NSArray *)objectsAtEvenIndexes;
- (NSIndexSet *)oddIndexes;
- (NSIndexSet *)evenIndexes;

- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index;

- (NSArray *)filteredArrayWhereProperty:(NSString *)property equals:(id)value;

- (void)writeToBinaryFile:(NSString *)path atomically:(BOOL)atomically;

/// Will never return nil.
- (NSString *)JSONString;

@end
