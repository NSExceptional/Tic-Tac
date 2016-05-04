//
//  TTCommentsHeaderView.h
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TTCommentsHeaderView : UIView

+ (instancetype)headerForYak:(YYYak *)yak;
@property (nonatomic, readonly) UIButton *addCommentButton;

@end
