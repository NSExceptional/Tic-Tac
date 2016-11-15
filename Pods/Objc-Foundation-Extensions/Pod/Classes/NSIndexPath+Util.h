//
//  NSIndexPath+Util.h
//  Luna
//
//  Created by Tanner on 2/9/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSIndexPath (Util)

+ (NSArray *)indexPathsInSection:(NSUInteger)section inRange:(NSRange)range;
+ (NSArray *)indexPathsInSection:(NSUInteger)section withIndexes:(NSIndexSet *)indexes;
+ (NSArray *)indexPathsForArrayToAppend:(NSUInteger)appendCount to:(NSUInteger)currentCount;

@end


@interface NSMoveIndexPath : NSObject

@property (nonatomic, readonly) NSIndexPath *from;
@property (nonatomic, readonly) NSIndexPath *to;
+ (instancetype)moveFrom:(NSIndexPath *)initial to:(NSIndexPath *)final;
+ (NSArray *)movesWithInitialIndexPaths:(NSArray *)initial andFinalIndexPaths:(NSArray *)final;

@end
