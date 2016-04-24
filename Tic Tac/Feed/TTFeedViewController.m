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


@interface TTFeedViewController ()
@property (nonatomic, readonly) UIBarButtonItem *sortToggleButton;
@property (nonatomic, readonly) UIBarButtonItem *composeButton;

@property (nonatomic) NSMutableOrderedSet<YYYak*> *dataSource;
@end

@implementation TTFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableOrderedSet orderedSet];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kYYDidUpdateUserNotification object:nil];
}

- (void)updateTitle {
    self.title = @([YYClient sharedClient].currentUser.karma).stringValue;
}

- (void)refresh {
    [[YYClient sharedClient] getLocalYaks:^(NSArray *collection, NSError *error) {
        [self displayOptionalError:error];
        if (!error) {
            [self.dataSource addObjectsFromArray:collection];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYYak *yak = self.dataSource[indexPath.row];
    NSString *reuse;
    if (yak.hasMedia) {
        reuse = @"photo_reuse";
    } else {
        reuse = @"text_reuse";
    }
    
    TTFeedTextCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuse];
    [self configureCell:cell forYak:yak];
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
    
    [NSUserDefaults addVisitedPost:yak.identifier];
}

#pragma mark Cell configuration

- (void)configureCell:(TTFeedTextCell *)cell forYak:(YYYak *)yak {
    cell.visited          = [[NSUserDefaults visitedPosts] containsObject:yak.identifier];
    cell.titleLabel.text  = yak.title;
    cell.scoreLabel.text  = @(yak.score).stringValue;
    cell.authorLabel.text = yak.handle;
    cell.votable          = yak;
    cell.votingSwipesEnabled = !yak.isReadOnly;
    
    if (yak.hasMedia) {
        [self findOrLoadImageforCell:(id)cell forYak:yak];
    }
}

- (void)findOrLoadImageforCell:(TTFeedPhotoCell *)cell forYak:(YYYak *)yak {
    // TODO
}

@end
