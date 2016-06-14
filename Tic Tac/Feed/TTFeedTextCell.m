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
        _godModeGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentGodModeActions:)];
        [self.contentView addGestureRecognizer:_godModeGesture];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
                                                          object:self queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                                                              
                                                              _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                                                              for (UILabel *label in @[_scoreLabel, _ageLabel, _authorLabel, _replyCountLabel]) {
                                                                  label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                                                              }
                                                          }];
    }
    
    return self;
}

- (void)setupStacks {
    // Custom views
    NSMutableArray *labels = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++)
        [labels addObject:[[UILabel alloc] initWithFrame:CGRectZero]];
    
    _titleLabel = labels[0], _scoreLabel = labels[1], _ageLabel = labels[2], _authorLabel = labels[3], _replyCountLabel = labels[4];
    
    // Label fonts and colors
    _titleLabel.font       = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    for (UILabel *label in @[_scoreLabel, _ageLabel, _authorLabel, _replyCountLabel]) {
        label.font      = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        label.textColor = [UIColor noVoteColor];
    }
    _authorLabel.textColor = [UIColor themeColor];
    
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    // Stacks
    UIStackView *stackHorizontalTopLeft  = [[UIStackView alloc] initWithArrangedSubviews:@[_replyCountLabel, _authorLabel]];
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
    [[self topStackView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(topBottomInset, inset, topBottomInset, inset));
    }];
    
    [self.ageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [super updateConstraints];
}

//- (void)layoutSubviews {
//    self.titleLabel.preferredMaxLayoutWidth = self.preferredTitleLabelMaxWidth;
//    [super layoutSubviews];
//}

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
             _stackVerticalMain, _stackHorizontalMain, _stackHorizontalTop, self.contentView];
}

- (CGFloat)preferredTitleLabelMaxWidth {
    return CGRectGetWidth(self.frame) - 2 * self.separatorInset.left;
}

/// For efficiency
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = backgroundColor ?: [UIColor whiteColor];
    
    for (UIView *view in self.opaqueViews) {
        view.backgroundColor = backgroundColor;
    }
}

- (void)presentGodModeActions:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan)
        [TTManager showGodModeForVotable:self.votable];
}

@end
