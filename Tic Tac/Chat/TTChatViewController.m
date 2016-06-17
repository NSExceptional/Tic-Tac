//
//  TTChatViewController.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTChatViewController.h"


@interface TTChatViewController () <ATLConversationViewControllerDelegate, ATLConversationViewControllerDataSource>
@end

@implementation TTChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTapLink:)
                                                 name:ATLUserDidTapLinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTapPhoneNumber:)
                                                 name:ATLUserDidTapPhoneNumberNotification object:nil];
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterShortStyle;
    });
    
    return formatter;
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)convVC attributedStringForDisplayOfDate:(NSDate *)date {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
                                 NSForegroundColorAttributeName: [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[[TTChatViewController dateFormatter] stringFromDate:date] attributes:attributes];
}

- (NSAttributedString *)conversationViewController:(id)convoVC attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus {
    if (recipientStatus.count == 0) return nil;
    
    NSMutableAttributedString *mergedStatuses = [NSMutableAttributedString new];
    
    [recipientStatus.allKeys enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:self.layerClient.authenticatedUser.userID]) {
            return;
        }
        
        NSString *checkmark = @"✔︎";
        NSString *messageStatus;
        UIColor *textColor = [UIColor lightGrayColor];
        switch (status) {
            case LYRRecipientStatusInvalid: {
                textColor = [UIColor redColor];
                messageStatus = @"Error";
                break;
            }
            case LYRRecipientStatusPending: {
                textColor = [UIColor lightGrayColor];
                messageStatus = @"Pending";
                break;
            }
            case LYRRecipientStatusSent: {
                textColor = [UIColor lightGrayColor];
                messageStatus = @"Sent";
                break;
            }
            case LYRRecipientStatusDelivered: {
                textColor = [UIColor orangeColor];
                messageStatus = @"Delivered";
                break;
            }
            case LYRRecipientStatusRead: {
                textColor = [UIColor greenColor];
                messageStatus = @"Read";
                break;
            }
        }
        NSAttributedString *statusString = [[NSAttributedString alloc] initWithString:messageStatus attributes:@{NSForegroundColorAttributeName: textColor}];
        [mergedStatuses appendAttributedString:statusString];
    }];
    
    return mergedStatuses;
}

- (void)userDidTapLink:(NSNotification *)notification {
    [[UIApplication sharedApplication] openURL:notification.object];
}

- (void)userDidTapPhoneNumber:(NSNotification *)notification {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", notification.object]]];
}

@end
