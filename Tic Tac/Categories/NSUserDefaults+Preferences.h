//
//  NSUserDefaults+Preferences.h
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSUserDefaults (Preferences)

#pragma mark Prefs
+ (BOOL)showBlockedContent;
+ (void)setShowBlockedContent:(BOOL)pref;

+ (BOOL)refreshFeedOnUserChange;
+ (void)setRefreshFeedOnUserChange:(BOOL)pref;

/// Defaults to 7
+ (NSInteger)daysToKeepHistory;
+ (void)setDaysToKeepHistory:(NSInteger)pref;

#pragma mark Users
+ (NSArray<NSString*> *)allUserIdentifiers;

+ (NSString *)unusedUserIdentifier;
+ (void)setUnusedUserIdentifier:(NSString *)unused;

+ (NSString *)currentUserIdentifier;
+ (void)setCurrentUserIdentifier:(NSString *)pref;

+ (NSArray<NSString*> *)otherUserIdentifiers;
+ (void)setOtherUserIdentifiers:(NSArray<NSString*> *)pref;

+ (NSString *)handleForUserIdentifier:(NSString *)userid;
+ (void)setHandle:(NSString *)handle forUserIdentifier:(NSString *)userid;

@end
