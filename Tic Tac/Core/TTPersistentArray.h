//
//  TTPersistentArray.h
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TTPersistentArray<ObjectType> : NSMutableArray<ObjectType>

@property (nonatomic, copy) ObjectType (^chooseDuplicate)(ObjectType original, ObjectType duplicate);

@end
