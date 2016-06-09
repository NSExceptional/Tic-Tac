//
//  TTFeedArray.h
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface TTFeedArray<ObjectType> : NSMutableArray<ObjectType>

@property (nonatomic, readonly) NSArray<ObjectType> *array;

@property (nonatomic, copy, nonnull) ObjectType (^chooseDuplicate)(ObjectType original, ObjectType duplicate);
@property (nonatomic, copy, nonnull) NSPredicate *filter;

/// Defaults to NO
@property (nonatomic) BOOL sortNewestFirst;
/// Defaults to YES
@property (nonatomic) BOOL keepsRemovedObjectsInHistory;

@end
NS_ASSUME_NONNULL_END
