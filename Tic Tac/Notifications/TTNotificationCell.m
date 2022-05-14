//
//  TTNotificationCell.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/10/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTNotificationCell.h"

@implementation TTNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.clipsToBounds = YES;
        
        _titleLabel   = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font   = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.contentLabel.textColor = UIColor.darkGrayColor;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
    }
    
    return self;
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    CGFloat inset = self.separatorInset.left;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView).insets(UIEdgeInsetsMake(inset, inset, inset, inset)).priorityMedium();
    }];
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
        make.left.right.equalTo(self.titleLabel);
        make.bottom.equalTo(self.contentView).insets(UIEdgeInsetsMake(inset, inset, inset, inset));
    }];
    
    [self.contentLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [super updateConstraints];
}

- (void)setUnread:(BOOL)unread {
    _unread = unread;
    
    self.backgroundColor = unread ? [UIColor colorWithRed:0.827 green:0.805 blue:0.909 alpha:1.000] : nil;
}

@end
