//
//  TBAlertController+Anywhere.m
//  Tic Tac
//
//  Created by Tanner on 6/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBAlertController+Anywhere.h"

@implementation TBAlertController (Anywhere)

- (void)showNow {
    [self showFromViewController:UIApplication.sharedApplication.delegate.window.topMostViewController];
}

@end
