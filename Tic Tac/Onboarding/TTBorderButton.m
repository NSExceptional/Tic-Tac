//
//  BOBorderButton.m
//  Boo
//
//  Created by Tanner on 11/23/15.
//
//

#import "TTBorderButton.h"

@interface TTBorderButton ()
@property (nonatomic) UIColor *previousTitleColor;
@end

@implementation TTBorderButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    self.borderColor  = self.tintColor;
    self.borderWidth  = 1;
    self.cornerRadius = 4;
    
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.clipsToBounds = YES;
    
    self.backgroundColor       = UIColor.clearColor;
    self.layer.backgroundColor = self.backgroundColor.CGColor;
    self.layer.borderColor     = self.tintColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.fillsUponSelection) {
        super.highlighted = highlighted;
        [UIView animateWithDuration:.2 animations:^{
            if (highlighted)
                self.backgroundColor = self.borderColor;
            else
                self.backgroundColor = UIColor.clearColor;
            // Swap title color
            if (_selectedTitleColor) {
                if (highlighted) {
                    _previousTitleColor       = self.titleLabel.textColor;
                    self.titleLabel.textColor = _selectedTitleColor;
                } else {
                    self.titleLabel.textColor = _previousTitleColor;
                    _previousTitleColor       = nil;
                }
            }

        }];
    } else {
        if (highlighted == super.highlighted) return;
        
        CGFloat newAlpha = highlighted ? .2 : 1;
        CGColorRef newColor = [self.tintColor colorWithAlphaComponent:newAlpha].CGColor;
        
        CABasicAnimation *alphaChange = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        alphaChange.fromValue = (id)self.layer.borderColor;
        alphaChange.toValue = (__bridge id)newColor;
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration   = 0.025;
        group.animations = @[alphaChange];
        
        [self.layer addAnimation:group forKey:@"selectionAnimation"];
        self.layer.borderColor = newColor;
        
        super.highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

#pragma mark Properties

- (void)setTintColor:(UIColor *)tintColor {
    self.layer.borderColor = tintColor.CGColor;
    [super setTintColor:tintColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)roundCorners {
    self.cornerRadius = CGRectGetHeight(self.frame)/2.f;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    if (self.fillsUponSelection)
        [self setTitleColor:selectedTitleColor forState:UIControlStateSelected];
    else
        [self setTitleColor:selectedTitleColor forState:UIControlStateHighlighted];
}

@end
