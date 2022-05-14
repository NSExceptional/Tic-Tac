//
//  TBNetworkActivity.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBNetworkActivity.h"


static NSInteger counter;

@implementation TBNetworkActivity

+ (void)push {
    @synchronized(self) {
        counter++;
//        UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    }
}

+ (void)pop {
    @synchronized(self) {
        counter--;
        if (counter == 0) {
//            UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
        } if (counter < 0) {
            [NSException raise:NSGenericException format:@"Cannot pop from empty activity stack"];
        }
    }
}

@end
