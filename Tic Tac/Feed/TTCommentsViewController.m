//
//  TTCommentsViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentsViewController.h"
#import "TTCommentsHeaderView.h"
#import "TTCommentCell.h"
#import "TTReplyViewController.h"

@interface TTCommentsViewController ()
@property (nonatomic, readonly) TTCommentsHeaderView *commentsHeaderView;
@property (nonatomic, readonly) YYYak *yak;
@property (nonatomic, readonly) TTFeedArray<YYComment*> *dataSource;
@end

@implementation TTCommentsViewController

+ (instancetype)commentsForYak:(YYYak *)yak {
    TTCommentsViewController *comments = [self new];
    comments->_yak = yak;
    return comments;
}

+ (instancetype)commentsForNotification:(YYNotification *)notification {
    TTCommentsViewController *comments = [self new];
    [[YYClient sharedClient] getYak:notification completion:^(YYYak *yak, NSError *error) {
        [comments displayOptionalError:error];
        if (!error) {
            comments->_yak = yak;
            [comments.commentsHeaderView updateWithYak:yak];
            
            if (comments.view.tag) {
                [comments reloadCommentSectionData];
            }
        }
    }];
    
    return comments;
}

- (id)init {
    self = [super init];
    if (self) {
        _dataSource = [TTFeedArray new];
        _dataSource.sortNewestFirst = YES;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    _commentsHeaderView = [TTCommentsHeaderView headerForYak:self.yak];
    self.tableView.tableHeaderView = self.commentsHeaderView;
    [self.commentsHeaderView.addCommentButton addTarget:self action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // So we know if we need to load the comments or not after loading the yak
    // if (self.view.tag) load comments, else they will be loaded here
    self.view.tag = 1;
    
    [self.refreshControl addTarget:self action:@selector(reloadComments) forControlEvents:UIControlEventValueChanged];
    
    if (self.yak) {
        [self reloadCommentSectionData];
    } else {
        self.title = nil;
    }
}

- (void)reloadComments {
    if (self.loadingData) return;
    
    self.loadingData = YES;
    [[YYClient sharedClient] getCommentsForYak:self.yak completion:^(NSArray *collection, NSError *error) {
        self.loadingData = NO;
        
        [self displayOptionalError:error message:@"Failed to load comments"];
        if (!error) {
            [self.dataSource setArray:collection];
            [self.tableView reloadSection:0];
            [self.refreshControl endRefreshing];
            
            // Update title
            if (self.dataSource.count == 1) { self.title = @"1 Comment"; } else {
                self.title = [NSString stringWithFormat:@"%@ Comments", @(self.dataSource.count)];
            }
        }
    }];
}

- (void)reloadCommentSectionData {
    // Title
    if (self.yak.replyCount == 1) { self.title = @"1 Comment"; } else {
        self.title = [NSString stringWithFormat:@"%@ Comments", @(self.yak.replyCount)];
    }
    
    // Delete button
    if ([self.yak.authorIdentifier isEqualToString:[YYClient sharedClient].currentUser.identifier]) {
        id delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePost)];
        self.navigationItem.rightBarButtonItem = delete;
    }
    
    // Load comments
    [self reloadComments];
}

- (void)deletePost {
    [self.navigationController popViewControllerAnimated:YES];
    
    [TBNetworkActivity push];
    [[YYClient sharedClient] deleteYakOrComment:self.yak completion:^(NSError *error) {
        [TBNetworkActivity pop];
        [self displayOptionalError:error];
    }];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCommentCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:kCommentCellReuse];
    [self configureCell:cell forComment:self.dataSource.allObjects[indexPath.row]];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.allObjects.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    YYComment *comment = self.dataSource[indexPath.row];
}

#pragma mark Cell configuration

- (void)configureCell:(TTCommentCell *)cell forComment:(YYComment *)comment {
    cell.titleLabel.text  = comment.body;
    cell.scoreLabel.text  = @(comment.score).stringValue;
    cell.authorLabel.text = comment.authorText;
    cell.votable          = comment;
    cell.votingSwipesEnabled = !self.yak.isReadOnly;
    cell.repliesEnabled = !self.yak.isReadOnly;
    cell.replyAction = ^{
        [self replyToUser:comment.username ?: comment.authorText];
    };
    
    [cell setIcon:comment.overlayIdentifier withColor:comment.backgroundIdentifier];
    
    // Long press to delete comment
    if ([comment.authorIdentifier isEqualToString:[YYClient sharedClient].currentUser.identifier]) {
        cell.longPressAction = ^{
            TBAlertController *delete = [TBAlertController alertViewWithTitle:@"More Options" message:nil];
            [delete setCancelButtonWithTitle:@"Cancel"];
            
            [delete addOtherButtonWithTitle:@"Delete" buttonAction:^(NSArray *textFieldStrings) {
                [TBNetworkActivity push];
                [[YYClient sharedClient] deleteYakOrComment:comment completion:^(NSError *error) {
                    [TBNetworkActivity pop];
                    [self displayOptionalError:error];
                    if (!error) {
                        [self reloadComments];
                    }
                }];
            }];
            
            [delete show];
        };
    } else {
        cell.longPressAction = nil;
    }
}

#pragma mark Replying

- (void)addComment {
    [self replyToUser:nil];
}

- (void)replyToUser:(NSString *)username {
    username = [username stringByAppendingString:@" "];
    [self.navigationController presentViewController:[TTReplyViewController initialText:username limit:-1 onSubmit:^(NSString *text, BOOL useHandle) {
        if (text.length > 200) {
            NSInteger i = 0;
            for (NSString *reply in [text brokenUpByCharacterLimit:200]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i++ * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self submitReplyToYak:reply useHandle:useHandle];
                });
            }
        } else {
            [self submitReplyToYak:text useHandle:useHandle];
        }
    }] animated:YES completion:nil];
}

- (void)submitReplyToYak:(NSString *)reply useHandle:(BOOL)useHandle {
    NSParameterAssert(reply.length < 200 && reply.length > 0);
    
    [[YYClient sharedClient] postComment:reply toYak:self.yak useHandle:useHandle completion:^(NSError *error) {
        [self displayOptionalError:error message:@"Failed to submit reply"];
        if (!error) {
            [self reloadComments];
        }
    }];
}

@end
