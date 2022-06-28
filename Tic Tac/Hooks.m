//
//  Hooks.m
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

#import <Foundation/Foundation.h>
@import FLEX;

@interface Hooks : NSObject

@end

@implementation Hooks
+ (void)load {
    FLEXMethod *bundleID = [NSBundle flex_methodNamed:@"bundleIdentifier"];
    IMP orig = bundleID.implementation;
    bundleID.implementation = imp_implementationWithBlock(^(NSBundle *bundle) {
        NSString *identifier = ((NSString *(*)(id, SEL))orig)(bundle, @selector(bundleIdentifier));
        if (bundle == NSBundle.mainBundle) {
            return @"com.yikyak.2";
        }
        
        return identifier;
    });
}
@end
