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
        [self initializeSubviews];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _godModeGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentGodModeActions:)];
        [self.contentView addGestureRecognizer:_godModeGesture];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
                                                          object:self queue:nil usingBlock:^(NSNotification *note) {
                                                              _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                                                              for (UILabel *label in @[_scoreLabel, _ageLabel, _authorLabel, _replyCountLabel]) {
                                                                  label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                                                              }
                                                          }];
    }
    
    return self;
}

- (void)initializeSubviews {
    // Create labels
    NSMutableArray *labels = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++) {
        UILabel *label  = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font      = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        label.textColor = [UIColor noVoteColor];
        [labels addObject:label];
        [self.contentView addSubview:label];
    }
    _titleLabel = labels[0], _scoreLabel = labels[1], _ageLabel = labels[2], _authorLabel = labels[3], _replyCountLabel = labels[4];
    
    // Label fonts and colors
    self.titleLabel.font       = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.titleLabel.textColor  = [UIColor blackColor];
    self.authorLabel.textColor = [UIColor themeColor];
    self.titleLabel.numberOfLines = 0;
}

- (MASViewAttribute *)leftOfTitleLabel { return self.contentView.mas_leading; }
+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    CGFloat inset = self.separatorInset.left;
    CGFloat horizontalTopBottomInset = 12;//inset * (2.f/3.f);
    UIEdgeInsets insets = UIEdgeInsetsMake(horizontalTopBottomInset, inset, horizontalTopBottomInset, inset);
    
    // To account for missing replies label
    UIView *firstTopLeading, *secondTopLeading = nil;
    if (self.replyCountLabel.hidden) {
        firstTopLeading = self.authorLabel;
    } else {
        firstTopLeading = self.replyCountLabel;
        secondTopLeading = self.authorLabel;
    }
    
    [firstTopLeading mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).insets(insets);
        make.leading.equalTo(self.titleLabel);
    }];
    [secondTopLeading mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.replyCountLabel.mas_trailing).offset(horizontalTopBottomInset);
        make.baseline.equalTo(firstTopLeading);
    }];
    
    [self.ageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).insets(insets);
        make.baseline.equalTo(firstTopLeading);
    }];
    [self.scoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.ageLabel.mas_leading).offset(-horizontalTopBottomInset);
        make.baseline.equalTo(firstTopLeading);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstTopLeading.mas_bottom).offset(8);
        make.trailing.bottom.equalTo(self.contentView).insets(insets);
        make.leading.equalTo(self.leftOfTitleLabel).insets(insets);
    }];
    
    [self.ageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.authorLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
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

- (void)setVisited:(BOOL)visited {
    _visited = visited;
    
    self.titleLabel.textColor = visited ? [UIColor noVoteColor] : [UIColor blackColor];
}

- (NSArray<UIView*> *)opaqueViews {
    return @[_titleLabel, _scoreLabel, _ageLabel, _authorLabel, _replyCountLabel, self.contentView];
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
