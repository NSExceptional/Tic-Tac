//
//  TTFeedArray.h
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSArray * _Nonnull (^ArraySourceBlock)();


NS_ASSUME_NONNULL_BEGIN
@interface TTFeedArray<ObjectType> : NSMutableArray<ObjectType>

@property (nonatomic, readonly) NSArray<ObjectType> *array;
@property (nonatomic, readonly) NSArray<ObjectType> *removed;
@property (nonatomic, readonly) NSArray<ObjectType> *allObjects;

@property (nonatomic) ArraySourceBlock removedObjectsPool;

@property (nonatomic, copy) ObjectType (^chooseDuplicate)(ObjectType original, ObjectType duplicate);
@property (nonatomic, copy) NSPredicate *filter;
/// Defaults to "created"
@property (nonatomic, copy, nonnull) NSString *sortDescriptorKey;

/// Defaults to NO
@property (nonatomic) BOOL sortNewestFirst;
/// Defaults to YES
@property (nonatomic) BOOL keepsRemovedObjectsInHistory;
/// Defaults to YES
@property (nonatomic) BOOL tagsRemovedObjects;

@property (nonatomic) NSInteger tag;

+ (nullable YYYak *)yakForNotificationIfPresent:(YYNotification *)notification;

@end
NS_ASSUME_NONNULL_END
