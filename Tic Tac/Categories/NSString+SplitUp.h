//
//  NSString+SplitUp.h
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (SplitUp)

- (NSArray<NSString*> *)brokenUpByCharacterLimit:(NSUInteger)limit;

@end
