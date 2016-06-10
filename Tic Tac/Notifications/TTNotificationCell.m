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
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel   = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font   = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.contentLabel.textColor = [UIColor darkGrayColor];
//        self.titleLabel.text = @" "; [self.titleLabel sizeToFit];
//        self.contentLabel.text = @" "; [self.contentLabel sizeToFit];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }
- (void)updateConstraints {
    self.contentView.clipsToBounds = YES;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(15);
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
    }];
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.contentView).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.bottom.equalTo(self.contentView).with.offset(-15);
    }];
    
    [super updateConstraints];
}

- (void)setUnread:(BOOL)unread {
    _unread = unread;
    
    self.backgroundColor = unread ? [UIColor colorWithRed:0.827 green:0.805 blue:0.909 alpha:1.000] : nil;
}

@end
