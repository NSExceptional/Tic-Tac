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


+ (NSDictionary *)avatars {
    if (!avatars) {
        avatars = @{@"000": [UIImage imageNamed:@"av_op"]};
    }
    
    return avatars;
}

- (void)setupStacks {
    [super setupStacks];
    
    self.replyCountLabel.hidden = YES;
    
    _iconImageView = [[UIImageView alloc] initWithImage:nil];
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.contentMode   = UIViewContentModeScaleAspectFill;
    
//    [self.stackHorizontalMain insertArrangedSubview:self.iconImageView atIndex:0];
}

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
    self.iconImageView.layer.cornerRadius = icon.size.width/2.f;
}

@end
