//
//  TTFeedTextCell.m
//  Tic Tac
//
//  Created by Tanner on 4/20/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTFeedTextCell.h"


@interface TTFeedTextCell ()
@property (nonatomic, readonly) UILabel *authorLabel;
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
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    self.titleLabel.numberOfLines = 0;
    
    // Stacks
    _stackHorizontalTop    = [[UIStackView alloc] initWithArrangedSubviews:@[_authorLabel, _scoreLabel]];
    _stackHorizontalBottom = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel]];
    _stackVerticalMain     = [[UIStackView alloc] initWithArrangedSubviews:@[_stackHorizontalTop, _stackHorizontalBottom]];
    
    self.stackHorizontalTop.axis         = UILayoutConstraintAxisHorizontal;
    self.stackHorizontalTop.alignment    = UIStackViewAlignmentLastBaseline;
    self.stackHorizontalTop.distribution = UIStackViewDistributionEqualSpacing;
    self.stackHorizontalTop.spacing      = 10;
    
    self.stackHorizontalBottom.axis         = UILayoutConstraintAxisHorizontal;
    self.stackHorizontalBottom.alignment    = UIStackViewAlignmentLastBaseline;
    self.stackHorizontalBottom.distribution = UIStackViewDistributionEqualSpacing;
    self.stackHorizontalBottom.spacing      = 10;
    
    self.stackVerticalMain.axis         = UILayoutConstraintAxisVertical;
    self.stackVerticalMain.alignment    = UIStackViewAlignmentLeading;
    self.stackVerticalMain.distribution = UIStackViewDistributionEqualSpacing;
    self.stackVerticalMain.spacing      = 10;
    // Does not need insets because we inset it with autolayout in updateConstraints
    
    [self.contentView addSubview:self.stackVerticalMain];
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    CGFloat inset = self.separatorInset.left;
    [self.stackVerticalMain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(inset, inset, inset, inset));
    }];
    
    [super updateConstraints];
}

- (UILabel *)votingLabel { return self.scoreLabel; }

- (NSString *)authorLabelText {
    return self.authorLabel.text;
}

- (void)setAuthorLabelText:(NSString *)authorLabelText {
    self.authorLabel.text = authorLabelText;
    self.authorLabel.hidden = authorLabelText.length == 0;
}

@end
