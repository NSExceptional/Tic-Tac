//
//  TTFeedTextCell.h
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTVotingCell.h"


@interface TTFeedTextCell : TTVotingCell

@property (nonatomic) BOOL visited;
@property (nonatomic) NSString *authorLabelText;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *scoreLabel;

@property (nonatomic, readonly) UIStackView *stackVerticalMain;
@property (nonatomic, readonly) UIStackView *stackHorizontalTop;
@property (nonatomic, readonly) UIStackView *stackHorizontalBottom;

/// To be overridden by subclasses. Do not call directly.
- (void)setupStacks;

@end
