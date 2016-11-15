//
//  UIImageView+Util.h
//  Luna
//
//  Created by Tanner on 11/28/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (Util)

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name tintColor:(UIColor *)color;
+ (UIImageView *)imageViewWithImageNamed:(NSString *)name;
- (void)setMaskImage:(UIImage *)mask;

@end
