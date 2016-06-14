//
//  TTCache.h
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface TTCache : NSObject

/// 5k latest yaks loaded, no older than N days
+ (NSOrderedSet<YYYak*> *)yakCache;
+ (void)addToYakCache:(YYYak *)yak;

+ (nullable NSArray<YYComment*> *)commentsForYakWithIdentifier:(NSString *)identifier;
+ (void)cacheComments:(NSArray<YYComment*> *)comments forYak:(YYYak *)yak;

/// The last 10k yaks visited by identifier
+ (NSOrderedSet<NSString*> *)visitedPosts;
+ (void)addVisitedPost:(NSString *)pref;

@end
NS_ASSUME_NONNULL_END
