//
//  TTFeedPhotoCell.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTFeedPhotoCell.h"


@implementation TTFeedPhotoCell

- (void)setupStacks {
    [super setupStacks];
    
    _mediaImageView = [[UIImageView alloc] initWithImage:nil];
    self.mediaImageView.clipsToBounds = YES;
    self.mediaImageView.contentMode   = UIViewContentModeScaleAspectFill;
    
    [self.stackVerticalMain addArrangedSubview:self.mediaImageView];
}

@end
