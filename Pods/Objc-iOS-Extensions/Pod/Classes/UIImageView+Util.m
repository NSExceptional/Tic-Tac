//
//  UIImageView+Util.m
//  Luna
//
//  Created by Tanner on 11/28/14.
//
//

#import "UIImageView+Util.h"
#import "UIImageView+Filter.h"
#import "UIImage+Util.h"


@implementation UIImageView (Util)

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name tintColor:(UIColor *)color {
    UIImage *image         = [[UIImage imageNamed:name] tintedImageWithColor:color];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode  = UIViewContentModeCenter;
    return imageView;
}

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    imageView.contentMode  = UIViewContentModeCenter;
    return imageView;
}

- (void)setMaskImage:(UIImage *)mask {
    CALayer *thumbMask       = [CALayer layer];
    thumbMask.contents       = (id)mask.CGImage;
    thumbMask.frame          = CGRectMake(0, 0, mask.size.width, mask.size.height);
    self.layer.mask          = thumbMask;
    self.layer.masksToBounds = YES;
}

@end
