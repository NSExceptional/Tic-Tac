//
//  NSObject.h
//  Luna
//
//  Created by Tanner on 1/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Util)

#pragma mark Success / Error / Progress
- (void)showSuccess:(NSString *)title;
- (void)showSuccess:(NSString *)title from:(UIViewController *)viewController;
- (void)showError:(NSError *)error;
- (void)showErrorMessage:(NSString *)message;
- (void)showError:(NSError *)error message:(NSString *)message;
- (void)showError:(NSError *)error message:(NSString *)message from:(UIViewController *)viewController;
- (void)showErrorMessage:(NSString *)message subtitle:(NSString *)subtitle;
- (void)showErrorMessage:(NSString *)message subtitle:(NSString *)subtitle from:(UIViewController *)viewController;
- (void)showProgress;
- (void)showProgressTitle:(NSString *)title;
- (void)showProgressEndless;
- (void)showProgressEndlessTitle:(NSString *)title;
- (void)showProgressTitle:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration from:(UIViewController *)viewController;

#pragma mark Hud
- (void)dismissHUD;
- (void)showActivityHUD;
- (void)showSuccessHUDWithMessage:(NSString *)message;
- (void)showSuccessHUD;
- (void)showFailureHUD;
- (void)showFailureHUDWithMessage:(NSString *)message;

@end
