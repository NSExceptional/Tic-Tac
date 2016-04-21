//
//  BOWelcomeButton.h
//  Boo
//
//  Created by Tanner on 12/9/15.
//
//

#import <UIKit/UIKit.h>
#import "TTBorderButton.h"


@interface TTWelcomeButton : TTBorderButton

+ (instancetype)buttonWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

// Do not set the text of this label directly. Use the \c subtitle property.
@property (nonatomic, readonly) UILabel *subtitleLabel;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) UIColor *selectedSubtitleColor;
@property (nonatomic) CGSize dimensions;

/** Sets the title color and automatically sets
    the subtitle color based on it. */
- (void)setTitleColorMagic:(UIColor *)color;

@end
