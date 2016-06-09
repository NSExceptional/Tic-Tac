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

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    id old = self.storage[idx];
    if ([old isEqual:obj]) {
        obj = self.chooseDuplicate(old, obj);
    } else {
        [self.history addObject:old];
    }
    
    self.storage[idx] = obj;
}

- (void)addObject:(id)anObject {
    NSArray *storage = self.storage.copy;
    for (id orig in storage) {
        if ([orig isEqual:anObject]) {
            anObject = self.chooseDuplicate(orig, anObject);
            // Object exists already, not replaced, nothing to do
            if (anObject == orig) { return; }
            
            // Object exists already, will be replaced, we're done
            NSInteger i = [self.storage indexOfObject:orig];
            self.storage[i] = anObject;
            return;
        }
    }
    
    // New object
    [self.storage addObject:anObject];
    [self.storage sortUsingDescriptors:@[[TTFeedArray sortDescriptor:self.sortNewestFirst]]];
}

- (void)addObjectsFromArray:(NSArray *)toAdd {
    // Replace duplicates in storage, remove duplicates
    // from "to add to storage"
    NSMutableArray *storage = self.storage.copy;
    NSMutableArray *toAddToStorage = toAdd.mutableCopy;
    for (id orig in storage)
        for (id new in toAdd)
            if ([orig isEqual:new]) {
                id replacement = self.chooseDuplicate(orig, new);
                // Object exists already, not replaced, nothing to do
                if (replacement == orig) { continue; }
                
                // Object exists already, will be replaced, should
                // be removed from the "to add" array
                NSInteger i = [self.storage indexOfObject:orig];
                self.storage[i] = replacement;
                [toAddToStorage removeObject:new];
            }
    
    // Filter remaining objects, add, sort
    [toAddToStorage filterUsingPredicate:self.filter];
    [self.storage addObjectsFromArray:toAddToStorage];
    [self.storage sortUsingDescriptors:@[[TTFeedArray sortDescriptor:self.sortNewestFirst]]];
}

- (NSUInteger)count { return self.storage.count; }

- (NSArray *)array {
    return self.storage.copy;
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
        [self.history addObjectsFromArray:removed.allObjects];
    }
    
    [self.storage setArray:newFeed];
}

- (void)removeObject:(id)anObject {
    NSInteger idx = [self.storage indexOfObject:anObject];
    
    if (idx != NSNotFound) {
        anObject = self.chooseDuplicate(self.storage[idx], anObject);
        
        [self.storage removeObjectAtIndex:idx];
        if (_keepsRemovedObjectsInHistory) {
            [self.history addObject:anObject];
        }
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx {
    id obj = self.storage[idx];
    
    [self.storage removeObjectAtIndex:idx];
    if (_keepsRemovedObjectsInHistory) {
        [self.history addObject:obj];
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

@end
