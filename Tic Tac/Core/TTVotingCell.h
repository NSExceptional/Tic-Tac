//
//  TTVotingCell.h
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "MCSwipeTableViewCell.h"


@interface TTVotingCell : MCSwipeTableViewCell

@property (nonatomic) BOOL removed;

/// Set this before setting votingSwipesEnabled
@property (nonatomic) YYVotable *votable;
@property (nonatomic) BOOL votingSwipesEnabled;

/// Subclasses should override
@property (nonatomic, readonly) UILabel *votingLabel;

@end
