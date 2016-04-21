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
    
    self.viewControllers = @[[TTFeedViewController inNavigationController],
                             [TTNotificationsViewController inNavigationController],
                             [TTProfileViewController inNavigationController],
                             [TTSettingsViewController inNavigationController]];
    
    NSArray *icons = @[@"tab_feed", @"tab_notifications", @"tab_profile", @"tab_settings"];
    NSArray *titles = @[@"Feed", @"Notifications", @"Profile", @"Settings"];
    
    NSInteger i = 0;
    for (UITabBarItem *item in self.tabBar.items) {
        item.image = [UIImage imageNamed:icons[i++]];
        item.title = titles[i];
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
    
    [self.feed refresh];
    [self.notifications refresh];
}

#pragma mark VC getters
- (TTFeedViewController *)feed { return (id)[(id)self.viewControllers[0] rootViewController]; }
- (TTNotificationsViewController *)notifications { return (id)[(id)self.viewControllers[1] rootViewController]; }
- (TTProfileViewController *)profile { return (id)[(id)self.viewControllers[2] rootViewController]; }
- (TTSettingsViewController *)settings { return (id)[(id)self.viewControllers[3] rootViewController]; }

@end
