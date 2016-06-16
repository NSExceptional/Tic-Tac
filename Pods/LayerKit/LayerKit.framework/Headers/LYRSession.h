//
//  LYRSession.h
//  LayerKit
//
//  Created by Kevin Coleman on 4/5/16.
//  Copyright (c) 2016 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRIdentity.h"

typedef NS_ENUM(NSUInteger, LYRSessionState) {
    LYRSessionStateUnauthenticated,
    LYRSessionStateAuthenticated,
    LYRSessionStateChallenged,
};

/**
 @abstract The `LYRSession` class models a Layer session.
 */
@interface LYRSession : NSObject

/**
 @abstract The identifier for the session.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 @abstract The authenticated user for the session.
 */
@property (nonatomic, readonly) LYRIdentity *authenticatedUser;

/**
 @abstract An enum value that describes the authentication state of the session.
 */
@property (nonatomic, readonly) LYRSessionState state;

/**
 @abstract The path to which the session is persisted.
 */
@property (nonatomic, readonly) NSString *sessionPath;

/**
 @abstract The database path for the underlying database for the session.
 */
@property (nonatomic, readonly) NSString *databasePath;

@end
