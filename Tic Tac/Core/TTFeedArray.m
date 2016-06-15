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
@property (nonatomic) BOOL staysSorted;
@property (nonatomic) BOOL delta;
@end

@implementation TTFeedArray
@synthesize allObjects = _allObjects;

#pragma mark New public interface

+ (nullable YYYak *)yakForNotificationIfPresent:(YYNotification *)notification {
    for (YYYak *yak in [TTCache yakCache])
        if ([yak.identifier isEqualToString:notification.thingIdentifier])
            return yak;
    
    return nil;
}

#pragma mark Overrides

- (NSSortDescriptor *)sortDescriptor:(BOOL)ascending {
    return [NSSortDescriptor sortDescriptorWithKey:self.sortDescriptorKey ascending:ascending];
}

+ (instancetype)array {
    return [self new];
}

- (id)init {
    self = [super init];
    if (self) {
        _storage            = [NSMutableArray array];
        _staysSorted        = YES;
        _sortNewestFirst    = NO;
        _tagsRemovedObjects = YES;
        self.sortDescriptorKey = @"created";
        self.removedObjectsPool = ^NSArray* { return @[]; };
        
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
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx { self.delta = YES;
    id old = self.storage[idx];
    if ([old isEqual:obj]) {
        obj = self.chooseDuplicate(old, obj);
    } else if (self.tagsRemovedObjects) {
        [self tagRemovedObjects:@[old]];
    }
    
    self.storage[idx] = obj;
}

- (void)addObject:(id)anObject { self.delta = YES;
    [self addObjectNoSort:anObject];
    [self.storage sortUsingDescriptors:@[[self sortDescriptor:self.sortNewestFirst]]];
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

- (void)addObjectsFromArray:(NSArray *)toAdd { self.delta = YES;
    NSMutableArray *toAddToStorage = toAdd.mutableCopy;
    [toAddToStorage filterUsingPredicate:self.filter];
    
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
    [self.storage sortUsingDescriptors:@[[self sortDescriptor:self.sortNewestFirst]]];
}

- (NSUInteger)count { return self.storage.count; }

- (NSArray<id> *)array {
    return self.storage.copy;
}

- (NSArray<id> *)removed {
    NSMutableOrderedSet *removed = [NSMutableOrderedSet orderedSetWithArray:self.removedObjectsPool()];
    [removed minusSet:[NSSet setWithArray:self.storage]];
    return [removed sortedArrayUsingDescriptors:@[[self sortDescriptor:self.sortNewestFirst]]];
}

- (NSArray<id> *)allObjects {
    NSArray *pool = self.removedObjectsPool();
    if (self.delta || !_allObjects || _allObjects.count != pool.count) {
        _allObjects = [pool sortedArrayUsingDescriptors:@[[self sortDescriptor:self.sortNewestFirst]]];
        self.delta = NO;
        
        // Tag objects that may not yet be identified as missing
        if (self.tagsRemovedObjects) {
            NSMutableSet *set = [NSMutableSet setWithArray:_allObjects];
            [set minusSet:[NSSet setWithArray:self.storage]];
            for (YYVotable *votable in set)
                votable.removed = YES;
        }
    }
    
    return _allObjects;
}

- (void)setArray:(NSArray *)newFeed { self.delta = YES;
    if (self.tagsRemovedObjects) {
        // Store removed objects in history by getting diff from new feed
        NSMutableSet *removed = [NSMutableSet setWithArray:self.storage];
        [removed minusSet:[NSSet setWithArray:newFeed]];
        [self tagRemovedObjects:removed.allObjects];
    }
    
    [self.storage setArray:[newFeed filteredArrayUsingPredicate:self.filter]];
}

- (void)removeObject:(id)anObject { _delta = YES;
    NSInteger idx = [self.storage indexOfObject:anObject];
    
    if (idx != NSNotFound) {
        self.storage[idx] = self.chooseDuplicate(self.storage[idx], anObject);
        [self removeObjectAtIndex:idx];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx { _delta = YES;
    id obj = self.storage[idx];
    
    [self.storage removeObjectAtIndex:idx];
    if (self.tagsRemovedObjects) {
        [self tagRemovedObjects:@[obj]];
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

- (void)tagRemovedObjects:(NSArray *)toAdd {
    for (YYVotable *votable in toAdd)
        votable.removed = YES;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    [self.storage enumerateObjectsUsingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    [self.storage enumerateObjectsWithOptions:opts usingBlock:block];
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id, NSUInteger, BOOL *))block {
    [self.storage enumerateObjectsAtIndexes:s options:opts usingBlock:block];
}

- (NSEnumerator<id> *)objectEnumerator {
    return self.storage.objectEnumerator;
}

- (NSEnumerator<id> *)reverseObjectEnumerator {
    return self.storage.reverseObjectEnumerator;
}

- (id)valueForKeyPath:(NSString *)keyPath {
    return [self.storage valueForKeyPath:keyPath];
}

@end
