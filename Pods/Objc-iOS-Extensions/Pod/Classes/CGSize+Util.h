//
//  CGSize+Util.h
//  Luna
//
//  Created by Tanner on 6/23/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE CGFloat CGSizeArea(CGSize s) {
    return s.width * s.height;
}

NS_INLINE NSUInteger CGSizeAreaIntegral(CGSize s) {
    return (NSUInteger)(ceil(2.0*(s.width * s.height)) / 2.0);
}
