//
//  TTCommentCell.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentCell.h"
#import "UIColor+TicTac.h"

static NSDictionary *avatars;

@interface TTCommentCell ()
@property (nonatomic, readonly) UILabel *iconLabel;
@end

@implementation TTCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.customColorViewContainerView = self.contentView;
    self.repliesEnabled = YES;
}

- (void)initializeSubviews {
    [super initializeSubviews];
 
    self.replyCountLabel.hidden = YES;
    
    _iconLabel = [[UIImageView alloc] initWithImage:nil];
    self.iconLabel.clipsToBounds = YES;
    self.iconLabel.contentMode   = UIViewContentModeScaleAspectFill;
    [self.iconLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.iconLabel];
}

- (MASViewAttribute *)leftOfTitleLabel { return self.iconLabel.mas_trailing; }
- (void)updateConstraints {
    CGFloat inset = self.separatorInset.left;
    CGFloat horizontalTopBottomInset = 12;//inset * (2.f/3.f);
    UIEdgeInsets insets = UIEdgeInsetsMake(horizontalTopBottomInset, inset, horizontalTopBottomInset, inset);
    
    [self.iconLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.contentView).insets(insets);
    }];
    
    [super updateConstraints];
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        YYRunBlock(self.longPressAction);
    }
}

- (void)setIcon:(NSString *)emoji withColor:(NSString *)hexColor {
    self.iconLabel.text = emoji;
    self.iconLabel.backgroundColor = [UIColor colorWithHexString:hexColor];
}

- (CGFloat)preferredTitleLabelMaxWidth {
    return [super preferredTitleLabelMaxWidth] - (self.iconLabel.frame.size.width + 15);
}

- (void)setRepliesEnabled:(BOOL)repliesEnabled {
    if (_repliesEnabled == repliesEnabled) return;
    
    _repliesEnabled = repliesEnabled;
    
    MCSwipeTableViewCellMode mode = repliesEnabled ? MCSwipeTableViewCellModeSwitch : MCSwipeTableViewCellModeNone;
    
    UIImageView *imageView = [UIImageView imageViewWithImageNamed:@"reply" tintColor:UIColor.whiteColor];
    @weakify(self);
    [self setSwipeGestureWithView:imageView color:UIColor.replyColor
                             mode:mode state:MCSwipeTableViewCellState3
                  completionBlock:^(MCSwipeTableViewCell *swipeCell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) { @strongify(self);
                      YYRunBlock(self.replyAction);
                  }];
}

@end
