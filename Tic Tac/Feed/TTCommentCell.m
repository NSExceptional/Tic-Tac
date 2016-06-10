//
//  TTCommentCell.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentCell.h"


static NSDictionary *avatars;

@interface TTCommentCell ()
@property (nonatomic, readonly) UIImageView *iconImageView;
@end

@implementation TTCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.customColorViewContainerView = self.contentView;
    self.repliesEnabled = YES;
}

- (void)setupStacks {
    [super setupStacks];
    
    self.replyCountLabel.hidden = YES;
    
    _iconImageView = [[UIImageView alloc] initWithImage:nil];
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.contentMode   = UIViewContentModeScaleAspectFill;
    [self.iconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.stackVerticalMain setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.stackHorizontalMain insertArrangedSubview:self.iconImageView atIndex:0];
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        YYRunBlock(self.longPressAction);
    }
}

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
    self.iconImageView.layer.cornerRadius = icon.size.width/2.f;
}

- (void)setIcon:(NSString *)iconName withColor:(NSString *)colorName {
    UIImage *icon  = [UIImage imageNamed:[@"icon_" stringByAppendingString:iconName]];
    UIImage *color = [UIImage imageNamed:[@"color_" stringByAppendingString:colorName]];
    
    UIImage *avatar = [UIImage imageByDrawingIcon:icon onTopOf:color iconTint:nil bgColor:nil];
    [self setIcon:avatar];
}

- (CGFloat)preferredTitleLabelMaxWidth {
    return [super preferredTitleLabelMaxWidth] - (CGRectGetWidth(self.iconImageView.frame) + self.stackHorizontalMain.spacing);
}

- (void)setRepliesEnabled:(BOOL)repliesEnabled {
    if (_repliesEnabled == repliesEnabled) return;
    
    _repliesEnabled = repliesEnabled;
    
    MCSwipeTableViewCellMode mode = repliesEnabled ? MCSwipeTableViewCellModeSwitch : MCSwipeTableViewCellModeNone;
    
    UIImageView *imageView = [UIImageView imageViewWithImageNamed:@"reply" tintColor:[UIColor whiteColor]];
    @weakify(self);
    [self setSwipeGestureWithView:imageView color:[UIColor replyColor]
                             mode:mode state:MCSwipeTableViewCellState3
                  completionBlock:^(MCSwipeTableViewCell *swipeCell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) { @strongify(self);
                      YYRunBlock(self.replyAction);
                  }];
}

- (void)setRemoved:(BOOL)removed {
    _removed = removed;
    if (removed) {
        self.backgroundColor = [UIColor colorWithRed:0.800 green:0.400 blue:0.400 alpha:1.000];
    } else {
        self.backgroundColor = nil;
    }
}

@end
