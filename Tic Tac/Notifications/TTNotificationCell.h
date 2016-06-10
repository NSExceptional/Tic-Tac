//
//  TTNotificationCell.h
//  Tic Tac
//
//  Created by CBORD Waco on 6/10/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TTNotificationCell : UITableViewCell

@property (nonatomic) BOOL unread;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *contentLabel;

@end
