//
//  TTFeedViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTFeedViewController.h"
#import "TTFeedTextCell.h"
#import "TTFeedPhotoCell.h"
#import "TTCommentsViewController.h"
#import "TTReplyViewController.h"


@interface TTFeedViewController ()
@property (nonatomic, readonly) UIBarButtonItem *sortToggleButton;
@property (nonatomic, readonly) UIBarButtonItem *composeButton;

@property (nonatomic, readonly) TTFeedArray<YYYak*> *dataSource;
@end

@implementation TTFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    _dataSource = [TTFeedArray new];
    self.dataSource.filter = [NSPredicate predicateWithBlock:^BOOL(YYYak *yak, NSDictionary *bindings) {
        return YYContainsPolitics(yak.title.lowercaseString);
    }];
    
    // Compose, register for update title notification, update title
    id comp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composePost)];
    self.navigationItem.rightBarButtonItem = comp;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kYYDidUpdateUserNotification object:nil];
    [self updateTitle];
}

- (void)updateTitle {
    self.title = @([YYClient sharedClient].currentUser.karma).stringValue;
}

- (void)refresh {
    if (self.loadingData) return;
    
    self.loadingData = YES;
    [[YYClient sharedClient] getLocalYaks:^(NSArray *collection, NSError *error) {
        self.loadingData = NO;
        [self displayOptionalError:error];
        if (!error) {
            [self.dataSource setArray:collection];
            [self.tableView reloadSection:0];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)composePost {
    [self.navigationController presentViewController:[TTReplyViewController initialText:nil limit:200 onSubmit:^(NSString *text, BOOL useHandle) {
        [TBNetworkActivity push];
        [[YYClient sharedClient] postYak:text useHandle:useHandle completion:^(NSError *error) {
            [self displayOptionalError:error];
            [TBNetworkActivity pop];
        }];
    }] animated:YES completion:nil];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYYak *yak = self.dataSource[indexPath.row];
    NSString *reuse;
    if (yak.hasMedia) {
        reuse = kFeedPhotoCellReuse;
    } else {
        reuse = kFeedTextCellReuse;
    }
    
    TTFeedTextCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuse];
    [self configureCell:cell forYak:yak];
    [cell layoutIfNeeded];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YYYak *yak = self.dataSource[indexPath.row];
    TTFeedTextCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.visited = YES;
    
    [TTCache addVisitedPost:yak.identifier];
    
    [self.navigationController pushViewController:[TTCommentsViewController commentsForYak:yak] animated:YES];
}

#pragma mark Cell configuration

- (void)configureCell:(TTFeedTextCell *)cell forYak:(YYYak *)yak {
    cell.visited              = [[TTCache visitedPosts] containsObject:yak.identifier];
    cell.titleLabel.text      = yak.title;
    cell.scoreLabel.text      = @(yak.score).stringValue;
    cell.ageLabel.text        = yak.created.relativeTimeString;
    cell.votable              = yak;
    cell.votingSwipesEnabled  = !yak.isReadOnly;
    [cell setAuthorLabelText:yak.username];
    
    if (yak.replyCount == 1) {
        cell.replyCountLabel.text = @"1 reply";
    } else {
        cell.replyCountLabel.text = [NSString stringWithFormat:@"%@ replies", @(yak.replyCount)];
    }
    
    if (yak.hasMedia) {
        [self findOrLoadImageforCell:(id)cell forYak:yak];
    }
}

- (void)findOrLoadImageforCell:(TTFeedPhotoCell *)cell forYak:(YYYak *)yak {
    // TODO
}

@end
