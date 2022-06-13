//
//  BOWelcomeButton.h
//  Boo
//
//  Created by Tanner on 12/9/15.
//
//

#import <UIKit/UIKit.h>
#import "TTBorderButton.h"


@interface TTWelcomeButton : TTOnboardButton

+ (instancetype)buttonWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

/// Do not set the text of this label directly. Use the \c subtitle property.
@property (nonatomic, readonly) UILabel *subtitleLabel;
@property (nonatomic, copy) NSString *subtitle;
/// Defaults to 50% of the subtitle's color, which is 50% of the \c labelColor.
/// Setting the label color will change this value, so set it after if you want to customize it.
@property (nonatomic) UIColor *selectedSubtitleColor;
@property (nonatomic) CGSize dimensions;

@end
