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
@property (nonatomic, readonly, class) BOOL showBlockedContent;
@property (nonatomic, readonly, class) BOOL refreshFeedOnUserChange;

/// Defaults to 7
@property (nonatomic, class) NSInteger daysToKeepHistory;

#pragma mark Users
@property (nonatomic, readonly, class) NSArray<NSString*> *allUserIdentifiers;

@property (nonatomic, class) NSString *unusedUserIdentifier;
@property (nonatomic, class) NSString *currentUserIdentifier;
@property (nonatomic, class) NSArray<NSString*> *otherUserIdentifiers;

+ (void)removeOtherUserIdentifier:(NSString *)pref;
+ (NSString *)handleForUserIdentifier:(NSString *)userid;
+ (void)setHandle:(NSString *)handle forUserIdentifier:(NSString *)userid;

@end
