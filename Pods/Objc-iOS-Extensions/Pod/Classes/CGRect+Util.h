//
//  CGRect+Util.h
//  Luna
//
//  Created by Tanner on 6/23/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE CGRect CGRectScaleRect(CGRect r, CGFloat scale) {
    return CGRectMake(r.origin.x * scale,
                      r.origin.y * scale,
                      r.size.width * scale,
                      r.size.height * scale);
}

NS_INLINE CGRect CGRectInsetAll(CGRect r, UIEdgeInsets i) {
    return CGRectMake(r.origin.x + i.left,
                      r.origin.y + i.top,
                      r.size.width - i.right,
                      r.size.height - i.bottom);
}

NS_INLINE CGRect CGRectInsetLeft(CGRect r, CGFloat dx, CGFloat dy) {
    return CGRectMake(r.origin.x + dx,
                      r.origin.y + dy,
                      r.size.width - dx,
                      r.size.height - dy);
}

NS_INLINE CGRect CGRectInsetRight(CGRect r, CGFloat dx, CGFloat dy) {
    return CGRectMake(r.origin.x,
                      r.origin.y,
                      r.size.width - dx,
                      r.size.height - dy);
}