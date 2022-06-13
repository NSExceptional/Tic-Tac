//
//  YYNotification+Util.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/10/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "YYNotification+Util.h"


@implementation YYNotification (Util)

- (NSString *)notificationHeadline {
    return self.subject;
}

- (BOOL)navigatesToYak {
    return self.reason == YYNotificationReasonYourYak || self.reason == YYNotificationReasonUpvotes;
}

@end
