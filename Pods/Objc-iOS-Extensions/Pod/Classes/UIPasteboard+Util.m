//
//  UIPasteboard+Util.m
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import "UIPasteboard+Util.h"

@implementation UIPasteboard (Util)

+ (void)copyTextToGeneral:(NSString *)string {
    [self generalPasteboard].string = string;
}

+ (void)copyImageToGeneral:(UIImage *)image {
    [self generalPasteboard].image = image;
}

@end
