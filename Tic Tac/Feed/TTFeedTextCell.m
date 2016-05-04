//
//  TTFeedTextCell.m
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTFeedTextCell.h"


@interface TTFeedTextCell ()
@end

@implementation TTFeedTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupStacks];
    }
    
    return self;
}

- (void)setupStacks {
    // Custom views
    _titleLabel      = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _scoreLabel      = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _ageLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _authorLabel     = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _replyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    _titleLabel.font      = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _scoreLabel.font      = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _ageLabel.font        = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _authorLabel.font     = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _replyCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    _scoreLabel.textColor      = [UIColor noVoteColor];
    _ageLabel.textColor        = [UIColor noVoteColor];
    _authorLabel.textColor     = [UIColor themeColor];
    _replyCountLabel.textColor = [UIColor noVoteColor];
    
    self.titleLabel.numberOfLines = 0;
    
    // Stacks
    UIStackView *stackHorizontalTopLeft = [[UIStackView alloc] initWithArrangedSubviews:@[_replyCountLabel, _authorLabel]];
    UIStackView *stackHorizontalTopRight = [[UIStackView alloc] initWithArrangedSubviews:@[_scoreLabel, _ageLabel]];
    _stackHorizontalTop  = [[UIStackView alloc] initWithArrangedSubviews:@[stackHorizontalTopLeft, stackHorizontalTopRight]];
    _stackVerticalMain   = [[UIStackView alloc] initWithArrangedSubviews:@[_stackHorizontalTop, _titleLabel]];
    _stackHorizontalMain = [[UIStackView alloc] initWithArrangedSubviews:@[_stackVerticalMain]];
    
    
    stackHorizontalTopLeft.axis         = UILayoutConstraintAxisHorizontal;
    stackHorizontalTopLeft.alignment    = UIStackViewAlignmentLastBaseline;
    stackHorizontalTopLeft.distribution = UIStackViewDistributionEqualSpacing;
    stackHorizontalTopLeft.spacing      = 12;
    
    stackHorizontalTopRight.axis         = UILayoutConstraintAxisHorizontal;
    stackHorizontalTopRight.alignment    = UIStackViewAlignmentLastBaseline;
    stackHorizontalTopRight.distribution = UIStackViewDistributionEqualSpacing;
    stackHorizontalTopRight.spacing      = 12;
    
    self.stackHorizontalTop.axis         = UILayoutConstraintAxisHorizontal;
    self.stackHorizontalTop.alignment    = UIStackViewAlignmentLastBaseline;
    self.stackHorizontalTop.distribution = UIStackViewDistributionEqualSpacing;
    self.stackHorizontalTop.spacing      = 15;
    
    self.stackHorizontalMain.axis         = UILayoutConstraintAxisHorizontal;
    self.stackHorizontalMain.alignment    = UIStackViewAlignmentTop;
    self.stackHorizontalMain.distribution = UIStackViewDistributionFill;
    self.stackHorizontalMain.spacing      = 10;
    
    self.stackVerticalMain.axis         = UILayoutConstraintAxisVertical;
    self.stackVerticalMain.alignment    = UIStackViewAlignmentFill;
    self.stackVerticalMain.distribution = UIStackViewDistributionEqualSpacing;
    self.stackVerticalMain.spacing      = 8;
    // Does not need insets because we inset it with autolayout in updateConstraints
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:[self topStackView]];
}

- (UIStackView *)topStackView { return self.stackHorizontalMain; }
+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    CGFloat inset = self.separatorInset.left;
    CGFloat topBottomInset = 12;//inset * (2.f/3.f);
    [[self topStackView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(topBottomInset, inset, topBottomInset, inset));
    }];
    
    [self.ageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    self.titleLabel.preferredMaxLayoutWidth = self.preferredTitleLabelMaxWidth;
    [super layoutSubviews];
}

- (UILabel *)votingLabel { return self.scoreLabel; }

- (NSString *)authorLabelText {
    return self.authorLabel.text;
}

- (void)setAuthorLabelText:(NSString *)authorLabelText {
    self.authorLabel.text = authorLabelText;
    self.authorLabel.hidden = authorLabelText.length == 0;
}

- (NSArray<UIView*> *)opaqueViews {
    return @[_titleLabel, _scoreLabel, _ageLabel, _authorLabel, _replyCountLabel,
             _stackVerticalMain, _stackHorizontalMain, _stackHorizontalTop];
}

- (CGFloat)preferredTitleLabelMaxWidth {
    return CGRectGetWidth(self.frame) - 2 * self.separatorInset.left;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = backgroundColor;
    
    for (UIView *view in self.opaqueViews) {
        view.backgroundColor = backgroundColor;
    }
}

@end
