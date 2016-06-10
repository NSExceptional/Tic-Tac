//
//  YYNotification+Util.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/10/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "YYNotification+Util.h"


@implementation YYNotification (Util)

- (BOOL)isPostReply {
    return [self.subject isEqualToString:@"New reply"];
}

- (NSString *)notificationHeadline {
    switch (self.reason) {
        case YYNotificationReasonUnspecified:
        case YYNotificationReasonHandleRemoved:
        case YYNotificationReasonVote:
            return self.subject;
        case YYNotificationReasonComment:
            return self.isPostReply ? @"Post reply" : @"Comment reply";
    }
}

@end
