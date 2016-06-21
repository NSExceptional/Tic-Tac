//
//  TTProfileViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTProfileViewController.h"
#import "TTWelcomeViewController.h"

@implementation TTProfileViewController


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kYYDidUpdateUserNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add new user
    id item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUserButtonPressed)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)updateTitle {
    YYUser *user = [YYClient sharedClient].currentUser;
    self.title = user.handle ? [NSString stringWithFormat:@"%@ | %@", user.handle, @(user.karma).stringValue] : @(user.karma).stringValue;
}

- (void)addUserButtonPressed {
    UINavigationController *nav = [TTWelcomeViewController inNavigationController];
    TTWelcomeViewController *welcome = nav.viewControllers.firstObject;
    
    id cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nav action:@selector(dismissAnimated)];
    welcome.navigationItem.leftBarButtonItem = cancel;
    
    [self presentViewController:nav animated:YES completion:nil];
}

@end
