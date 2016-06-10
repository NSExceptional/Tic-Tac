//
//  TTReplyViewController.h
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TTReplyViewController : UIViewController

+ (UINavigationController *)initialText:(NSString *)text limit:(NSUInteger)limit onSubmit:(void(^)(NSString *text, BOOL useHandle))submit;

@end
