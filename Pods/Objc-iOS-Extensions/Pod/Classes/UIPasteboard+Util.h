//
//  UIPasteboard+Util.h
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import <UIKit/UIKit.h>

@interface UIPasteboard (Util)

+ (void)copyTextToGeneral:(NSString *)string;
+ (void)copyImageToGeneral:(UIImage *)image;

@end
