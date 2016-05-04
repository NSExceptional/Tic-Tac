//
//  TTTableViewController.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTTableViewController.h"
#import "TTVotableTableView.h"
#import "TTFeedTextCell.h"
#import "TTFeedPhotoCell.h"
#import "TTCommentCell.h"

@interface TTTableViewController ()
@property (nonatomic, readonly) NSMutableArray<NSNumber*> *rowHeights;
@end

@implementation TTTableViewController

- (void)loadView {
    self.tableView = [[TTVotableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view = self.tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight      = UITableViewAutomaticDimension;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableView.rowHeight      = UITableViewAutomaticDimension;
    self.tableView.layoutMargins  = UIEdgeInsetsZero;
    
    [self.tableView registerClass:[TTFeedTextCell class] forCellReuseIdentifier:kFeedTextCellReuse];
    [self.tableView registerClass:[TTFeedPhotoCell class] forCellReuseIdentifier:kFeedPhotoCellReuse];
    [self.tableView registerClass:[TTCommentCell class] forCellReuseIdentifier:kCommentCellReuse];
    
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
        return 100;
    }
}

@end
