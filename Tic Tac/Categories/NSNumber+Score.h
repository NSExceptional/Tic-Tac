//
//  NSNumber+Score.h
//  Tic Tac
//
//  Created by CBORD Waco on 6/14/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSNumber (Score)

- (NSAttributedString *)scoreStringForVote:(YYVoteStatus)status;

@property (nonatomic, readonly) NSString *scoreString;

@end
