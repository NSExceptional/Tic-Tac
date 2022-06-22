//
//  VoteControl.h
//  Tic Tac
//
//  Created by Tanner Bennett on 6/17/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VoteStatus) {
    VoteStatusDownvoted = -1,
    VoteStatusNone = 0,
    VoteStatusUpvoted = 1,
};

@interface VoteControl : UIView

+ (instancetype)withInitialScore:(NSInteger)score initialStatus:(VoteStatus)status;

@property (nonatomic) VoteStatus status;
@property (nonatomic, readonly) NSInteger score;

@property (nonatomic, nullable) void (^onVoteStatusChange)(VoteStatus newStatus);

@end

NS_ASSUME_NONNULL_END
