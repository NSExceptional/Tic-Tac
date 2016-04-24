//
//  TTVotingCell.m
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTVotingCell.h"

#define swipeDone ^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)


@interface TTVotingCell ()
@property YYVoteStatus        newVoteStatus;      // Used in the `undo` block
@property YYVoteStatus        previousVoteStatus; // to undo changes to the
@property (nonatomic) UIColor *previousColor;     // vote and label color.

@property (strong) MCSwipeCompletionBlock revokeVote;
@property (strong) MCSwipeCompletionBlock upvote;
@property (strong) MCSwipeCompletionBlock downvote;

@property MCSwipeTableViewCellMode mode;
@end

@implementation TTVotingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
    }
    
    return self;
}

- (UILabel *)votingLabel { return nil; }

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.shouldAnimateIcons = NO;
    
    self.newVoteStatus      = YYVoteStatusNone;
    self.previousVoteStatus = YYVoteStatusNone;
    self.mode = MCSwipeTableViewCellModeSwitch;
    
    @weakify(self);
    ErrorBlock undo = ^(NSError *error) { @strongify(self);
        if (error) {
            [error showWithTitle:@"Error submitting vote"];
            self.votingLabel.textColor = self.previousColor;
            
            // Undo text value change
            switch (self.newVoteStatus) {
                case YYVoteStatusUpvoted:
                    if (self.previousVoteStatus == YYVoteStatusDownvoted)
                        [self.votingLabel decrementText];
                    [self.votingLabel decrementText];
                    break;
                case YYVoteStatusDownvoted:
                    if (self.previousVoteStatus == YYVoteStatusUpvoted)
                        [self.votingLabel incrementText];
                    [self.votingLabel incrementText];
                    break;
                case YYVoteStatusNone:
                    if (self.previousVoteStatus == YYVoteStatusUpvoted)
                        [self.votingLabel incrementText];
                    if (self.previousVoteStatus == YYVoteStatusDownvoted)
                        [self.votingLabel decrementText];
                    break;
            }
            
            self.newVoteStatus = self.previousVoteStatus;
            [self setupSwipeActions];
        } else {
            self.previousVoteStatus = self.votable.voteStatus;
        }
    };
    self.revokeVote = swipeDone { @strongify(self);
        self.previousColor         = self.votingLabel.textColor;
        self.votingLabel.textColor = [UIColor noVoteColor];
        self.newVoteStatus         = YYVoteStatusNone;
        [self setupSwipeActions];
        
        [[YYClient sharedClient] removeVote:self.votable completion:undo];
    };
    self.upvote = swipeDone { @strongify(self);
        if (self.previousVoteStatus == YYVoteStatusUpvoted) {
            self.revokeVote(cell, state, mode); // Revoke vote
            [self.votingLabel decrementText];
        }
        else {
            // +2 to go from downvote --> upvote
            if (self.previousVoteStatus == YYVoteStatusDownvoted)
                [self.votingLabel incrementText];
            [self.votingLabel incrementText];
            self.previousColor         = self.votingLabel.textColor;
            self.votingLabel.textColor = [UIColor upvoteColor];
            self.newVoteStatus         = YYVoteStatusUpvoted;
            [[YYClient sharedClient] upvote:self.votable completion:undo];
        }
        
        [self setupSwipeActions];
    };
    self.downvote = swipeDone { @strongify(self);
        if (self.previousVoteStatus == YYVoteStatusDownvoted) {
            self.revokeVote(cell, state, mode); // Revoke vote
            [self.votingLabel incrementText];
        }
        else {
            // -2 to go from upvote --> downvote
            if (self.previousVoteStatus == YYVoteStatusUpvoted)
                [self.votingLabel decrementText];
            [self.votingLabel decrementText];
            self.previousColor         = self.votingLabel.textColor;
            self.votingLabel.textColor = [UIColor downvoteColor];
            self.newVoteStatus         = YYVoteStatusDownvoted;
            [[YYClient sharedClient] downvote:self.votable completion:undo];
        }
        
        [self setupSwipeActions];
    };
}

- (void)prepareForReuse {
    self.votable = nil;
}

- (void)setVotingSwipesEnabled:(BOOL)votingSwipesEnabled {
    _votingSwipesEnabled = votingSwipesEnabled;
    
    if (votingSwipesEnabled) {
        self.mode = MCSwipeTableViewCellModeSwitch;
    } else {
        self.mode = MCSwipeTableViewCellModeNone;
    }
    
    [self setupSwipeActions];
}

- (void)setVotable:(YYVotable *)votable {
    _votable                = votable;
    self.previousVoteStatus = votable.voteStatus;
    self.newVoteStatus      = votable.voteStatus;
}

- (void)setupSwipeActions {
    self.secondTrigger = .5;
    UIImageView *upvoteView;
    UIImageView *downvoteView;
    switch (self.newVoteStatus) {
        case YYVoteStatusUpvoted:
            upvoteView   = [UIImageView imageViewWithImageNamed:@"post_revoke_upvote"];
            downvoteView = [UIImageView imageViewWithImageNamed:@"post_downvote"];
            break;
        case YYVoteStatusDownvoted:
            upvoteView   = [UIImageView imageViewWithImageNamed:@"post_upvote"];
            downvoteView = [UIImageView imageViewWithImageNamed:@"post_revoke_downvote"];
            break;
        case YYVoteStatusNone:
            upvoteView   = [UIImageView imageViewWithImageNamed:@"post_upvote"];
            downvoteView = [UIImageView imageViewWithImageNamed:@"post_downvote"];
            break;
            
        default:
            break;
    }
    
    [self setSwipeGestureWithView:upvoteView color:[UIColor upvoteColor] mode:self.mode state:MCSwipeTableViewCellState1 completionBlock:self.upvote];
    [self setSwipeGestureWithView:downvoteView color:[UIColor downvoteColor] mode:self.mode state:MCSwipeTableViewCellState2 completionBlock:self.downvote];
}

/** Allows the swipe forward gesture to take precedence over the cell's gestures. */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
        return YES;
    
    return NO;
}

@end
