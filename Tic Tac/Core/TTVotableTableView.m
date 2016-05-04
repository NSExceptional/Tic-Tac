//
//  TTVotableTableView.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTVotableTableView.h"


@implementation TTVotableTableView

- (NSUInteger)totalRows {
    NSInteger count = 0;
    for (NSInteger i = 0; i < self.numberOfSections; i++)
        count += [self numberOfRowsInSection:i];
    
    return count;
}

- (void)_numberOfRowsDidChange {
    [super _numberOfRowsDidChange];
    
    if ([self totalRows] == 0) {
        self.tableFooterView = [UIView new];
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
    else {
        [UIView animateWithDuration:.2 animations:^{
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            self.backgroundView = nil;
            self.tableFooterView = nil;
        }];
    }
}

@end
