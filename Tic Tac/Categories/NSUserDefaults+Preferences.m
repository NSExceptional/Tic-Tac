//
//  NSUserDefaults+Preferences.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSUserDefaults+Preferences.h"


static NSMutableOrderedSet *history;
NSMutableOrderedSet *visitedPosts;

#define DEFAULT [NSUserDefaults standardUserDefaults]
@implementation NSUserDefaults (Preferences)

+ (BOOL)refreshFeedOnUserChange {
    return [DEFAULT boolForKey:kPref_refreshFeedOnUserChange];
}

+ (void)setRefreshFeedOnUserChange:(BOOL)pref {
    [DEFAULT setBool:pref forKey:kPref_refreshFeedOnUserChange];
}


+ (NSString *)currentUserIdentifier {
    return [DEFAULT stringForKey:kPref_currentUserIdentifier];
}

+ (void)setCurrentUserIdentifier:(NSString *)pref {
    [DEFAULT setObject:pref forKey:kPref_currentUserIdentifier];
}

+ (NSArray<NSString*> *)otherUserIdentifiers {
    return [DEFAULT arrayForKey:kPref_otherUserIdentifiers];
}

+ (void)setOtherUserIdentifiers:(NSArray<NSString*> *)pref {
    [DEFAULT setObject:pref forKey:kPref_otherUserIdentifiers];
}

// TODO other stuff

+ (NSInteger)daysToKeepHistory {
    return [DEFAULT integerForKey:kPref_clearHistoryAfterDays];
}

+ (void)setDaysToKeepHistory:(NSInteger)pref {
    [DEFAULT setInteger:pref forKey:kPref_clearHistoryAfterDays];
}

@end
