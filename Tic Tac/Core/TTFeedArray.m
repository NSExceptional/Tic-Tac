//
//  TTFeedArray.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTFeedArray.h"


static NSSortDescriptor *sortDescriptor;

@interface TTFeedArray<ObjectType> ()
@property (nonatomic, readonly) NSMutableArray *storage;
@property (nonatomic, readonly) NSMutableOrderedSet *history;
@property (nonatomic) BOOL staysSorted;
@end

@implementation TTFeedArray

+ (NSSortDescriptor *)sortDescriptor:(BOOL)ascending {
    return [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:ascending];
}

+ (instancetype)array {
    return [self new];
}

- (id)init {
    self = [super init];
    if (self) {
        _storage = [NSMutableArray array];
        _staysSorted = YES;
        _sortNewestFirst = NO;
        _keepsRemovedObjectsInHistory = YES;
        _tagsRemovedObjects = YES;
        
        self.chooseDuplicate = ^id(YYVotable *orig, YYVotable *dup) {
            return dup;
        };
        self.filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return YES;
        }];
    }
    
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    return self.storage[index];
}

/// Replaces duplicates or old objects, keeps removed in history
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    id old = self.storage[idx];
    if ([old isEqual:obj]) {
        obj = self.chooseDuplicate(old, obj);
    } else if (self.keepsRemovedObjectsInHistory) {
        [self addObjectToHistory:old];
    }
    
    self.storage[idx] = obj;
}

- (void)addObject:(id)anObject {
    [self addObjectNoSort:anObject];
    [self.storage sortUsingDescriptors:@[[TTFeedArray sortDescriptor:self.sortNewestFirst]]];
}

/// Replaces duplicate ones, does nothing for existing ones, adds new ones
- (void)addObjectNoSort:(id)new {
    NSArray *storage = self.storage.copy;
    for (id orig in storage) {
        if ([orig isEqual:new]) {
            [self maybeAddExistingObject:new orig:orig];
            return;
        }
    }
    
    // New object
    [self.storage addObject:new];
}

/// Assumes new and orig are equal
- (void)maybeAddExistingObject:(id)new orig:(id)orig {
    id replacement = self.chooseDuplicate(orig, new);
    // Object exists already, not replaced, nothing to do
    if (replacement == orig) { return; }
    
    // Object exists already, will be replaced, we're done
    NSInteger i = [self.storage indexOfObject:orig];
    self.storage[i] = replacement;
}

- (void)addObjectsFromArray:(NSArray *)toAdd {
    NSMutableArray *toAddToStorage = toAdd.mutableCopy;
    //    [toAddToStorage filterUsingPredicate:self.filter];
    
    // Replace duplicates in storage, remove duplicates
    // from "to add to storage"
    NSMutableArray *storage = self.storage.copy;
    for (id new in toAdd)
        for (id orig in storage)
            if ([orig isEqual:new]) {
                // Old or new obj exists, do not add again
                [toAddToStorage removeObject:new];
                [self maybeAddExistingObject:new orig:orig];
            }
    
    // Add, sort
    [self.storage addObjectsFromArray:toAddToStorage];
    [self.storage sortUsingDescriptors:@[[TTFeedArray sortDescriptor:self.sortNewestFirst]]];
}

- (NSUInteger)count { return self.storage.count; }

- (NSArray<id> *)array {
    return self.storage.copy;
}

- (NSArray<id> *)removed {
    return self.history.array;
}

- (NSArray<id> *)allObjects {
    NSMutableArray *tmp = self.storage.mutableCopy;
    [tmp addObjectsFromArray:self.history.array];
    return [tmp sortedArrayUsingDescriptors:@[[TTFeedArray sortDescriptor:self.sortNewestFirst]]];
}

- (void)setKeepsRemovedObjectsInHistory:(BOOL)keepsRemovedObjectsInHistory {
    if (_keepsRemovedObjectsInHistory == keepsRemovedObjectsInHistory) return;
    _keepsRemovedObjectsInHistory = keepsRemovedObjectsInHistory;
    
    if (keepsRemovedObjectsInHistory) {
        _history = [NSMutableOrderedSet orderedSet];
    } else {
        _history = nil;
    }
}

- (void)setArray:(NSArray *)newFeed {
    if (self.keepsRemovedObjectsInHistory) {
        // Store removed objects in history by getting diff from new feed
        NSMutableSet *removed = [NSMutableSet setWithArray:self.storage];
        [removed minusSet:[NSSet setWithArray:newFeed]];
        [self addObjectsToHistory:removed.allObjects];
    }
    
    [self.storage setArray:newFeed];
}

- (void)removeObject:(id)anObject {
    NSInteger idx = [self.storage indexOfObject:anObject];
    
    if (idx != NSNotFound) {
        self.storage[idx] = self.chooseDuplicate(self.storage[idx], anObject);
        [self removeObjectAtIndex:idx];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    id obj = self.storage[idx];
    
    [self.storage removeObjectAtIndex:idx];
    if (_keepsRemovedObjectsInHistory) {
        [self addObjectsToHistory:obj];
    }
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    for (id obj in otherArray)
        [self removeObject:obj];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObjectAtIndex:idx];
    }];
}

- (void)removeObjectsInRange:(NSRange)range {
    NSUInteger max = range.location + range.length;
    for (NSUInteger i = range.location; i < max; i++)
        [self removeObjectAtIndex:i];
}

- (void)addObjectToHistory:(id)anObject {
    [self.history addObject:anObject];
    if (self.tagsRemovedObjects) {
        [(YYVotable *)anObject setRemoved:YES];
    }
}

- (void)addObjectsToHistory:(NSArray *)toAdd {
    [self.history addObjectsFromArray:toAdd];
    if (self.tagsRemovedObjects) {
        for (YYVotable *votable in toAdd)
            votable.removed = YES;
    }
}

@end
