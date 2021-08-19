//
//  TTChatListViewController.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTChatListViewController.h"
#import "TTChatViewController.h"


@interface TTChatListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>
@property (nonatomic, readonly) LYRClient *layer;
@end

@implementation TTChatListViewController

+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient {
    TTChatListViewController *chat = [super conversationListViewControllerWithLayerClient:layerClient];
    return chat;
}

- (LYRClient *)layer { return [YYClient sharedClient].layerClient; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate   = self;
    
    id compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                               target:self action:@selector(composeButtonPressed)];
    self.navigationItem.rightBarButtonItem = compose;
    
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [[YYClient sharedClient] layerIdentifierForPersona:@"o_RNrmaCXRROnbwH60RAiz5rEWHeBNzJsbHuPg" completion:^(NSString *string, NSError *error) {
    //                if (!error) {
    //                    NSSet *participants = [NSSet setWithArray:@[string, self.layer.authenticatedUser.userID]];
    //                    LYRConversation *convo = [self.layer newConversationWithParticipants:participants options:nil error:&error];
    //                    [self conversationListViewController:self didSelectConversation:convo];
    //                }
    //            }];
    //        });
}

- (void)composeButtonPressed {
    NSString *message = @"Enter a comma-space separated list of Layer identifiers.";
    TBAlertController *compose = [TBAlertController alertViewWithTitle:@"Compose" message:message];
    [compose addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"45edrtg9ewfh8h, 76ty89u0iohuvh";
    }];
    [compose addOtherButtonWithTitle:@"Cancel"];
    [compose addOtherButtonWithTitle:@"Start" buttonAction:^(NSArray *textFieldStrings) {
        NSError *error = nil;
        NSSet *participants = [NSSet setWithArray:[textFieldStrings.firstObject componentsSeparatedByString:@", "]];
        participants = [participants setByAddingObject:self.layer.authenticatedUser.userID];
        LYRConversation *convo = [self.layer newConversationWithParticipants:participants options:nil error:&error];
        if (error) {
            [self displayOptionalError:error];
        } else {
            [self conversationListViewController:self didSelectConversation:convo];
        }
    }];
    [compose showFromViewController:self];
}

- (LYRConversation *)conversationAt:(NSInteger)row {
    return [self.queryController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

#pragma mark ATLConversationListViewControllerDelegate

- (void)conversationListViewController:(ATLConversationListViewController *)listvc didSelectConversation:(LYRConversation *)conversation {
    TTChatViewController *controller = [TTChatViewController conversationViewControllerWithLayerClient:self.layer];
    controller.conversation = conversation;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - ATLConversationListViewControllerDataSource

- (NSString *)conversationListViewController:(ATLConversationListViewController *)list titleForConversation:(LYRConversation *)conversation {
    // Get participants without myself
    NSMutableSet<LYRIdentity*> *users = conversation.participants.mutableCopy;
    [users minusSet:[NSSet setWithObject:self.layerClient.authenticatedUser]];
    
    if (users.count == 0) return @"No Participants";
    
    NSMutableArray *names  = [NSMutableArray array];
    NSArray *identifiers   = [conversation.metadata[@"users"] allKeys];
    NSDictionary *allUsers = conversation.metadata[@"users"];
    for (NSString *identifier in identifiers) {
        if (![identifier isEqualToString:self.layerClient.authenticatedUser.userID]) {
            [names addObject:allUsers[identifier][@"handle"] ?: identifier];
        }
    }
    
    return [names componentsJoinedByString:@", "];
    
//    id dict = @{@"users": @{@"42a428a7-a8af-4875-aa12-a28bb3d18574": @{@"handle": @"Lechuza",
//                                                                       @"push_notify": @"1",
//                                                                       @"accepted": @"1"},
//                            @"487135b8-e609-40df-a68c-dda903b676c0": @{@"handle": @"Sunset",
//                                                                       @"push_notify": @"1",
//                                                                       @"accepted": @"0"},
//                            @"34457298-a6f4-4042-8eec-fcfe70b2ef90": @{@"handle": @"TheLuna",
//                                                                       @"push_notify": @"1",
//                                                                       @"accepted": @"1"}}};
}

#pragma mark - Participant Delegate

- (void)participantTableViewController:(ATLParticipantTableViewController *)partictvc didSelectParticipant:(id <ATLParticipant>)participant {
    [self.navigationController popViewControllerAnimated:NO];
    
    // Create a new conversation
    NSError *error = nil;
    LYRConversation *conversation = [self.layerClient newConversationWithParticipants:[NSSet setWithArray:@[self.layer.authenticatedUser.userID, participant.userID]] options:nil error:&error];
    if (!conversation) {
        NSLog(@"New Conversation creation failed: %@", error);
    } else {
        [self conversationListViewController:self didSelectConversation:conversation];
    }
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)partictvc didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion {
}

@end
