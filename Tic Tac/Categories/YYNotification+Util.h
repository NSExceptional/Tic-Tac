//
//  YYNotification+Util.h
//  Tic Tac
//
//  Created by CBORD Waco on 6/10/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YYNotification (Util)

@property (nonatomic, readonly) BOOL isPostReply;
@property (nonatomic, readonly) NSString *notificationHeadline;

@end
