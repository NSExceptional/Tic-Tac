//
//  BOBorderButton.h
//  Boo
//
//  Created by Tanner on 11/23/15.
//
//

#import <UIKit/UIKit.h>

@interface TTBorderButton : UIButton

@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *selectedTitleColor;
@property (nonatomic) BOOL    fillsUponSelection;

- (void)roundCorners;

@end
