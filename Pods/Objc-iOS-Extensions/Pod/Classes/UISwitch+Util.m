//
//  UISwitch+Util.m
//  Luna
//
//  Created by Tanner on 7/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UISwitch+Util.h"

@implementation UISwitch (Util)

- (void)setOnWithoutEvent:(BOOL)on {
    if (self.isOn == on) return;
    
    NSArray *targets = self.allTargets.allObjects;
    NSMutableDictionary *actions = [NSMutableDictionary new];
    
    for (id target in targets) {
        NSArray *targetActions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        actions[target] = targetActions;
        for (NSString *action in targetActions)
            [self removeTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventValueChanged];
    }
    
    self.on = on;
    
    for (id target in targets) {
        NSArray *targetActions = actions[target];
        for (NSString *action in targetActions)
            [self addTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventValueChanged];
    }
}

@end
