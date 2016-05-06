//
//  Tic-Tac-Constants.m
//  Tic Tac
//
//  Created by Tanner on 5/2/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "Tic-Tac-Constants.h"


NSString * const kPref_currentUserIdentifier = @"current_user";
NSString * const kPref_otherUserIdentifiers = @"other_users";
NSString * const kPref_refreshFeedOnUserChange = @"refresh_feed_on_user_change";
NSString * const kPref_clearHistoryAfterDays = @"remove_from_history_after";


#pragma mark Functions

BOOL YYContainsPolitics(NSString *string) {
    if ([string containsString:@"trump"] || [string containsString:@"hillary"] || [string containsString:@"bernie"] || [string containsString:@"cruz"] ||
        [string containsString:@"elect"] || [string containsString:@"politic"] || [string containsString:@"candida"] ||
        [string containsString:@"obama"] || [string containsString:@"bush"]    || [string containsString:@"presiden"]) {
        return NO;
    }
    return YES;
}

BOOL YYContainsThirst(NSString *string) {
    if ([string containsString:@"horny"] || [string containsString:@"sex"] || [string containsString:@"get laid"] ||
        [string containsString:@"cuddle"] || [string matchGroupAtIndex:0 forRegex:@"(to|wanna|want to|good|get) fuck"]) {
        return YES;
    }
    
    return NO;
}
