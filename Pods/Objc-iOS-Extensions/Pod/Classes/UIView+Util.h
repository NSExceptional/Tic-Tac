//
//  UIView.h
//  Luna
//
//  Created by Tanner on 1/6/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CGFramePart) {
    CGFramePartX,
    CGFramePartY,
    CGFramePartWidth,
    CGFramePartHeight
};

@interface UIView (Util)

- (UIView *)subviewWithClass:(Class)classObject;
- (UIView *)subviewWithClass:(Class)classObject passingTest:(BOOL(^)(UIView *view))test;

- (void)setFrameOrigin:(CGPoint)origin;
- (void)setFrameSize:(CGSize)size;
- (void)setFrameWidth:(CGFloat)width;
- (void)setFrameHeight:(CGFloat)height;
- (void)setFrameX:(CGFloat)xpos;
- (void)setFrameY:(CGFloat)ypos;

- (void)setCenterX:(CGFloat)xpos;
- (void)setCenterY:(CGFloat)ypos;

- (void)centerWithinView:(UIView *)view;

- (void)centerYInView:(UIView *)view alignToLeftWithPadding:(CGFloat)padding;
- (void)centerYInView:(UIView *)view alignToRightWithPadding:(CGFloat)padding;
- (void)centerYInView:(UIView *)view centerXBetweenView:(UIView *)left andView:(UIView *)right;
- (void)centerYInView:(UIView *)view centerXBetweenView:(UIView *)view and:(CGFloat)xright;
- (void)centerYInView:(UIView *)view centerXBetween:(CGFloat)xleft andView:(UIView *)view;
- (void)centerYInView:(UIView *)view centerXBetween:(CGFloat)xleft and:(CGFloat)xright;

- (void)centerXInView:(UIView *)view alignToTopWithPadding:(CGFloat)padding;
- (void)centerXInView:(UIView *)view alignToBottomWithPadding:(CGFloat)padding;
- (void)centerXInView:(UIView *)view centerYBetweenView:(UIView *)above andView:(UIView *)below;
- (void)centerXInView:(UIView *)view centerYBetweenView:(UIView *)above and:(CGFloat)ybottom;
- (void)centerXInView:(UIView *)view centerYBetween:(CGFloat)ytop andView:(UIView *)below;
- (void)centerXInView:(UIView *)view centerYBetween:(CGFloat)ytop and:(CGFloat)ybottom;

/** All constraints held by the view and its subviews. */
- (NSArray *)allConstraintsInHierarchy;
- (NSArray *)allConstraintsInHierarchyExcludingViews:(NSArray *)views;

+ (CGFloat)sumOfFramePart:(CGFramePart)part ofViews:(NSArray *)views;

@end
