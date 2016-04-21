//
//  UIViewController+TicTac.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "UIViewController+TicTac.h"


@implementation UIViewController (TicTac)

+ (UINavigationController *)inNavigationController {
    return [[UINavigationController alloc] initWithRootViewController:[self new]];
}

- (void)displayOptionalError:(NSError *)error {
    if (error) {
        [[TBAlertController simpleOKAlertWithTitle:@"Error" message:error.localizedDescription] showFromViewController:self];
    }
}

@end
