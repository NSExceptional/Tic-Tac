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

+ (NSArray<NSString*> *)allUserIdentifiers {
    NSString *cur = [self currentUserIdentifier];
    return cur ? [[self otherUserIdentifiers] arrayByAddingObject:cur] : [self otherUserIdentifiers];
}

+ (NSString *)currentUserIdentifier {
    return [DEFAULT stringForKey:kPref_currentUserIdentifier];
}

+ (void)setCurrentUserIdentifier:(NSString *)pref {
    [DEFAULT setObject:pref forKey:kPref_currentUserIdentifier];
}

+ (NSArray<NSString*> *)otherUserIdentifiers {
    return @[@"352552DE-C5AC-4FA8-8EE0-F0FC1BF521EA",
             @"92099E85-7D70-4AF1-8F2A-65316CC80F41",
             @"F336DE49-6AE0-4979-AEE5-74919B959762",
             @"91281688-4356-4540-80B8-E25D2AE07BC0"];
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
