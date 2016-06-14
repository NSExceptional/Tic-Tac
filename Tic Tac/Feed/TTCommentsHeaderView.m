//
//  TTCommentsHeaderView.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentsHeaderView.h"


@interface TTCommentsHeaderView ()
@property (nonatomic, readonly) UILabel *replyCountLabel;
@property (nonatomic, readonly) UILabel *scoreLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *ageLabel;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UIButton *chatButton; /* unused atm */

@property (nonatomic, readonly) UIView *hairlineView;
@end

@implementation TTCommentsHeaderView

+ (instancetype)headerForYak:(YYYak *)yak {
    TTCommentsHeaderView *view = [[self alloc] initWithFrame:CGRectZero];
    
    if (!yak) {
        view.titleLabel.text = @"Loading…";
        [view setFrameHeight:[view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height];
        [view setNeedsLayout];
        [view layoutIfNeeded];
    } else {
        [view updateWithYak:yak];
    }

    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _replyCountLabel   = [[UILabel alloc] initWithFrame:CGRectZero];
        _scoreLabel        = [[UILabel alloc] initWithFrame:CGRectZero];
        _authorLabel       = [[UILabel alloc] initWithFrame:CGRectZero];
        _ageLabel          = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel        = [[UILabel alloc] initWithFrame:CGRectZero];
        _addCommentButton  = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:@"Add Comment" forState:UIControlStateNormal];
            button;
        });
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 20;
        
        self.replyCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.scoreLabel.font      = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.ageLabel.font        = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.authorLabel.font     = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        self.replyCountLabel.textColor = [UIColor noVoteColor];
        self.scoreLabel.textColor      = [UIColor noVoteColor];
        self.ageLabel.textColor        = [UIColor noVoteColor];
        self.authorLabel.textColor     = [UIColor themeColor];
        
        _hairlineView = [[UIView alloc] initWithFrame:CGRectZero];
        self.hairlineView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200];
        
        [self addSubview:self.replyCountLabel];
        [self addSubview:self.scoreLabel];
        [self addSubview:self.ageLabel];
        [self addSubview:self.authorLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.addCommentButton];
        [self addSubview:self.hairlineView];
    }
    return self;
}

- (void)updateWithYak:(YYYak *)yak {
    NSParameterAssert(yak);
    
    self.scoreLabel.attributedText = [@(yak.score) scoreStringForVote:yak.voteStatus];
    self.authorLabel.text          = yak.username;
    self.authorLabel.hidden        = yak.username.length == 0;
    self.ageLabel.text             = yak.created.relativeTimeString;
    self.titleLabel.text           = yak.title;
    self.addCommentButton.hidden   = yak.isReadOnly;
    self.chatButton.hidden         = self.authorLabel.hidden;
    
    if (yak.replyCount == 1) {
        self.replyCountLabel.text = @"1 reply";
    } else {
        self.replyCountLabel.text = [NSString stringWithFormat:@"%@ replies", @(yak.replyCount)];
    }
    
    [self setFrameHeight:[self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height];
//    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    CGFloat bottomInset = 15, topInset = 10, hInset = 15;
    UIEdgeInsets insets  = UIEdgeInsetsMake(topInset, hInset, bottomInset, hInset);
    
    [self.hairlineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1.f/[UIScreen mainScreen].scale));
        make.left.right.bottom.equalTo(self);
    }];
    
    [self.replyCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(insets.top);
        make.left.mas_equalTo(insets.left);
    }];
    [self.scoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.replyCountLabel);
        make.leading.equalTo(self.replyCountLabel.mas_trailing).insets(insets);
    }];
    
    [self.ageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.replyCountLabel);
        make.trailing.equalTo(self).insets(insets);
    }];
    [self.authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.replyCountLabel);
        make.trailing.equalTo(self.ageLabel.mas_leading).insets(insets);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.replyCountLabel.mas_bottom).offset(bottomInset);
        make.left.right.equalTo(self).insets(insets);
    }];
    [self.addCommentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(bottomInset);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-bottomInset);
    }];
    
    [self.authorLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.scoreLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow+1 forAxis:UILayoutConstraintAxisHorizontal];
    
    [super updateConstraints];
}

@end
