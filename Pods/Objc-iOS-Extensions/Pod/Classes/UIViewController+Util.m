//
//  UIViewController.m
//  Luna
//
//  Created by Tanner on 1/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UIViewController+Util.h"
@import SafariServices;


@implementation UIViewController (Util)

- (UIViewController *)topmostViewController {
    if (self.presentedViewController) {
        return self.presentedViewController.topmostViewController;
    }
    
    return self;
}

- (void)dismissAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)launchLinkInBrowser:(NSString *)urlString {
    NSURL *url;
    if ([urlString isKindOfClass:[NSURL class]]) {
        url = (id)urlString;
    } else  {
        url = [NSURL URLWithString:urlString];
    }
    
    if ([SFSafariViewController class]) {
        id browser = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:browser animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end