//
//  BOBorderButton.m
//  Boo
//
//  Created by Tanner on 11/23/15.
//
//

#import "TTBorderButton.h"

@interface CALayer (Private)
@property (nonatomic) BOOL tb_continuousCorners;
@property (nonatomic) BOOL continuousCorners;
@end

@implementation CALayer (Private)
@dynamic continuousCorners;

static BOOL respondsToContinuousCorners = NO;

+ (void)load {
    respondsToContinuousCorners = [CALayer
        instancesRespondToSelector:@selector(setContinuousCorners:)
    ];
}

- (BOOL)tb_continuousCorners {
    if (respondsToContinuousCorners) {
        return self.continuousCorners;
    }
    
    return NO;
}

- (void)setTb_continuousCorners:(BOOL)enabled {
    if (respondsToContinuousCorners) {
        if (@available(iOS 13, *)) {
            self.cornerCurve = kCACornerCurveContinuous;
        } else {
            self.continuousCorners = enabled;
        }
    }
}

@end

@interface TTOnboardButton ()
@property (nonatomic) UIColor *currentColor;
@property (nonatomic) UIColor *previousTitleColor;
@property (nonatomic, readonly) UIColor *highlightColor;

@property (nonatomic, readonly) UIColor *borderColor;
@end

@implementation TTOnboardButton

+ (instancetype)buttonWithStyle:(TTOnboardButtonStyle)style {
    TTOnboardButton *button = [self alloc];
    button->_appearanceStyle = style;
    return [button init];
}

- (id)init {
    self = [super init];
    if (self) {
        self.selectionFadeDuration = 0;
        self.labelColor = UIColor.labelColor;
        self.currentColor = self.tintColor;
        
        if (self.appearanceStyle == TTOnboardButtonStyleBordered) {
            self.borderWidth = 1;
        }
        
        self.clipsToBounds = YES;
        
        self.layer.tb_continuousCorners = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cornerRadius = self.frame.size.height * 0.28;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted == highlighted) return;
    super.highlighted = highlighted;
    
    [UIView animateWithDuration:self.selectionFadeDuration animations:^{
        if (highlighted) {
            self.currentColor = self.highlightColor;
        } else {
            self.currentColor = self.tintColor;
        }
        
        // Swap title color
        if (self.selectedLabelColor) {
            if (highlighted) {
                [self setTitleColor:self.selectedLabelColor forState:self.state];
            } else {
                [self setTitleColor:self.labelColor forState:self.state];
            }
        }
    }];
}

#pragma mark Properties

- (void)tintColorDidChange {
    self.currentColor = self.tintColor;
}

- (void)setLabelColor:(UIColor *)labelColor {
    _labelColor = labelColor;
    self.selectedLabelColor = [labelColor colorWithAlphaComponent:0.5];
    
    if (self.highlighted && self.appearanceStyle == TTOnboardButtonStyleFilled) {
        labelColor = [labelColor colorWithAlphaComponent:0.5];
    }
    
    [self setTitleColor:_labelColor forState:UIControlStateNormal];
    [self setTitleColor:_selectedLabelColor forState:UIControlStateHighlighted];
}

- (UIColor *)currentColor {
    switch (self.appearanceStyle) {
        case TTOnboardButtonStyleBordered:
            return [UIColor colorWithCGColor:self.layer.borderColor];
        case TTOnboardButtonStyleFilled:
            return self.backgroundColor;
    }
}

- (void)setCurrentColor:(UIColor *)color {
    switch (self.appearanceStyle) {
        case TTOnboardButtonStyleBordered:
            if (self.highlighted) {
                self.backgroundColor = color;
                self.layer.borderColor = color.CGColor;
            } else {
                self.backgroundColor   = UIColor.clearColor;
                self.layer.borderColor = color.CGColor;
            }
            break;
        case TTOnboardButtonStyleFilled:
            self.backgroundColor = color;
            break;
    }
}

- (UIColor *)highlightColor {
    switch (self.appearanceStyle) {
        case TTOnboardButtonStyleBordered:
            return self.tintColor;
        case TTOnboardButtonStyleFilled:
            return [self.tintColor colorWithAlphaComponent:0.5];
    }
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

- (UIColor *)borderColor {
    return self.layer.borderColor ? [UIColor colorWithCGColor:self.layer.borderColor] : nil;
}

@end
