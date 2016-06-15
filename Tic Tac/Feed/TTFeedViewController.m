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
#import "TTCensorshipControl.h"


@interface TTFeedViewController () <TTCensorshipDelegate>
@property (nonatomic, readonly) UIBarButtonItem *sortToggleButton;
@property (nonatomic, readonly) UIBarButtonItem *composeButton;

@property (nonatomic, readonly) TTFeedArray<YYYak*> *dataSource;
@property (nonatomic, readonly) NSArray<YYYak*> *arrayToUse;
@end

@implementation TTFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [TTCensorshipControl withDelegate:self];
    
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    _dataSource = [TTFeedArray new];
    self.dataSource.removedObjectsPool = ^NSArray* { return [TTCache yakCache].array; };
    //    self.dataSource.filter = [NSPredicate predicateWithBlock:^BOOL(YYYak *yak, NSDictionary *bindings) {
    //        return YYContainsPolitics(yak.title.lowercaseString);
    //    }];
    
    // Compose, register for update title notification, update title
    id comp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composePost)];
    self.navigationItem.rightBarButtonItem = comp;
}

- (void)refresh {
    if (self.loadingData) return;
    
    self.loadingData = YES;
    [[YYClient sharedClient] getLocalYaks:^(NSArray *collection, NSError *error) {
        self.loadingData = NO;
        [self displayOptionalError:error];
        if (!error) {
            [TTCache cacheYaks:collection];
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

- (NSArray<YYYak*> *)arrayToUse {
    return self.showsAll ? self.dataSource.allObjects : self.dataSource;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYYak *yak = self.arrayToUse[indexPath.row];
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
    return self.arrayToUse.count;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YYYak *yak = self.arrayToUse[indexPath.row];
    TTFeedTextCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.visited = YES;
    
    [TTCache addVisitedPost:yak.identifier];
    
    [self.navigationController pushViewController:[TTCommentsViewController commentsForYak:yak] animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.arrayToUse[indexPath.row].removed == YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (style == UITableViewCellEditingStyleDelete) {
        [TTCache removeYakFromCache:self.dataSource.allObjects[indexPath.row]];
        [tableView deleteRow:indexPath.row inSection:0];
    }
}

#pragma mark Cell configuration

- (void)configureCell:(TTFeedTextCell *)cell forYak:(YYYak *)yak {
    cell.visited                   = [[TTCache visitedPosts] containsObject:yak.identifier];
    cell.titleLabel.text           = yak.title;
    cell.scoreLabel.attributedText = [@(yak.score) scoreStringForVote:yak.voteStatus];
    cell.ageLabel.text             = yak.created.relativeTimeString;
    cell.votable                   = yak;
    cell.votingSwipesEnabled       = !yak.isReadOnly;
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
