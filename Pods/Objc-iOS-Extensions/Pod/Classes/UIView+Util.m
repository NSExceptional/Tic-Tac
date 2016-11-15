//
//  UIView.m
//  Luna
//
//  Created by Tanner on 1/6/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UIView+Util.h"

#define roundToHalf(x) ((round(x * 2) / 2.f))

@implementation UIView (Util)

- (UIView *)subviewWithClass:(Class)classObject {
    NSParameterAssert(classObject);
    if (!self.subviews.count) return nil;
    
    for (UIView *v in self.subviews)
        if ([v isKindOfClass:classObject])
            return v;
    
    return nil;
}

- (UIView *)subviewWithClass:(Class)classObject passingTest:(BOOL (^)(UIView *))test {
    NSParameterAssert(classObject); NSParameterAssert(test);
    if (!self.subviews.count) return nil;
    
    for (UIView *v in self.subviews)
        if ([v isKindOfClass:classObject] && test(v))
            return v;
    
    return nil;
}

- (void)setFrameOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame   = frame;
}

- (void)setFrameSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size   = size;
    self.frame   = frame;
}

- (void)setFrameWidth:(CGFloat)width {
    CGRect frame     = self.frame;
    frame.size.width = width;
    self.frame       = frame;
}

- (void)setFrameHeight:(CGFloat)height {
    CGRect frame      = self.frame;
    frame.size.height = height;
    self.frame        = frame;
}

- (void)setFrameX:(CGFloat)xpos {
    CGRect frame   = self.frame;
    frame.origin.x = xpos;
    self.frame     = frame;
}

- (void)setFrameY:(CGFloat)ypos {
    CGRect frame   = self.frame;
    frame.origin.y = ypos;
    self.frame     = frame;
}

- (void)setCenterX:(CGFloat)xpos{
    CGPoint p = self.center;
    p.x = xpos;
    self.center = p;
}

- (void)setCenterY:(CGFloat)ypos {
    CGPoint p = self.center;
    p.y = ypos;
    self.center = p;
}

- (void)centerWithinView:(UIView *)view {
    CGRect s  = view.frame;
    CGPoint p = self.center;
    p.x = s.size.width/2.f;
    p.y = s.size.height/2.f;
    self.center = p;
}

- (void)centerYInView:(UIView *)view alignToLeftWithPadding:(CGFloat)padding {
    self.center = view.center;
    [self setFrameX:padding];
    // Rounding
    [self setFrameY:self.frame.origin.y];
}

- (void)centerYInView:(UIView *)view alignToRightWithPadding:(CGFloat)padding {
    self.center  = view.center;
    CGFloat xpos = CGRectGetWidth(view.frame) - padding;
    xpos        -= CGRectGetWidth(self.frame);
    [self setFrameX:xpos];
    // Rounding
    [self setFrameY:self.frame.origin.y];
}

- (void)centerYInView:(UIView *)view centerXBetweenView:(UIView *)left andView:(UIView *)right {
    NSParameterAssert(CGRectGetMaxX(left.frame) < CGRectGetMinX(right.frame));
    [self centerYInView:view centerXBetween:CGRectGetMaxX(left.frame) and:CGRectGetMinX(right.frame)];
}

- (void)centerYInView:(UIView *)view centerXBetweenView:(UIView *)left and:(CGFloat)xright {
    NSParameterAssert(CGRectGetMaxX(left.frame) < xright);
    [self centerYInView:view centerXBetween:CGRectGetMaxX(left.frame) and:xright];
}

- (void)centerYInView:(UIView *)view centerXBetween:(CGFloat)xleft andView:(UIView *)right {
    NSParameterAssert(xleft < CGRectGetMinX(right.frame));
    [self centerYInView:view centerXBetween:xleft and:CGRectGetMinX(right.frame)];
}

- (void)centerYInView:(UIView *)view centerXBetween:(CGFloat)xleft and:(CGFloat)xright {
    NSParameterAssert(xleft < xright);
    self.center = view.center;
    [self setFrameX:xleft + (xright - xleft)/2.f - CGRectGetWidth(self.frame)/2.f];
}


- (void)centerXInView:(UIView *)view alignToTopWithPadding:(CGFloat)padding {
    self.center = view.center;
    [self setFrameY:padding];
    // Rounding
    [self setFrameX:self.frame.origin.x];
}

- (void)centerXInView:(UIView *)view alignToBottomWithPadding:(CGFloat)padding {
    self.center  = view.center;
    CGFloat ypos = CGRectGetHeight(view.frame) - padding;
    ypos        -= CGRectGetHeight(self.frame);
    [self setFrameY:ypos];
    // Rounding
    [self setFrameX:self.frame.origin.x];
}

- (void)centerXInView:(UIView *)view centerYBetweenView:(UIView *)above andView:(UIView *)below {
    NSParameterAssert(CGRectGetMaxY(above.frame) < CGRectGetMinY(below.frame));
    [self centerXInView:view centerYBetween:CGRectGetMaxY(above.frame) and:CGRectGetMinY(below.frame)];
}

- (void)centerXInView:(UIView *)view centerYBetweenView:(UIView *)above and:(CGFloat)ybottom {
    NSParameterAssert(CGRectGetMaxY(above.frame) < ybottom);
    [self centerXInView:view centerYBetween:CGRectGetMaxY(above.frame) and:ybottom];
}

- (void)centerXInView:(UIView *)view centerYBetween:(CGFloat)ytop andView:(UIView *)below {
    NSParameterAssert(ytop < CGRectGetMinY(below.frame));
    [self centerXInView:view centerYBetween:ytop and:CGRectGetMinY(below.frame)];
}

- (void)centerXInView:(UIView *)view centerYBetween:(CGFloat)ytop and:(CGFloat)ybottom {
    NSParameterAssert(ytop < ybottom);
    self.center = view.center;
    [self setFrameY:(ytop + (ybottom - ytop)/2.f) - CGRectGetHeight(self.frame)/2.f];
}

- (NSArray *)allConstraintsInHierarchy {
    return [self allConstraintsInHierarchyExcludingViews:nil];
}

- (NSArray *)allConstraintsInHierarchyExcludingViews:(NSArray *)views {
    NSMutableSet *constraints = self.constraints.mutableCopy;
    NSMutableArray *subviews;
    if (views.count) {
        subviews = self.subviews.mutableCopy;
        [subviews removeObjectsInArray:views];
    } else {
        subviews = (id)self.subviews;
    }
    
    for (UIView *subview in subviews)
        [constraints addObjectsFromArray:subview.constraints];
    
    // Filter dangling constraints containing excluded views
    NSMutableSet *filteredConstraints = constraints.mutableCopy;
    for (NSLayoutConstraint *constraint in constraints)
        if ([views containsObject:constraint.firstItem] || [views containsObject:constraint.secondItem])
            [filteredConstraints removeObject:constraint];
    
    return filteredConstraints.allObjects;
}

+ (CGFloat)sumOfFramePart:(CGFramePart)part ofViews:(NSArray *)views {
    CGFloat sum = 0;
    
    switch (part) {
        case CGFramePartX:
            for (UIView *view in views)
                sum += view.frame.origin.x;
            break;
            
        case CGFramePartY:
            for (UIView *view in views)
                sum += view.frame.origin.y;
            break;
            
        case CGFramePartWidth:
            for (UIView *view in views)
                sum += CGRectGetWidth(view.frame);
            break;
            
        case CGFramePartHeight:
            for (UIView *view in views)
                sum += CGRectGetHeight(view.frame);
            break;
    }
    
    return sum;
}

@end
