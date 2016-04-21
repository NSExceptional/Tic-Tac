//
//  UITableView+Util.m
//  Luna
//
//  Created by Tanner on 3/8/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UITableView+Util.h"
#import "NSIndexPath+Util.h"

@implementation UITableView (Util)

- (void)performUpdate:(TBTableUpdate *)update {
    [self performUpdate:update deleteAnimation:UITableViewRowAnimationLeft insertAnimation:UITableViewRowAnimationTop];
}

- (void)performUpdate:(TBTableUpdate *)update deleteAnimation:(UITableViewRowAnimation)deleteAnimation insertAnimation:(UITableViewRowAnimation)insertAnimation {
    [self beginUpdates];
    [self insertRowsAtIndexPaths:update.insert withRowAnimation:insertAnimation];
    [self deleteRowsAtIndexPaths:update.remove withRowAnimation:deleteAnimation];
    for (NSMoveIndexPath *move in update.move)
        [self moveRowAtIndexPath:move.from toIndexPath:move.to];
    [self endUpdates];
    [self reloadRowsAtIndexPaths:update.reload withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section {
    [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section {
    [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section {
    [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)insertSection:(NSUInteger)section {
    [self insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadSection:(NSUInteger)section {
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

#pragma mark - UITableViewDiff
@interface UITableViewDiff : NSObject
@property (nonatomic, readonly) NSArray *moves;      // Array of `NSMoveIndexPath`s
@property (nonatomic, readonly) NSArray *deletions;  // array of `NSIndexPath`s
@property (nonatomic, readonly) NSArray *insertions; // Array of `NSIndexPath`s
@end

@implementation UITableViewDiff

+ (instancetype)diffInitial:(NSArray *)initial final:(NSArray *)final {
    NSParameterAssert(initial); NSParameterAssert(final);
    
    NSSet *initialSet = [NSSet setWithArray:initial];
    NSSet *finalSet   = [NSSet setWithArray:final];
    NSSet *insertSet  = ({
        NSMutableSet *set = finalSet.mutableCopy;
        [set minusSet:initialSet];
        set.copy;
    });
    NSSet *deleteSet  = ({
        NSMutableSet *set = initialSet.mutableCopy;
        [set minusSet:finalSet];
        set.copy;
    });
    
    NSArray *moves      = [UITableViewDiff indexPathsForMovesFrom:initial to:final withInsertions:insertSet andDeletions:deleteSet];
    NSArray *deletions  = [UITableViewDiff indexPathsForDeletions:deleteSet inArray:initial];
    NSArray *insertions = [UITableViewDiff indexPathsForInsertions:insertSet inArray:final];
    return [[UITableViewDiff alloc] initWithMoves:moves deletions:deletions andInsertions:insertions];
}

- (id)initWithMoves:(NSArray *)move deletions:(NSArray *)delete andInsertions:(NSArray *)insert {
    NSParameterAssert(move); NSParameterAssert(delete); NSParameterAssert(insert);
    
    self = [super init];
    if (self) {
        _moves      = move;
        _deletions  = delete;
        _insertions = insert;
    }
    
    return self;
}

+ (NSArray *)indexPathsForMovesFrom:(NSArray *)initial to:(NSArray *)final withInsertions:(NSSet *)insertions andDeletions:(NSSet *)deletions {
    __block NSInteger delta = 0;
    NSMutableArray *moves   = [NSMutableArray array];
    
    [initial enumerateObjectsUsingBlock:^(id objInitial, NSUInteger leftIdx, BOOL *stop) {
        if ([deletions containsObject:objInitial]) {
            delta++;
            return;
        }
        
        NSUInteger localDelta = delta;
        
        for (NSUInteger rightIdx = 0; rightIdx < final.count; rightIdx++) {
            id objFinal = final[rightIdx];
            if ([insertions containsObject:objFinal]) {
                localDelta--;
                continue;
            }
            
            if ([objFinal isEqual:objInitial]) {
                NSInteger adjustedRightIdx = rightIdx + localDelta;
                if (leftIdx != rightIdx && adjustedRightIdx != leftIdx) {
                    NSIndexPath *from = [NSIndexPath indexPathForRow:leftIdx inSection:0];
                    NSIndexPath *to   = [NSIndexPath indexPathForRow:rightIdx inSection:0];
                    [moves addObject:[NSMoveIndexPath moveFrom:from to:to]];
                }
            }
        }
    }];
    
    return moves.copy;
}

+ (NSArray *)indexPathsForInsertions:(NSSet *)insert inArray:(NSArray *)final {
    NSMutableArray *result = [NSMutableArray array];
    [final enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([insert containsObject:obj])
            [result addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    return result.copy;
}

+ (NSArray *)indexPathsForDeletions:(NSSet *)delete inArray:(NSArray *)initial {
    NSMutableArray *result = [NSMutableArray array];
    [initial enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([delete containsObject:obj])
            [result addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    return result.copy;
}

@end

#pragma mark - TBTableUpdate
#pragma mark -

@implementation TBTableUpdate

#pragma mark Initializers

+ (instancetype)firstSectionInsert:(NSIndexSet *)insert delete:(NSIndexSet *)delete  moveFrom:(NSIndexSet *)from moveTo:(NSIndexSet *)to reload:(NSIndexSet *)reload {
    NSArray *removals   = [NSIndexPath indexPathsInSection:0 withIndexes:delete];
    NSArray *insertions = [NSIndexPath indexPathsInSection:0 withIndexes:insert];
    NSArray *moveFrom   = [NSIndexPath indexPathsInSection:0 withIndexes:from];
    NSArray *moveTo     = [NSIndexPath indexPathsInSection:0 withIndexes:to];
    NSArray *refreshes  = [NSIndexPath indexPathsInSection:0 withIndexes:reload];
    
    return [[TBTableUpdate alloc] initWithInsertions:insertions andDeletions:removals andRefreshes:refreshes moveFrom:moveFrom to:moveTo];
}

+ (instancetype)updateInsert:(NSArray *)insert delete:(NSArray *)delete moveFrom:(NSArray *)from moveTo:(NSArray *)to reload:(NSArray *)reload {
    return [[self alloc] initWithInsertions:insert andDeletions:delete andRefreshes:reload moveFrom:from to:to];
}

+ (instancetype)updateFromDataSource:(NSArray *)initial toDataSource:(NSArray *)final {
    return [[self alloc] initWithTableViewDiff:[UITableViewDiff diffInitial:initial final:final]];
}

- (id)init {
    self = [super init];
    if (self) {
        _insert = @[];
        _remove = @[];
        _move   = @[];
        _reload = @[];
    }
    
    return self;
}

- (id)initWithTableViewDiff:(UITableViewDiff *)diff {
    NSParameterAssert(diff);
    
    self = [super init];
    if (self) {
        _insert = diff.insertions;
        _remove = diff.deletions;
        _move   = diff.moves;
        _reload = ({
            NSMutableArray *reloads = [NSMutableArray array];
            for (NSMoveIndexPath *move in diff.moves)
                [reloads addObject:move.to];
            reloads.copy;
        });
    }
    
    return self;
}

- (id)initWithInsertions:(NSArray *)insertions andDeletions:(NSArray *)deletions andRefreshes:(NSArray *)refreshes moveFrom:(NSArray *)from to:(NSArray *)to {
    NSParameterAssert(deletions); NSParameterAssert(insertions); NSParameterAssert(refreshes); NSParameterAssert(from && to);
    NSParameterAssert(from.count == to.count);
    
    self = [super init];
    if (self) {
        _insert = insertions;
        _remove = deletions;
        _move   = [NSMoveIndexPath movesWithInitialIndexPaths:from andFinalIndexPaths:to];
        _reload = refreshes;
    }
    
    return self;
}

@end