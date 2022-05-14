//
//  NSError+Display.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSError+Display.h"


@implementation NSError (Display)

- (void)show {
    [UIApplication.sharedApplication.windows.firstObject.rootViewController displayOptionalError:self];
}

- (void)showWithTitle:(NSString *)message {
    [UIApplication.sharedApplication.windows.firstObject.rootViewController displayOptionalError:self message:message];
}

@end
