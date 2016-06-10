//
//  TTNotificationCell.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/10/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTNotificationCell.h"

@implementation TTNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setUnread:(BOOL)unread {
    _unread = unread;
    
    self.backgroundColor = unread ? [UIColor colorWithRed:0.448 green:0.261 blue:0.909 alpha:0.500] : nil;
}

@end
