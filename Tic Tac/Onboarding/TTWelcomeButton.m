//
//  BOWelcomeButton.m
//  Boo
//
//  Created by Tanner on 12/9/15.
//
//

#import "TTWelcomeButton.h"

@interface TTWelcomeButton ()
@property (nonatomic) UIColor *subtitleColor;
@end


@implementation TTWelcomeButton

+ (instancetype)buttonWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    TTWelcomeButton *button = [self buttonWithStyle:TTOnboardButtonStyleFilled];
    [button setTitle:title forState:UIControlStateNormal];
    button.subtitle = subtitle;
    return button;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        [self addSubview:_subtitleLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel centerWithinView:self.titleLabel.superview];
    [self.titleLabel setFrameY:CGRectGetMinY(self.titleLabel.frame) - CGRectGetHeight(self.titleLabel.frame)/2.f];
    _subtitleLabel.center = self.titleLabel.center;
    [_subtitleLabel setFrameY:CGRectGetHeight(self.frame) * .082 + CGRectGetMaxY(self.titleLabel.frame)];
}

- (NSString *)subtitle {
    return _subtitleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitleLabel.text = subtitle;
    [_subtitleLabel sizeToFit];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark Overrides

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted == highlighted) return;
    super.highlighted = highlighted;
    
    // Swap subtitle color
    [UIView animateWithDuration:self.selectionFadeDuration animations:^{
        if (self.selectedSubtitleColor) {
            if (highlighted) {
                self.subtitleLabel.textColor = self.selectedSubtitleColor;
            } else {
                self.subtitleLabel.textColor = self.subtitleColor;
            }
        }
    }];
}

- (void)setLabelColor:(UIColor *)labelColor {
    super.labelColor = labelColor;
    
    self.subtitleColor = [labelColor colorWithAlphaComponent:0.5];
    self.selectedSubtitleColor = [self.subtitleColor colorWithAlphaComponent:0.5];
    
    if (self.highlighted) {
        self.subtitleLabel.textColor = self.selectedSubtitleColor;
    } else {
        self.subtitleLabel.textColor = self.subtitleColor;
    }
}

- (CGSize)intrinsicContentSize {
    if (_dimensions.width > 0 && _dimensions.height > 0) {
        return _dimensions;
    }
    
    return [super intrinsicContentSize];
}

- (void)sizeToFit {
    [self setFrameSize:self.intrinsicContentSize];
}

#pragma mark Misc

- (UIColor *)darkerColorFrom:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.1, 0.0)
                               green:MAX(g - 0.1, 0.0)
                                blue:MAX(b - 0.1, 0.0)
                               alpha:a];
    return nil;
}

@end
