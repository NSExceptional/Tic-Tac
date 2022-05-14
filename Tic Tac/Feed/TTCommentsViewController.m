//
//  TTCommentsViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentsViewController.h"
#import "TTCommentCell.h"
#import "TTReplyViewController.h"
#import "TTCensorshipControl.h"


@interface TTCommentsViewController () <TTCensorshipDelegate>
@property (nonatomic, readonly) TTFeedArray<YYComment*> *dataSource;
@property (nonatomic, readonly) NSArray<YYComment*> *arrayToUse;
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
            [TTCache cacheYak:yak];
            comments->_yak = yak;
            [comments.commentsHeaderView updateWithYak:yak];
            
            if (comments.view.tag) {
                [comments reloadCommentSectionData];
            }
        } else {
            if (comments.view.tag) {
                [comments dismissAndNotifyYakRemoved];
            } else {
                comments.view.tag = 2;
            }
        }
    }];
    
    return comments;
}

- (void)dismissAndNotifyYakRemoved {
    [self.navigationController popViewControllerAnimated:YES];
    [[TBAlertController simpleOKAlertWithTitle:@"Yak Not Available" message:@"This yak has been removed."] showNow];
}

- (id)init {
    self = [super init];
    if (self) {
        _dataSource = [TTFeedArray new];
        _dataSource.sortNewestFirst = YES;
        @weakify(self);
        self.dataSource.removedObjectsPool = ^NSArray* { @strongify(self);
            return [TTCache commentsForYakWithIdentifier:self.yak.identifier];
        };
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
    
    self.navigationItem.titleView = [TTCensorshipControl withDelegate:self];
    
    // Dismiss in viewDidAppear
    if (self.view.tag == 2) {
        return;
    }
    
    // So we know if we need to load the comments or not after loading the yak
    // if (self.view.tag) load comments, else they will be loaded here
    self.view.tag = 1;
    
    [self.refreshControl addTarget:self action:@selector(reloadComments) forControlEvents:UIControlEventValueChanged];
    
    if (self.yak) {
        [self reloadCommentSectionData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.view.tag == 2) {
        [self dismissAndNotifyYakRemoved];
    }
}

#pragma mark Misc

- (void)reloadComments {
    if (self.loadingData) return;
    
    __block NSArray *unusedComments = nil;
    __block BOOL loadingUnused = NO, loadingUsed = YES;
    self.loadingData = YES;
    
    // Load comments from usual account
    [[YYClient sharedClient] getCommentsForYak:self.yak completion:^(NSArray *collection, NSError *error) {
        loadingUsed = NO;
        self.loadingData = loadingUnused && loadingUsed;
        
        [self displayOptionalError:error message:@"Failed to load comments"];
        if (!error) {
            BOOL scroll = self.dataSource.count == 0;
            
//            [self analyzeComments:collection];
            [TTCache cacheComments:collection forYak:self.yak];
            [self.dataSource setArray:collection];
            [self checkForBlockedComments:unusedComments];
            [self.tableView reloadSection:0];
            [self.refreshControl endRefreshing];
            
            // Scroll to the bottom
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.333 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (scroll && self.dataSource.count) {
                    NSIndexPath *last = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            });
        }
    }];
    
    // Load and check for potentially blocked comments
    NSString *unused = [NSUserDefaults unusedUserIdentifier];
    if ([NSUserDefaults showBlockedContent] && unused) {
        // Make temporary client
        YYClient *temp = [YYClient sharedClient].copy;
        temp.userIdentifier = unused;
        
        loadingUnused = YES;
        [temp getCommentsForYak:self.yak completion:^(NSArray *collection, NSError *error) {
            loadingUnused    = NO;
            self.loadingData = loadingUnused && loadingUsed;
            unusedComments   = collection;
            
            // If we already loaded the rest...
            if (!error && self.dataSource.count && [self checkForBlockedComments:collection]) {
//                [self analyzeComments:collection]; // Only need to analyze the new ones
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            }
        }];
    }
}

/// @return Whether blocked comments were found and added
- (BOOL)checkForBlockedComments:(NSArray *)unused {
    if (!unused.count || !self.dataSource.count) { return NO; }
    
    // Remove existing
    NSMutableSet *blocked = [NSMutableSet setWithArray:unused];
    [blocked minusSet:[NSSet setWithArray:self.dataSource]];
    
    // Set blocked, cache, merge
    if (blocked.count) {
        for (YYComment *comment in blocked) {
            comment.blocked = YES;
        }
        
        [TTCache cacheComments:blocked.allObjects forYak:self.yak];
        [self.dataSource addObjectsFromArray:blocked.allObjects];
        return YES;
    }
    
    return NO;
}

- (void)reloadCommentSectionData {
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

/// Assigns usernames to comments with missing usernames based on backID + overlayID
- (void)analyzeComments:(NSArray *)comments {
    NSMutableDictionary *handles = [NSMutableDictionary dictionary];
    for (YYComment *comment in comments) {
        if (comment.username.length) {
            handles[comment.relevantAuthorIdentifier] = comment.username;
        }
    }
    for (YYComment *comment in comments) {
        if (handles[comment.relevantAuthorIdentifier]) {
            [comment setValue:handles[comment.relevantAuthorIdentifier] forKey:@"username"];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSArray<YYComment*> *)arrayToUse {
    return self.showsAll ? self.dataSource.allObjects : self.dataSource;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCommentCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:kCommentCellReuse];
    [self configureCell:cell forComment:self.arrayToUse[indexPath.row]];
    cell.titleLabel.preferredMaxLayoutWidth = cell.preferredTitleLabelMaxWidth;
    [cell layoutIfNeeded];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayToUse.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showOptionsForComment:self.arrayToUse[indexPath.row]];
}

- (void)showOptionsForComment:(YYComment *)comment {
    TBAlertController *options = [TBAlertController alertViewWithTitle:@"More Options" message:nil];
    [options setCancelButtonWithTitle:@"Cancel"];
    
    [options addOtherButtonWithTitle:@"Copy text" buttonAction:^(NSArray *textFieldStrings) {
        [UIPasteboard generalPasteboard].string = comment.body;
    }];
    
    if ([comment.authorIdentifier isEqualToString:[YYClient sharedClient].currentUser.identifier]) {
        [options addOtherButtonWithTitle:@"Delete" buttonAction:^(NSArray *textFieldStrings) {
            [TBNetworkActivity push];
            [[YYClient sharedClient] deleteYakOrComment:comment completion:^(NSError *error) {
                [TBNetworkActivity pop];
                [self displayOptionalError:error];
                if (!error) {
                    [self reloadComments];
                }
            }];
        }];
        [options setDestructiveButtonIndex:1];
    }
    
    [options showNow];
}

#pragma mark Cell configuration

- (void)configureCell:(TTCommentCell *)cell forComment:(YYComment *)comment {
    cell.titleLabel.text           = comment.body;
    cell.scoreLabel.attributedText = [@(comment.score) scoreStringForVote:comment.voteStatus];
    cell.ageLabel.text             = comment.created.relativeTimeString;
    cell.authorLabel.text          = comment.username ?: comment.authorText;
    cell.votable                   = comment; // removed, blocked, etc
    cell.votingSwipesEnabled       = !(self.yak.isReadOnly || comment.blocked);
    cell.repliesEnabled            = !self.yak.isReadOnly;
    cell.replyAction               = ^{
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
