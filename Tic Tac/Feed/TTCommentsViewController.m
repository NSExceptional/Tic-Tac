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
@property (nonatomic, readonly) TTPersistentArray<YYComment*> *dataSource;
@end

@implementation TTCommentsViewController

+ (instancetype)commentsForYak:(YYYak *)yak {
    TTCommentsViewController *comments = [self new];
    comments->_yak = yak;
    return comments;
}

- (id)init {
    self = [super init];
    if (self) {
        _dataSource = [TTPersistentArray new];
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
    
    // Title
    if (self.yak.replyCount == 1) { self.title = @"1 Comment"; } else {
        self.title = [NSString stringWithFormat:@"%@ Comments", @(self.yak.replyCount)];
    }
    
    // Load comments
    [self reloadComments];
}


- (void)reloadComments {
    if (self.loadingData) return;
    
    self.loadingData = YES;
    [[YYClient sharedClient] getCommentsForYak:self.yak completion:^(NSArray *collection, NSError *error) {
        self.loadingData = NO;
        
        [self displayOptionalError:error message:@"Failed to load comments"];
        if (!error) {
            [self.dataSource addObjectsFromArray:collection];
            [self.tableView reloadSection:0];
            
            // Update title
            if (self.dataSource.count == 1) { self.title = @"1 Comment"; } else {
                self.title = [NSString stringWithFormat:@"%@ Comments", @(self.dataSource.count)];
            }
        }
    }];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCommentCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:kCommentCellReuse];
    [self configureCell:cell forComment:self.dataSource[indexPath.row]];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
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
}

#pragma mark Replying

- (void)addComment {
    [self replyToUser:nil];
}

- (void)replyToUser:(NSString *)username {
    username = [username stringByAppendingString:@" "];
    [self.navigationController presentViewController:[TTReplyViewController replyWithInitialText:username onSubmit:^(NSString *text, BOOL useHandle) {
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
