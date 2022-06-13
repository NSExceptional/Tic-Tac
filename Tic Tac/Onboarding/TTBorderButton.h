//
//  BOBorderButton.h
//  Boo
//
//  Created by Tanner on 11/23/15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TTOnboardButtonStyle) {
    TTOnboardButtonStyleBordered,
    TTOnboardButtonStyleFilled,
};

/// Change the button's tintColor to adjust its appearance.
@interface TTOnboardButton : UIButton

+ (instancetype)buttonWithStyle:(TTOnboardButtonStyle)style;


@property (nonatomic, readonly) TTOnboardButtonStyle appearanceStyle;

@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) UIColor *labelColor;
@property (nonatomic) UIColor *selectedLabelColor;
/// Defaults to 0
@property (nonatomic) CGFloat selectionFadeDuration;

@end
