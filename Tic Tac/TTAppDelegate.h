//
//  AppDelegate.h
//  Tic Tac
//
//  Created by Tanner on 4/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTabBarController.h"


@interface TTAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (nonatomic, readonly) TTTabBarController *tabBarController;

- (void)setupNewUser:(VoidBlock)completion;

@end

