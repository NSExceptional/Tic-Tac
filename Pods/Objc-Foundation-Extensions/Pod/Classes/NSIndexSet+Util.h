//
//  NSIndexSet+Util.h
//  Luna
//
//  Created by Tanner on 1/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (Util)

+ (instancetype)indexSetByInvertingRange:(NSRange)range withLength:(NSUInteger)length;
+ (instancetype)indexSetWithoutIndexes:(NSIndexSet *)indexes inRange:(NSRange)range;
+ (instancetype)indexPathsInFirstSectionInCollection:(NSArray<NSIndexPath*> *)collection;

@end
