//
//  TTVotableTableView.h
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableView (Private)
/// Using this to add an "empty" banner whenever new rows are added or removed
- (void)_numberOfRowsDidChange;
@end


@interface TTVotableTableView : UITableView

@property (nonatomic) BOOL showsEmptyMessage;

@end
