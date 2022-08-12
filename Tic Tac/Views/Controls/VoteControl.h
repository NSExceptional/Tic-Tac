//
//  VoteControl.h
//  Tic Tac
//
//  Created by Tanner Bennett on 6/17/22.
//

#import <UIKit/UIKit.h>
#import <YYVotable.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoteControl : UIView

@property (nonatomic, readonly) YYVoteStatus status;
@property (nonatomic, readonly) NSInteger score;

- (void)setVote:(YYVoteStatus)status score:(NSInteger)score;

@property (nonatomic, nullable) void (^onVoteStatusChange)(YYVoteStatus newStatus, NSInteger newScore);

/// Use this to resize the stepper control
@property (nonatomic) CGVector stepperScale;

@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface VoteControl (Private)
@property (nonatomic, readonly) UIButton *upvoteButton;
@property (nonatomic, readonly) UIButton *downvoteButton;

- (void)simulateVote:(YYVoteStatus)vote;
@end

NS_ASSUME_NONNULL_END
