//
//  NSAttributedString+Util.h
//  Luna
//
//  Created by Tanner on 3/18/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSAttributedString (Util)

/** @note If `value` is not specified, the old value will be used. */
- (NSAttributedString *)attributedStringByReplacingOccurencesOfAttribute:(id)oldAttribute withAttribute:(id)newAttribute newValue:(nullable id)value;

@end
NS_ASSUME_NONNULL_END
