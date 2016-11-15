//
//  NSIndexPath+Util.m
//  Luna
//
//  Created by Tanner on 2/9/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSIndexPath+Util.h"

@implementation NSIndexPath (Util)

+ (NSArray *)indexPathsInSection:(NSUInteger)section inRange:(NSRange)range {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger row = range.location; row < range.location + range.length; row++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    
    return indexPaths.copy;
}

+ (NSArray *)indexPathsInSection:(NSUInteger)section withIndexes:(NSIndexSet *)indexes {
    NSParameterAssert(indexes);
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }];
    
    return indexPaths.copy;
}

+ (NSArray *)indexPathsForArrayToAppend:(NSUInteger)appendCount to:(NSUInteger)currentCount {
    NSMutableArray *indexPaths   = [[NSMutableArray alloc] initWithCapacity:appendCount];
    
    for (NSUInteger index = 0; index < appendCount; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentCount + index inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    return indexPaths.copy;
}

@end

@implementation NSMoveIndexPath

+ (instancetype)moveFrom:(NSIndexPath *)initial to:(NSIndexPath *)final {
    return [[self alloc] initWithInitial:initial andFinal:final];
}

- (id)initWithInitial:(NSIndexPath *)initial andFinal:(NSIndexPath *)final {
    NSParameterAssert(initial); NSParameterAssert(final);
    self = [super init];
    if (self) {
        _from = initial;
        _to   = final;
    }
    
    return self;
}

+ (NSArray *)movesWithInitialIndexPaths:(NSArray *)initial andFinalIndexPaths:(NSArray *)final {
    NSParameterAssert(initial.count == final.count);
    NSMutableArray *moves = [NSMutableArray array];
    for (NSUInteger i = 0; i < initial.count; i++)
        [moves addObject:[NSMoveIndexPath moveFrom:initial[i] to:initial[i]]];
    return moves.copy;
}

@end