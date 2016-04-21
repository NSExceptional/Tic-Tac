//
//  UIImage+Tint.h
//  Luna
//
//  Created by Tanner on 8/24/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIImage (Util)

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;
+ (UIImage *)imageByDrawingIcon:(UIImage *)icon onTopOf:(UIImage *)background iconTint:(UIColor *)iconTint bgColor:(UIColor *)bgColor;
- (UIImage *)paddedImage:(UIEdgeInsets)insets;
/** @return The image centered in the padding, or the original image if it does not fit in the given size. */
- (UIImage *)paddedToSize:(CGSize)size;
- (UIImage *)croppedToRect:(CGRect)rect;

/// Saves the recieving image to the camera roll.
- (void)saveToLibrary:(void (^)(NSError *error))completion;

@end
NS_ASSUME_NONNULL_END
