//
//  NSError+Display.h
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (Display)

- (void)show;
- (void)showWithTitle:(NSString *)message;

@end
