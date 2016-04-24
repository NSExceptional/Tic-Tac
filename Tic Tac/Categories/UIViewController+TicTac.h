//
//  UIViewController+TicTac.h
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (TicTac)

+ (UINavigationController *)inNavigationController;
- (void)displayOptionalError:(NSError *)error;
- (void)displayOptionalError:(NSError *)error message:(NSString *)message;

@end
