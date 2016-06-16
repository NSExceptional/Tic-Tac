//
//  TTChatViewController.m
//  Tic Tac
//
//  Created by CBORD Waco on 6/16/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTChatViewController.h"
#import "YakKit.h"


@interface TTChatViewController ()
@property (nonatomic, readonly) LYRClient *layer;
@end

@implementation TTChatViewController

- (LYRClient *)layer { return [YYClient sharedClient].layerClient; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self connectToLayerAndInitialize];
}

- (void)connectToLayerAndInitialize {
    if (!self.layer.isConnected) {
        [self.layer connectWithCompletion:^(BOOL success, NSError *error) {
            [self displayOptionalError:error];
            if (success) {
                if ([YYClient sharedClient].currentUser.handle) {
                    if (self.layer.authenticatedUser) {
                        [self loadConversations];
                    } else {
                        [self authenticateWithLayer];
                    }
                } else {
                    // No handle, no chat?
                }
            }
        }];
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
                    [self.layer authenticateWithIdentityToken:identityToken completion:^(LYRIdentity *authenticatedUser, NSError *error3) {
                        [self displayOptionalError:error3 message:@"Failed to authenticate chat"];
                        if (!error3) {
                            [self didAuthenticate];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)didAuthenticate {
    
}

- (void)loadConversations {
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    query.limit = 20;
    query.offset = 0;
    
    NSError *error;
    NSOrderedSet *messages = [self.layer executeQuery:query error:&error];
    if (!error) {
        NSLog(@"%tu messages in conversation", messages.count);
    } else {
        NSLog(@"Query failed with error %@", error);
    }
}

#pragma mark ATLConversationListViewControllerDelegate

- (void)conversationListViewController:(ATLConversationListViewController *)listvc didSelectConversation:(LYRConversation *)conversation {
    SampleConversationViewController *controller = [SampleConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.conversation = conversation;
    controller.displaysAddressBar = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
