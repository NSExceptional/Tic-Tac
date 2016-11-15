//
//  UISwitch+Util.h
//  Luna
//
//  Created by Tanner on 7/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISwitch (Util)

/** Assumes all control events are value changed. Potentially expensive operation */
- (void)setOnWithoutEvent:(BOOL)on;

@end
