//
//  Tic-Tac-Constants.h
//  Tic Tac
//
//  Created by Tanner on 5/2/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kPref_unusedUserIdentifier;
extern NSString * const kPref_handlesToUserIdentifiers;
extern NSString * const kPref_currentUserIdentifier;
extern NSString * const kPref_otherUserIdentifiers;
extern NSString * const kPref_refreshFeedOnUserChange;
extern NSString * const kPref_clearHistoryAfterDays;
extern NSString * const kPref_showBlockedContent;


#pragma mark Functions
extern BOOL YYContainsPolitics(NSString *string);
extern BOOL YYContainsThirst(NSString *string);