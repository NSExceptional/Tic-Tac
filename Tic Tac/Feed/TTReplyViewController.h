//
//  TTReplyViewController.h
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TTReplyViewController : UIViewController

+ (UINavigationController *)replyWithInitialText:(NSString *)text onSubmit:(void(^)(NSString *text, BOOL useHandle))submit;

@end
