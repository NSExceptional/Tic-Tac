//
//  TTTabBarController.m
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTTabBarController.h"
#import "TTFeedViewController.h"
#import "TTNotificationsViewController.h"
#import "TTProfileViewController.h"
#import "TTSettingsViewController.h"


@interface TTTabBarController ()
@property (nonatomic, readonly) TTFeedViewController *feed;
@property (nonatomic, readonly) TTNotificationsViewController *notifications;
@property (nonatomic, readonly) TTProfileViewController *profile;
@property (nonatomic, readonly) TTSettingsViewController *settings;

@property (nonatomic) BOOL ready;
@end

@implementation TTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllers = @[TTFeedViewController.inNavigationController,
                             [TTNotificationsViewController inNavigationController],
                             [UIViewController inNavigationController],
                             [TTProfileViewController inNavigationController]];
    
    NSArray *icons = @[@"tab_feed", @"tab_notifications", @"tab_chat", @"tab_profile", @"tab_settings"];
    NSArray *titles = @[@"Feed", @"Notifications", @"Chat", @"Profile", @"Settings"];
    
    NSInteger i = 0;
    for (UITabBarItem *item in self.tabBar.items) {
        item.image = [UIImage imageNamed:icons[i]];
        item.title = titles[i++];
        //        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        //        item.titlePositionAdjustment = UIOffsetMake(0, 12);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.ready) {
        [self.feed refresh];
        [self.notifications refresh];
    }
}

- (void)notifyUserIsReady {
    self.ready = YES;
 
    [YYClient.sharedClient updateUser:^(NSError *error) {
        if (!error) {
            YYClient *client = YYClient.sharedClient;
            if (client.currentUser.handle) {
                [NSUserDefaults setHandle:client.currentUser.handle forUserIdentifier:client.userIdentifier];
                [self.profile.tableView reloadData];
            }
        }
    }];
    
    [self.feed refresh];
    [self.notifications refresh];
    [self.profile.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

#pragma mark VC getters
- (TTFeedViewController *)feed { return (id)[(id)self.viewControllers[0] viewControllers][0]; }
- (TTNotificationsViewController *)notifications { return (id)[(id)self.viewControllers[1] viewControllers][0]; }
- (TTSettingsViewController *)chat { return (id)[(id)self.viewControllers[2] viewControllers][0]; }
- (TTProfileViewController *)profile { return (id)[(id)self.viewControllers[3] viewControllers][0]; }
- (TTSettingsViewController *)settings { return (id)[(id)self.viewControllers[4] viewControllers][0]; }

@end
