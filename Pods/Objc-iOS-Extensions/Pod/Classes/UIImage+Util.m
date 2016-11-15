//
//  UIImage+Tint.m
//  Luna
//
//  Created by Tanner on 8/24/14.
//
//

#import "UIImage+Util.h"
#import "CGRect+Util.h"
@import AssetsLibrary;
@import Photos;


@implementation UIImage (Util)

// It's important to pass in 0.0f to this function to draw the image to the scale of the screen
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)imageByDrawingIcon:(UIImage *)icon onTopOf:(UIImage *)background iconTint:(UIColor *)iconTint bgColor:(UIColor *)bgColor {
    
    if (iconTint) {
        icon = [icon tintedImageWithColor:iconTint];
    }
    if (bgColor) {
        background = [background tintedImageWithColor:bgColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(background.size, NO, 0.0f);
    CGRect mainBounds = CGRectMake(0, 0, background.size.width, background.size.height);
    
    CGFloat iconX = (mainBounds.size.width - icon.size.width)/2;
    CGFloat iconY = (mainBounds.size.height - icon.size.height)/2;
    CGRect iconBounds = CGRectMake(iconX, iconY, icon.size.width, icon.size.height);
    
    [background drawInRect:mainBounds];
    [icon drawInRect:iconBounds];
    
    UIImage *stackedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return stackedImage;
}

- (UIImage *)paddedImage:(UIEdgeInsets)insets {
    CGSize newSize = self.size;
    newSize.height += insets.top + insets.bottom;
    newSize.width  += insets.left + insets.right;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    CGPoint origin = CGPointMake(insets.left, insets.top);
    [self drawAtPoint:origin];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)paddedToSize:(CGSize)size {
    if (size.width < self.size.width || size.height < self.size.height)
        return self;
    
    CGFloat dw = size.width - self.size.width;
    CGFloat dh = size.height - self.size.height;
    UIEdgeInsets insets = UIEdgeInsetsMake(dh/2.f, dw/2.f, dh/2.f, dw/2.f);
    return [self paddedImage:insets];
}

- (UIImage *)croppedToRect:(CGRect)rect {
    rect            = CGRectScaleRect(rect, self.scale);
    CGImageRef ref  = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:ref scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(ref);
    return result;
}

- (void)saveToLibrary:(void (^)(NSError *error))completion {
#if __has_include(<Photos/PHPhotoLibrary.h>)
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    [library performChanges:^{
        [PHAssetCreationRequest creationRequestForAssetFromImage:self];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completion(success ? nil : error);
    }];
#else
    ALAssetsLibrary *library = [ALAssetsLibrary new];
    
    [library writeImageToSavedPhotosAlbum:self.CGImage orientation:(ALAssetOrientation)self.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (completion) completion(error);
    }];
#endif
}

@end
