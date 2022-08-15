//
//  Firebase-Private.h
//  Tic Tac
//
//  Created by Tanner Bennett on 8/12/22.
//

#ifndef Firebase_Private_h
#define Firebase_Private_h

@import Foundation;
@import FirebaseAuth;
#import "FIRAuthStoredUserManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FIRRetrieveUserCallback)(FIRUser *_Nullable user, NSError *_Nullable error);

@interface FIRUser (Private) <NSSecureCoding>

+ (void)retrieveUserWithAuth:(FIRAuth *)auth
                  accessToken:(nullable NSString *)accessToken
    accessTokenExpirationDate:(nullable NSDate *)accessTokenExpirationDate
                 refreshToken:(nullable NSString *)refreshToken
                    anonymous:(BOOL)anonymous
                     callback:(FIRRetrieveUserCallback)callback;

@end

NS_ASSUME_NONNULL_END

#endif /* Firebase_Private_h */
