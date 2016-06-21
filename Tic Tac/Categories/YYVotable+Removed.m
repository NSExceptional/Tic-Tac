//
//  YYVotable+Removed.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "YYVotable+Removed.h"


static NSInteger const kOldWasRemovedTagValue = 0xdeadbabe;

NS_OPTIONS(NSUInteger, YYVotableObjectStatus) {
    YYVotableObjectStatusRemoved = 1 << 0,
    YYVotableObjectStatusBlocked = 1 << 1
};

#define TTBitmaskBOOLProperty(get, set, backing, flag) \
- (BOOL) get { return backing & flag; }\
- (void) set :(BOOL)var {\
    if (var) { backing |= flag; \
    } else { backing &= ~flag; } \
}

@implementation YYVotable (Removed)

- (BOOL)removed {
    // Delete a week from JUNE 21
    if (self.tag == kOldWasRemovedTagValue) {
        self.tag = 0; self.removed = YES;
    }
    
    return self.tag & YYVotableObjectStatusRemoved;
}

- (void)setRemoved:(BOOL)removed {
    if (removed) {
        self.tag |= YYVotableObjectStatusRemoved;
    } else {
        self.tag &= ~YYVotableObjectStatusRemoved;
    }
}

TTBitmaskBOOLProperty(blocked, setBlocked, self.tag, YYVotableObjectStatusBlocked)

@end
