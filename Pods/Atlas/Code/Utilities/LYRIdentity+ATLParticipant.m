//
//  LYRIdentity+ATLParticipant.m
//  Atlas
//
//  Created by Kabir Mahal on 2/17/16.
//  Copyright (c) 2016 Layer. All rights reserved.
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

#import "LYRIdentity+ATLParticipant.h"

@implementation LYRIdentity (ATLParticipant)

- (NSString *)avatarInitials
{
    NSString * initials = @"";
    if (self.firstName && self.firstName.length > 0 && self.lastName && self.lastName.length > 0) {
        initials = [NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
    }
    else if (self.displayName && self.displayName.length > 1) {
      initials = [self.displayName substringToIndex:2];
    }
    return initials;
}

- (UIImage *)avatarImage
{
    return nil;
}

@end
