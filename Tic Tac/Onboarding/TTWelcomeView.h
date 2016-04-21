//
//  BOWelcomeView.h
//  Boo
//
//  Created by Tanner on 11/16/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^VoidBlock)();


@interface TTWelcomeView : UIView

@property (nonatomic, copy) VoidBlock useNewUserButtonAction;
@property (nonatomic, copy) VoidBlock useTokenButtonAction;
@property (nonatomic, copy) VoidBlock logoTapAction;

@end
