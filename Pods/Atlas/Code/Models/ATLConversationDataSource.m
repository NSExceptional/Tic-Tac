//
//  ATLConversationDataSource.m
//  Atlas
//
//  Created by Kevin Coleman on 2/4/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
#import "ATLConversationDataSource.h"

/**
 @abstract Extracts the LYRConversation instance used as a property comparison value from an LYRPredicate, if exists.
 @param predicate The predicate which to search for an LYRConversation instance.
 @return The first LYRConversation instance found in the predicate.
 */
LYRConversation *LYRConversationDataSourceConversationFromPredicate(LYRPredicate *predicate)
{
    LYRConversation *conversation;
    if ([predicate isKindOfClass:[LYRCompoundPredicate class]]) {
        for (LYRPredicate *subPredicate in [(LYRCompoundPredicate *)predicate subpredicates]) {
            conversation = LYRConversationDataSourceConversationFromPredicate(subPredicate);
            if (conversation) {
                return conversation;
            }
        }
    } else {
        if ([predicate.property isEqualToString:@"conversation"]) {
            conversation = predicate.value;
        }
    }
    return conversation;
}

@interface ATLConversationDataSource ()

@property (nonatomic, readwrite) LYRQueryController *queryController;
@property (nonatomic, readwrite) BOOL expandingPaginationWindow;
@property (nonatomic, readwrite) LYRConversation *conversation;

@end

@implementation ATLConversationDataSource

NSInteger const ATLNumberOfSectionsBeforeFirstMessageSection = 1;
NSInteger const ATLQueryControllerPaginationWindow = 30;

+ (instancetype)dataSourceWithLayerClient:(LYRClient *)layerClient query:(LYRQuery *)query
{
    return [[self alloc] initWithLayerClient:layerClient query:query];
}

- (id)initWithLayerClient:(LYRClient *)layerClient query:(LYRQuery *)query
{
    self = [super init];
    if (self) {
        NSUInteger numberOfMessagesAvailable = [layerClient countForQuery:query error:nil];
        NSUInteger numberOfMessagesToDisplay = MIN(numberOfMessagesAvailable, ATLQueryControllerPaginationWindow);
    
        NSError *error = nil;
        _queryController = [layerClient queryControllerWithQuery:query error:&error];
        if (!_queryController) {
            NSLog(@"LayerKit failed to create a query controller with error: %@", error);
            return nil;
        }
        _queryController.updatableProperties = [NSSet setWithObjects:@"parts.transferStatus", @"recipientStatusByUserID", @"sentAt", nil];
        _queryController.paginationWindow = -numberOfMessagesToDisplay;
        
        self.conversation = LYRConversationDataSourceConversationFromPredicate(query.predicate);
        
        BOOL success = [_queryController execute:&error];
        if (!success) NSLog(@"LayerKit failed to execute query with error: %@", error);
    }
    return self;
}

- (void)expandPaginationWindow
{
    self.expandingPaginationWindow = YES;
    if (!self.queryController) {
        self.expandingPaginationWindow = NO;
        return;
    }
    
    if (![self moreMessagesAvailable]) {
        self.expandingPaginationWindow = NO;
        return;
    }

    int messagesAvailableLocally = (int)[self messagesAvailableLocally] - (int)ATLQueryControllerPaginationWindow;
    if (messagesAvailableLocally <= 0) {
        [self requestToSynchronizeMoreMessages:ABS(messagesAvailableLocally)];
    } else {
        [self finishExpandingPaginationWindow];
    }
}

- (void)finishExpandingPaginationWindow
{
    NSUInteger numberOfMessagesToDisplay = MIN(-self.queryController.paginationWindow + ATLQueryControllerPaginationWindow, self.queryController.totalNumberOfObjects);
    self.queryController.paginationWindow = -numberOfMessagesToDisplay;
    self.expandingPaginationWindow = NO;
}

- (void)requestToSynchronizeMoreMessages:(NSUInteger)numberOfMessagesToSynchronize
{
    NSError *error;
    __weak typeof(self) weakSelf = self;
    __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:LYRConversationDidFinishSynchronizingNotification object:self.conversation queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (observer) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        [weakSelf finishExpandingPaginationWindow];
    }];
    BOOL success = [self.conversation synchronizeMoreMessages:numberOfMessagesToSynchronize error:&error];
    if (!success) {
        if (observer) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        [weakSelf finishExpandingPaginationWindow];
        return;
    }
}

- (BOOL)moreMessagesAvailable
{
    return [self messagesAvailableLocally] != 0 || [self messagesAvailableRemotely] != 0;
}

- (NSUInteger)messagesAvailableLocally
{
    return self.queryController.totalNumberOfObjects - ABS(self.queryController.count);
}

- (NSUInteger)messagesAvailableRemotely
{
    return (NSUInteger)MAX((NSInteger)0, (NSInteger)self.conversation.totalNumberOfMessages - (NSInteger)ABS(self.queryController.count));
}

- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
{
    return [self queryControllerIndexPathForCollectionViewSection:collectionViewIndexPath.section];
}

- (NSIndexPath *)queryControllerIndexPathForCollectionViewSection:(NSInteger)collectionViewSection
{
    NSInteger queryControllerRow = [self queryControllerRowForCollectionViewSection:collectionViewSection];
    NSIndexPath *queryControllerIndexPath = [NSIndexPath indexPathForRow:queryControllerRow inSection:0];
    return queryControllerIndexPath;
}

- (NSInteger)queryControllerRowForCollectionViewSection:(NSInteger)collectionViewSection
{
    return collectionViewSection - ATLNumberOfSectionsBeforeFirstMessageSection;
}

- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)queryControllerIndexPath
{
    return [self collectionViewIndexPathForQueryControllerRow:queryControllerIndexPath.row];
}

- (NSIndexPath *)collectionViewIndexPathForQueryControllerRow:(NSInteger)queryControllerRow
{
    NSInteger collectionViewSection = [self collectionViewSectionForQueryControllerRow:queryControllerRow];
    NSIndexPath *collectionViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:collectionViewSection];
    return collectionViewIndexPath;
}

- (NSInteger)collectionViewSectionForQueryControllerRow:(NSInteger)queryControllerRow
{
    return queryControllerRow + ATLNumberOfSectionsBeforeFirstMessageSection;
}

- (LYRMessage *)messageAtCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
{
    NSIndexPath *queryControllerIndexPath = [self queryControllerIndexPathForCollectionViewIndexPath:collectionViewIndexPath];
    LYRMessage *message = [self.queryController objectAtIndexPath:queryControllerIndexPath];
    return message;
}

- (LYRMessage *)messageAtCollectionViewSection:(NSInteger)collectionViewSection
{
    NSIndexPath *queryControllerIndexPath = [self queryControllerIndexPathForCollectionViewSection:collectionViewSection];
    LYRMessage *message = [self.queryController objectAtIndexPath:queryControllerIndexPath];
    return message;
}

@end
