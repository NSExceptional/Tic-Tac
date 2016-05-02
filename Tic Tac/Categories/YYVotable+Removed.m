//
//  YYVotable+Removed.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "YYVotable+Removed.h"


static NSInteger const kWasRemovedTagValue = 0xdeadbabe;

@implementation YYVotable (Removed)

- (BOOL)removed {
    return self.tag == kWasRemovedTagValue;
}

- (void)setRemoved:(BOOL)removed {
    self.tag = removed ? kWasRemovedTagValue : 0;
}

@end
