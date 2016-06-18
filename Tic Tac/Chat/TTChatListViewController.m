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
    [chat connectToLayerAndInitialize];
    return chat;
}

- (LYRClient *)layer { return [YYClient sharedClient].layerClient; }

- (void)viewDidLoad {
    [self connectToLayerAndInitialize];
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate   = self;
}

- (void)connectToLayerAndInitialize {
    if (!self.layer.isConnected) {
        [self.layer connectWithCompletion:^(BOOL success, NSError *error) {
            [self displayOptionalError:error];
            if (success) {
                if ([YYClient sharedClient].currentUser.handle) {
                    if (!self.layer.authenticatedUser) {
                        [self authenticateWithLayer];
                    }
                }
            }
        }];
    } else if (!self.layer.authenticatedUser) {
        [self authenticateWithLayer];
    }
}

- (void)authenticateWithLayer {
    NSAssert(!self.layer.authenticatedUser, @"Already authenticated with layer");
    
    [self.layer requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        assert((!nonce && error) || (nonce && !error));
        [self displayOptionalError:error message:@"Failed to authenticate chat"];
        if (!error) {
            [[YYClient sharedClient] authenticateForLayer:nonce completion:^(NSString *identityToken, NSError *error2) {
                [self displayOptionalError:error2 message:@"Failed to authenticate chat"];
                if (!error2) {
                    [self.layer authenticateWithIdentityToken:identityToken completion:^(LYRIdentity *user, NSError *error3) {
                        [self displayOptionalError:error3 message:@"Failed to authenticate chat"];
                    }];
                }
            }];
        }
    }];
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
    return conversation.metadata[@"users"][users.allObjects.firstObject.userID][@"handle"] ?: users.allObjects.firstObject.userID;
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
