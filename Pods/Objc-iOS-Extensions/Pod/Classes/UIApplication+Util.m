//
//  UIApplication+Util.m
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import "UIApplication+Util.h"

@implementation UIApplication (Util)

+ (void)openURLString:(NSString *)string {
    [[self sharedApplication] openURL:[NSURL URLWithString:string]];
}

@end
