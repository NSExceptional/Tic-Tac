//
//  TTCommentsViewController.h
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTTableViewController.h"
#import "TTCommentsHeaderView.h"


@interface TTCommentsViewController : TTTableViewController

+ (instancetype)commentsForYak:(YYYak *)yak;
+ (instancetype)commentsForNotification:(YYNotification *)notification;

@property (nonatomic, readonly) YYYak *yak;
@property (nonatomic, readonly) TTCommentsHeaderView *commentsHeaderView;

@end
