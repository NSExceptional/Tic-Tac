//
//  TTCommentCell.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCommentCell.h"


@interface TTCommentCell ()
@property (nonatomic, readonly) UIImageView *iconImageView;
@end

@implementation TTCommentCell

- (void)setupStacks {
    [super setupStacks];
    
    _iconImageView = [[UIImageView alloc] initWithImage:nil];
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.contentMode   = UIViewContentModeScaleAspectFill;
    
    [self.stackHorizontalBottom insertArrangedSubview:self.iconImageView atIndex:0];
}

- (UIImage *)icon {
    return self.iconImageView.image;
}

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
    self.iconImageView.layer.cornerRadius = icon.size.width/2.f;
}

@end
