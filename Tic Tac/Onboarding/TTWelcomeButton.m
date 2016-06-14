//
//  BOWelcomeButton.m
//  Boo
//
//  Created by Tanner on 12/9/15.
//
//

#import "TTWelcomeButton.h"

@interface TTWelcomeButton ()
@property (nonatomic) UIColor *previousSubtitleColor;
@end


@implementation TTWelcomeButton

+ (instancetype)buttonWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    TTWelcomeButton *button = [[self alloc] initWithFrame:CGRectZero];
    [button setTitle:title forState:UIControlStateNormal];
    button.subtitle = subtitle;
    return button;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
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

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted == highlighted) return;
    super.highlighted = highlighted;
    
    // Swap subtitle color
    [UIView animateWithDuration:.2 animations:^{
        if (self.fillsUponSelection && _selectedSubtitleColor) {
            if (highlighted) {
                _previousSubtitleColor   = _subtitleLabel.textColor;
                _subtitleLabel.textColor = _selectedSubtitleColor;
            } else {
                _subtitleLabel.textColor = _previousSubtitleColor;
                _previousSubtitleColor   = nil;
            }
        }
    }];
}

- (CGSize)intrinsicContentSize {
    if (_dimensions.width > 0 && _dimensions.height > 0)
        return _dimensions;
    return [super intrinsicContentSize];
}

- (void)sizeToFit {
    [self setFrameSize:self.intrinsicContentSize];
}

- (void)setTitleColorMagic:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateNormal];
    _subtitleLabel.textColor = [self darkerColorFrom:color];
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
