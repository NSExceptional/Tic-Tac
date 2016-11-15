//
//  NSRange+Util.h
//  Luna
//
//  Created by Tanner on 1/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Extends the range by decrementing `range.location` by `left` and incrementing `range.length` by `left + right`.
 Passing the same value to `left` and `right` essentially padds the range by that ammount.
 
 @warning `NSRange` is bounded to the left by zero, so `left` must not be greater than `range.location`.
*/
NS_INLINE NSRange NSMakeRangeByAddingPaddingToRange(NSRange range, NSUInteger left, NSUInteger right) {
    assert(range.location >= left);
    range.location -= left;
    range.length += left + right;
    return range;
}

/**
 A safeguard for `NSMakeRangeByAddingPaddingToRange` against the case where `left` is greater than `range.location`.
 This calls `NSMakeRangeByAddingPaddingToRange` with a guarantee that `left` will never be greater than `range.location`.
 */
NS_INLINE NSRange NSMakeRangeBySafelyAddingPaddingToRange(NSRange range, NSUInteger left, NSUInteger right) {
    if (range.location < left)
        left = range.location;
    return NSMakeRangeByAddingPaddingToRange(range, left, right);
}
