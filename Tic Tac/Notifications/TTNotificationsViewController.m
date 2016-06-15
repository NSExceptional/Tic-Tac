//
//  TTNotificationsViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTNotificationsViewController.h"
#import "TTNotificationCell.h"
#import "TTCommentsViewController.h"


@interface TTNotificationsViewController ()
@property (nonatomic, readonly) TTFeedArray<YYNotification*> *dataSource;
@property (nonatomic          ) BOOL markingRead;
@end

@implementation TTNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [TTFeedArray new];
    self.dataSource.sortDescriptorKey = @"updated";
    self.dataSource.filter = [NSPredicate predicateWithBlock:^BOOL(YYNotification *notification, id bindings) {
        return notification.reason != YYNotificationReasonVote;
    }];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
    
    id button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(markAllRead)];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)refresh {
    if (self.loadingData) return;
    
    self.loadingData = YES;
    [[YYClient sharedClient] getNotifications:^(NSArray *collection, NSError *error) {
        self.loadingData = NO;
        [self displayOptionalError:error];
        if (!error) {
            [self.dataSource addObjectsFromArray:collection];
            [self.tableView reloadSection:0];
            [self updateBadge];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)markAllRead {
    self.markingRead = YES;
    
    __block int count = 0;
    for (YYNotification *note in self.dataSource) {
        [[YYClient sharedClient] mark:note read:YES completion:^(NSError *error) {
            [self displayOptionalError:error];
            if (++count == self.dataSource.count) {
                self.markingRead = NO;
                [self refresh];
            }
        }];
    }
    //    [[YYClient sharedClient] markEach:self.dataSource read:YES completion:^(NSError *error) {
    //        self.markingRead = NO;
    //        [self displayOptionalError:error];
    //        [self refresh];
    //    }];
}

- (void)setMarkingRead:(BOOL)markingRead {
    if (_markingRead == markingRead) return;
    
    _markingRead = markingRead;
    
    if (markingRead) {
        [TBNetworkActivity push];
    } else {
        [TBNetworkActivity pop];
    }
}

- (void)updateBadge {
    NSUInteger unread = [self.dataSource filteredArrayWhereProperty:@"unread" equals:@YES].count;
    if (unread) {
        self.navigationController.tabBarItem.badgeValue = @(unread).stringValue;
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYNotification *notification = self.dataSource[indexPath.row];
    NSString *reuse = kNotificationReuse;
    
    TTNotificationCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuse];
    [self configureCell:cell forNotification:notification];
    [cell layoutIfNeeded];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YYNotification *notification = self.dataSource[indexPath.row];
    TTNotificationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.unread = NO;
    
    YYYak *yak = [TTFeedArray yakForNotificationIfPresent:notification];
    if (yak) {
        [self.navigationController pushViewController:[TTCommentsViewController commentsForYak:yak] animated:YES];
    } else {
        [self.navigationController pushViewController:[TTCommentsViewController commentsForNotification:notification] animated:YES];
    }
    
    if (notification.unread) {
        [[YYClient sharedClient] mark:notification read:YES completion:^(NSError *error) {
            [self displayOptionalError:error];
            [notification setValue:@NO forKey:@"unread"];
            [self updateBadge];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row].navigatesToYak;
}

- (void)configureCell:(TTNotificationCell *)cell forNotification:(YYNotification *)notification {
    cell.titleLabel.text   = notification.notificationHeadline;
    cell.contentLabel.text = notification.content;
    cell.unread            = notification.unread;
}

@end
