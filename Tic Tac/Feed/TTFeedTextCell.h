//
//  TTFeedTextCell.h
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTVotingCell.h"


@interface TTFeedTextCell : TTVotingCell

@property (nonatomic, readonly) UILongPressGestureRecognizer *godModeGesture;

@property (nonatomic) BOOL visited;
@property (nonatomic) NSString *authorLabelText;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *scoreLabel;
@property (nonatomic, readonly) UILabel *ageLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *replyCountLabel;

- (void)initializeSubviews;
@property (nonatomic, readonly) MASViewAttribute *leftOfTitleLabel;

/// For scrolling optimization
@property (nonatomic, readonly) NSArray<UIView*> *opaqueViews;
/// For proper row heights
@property (nonatomic, readonly) CGFloat preferredTitleLabelMaxWidth;

@end
