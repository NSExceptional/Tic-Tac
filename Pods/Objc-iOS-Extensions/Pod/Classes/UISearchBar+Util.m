//
//  UISearchBar+Util.m
//  Luna
//
//  Created by Tanner on 6/26/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UISearchBar+Util.h"

@implementation UISearchBar (Util)

- (UITextField *)textField {
    Class uisearchbartextfield = NSClassFromString(@"UISearchBarTextField");
    
    UIView *v = self.subviews.firstObject;
    for (UITextField *s in v.subviews)
        if ([s isKindOfClass:uisearchbartextfield])
            return s;
    
    return nil;
}

@end
