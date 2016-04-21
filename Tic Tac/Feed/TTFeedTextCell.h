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
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *scoreLabel;
@property (nonatomic, readonly) UILabel *authorLabel;

@end
