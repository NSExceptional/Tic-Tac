//
//  TTTableViewController.h
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString * const kFeedTextCellReuse = @"kFeedTextCellReuse";
static NSString * const kFeedPhotoCellReuse = @"kFeedPhotoCellReuse";
static NSString * const kCommentCellReuse = @"kCommentCellReuse";
static NSString * const kNotificationReuse = @"kNotificationReuse";

@interface TTTableViewController : UITableViewController

@property (nonatomic) BOOL loadingData;

@end
