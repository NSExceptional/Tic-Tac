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

#pragma mark Prefs

+ (BOOL)showBlockedContent {
    return YES;
//    return [DEFAULT boolForKey:kPref_showBlockedContent];
}

+ (void)setShowBlockedContent:(BOOL)pref {
    [DEFAULT setBool:pref forKey:kPref_showBlockedContent];
}

+ (BOOL)refreshFeedOnUserChange {
    return [DEFAULT boolForKey:kPref_refreshFeedOnUserChange];
}

+ (void)setRefreshFeedOnUserChange:(BOOL)pref {
    [DEFAULT setBool:pref forKey:kPref_refreshFeedOnUserChange];
}

+ (NSInteger)daysToKeepHistory {
    return [DEFAULT integerForKey:kPref_clearHistoryAfterDays];
}

+ (void)setDaysToKeepHistory:(NSInteger)pref {
    [DEFAULT setInteger:pref forKey:kPref_clearHistoryAfterDays];
}

#pragma mark Users

+ (NSArray<NSString*> *)allUserIdentifiers {
    NSString *cur = [self currentUserIdentifier];
    NSArray *all = cur ? [[self otherUserIdentifiers] arrayByAddingObject:cur] : [self otherUserIdentifiers];
    return [all sortedArrayUsingSelector:@selector(compare:)];
}


+ (NSString *)unusedUserIdentifier {
    return @"F0298880-19F0-4FEA-8357-BD480E621EB8";
//    return [DEFAULT stringForKey:kPref_unusedUserIdentifier];
}

+ (void)setUnusedUserIdentifier:(NSString *)unused {
    NSParameterAssert(unused);
    [DEFAULT setObject:unused forKey:kPref_unusedUserIdentifier];
}


+ (NSString *)currentUserIdentifier {
    return [DEFAULT stringForKey:kPref_currentUserIdentifier];
}

+ (void)setCurrentUserIdentifier:(NSString *)pref {
    NSParameterAssert(pref);
    
    NSString *current = [self currentUserIdentifier];
    if (current && ![current isEqualToString:pref]) {
        NSMutableArray *others = [self otherUserIdentifiers].mutableCopy;
        [others removeObject:pref];
        [others addObject:current];
        [self setOtherUserIdentifiers:others];
    }
    [DEFAULT setObject:pref forKey:kPref_currentUserIdentifier];
}


+ (NSArray<NSString*> *)otherUserIdentifiers {
//    return @[@"352552DE-C5AC-4FA8-8EE0-F0FC1BF521EA",
//             @"92099E85-7D70-4AF1-8F2A-65316CC80F41",
//             @"F336DE49-6AE0-4979-AEE5-74919B959762",
//             @"91281688-4356-4540-80B8-E25D2AE07BC0"];
    return [DEFAULT arrayForKey:kPref_otherUserIdentifiers] ?: @[];
}

+ (void)setOtherUserIdentifiers:(NSArray<NSString*> *)pref {
    NSParameterAssert(pref);
    pref = [pref sortedArrayUsingSelector:@selector(compare:)];
    [DEFAULT setObject:pref forKey:kPref_otherUserIdentifiers];
}

+ (void)removeOtherUserIdentifier:(NSString *)pref {
    NSMutableArray *identifiers = [self otherUserIdentifiers].mutableCopy;
    [identifiers removeObject:pref];
    [self setOtherUserIdentifiers:identifiers];
}


+ (NSString *)handleForUserIdentifier:(NSString *)userid {
    NSParameterAssert(userid);
    return [DEFAULT dictionaryForKey:kPref_handlesToUserIdentifiers][userid];
}

+ (void)setHandle:(NSString *)handle forUserIdentifier:(NSString *)userid {
    NSParameterAssert(handle); NSParameterAssert(userid);
    NSMutableDictionary *handles = [DEFAULT dictionaryForKey:kPref_handlesToUserIdentifiers].mutableCopy ?: [NSMutableDictionary new];
    handles[userid] = handle;
    [DEFAULT setObject:handles forKey:kPref_handlesToUserIdentifiers];
}

@end
