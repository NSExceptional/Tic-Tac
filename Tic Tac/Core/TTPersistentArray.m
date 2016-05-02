//
//  TTPersistentArray.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTPersistentArray.h"


static NSSortDescriptor *sortDescriptor;

@interface TTPersistentArray<ObjectType> ()
@property (nonatomic, readonly) NSMutableArray *storage;
@property (nonatomic) BOOL staysSorted;
@end

@implementation TTPersistentArray

+ (NSSortDescriptor *)sortDescriptor {
    @synchronized(self) {
        if (sortDescriptor) {
            return sortDescriptor;
        } else {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
            return sortDescriptor;
        }
    }
}

+ (instancetype)array {
    return [self new];
}

- (id)init {
    self = [super init];
    if (self) {
        _storage = [NSMutableArray array];
        _staysSorted = YES;
        
        self.chooseDuplicate = ^id(YYVotable *orig, YYVotable *dup) {
            return dup;
        };
    }
    
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    return self.storage[index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    self.storage[idx] = obj;
}

- (void)addObject:(id)anObject {
    for (id orig in self.storage)
        if ([orig isEqual:anObject])
            anObject = self.chooseDuplicate(orig, anObject);
    
    [self.storage addObject:anObject];
    [self.storage sortUsingDescriptors:@[[TTPersistentArray sortDescriptor]]];
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    // Replace duplicates with the one we want to keep
    NSMutableArray *mutableOriginal = self.storage.mutableCopy;
    for (id orig in self.storage)
        for (id new in otherArray)
            if ([orig isEqual:new]) {
                id replacement = self.chooseDuplicate(orig, new);
                if (replacement == orig) continue;
                
                NSInteger i = [mutableOriginal indexOfObject:orig];
                mutableOriginal[i] = new;
            }
    
    
    [self.storage addObjectsFromArray:otherArray];
    [self.storage sortUsingDescriptors:@[[TTPersistentArray sortDescriptor]]];
}

- (NSUInteger)count { return self.storage.count; }

@end
