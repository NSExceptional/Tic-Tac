//
//  TTVotableTableView.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTVotableTableView.h"


@implementation TTVotableTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.tableFooterView =  ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = self.separatorColor;
            view;
        });
    }
    
    return self;
}

- (NSUInteger)totalRows {
    NSInteger count = 0;
    for (NSInteger i = 0; i < self.numberOfSections; i++)
        count += [self numberOfRowsInSection:i];
    
    return count;
}

- (void)_numberOfRowsDidChange {
    [super _numberOfRowsDidChange];
    
    if (!self.showsEmptyMessage) { return; }
    
    NSUInteger totalRows = [self totalRows];
    if (totalRows == 0 && !self.backgroundView) {
        self.backgroundView = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            label.text = @"Nothing to see here!";
            label.font = [UIFont systemFontOfSize:27];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor noVoteColor];
            label.alpha = 0;
            label;
        });
        
        [UIView animateWithDuration:.2 animations:^{
            self.backgroundView.alpha = 1;
        }];
    }
    else if (totalRows != 0) {
        [UIView animateWithDuration:.2 animations:^{
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            self.backgroundView = nil;
        }];
    }
}

@end
