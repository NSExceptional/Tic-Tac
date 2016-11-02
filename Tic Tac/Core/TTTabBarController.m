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
#import "TTChatListViewController.h"


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
    
    id chat = [TTChatListViewController conversationListViewControllerWithLayerClient:[YYClient sharedClient].layerClient];
    self.viewControllers = @[[TTFeedViewController inNavigationController],
                             [TTNotificationsViewController inNavigationController],
                             [[UINavigationController alloc] initWithRootViewController:chat],
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
    [self connectToLayerAndInitialize];
 
    [[YYClient sharedClient] updateConfiguration:nil];
    [[YYClient sharedClient] updateUser:^(NSError *error) {
        if (!error) {
            YYClient *client = [YYClient sharedClient];
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

#pragma mark Layer

- (void)connectToLayerAndInitialize {
    LYRClient *layer = [YYClient sharedClient].layerClient;
    if (!layer.isConnected) {
        [layer connectWithCompletion:^(BOOL success, NSError *error) {
            [self displayOptionalError:error];
            if (success) {
                if ([YYClient sharedClient].currentUser.handle) {
                    if (!layer.authenticatedUser) {
                        [self authenticateWithLayer];
                    }
                }
            }
        }];
    } else if (!layer.authenticatedUser) {
        [self authenticateWithLayer];
    }
}

- (void)authenticateWithLayer {
    LYRClient *layer = [YYClient sharedClient].layerClient;
    NSAssert(!layer.authenticatedUser, @"Already authenticated with layer");
    
    [layer requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        assert((!nonce && error) || (nonce && !error));
        [self displayOptionalError:error message:@"Failed to authenticate chat"];
        if (!error) {
            [[YYClient sharedClient] authenticateForLayer:nonce completion:^(NSString *identityToken, NSError *error2) {
                [self displayOptionalError:error2 message:@"Failed to authenticate chat"];
                if (!error2) {
                    [layer authenticateWithIdentityToken:identityToken completion:^(LYRIdentity *user, NSError *error3) {
                        [self displayOptionalError:error3 message:@"Failed to authenticate chat"];
                    }];
                }
            }];
        }
    }];
}

- (void)updateChatList {
    UINavigationController *nav = (id)self.viewControllers[2];
    nav.viewControllers = @[[TTChatListViewController conversationListViewControllerWithLayerClient:[YYClient sharedClient].layerClient]];
}

@end
