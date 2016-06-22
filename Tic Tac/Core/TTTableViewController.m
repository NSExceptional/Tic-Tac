//
//  TTTableViewController.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTTableViewController.h"
#import "TTTableView.h"
#import "TTFeedTextCell.h"
#import "TTFeedPhotoCell.h"
#import "TTCommentCell.h"
#import "TTNotificationCell.h"


@interface TTTableViewController ()
@property (nonatomic, readonly) NSMutableArray<NSNumber*> *rowHeights;
@end

@implementation TTTableViewController

- (void)loadView {
    self.tableView = [[TTTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view = self.tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (TTTableView *)_tableView { return (id)super.tableView; };

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorInset     = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableView.rowHeight          = UITableViewAutomaticDimension;
    self.tableView.layoutMargins      = UIEdgeInsetsZero;
    
    [self.tableView registerClass:[TTFeedTextCell class] forCellReuseIdentifier:kFeedTextCellReuse];
    [self.tableView registerClass:[TTFeedPhotoCell class] forCellReuseIdentifier:kFeedPhotoCellReuse];
    [self.tableView registerClass:[TTCommentCell class] forCellReuseIdentifier:kCommentCellReuse];
    [self.tableView registerClass:[TTNotificationCell class] forCellReuseIdentifier:kNotificationReuse];
    
    self.refreshControl = [UIRefreshControl new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.rowHeights.count) {
        [self.rowHeights addObject:@(cell.frame.size.height)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.rowHeights.count) {
        return self.rowHeights[indexPath.row].floatValue;
    } else {
        return 64;
    }
}

- (void)setLoadingData:(BOOL)loadingData {
    if (_loadingData == loadingData) return;
    
    _loadingData = loadingData;
    
    if (loadingData) {
        [TBNetworkActivity push];
    } else {
        [self _tableView].showsEmptyMessage = YES;
        [TBNetworkActivity pop];
    }
}

- (void)setShowsAll:(BOOL)showsAll {
    if (showsAll == _showsAll) return;
    _showsAll = showsAll;
    [self.tableView reloadData];
}

@end
