//
//  BOWelcomeView.m
//  Boo
//
//  Created by Tanner on 11/16/15.
//
//

#import "TTWelcomeView.h"
#import "TTWelcomeButton.h"

#define kIs3x (UIScreen.mainScreen.scale == 3.0)
#define SCREEN_WIDTH (UIScreen.mainScreen.bounds.size.width)
#define SCREEN_HEIGHT (UIScreen.mainScreen.bounds.size.height)
#define kNavBarHeight 44.f

@interface TTWelcomeView ()

@property (nonatomic) TTWelcomeButton *useNewUserButton;
@property (nonatomic) TTWelcomeButton *userTokenButton;
@property (nonatomic) UIButton *authTokenButton;

@property (nonatomic) UILabel *welcomeLabel;
@property (nonatomic) UILabel *bodyLabel;
@property (nonatomic) NSLayoutConstraint *logoWidth;

@property (nonatomic) UIImageView *logo;
@property (nonatomic) UIView      *circle;
@property (nonatomic) UILabel     *descriptionLabel;
@property (nonatomic) UIView      *hairline;

@end

@implementation TTWelcomeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubviews];
        @weakify(self);
        self.logoTapAction = ^{ @strongify(self);
            self.tintColor                  = UIColor.themeColor;
            self.circle.backgroundColor     = self.tintColor;
            self.useNewUserButton.tintColor = self.tintColor;
            self.userTokenButton.tintColor  = self.tintColor;
            self.authTokenButton.tintColor  = self.tintColor;
        };
    }
    
    return self;
}

- (void)initializeSubviews {
    self.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.tintColor = UIColor.themeColor;
    
    CGRect frame           = CGRectZero;
    UIImage *booIcon       = [UIImage imageNamed:@"login_icon"];
    NSMutableAttributedString *welcomeToTicTac = [[NSMutableAttributedString alloc] initWithString:@"Welcome to Tic Tac"];;
    NSString *description  = @"A powerful Yik Yak client with the ability to filter posts, "
    @"change users, and more.";
    NSString *loginDesc    = @"Continue using a new Yik Yak account.";
    NSString *signUpDesc   = @"Enter the user token of an existing account.";
    NSString *authTokeDesc = @"What is a user token?";
    
    self.logo             = [[UIImageView alloc] initWithImage:booIcon];
    self.circle           = ({UIView *v = [UIView new]; v.backgroundColor = UIColor.themeColor; v;});
    self.welcomeLabel     = [[UILabel alloc] initWithFrame:frame];
    self.descriptionLabel = [[UILabel alloc] initWithFrame:frame];
    self.useNewUserButton = [TTWelcomeButton buttonWithTitle:@"New User" subtitle:loginDesc];
    self.userTokenButton  = [TTWelcomeButton buttonWithTitle:@"Existing User" subtitle:signUpDesc];
    self.authTokenButton  = [UIButton buttonWithType:UIButtonTypeSystem];
    self.hairline         = ({
        UIView *v = [[UIView alloc] initWithFrame:frame];
        v.backgroundColor = UIColor.welcomeHairlineColor;
        v;
    });
    
    // Logo in circle
    _circle.backgroundColor = self.tintColor;
    [_circle addSubview:_logo];
    
    // Auth token section
    [_authTokenButton setTitle:authTokeDesc forState:UIControlStateNormal];
    [_authTokenButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    
    // Buttons
    _useNewUserButton.dimensions = CGSizeMake(SCREEN_WIDTH*.9, SCREEN_HEIGHT*.10);
    _userTokenButton.dimensions = _useNewUserButton.dimensions;
    for (TTWelcomeButton *button in @[_useNewUserButton, _userTokenButton]) {
        button.tintColor = self.tintColor;
        // Button is filled so we want white color
        button.labelColor = UIColor.whiteColor;
    }
    
    // Welcome label font
    id thinFont    = [UIFont systemFontOfSize:39 weight:UIFontWeightLight];
    id regularFont = [UIFont systemFontOfSize:39 weight:UIFontWeightSemibold];
    [welcomeToTicTac addAttribute:NSFontAttributeName value:thinFont range:NSMakeRange(0, welcomeToTicTac.length)];
    [welcomeToTicTac addAttribute:NSFontAttributeName value:regularFont range:NSMakeRange(welcomeToTicTac.length-7, 7)];
    _welcomeLabel.attributedText = welcomeToTicTac;
    
    // Line spacing for second label
    NSMutableAttributedString *body = [[NSMutableAttributedString alloc] initWithString:description];
    NSMutableParagraphStyle *style  = [NSMutableParagraphStyle new];
    style.lineSpacing = 8;
    [body addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, body.length)];
    _descriptionLabel.attributedText = body;
    _descriptionLabel.textAlignment  = NSTextAlignmentCenter;
    _descriptionLabel.numberOfLines  = 0;
    
    // Button actions
    for (UIButton *button in @[_useNewUserButton, _userTokenButton, _authTokenButton])
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add subviews
    for (UIView *view in @[_circle, _welcomeLabel, _descriptionLabel, _useNewUserButton, _userTokenButton, _hairline, _authTokenButton]) {
        [self addSubview:view];
        [view sizeToFit];
    }
}

- (void)layoutSubviews {
    self.tintColor = UIColor.themeColor;
    
    // Logo in circle
    CGFloat boowh = kIs3x ? 154 : 115;
    CGFloat circleYOffset = kIs3x ? kNavBarHeight + SCREEN_HEIGHT*.04 : SCREEN_HEIGHT*.10;
    [_circle setFrameSize:CGSizeMake(boowh, boowh)];
    [_circle centerXInView:self alignToTopWithPadding:circleYOffset];
    _circle.layer.cornerRadius = boowh/2.f;
    _circle.backgroundColor = self.tintColor;
    [_logo centerWithinView:_logo.superview];
    [_logo setFrameY:boowh*.22];
    
    // Width of buttons and hairline
    CGFloat paddedWidth = SCREEN_WIDTH*.9;
    
    // Auth token section
    [_hairline setFrameSize:CGSizeMake(paddedWidth, 1.f/UIScreen.mainScreen.scale)];
    [_hairline centerXInView:self alignToBottomWithPadding:70];
    [_authTokenButton centerXInView:self centerYBetweenView:_hairline and:SCREEN_HEIGHT - 30];
    
    // Buttons
    _authTokenButton.tintColor = self.tintColor;
    _useNewUserButton.dimensions = CGSizeMake(paddedWidth, 30);
    _userTokenButton.dimensions = _useNewUserButton.dimensions;
    [_userTokenButton centerXInView:self alignToBottomWithPadding:SCREEN_HEIGHT*.12];
    [_useNewUserButton centerXInView:self alignToBottomWithPadding:SCREEN_HEIGHT*.12 + SCREEN_HEIGHT*.02 + CGRectGetHeight(_userTokenButton.frame)];    
    _userTokenButton.selectionFadeDuration = 0.1;
    _useNewUserButton.selectionFadeDuration = 0.1;
    
    // Big labels
    [_welcomeLabel sizeToFit];
    _descriptionLabel.preferredMaxLayoutWidth = paddedWidth;
    [_descriptionLabel setFrameSize:[_descriptionLabel sizeThatFits:CGSizeMake(paddedWidth, CGFLOAT_MAX)]];
    
    // Position labels
    CGFloat bothHeights = CGRectGetHeight(_welcomeLabel.frame) + CGRectGetHeight(_descriptionLabel.frame) + 33;
    CGFloat top = CGRectGetMaxY(_circle.frame);
    CGFloat bottom = CGRectGetMinY(_useNewUserButton.frame);
    CGFloat gap = bottom - top;
    CGFloat spacing = round((gap - bothHeights) / 2.f);
    [_welcomeLabel centerXInView:self alignToTopWithPadding:CGRectGetMaxY(_circle.frame) + spacing];
    [_descriptionLabel centerXInView:self alignToTopWithPadding:CGRectGetMaxY(_welcomeLabel.frame) + 33];
}

- (void)buttonPressed:(UIButton *)sender {
    if (sender == self.useNewUserButton){
        self.useNewUserButtonAction();
    } else if (sender == self.userTokenButton) {
        self.signInButtonAction();
    } else if (sender == self.authTokenButton) {
        
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unknown button tapped in welcome view"];
    }
}

- (void)setLogoTapAction:(YYVoidBlock)logoTapAction {
    _logoTapAction = [logoTapAction copy];
    if (logoTapAction) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTapped)];
        [self.circle addGestureRecognizer:tap];
    } else if (self.circle.gestureRecognizers.count) {
        [self.circle removeGestureRecognizer:self.circle.gestureRecognizers.firstObject];
    }
}

- (void)logoTapped {
    self.logoTapAction();
}

@end
