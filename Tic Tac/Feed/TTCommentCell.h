//
//  TTCommentCell.h
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTFeedTextCell.h"


@interface TTCommentCell : TTFeedTextCell

@property (nonatomic) BOOL isOP;
@property (nonatomic) BOOL repliesEnabled;
@property (nonatomic, copy) VoidBlock replyAction;

@property (nonatomic) VoidBlock longPressAction;

- (void)setIcon:(NSString *)icon withColor:(NSString *)color;

@end
