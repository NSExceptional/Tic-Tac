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


@interface TTCommentsViewController ()
@property (nonatomic, readonly) TTCommentsHeaderView *commentsHeaderView;
@property (nonatomic, readonly) YYYak *yak;
@property (nonatomic, readonly) TTPersistentArray<YYComment*> *dataSource;
@property (nonatomic) BOOL loadingData;
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
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    _commentsHeaderView = [[TTCommentsHeaderView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self.commentsHeaderView configureForYak:self.yak];
    [self.commentsHeaderView setFrameHeight:[_commentsHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height];
    self.tableView.tableHeaderView = self.commentsHeaderView;
    
    self.refreshControl = [UIRefreshControl new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
}

- (void)viewDidLoad {
    // Title
    if (self.yak.replyCount == 1) { self.title = @"1 Comment"; } else {
        self.title = [NSString stringWithFormat:@"%@ Comments", @(self.yak.replyCount)];
    }
    
    [self.tableView registerClass:[TTCommentCell class] forCellReuseIdentifier:@"comment_reuse"];
    
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
            [self.tableView reloadData];
            // Update title
            if (self.dataSource.count == 1) { self.title = @"1 Comment"; } else {
                self.title = [NSString stringWithFormat:@"%@ Comments", @(self.dataSource.count)];
            }
        }
    }];
}

//- (void)mergeNewWithOldComments:(NSArray<YYComment*> *)comments {
//    // Replace old comments with new ones
//    NSMutableArray *dataSourceWithNew = self.dataSource.mutableCopy;
//    for (YYComment *new in comments) {
//        for (YYComment *old in self.dataSource) {
//            if ([new isEqual:old]) {
//                dataSourceWithNew[[dataSourceWithNew indexOfObject:old]] = new;
//            }
//        }
//    }
//    
//    // Mark missing comments as removed
//    NSMutableSet *onlyRemoved = [NSMutableSet setWithArray:dataSourceWithNew];
//    [onlyRemoved minusSet:[NSSet setWithArray:comments]];
//    for (YYComment *comment in onlyRemoved) {
//        comment.removed = YES;
//    }
//    
//    NSMutableSet *allComments = [NSMutableSet setWithArray:dataSourceWithNew];
//    [allComments addObjectsFromArray:comments];
//    self.dataSource = [allComments.allObjects sortedArrayUsingSelector:@selector(compareCreated:)];
//}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCommentCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:@"comment_reuse"];
    [self configureCell:cell forComment:self.dataSource[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    YYComment *comment = self.dataSource[indexPath.row];
}

#pragma mark Cell configuration

- (void)configureCell:(TTCommentCell *)cell forComment:(YYComment *)comment {
    cell.titleLabel.text  = comment.body;
    cell.scoreLabel.text  = @(comment.score).stringValue;
    cell.authorLabel.text = comment.username;
    cell.color            = comment.backgroundIdentifier;
    cell.avatar           = comment.overlayIdentifier;
    cell.votable          = comment;
    cell.votingSwipesEnabled = !self.yak.isReadOnly;
}

@end
