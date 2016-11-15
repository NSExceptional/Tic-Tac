//
//  TTManager.m
//  Tic Tac
//
//  Created by Tanner on 6/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTManager.h"


@interface TTManager ()

@end

@implementation TTManager

+ (void)showGodModeForVotable:(YYVotable *)votable {
    TBAlertController *god = [TBAlertController alertViewWithTitle:@"God Mode" message:@"Let's fuck shit up"];
    [god addOtherButtonWithTitle:@"Make popular" target:self action:@selector(superUpvote:) withObject:votable];
    [god addOtherButtonWithTitle:@"Murder this bitch" target:self action:@selector(superDownvote:) withObject:votable];
    [god addOtherButtonWithTitle:@"Remove it for good" target:self action:@selector(superReport:) withObject:votable];
    [god addOtherButtonWithTitle:@"Revoke upvotes" target:self action:@selector(superUnpvote:) withObject:votable];
    [god addOtherButtonWithTitle:@"Revoke downvotes" target:self action:@selector(superUndownvote:) withObject:votable];
    [god setCancelButtonWithTitle:@"Cancel"];
    [god showNow];
}

+ (void)superSomething:(void(^)(YYClient *client))action {
    CLLocation *orig = [YYClient sharedClient].location;
    
    NSInteger i = 0;
    [TBNetworkActivity push];
    for (NSString *userIdentifier in [NSUserDefaults allUserIdentifiers]) {
        YYClient *temp = [YYClient new];
        temp.region    = kRegionUSCentral;
        temp.location  = [self scatter:orig];
        temp.userIdentifier = userIdentifier;
        
        action(temp);
        if (++i == [NSUserDefaults otherUserIdentifiers].count) {
            [TBNetworkActivity pop];
        }
    }
}

+ (CLLocation *)scatter:(CLLocation *)loc {
    int randA = arc4random() % 2 == 0 ? 1 : -1;
    int randB = arc4random() % 2 == 0 ? 1 : -1;
    // 1 / [1-3] * 200 gives us a change range of 0.00500 to 0.00167
    double multiplier = (arc4random_uniform(2)+1) * 200;
    // salt for extra randomness between locations
    double salt = arc4random_uniform(5000); salt /= 10000000.f;
    CLLocationDegrees lat = loc.coordinate.latitude  + salt + randA / multiplier;
    CLLocationDegrees lng = loc.coordinate.longitude - salt + randB / multiplier;
    
    if (lat == loc.coordinate.latitude || lng == loc.coordinate.longitude) {
        return [self scatter:loc];
    }
    
    return [[CLLocation alloc] initWithLatitude:lat longitude:lng];
}

+ (void)superUpvote:(YYVotable *)votable {
    [self superSomething:^(YYClient *client) {
        [client upvote:votable completion:^(NSError *error) {
            [votable setValue:@(YYVoteStatusNone) forKey:@"voteStatus"];
            NSLog(@"%@", error.localizedDescription);
        }];
    }];
}

+ (void)superDownvote:(YYVotable *)votable {
    [self superSomething:^(YYClient *client) {
        [client downvote:votable completion:^(NSError *error) {
            [votable setValue:@(YYVoteStatusNone) forKey:@"voteStatus"];
            NSLog(@"%@", error.localizedDescription);
        }];
    }];
}

+ (void)superUnpvote:(YYVotable *)votable {
    [votable setValue:@(YYVoteStatusUpvoted) forKey:@"voteStatus"];
    [self superSomething:^(YYClient *client) {
        [client removeVote:votable completion:^(NSError *error) {
            [votable setValue:@(YYVoteStatusUpvoted) forKey:@"voteStatus"];
            NSLog(@"%@", error.localizedDescription);
        }];
    }];
}

+ (void)superUndownvote:(YYVotable *)votable {
    [votable setValue:@(YYVoteStatusDownvoted) forKey:@"voteStatus"];
    [self superSomething:^(YYClient *client) {
        [client removeVote:votable completion:^(NSError *error) {
            [votable setValue:@(YYVoteStatusDownvoted) forKey:@"voteStatus"];
            NSLog(@"%@", error.localizedDescription);
        }];
    }];
}

+ (void)superReport:(YYVotable *)votable {
    
}

@end
