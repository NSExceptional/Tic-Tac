//
//  BOWelcomeView.h
//  Boo
//
//  Created by Tanner on 11/16/15.
//
//

#import <UIKit/UIKit.h>
#import <YakKit/YakKit.h>


@interface TTWelcomeView : UIView

@property (nonatomic, copy) YYVoidBlock useNewUserButtonAction;
@property (nonatomic, copy) YYVoidBlock signInButtonAction;
@property (nonatomic, copy) YYVoidBlock logoTapAction;

@end
