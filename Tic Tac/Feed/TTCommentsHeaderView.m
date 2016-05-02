//
//  TTCommentsHeaderView.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentsHeaderView.h"


@interface TTCommentsHeaderView ()
@property (nonatomic, readonly) UILabel *scoreLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *ageLabel;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UIButton *addCommentButton;
@property (nonatomic, readonly) UIButton *chatButton; /* unused atm */

@property (nonatomic, readonly) UIView *hairlineView;
@property (nonatomic, readonly) UIStackView *stackHorizontalTop;
@property (nonatomic, readonly) UIStackView *stackVerticalMain;
@end

@implementation TTCommentsHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hairlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.hairlineView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.199];
        [self addSubview:_hairlineView];
        [self setupStacks];
    }
    return self;
}

- (void)setupStacks {
    // Custom views
    _scoreLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _authorLabel       = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _ageLabel          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _addCommentButton  = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Add Comment" forState:UIControlStateNormal];
        button;
    });
    
    self.titleLabel.numberOfLines = 0;
    _scoreLabel.font  = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _ageLabel.font    = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    _scoreLabel.textColor  = [UIColor noVoteColor];
    _ageLabel.textColor    = [UIColor noVoteColor];
    _authorLabel.textColor = [UIColor themeColor];

    // Stacks
    _stackHorizontalTop  = [[UIStackView alloc] initWithArrangedSubviews:@[_scoreLabel, _authorLabel, _ageLabel]];
    _stackVerticalMain   = [[UIStackView alloc] initWithArrangedSubviews:@[_stackHorizontalTop, _titleLabel, _addCommentButton]];
    
    self.stackHorizontalTop.axis         = UILayoutConstraintAxisHorizontal;
    self.stackHorizontalTop.alignment    = UIStackViewAlignmentFirstBaseline;
    self.stackHorizontalTop.distribution = UIStackViewDistributionEqualCentering;
    self.stackHorizontalTop.spacing      = 15;
    
    self.stackVerticalMain.axis         = UILayoutConstraintAxisVertical;
    self.stackVerticalMain.alignment    = UIStackViewAlignmentFill;
    self.stackVerticalMain.distribution = UIStackViewDistributionEqualSpacing;
    self.stackVerticalMain.spacing      = 10;
    // Does not need insets because we inset it with autolayout in updateConstraints
    
    [self addSubview:[self topStackView]];
}

- (UIStackView *)topStackView { return self.stackVerticalMain; }
+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    [self.hairlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1.f/[UIScreen mainScreen].scale));
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    CGFloat inset = 15;
    [[self topStackView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(inset, inset, inset, inset));
    }];
    
    [super updateConstraints];
}

- (void)configureForYak:(YYYak *)yak {
    self.scoreLabel.text = @(yak.score).stringValue;
    self.authorLabel.text = yak.handle;
    self.authorLabel.hidden = yak.handle.length == 0;
    self.ageLabel.text = yak.created.relativeTimeString;
    self.titleLabel.text = yak.title;
    self.addCommentButton.hidden = yak.isReadOnly;
    self.chatButton.hidden = self.authorLabel.hidden;
}

@end
