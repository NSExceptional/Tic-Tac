//
//  NSNull+nil.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/31/22.
//

#import <Foundation/Foundation.h>
#include <objc/runtime.h>

NSInteger _placeholder(id self, SEL selector, ...) {
    return 0;
}

@implementation NSNull (TryToFailMe)
+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    return class_addMethod([self class], aSEL, (IMP)_placeholder, "i@:?");
}
@end
