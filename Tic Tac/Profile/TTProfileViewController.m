//
//  TTProfileViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTProfileViewController.h"


@implementation TTProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kYYDidUpdateUserNotification object:nil];
}

- (void)updateTitle {
    YYUser *user = [YYClient sharedClient].currentUser;
    self.title = [NSString stringWithFormat:@"%@ | %@", user.handle ?: @"Me", @(user.karma).stringValue];
}

@end
