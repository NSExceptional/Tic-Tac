//
//  UILabel+Util.m
//  Luna
//
//  Created by Tanner on 2/15/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UILabel+Util.h"

@implementation UILabel (Util)

- (void)incrementText {
    self.text = @(self.text.integerValue+1).stringValue;
}

- (void)decrementText {
    self.text = @(self.text.integerValue-1).stringValue;
}

@end
