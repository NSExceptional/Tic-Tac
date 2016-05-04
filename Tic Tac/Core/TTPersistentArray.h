//
//  TTPersistentArray.h
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface TTPersistentArray<ObjectType> : NSMutableArray<ObjectType>

@property (nonatomic, copy, nonnull) ObjectType (^chooseDuplicate)(ObjectType original, ObjectType duplicate);
@property (nonatomic, copy, nonnull) NSPredicate *filter;
@property (nonatomic) BOOL sortNewestFirst;

@end
NS_ASSUME_NONNULL_END
