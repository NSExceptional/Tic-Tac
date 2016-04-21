//
//  NSUserDefaults+Preferences.h
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSUserDefaults (Preferences)

+ (BOOL)refreshFeedOnUserChange;
+ (void)setRefreshFeedOnUserChange:(BOOL)pref;

+ (NSString *)currentUserIdentifier;
+ (void)setCurrentUserIdentifier:(NSString *)pref;
+ (NSArray<NSString*> *)otherUserIdentifiers;
+ (void)setOtherUserIdentifiers:(NSArray<NSString*> *)pref;

// Will be saved externally //

+ (NSOrderedSet<YYYak*> *)history;
+ (void)addToHistory:(YYYak *)pref;
+ (NSInteger)daysToKeepHistory;
+ (void)setDaysToKeepHistory:(NSInteger)pref;

+ (NSOrderedSet<NSString*> *)visitedPosts;
+ (void)addVisitedPost:(NSString *)pref;

@end
