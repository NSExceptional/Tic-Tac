//
//  NSUserDefaults+Preferences.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSUserDefaults+Preferences.h"

#define DEFAULT [NSUserDefaults standardUserDefaults]
@implementation NSUserDefaults (Preferences)

+ (BOOL)refreshFeedOnUserChange {
    return [DEFAULT boolForKey:kPref_RefreshFeedOnUserChange];
}

+ (void)setRefreshFeedOnUserChange:(BOOL)pref {
    [DEFAULT setBool:pref forKey:kPref_RefreshFeedOnUserChange];
}


+ (NSString *)currentUserIdentifier {
    return [DEFAULT stringForKey:kPref_CurrentUserIdentifier];
}

+ (void)setCurrentUserIdentifier:(NSString *)pref {
    [DEFAULT setObject:pref forKey:kPref_CurrentUserIdentifier];
}

+ (NSArray<NSString*> *)otherUserIdentifiers {
    return [DEFAULT arrayForKey:kPref_OtherUserIdentifiers];
}

+ (void)setOtherUserIdentifiers:(NSArray<NSString*> *)pref {
    [DEFAULT setObject:pref forKey:kPref_OtherUserIdentifiers];
}

// TODO other stuff

+ (NSOrderedSet<YYYak*> *)history {return nil;}
+ (void)addToHistory:(YYYak *)pref {}
+ (NSInteger)daysToKeepHistory {return 0;}
+ (void)setDaysToKeepHistory:(NSInteger)pref {}

+ (NSOrderedSet<NSString*> *)visitedPosts {return nil;}
+ (void)addVisitedPost:(NSString *)pref {}


@end
