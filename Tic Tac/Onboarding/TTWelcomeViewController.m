//
//  TTWelcomeViewController.m
//  Boo
//
//  Created by Tanner on 04/19/16.
//
//

#import "TTWelcomeViewController.h"
#import "TTWelcomeView.h"
#import "TTTabBarController.h"
#import "TTAppDelegate.h"

#import "TBAlertController.h"
@class BOAuthTokenViewController;


@interface TTWelcomeViewController () <UITextFieldDelegate>
@property (nonatomic, readonly) TTWelcomeView *welcomeView;
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) TTTabBarController *tabBarController;
@end

@implementation TTWelcomeViewController

- (void)loadView { self.view = [[TTWelcomeView alloc] initWithFrame:[UIScreen mainScreen].bounds]; }
- (TTWelcomeView *)welcomeView { return (id)self.view; }

- (UIWindow *)window {
    return [(id)[UIApplication sharedApplication] keyWindow];
}

- (TTTabBarController *)tabBarController {
    return (id)[(id)[UIApplication sharedApplication].delegate tabBarController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTAppDelegate *appdelegate = (id)[UIApplication sharedApplication].delegate;
    
    // Generate a new user profile
    self.welcomeView.useNewUserButtonAction = ^{
        self.window.rootViewController = self.tabBarController;
        // MUST SET CURRENT USER ID BEFORE CALLING BLOCK
        // TODO
        [appdelegate setupNewUser:^{
            // Present, set window root, notify
            [self presentViewController:self.tabBarController animated:YES completion:^{
                [UIApplication sharedApplication].keyWindow.rootViewController = appdelegate.tabBarController;
                [appdelegate.tabBarController notifyUserIsReady];
            }];
        }];
    };
    
    // Use an existing profile
    self.welcomeView.signInButtonAction = ^{
        // Temporary until I feel like designing an entire screen for this
        if (YYClient.sharedClient.location) {
            [self promptForPhoneNumber];
        } else {
            [self promptForLocation];
        }
    };
}

- (void)promptForLocation {
    TBAlertController *getLocationPrompt = [TBAlertController alertViewWithTitle:@"Location" message:nil];
    [getLocationPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Latitude";
        textField.delegate = self;
        textField.text = @"31.534173";
    }];
    [getLocationPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude";
        textField.delegate = self;
        textField.text = @"-97.123863";
    }];
    
    [getLocationPrompt setCancelButtonWithTitle:@"Cancel"];
    [getLocationPrompt addOtherButtonWithTitle:@"Next" buttonAction:^(NSArray<NSString*> *textFieldStrings) {
        CLLocationDegrees lat = textFieldStrings[0].floatValue;
        CLLocationDegrees lng = textFieldStrings[1].floatValue;
        YYClient.sharedClient.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        [self promptForPhoneNumber];
    }];
    
    [getLocationPrompt showFromViewController:self];
}

- (void)promptForPhoneNumber {
    [TBAlert makeAlert:^(TBAlert *make) {
        make.title(@"Sign In with Your Phone Number");
        make.message(@"Your handle, yakarma, and notifications will be restored.");
        make.configuredTextField(^(UITextField *textField) {
            textField.placeholder = @"Phone Number";
            textField.keyboardType = UIKeyboardTypePhonePad;
            
            textField.textContentType = UITextContentTypeTelephoneNumber;
            textField.returnKeyType = UIReturnKeyGo;            
        });
        make.button(@"Cancel").cancelStyle();
        make.button(@"Go").handler(^(NSArray<NSString *> *textFieldStrings) {
            // Display the tab bar, or tell them it wasn't a valid user token.
            if (YYIsValidPhoneNumber(textFieldStrings[0])) {
                NSString *phone = YYExtractFormattedPhoneNumber(textFieldStrings[0]);
                
                // Display loading alert
                TBAlertController *loading = [TBAlertController alertViewWithTitle:@"One Moment…" message:nil];
                [loading showFromViewController:self];
                
                [YYClient.sharedClient startSignInWithPhone:phone verify:^(NSString *vid, NSError *error) {
                    [loading dismissAnimated:YES completion:^{
                        if (error) {
                            [self signInFailed:error];
                        } else {
                            [self promptForVerificationCode:vid];
                        }
                    }];
                    
                }];
            }
            else {
                [self notifyOfIncorrectPhoneFormat];
            }
        });
    } showFrom:self];
}

- (void)promptForVerificationCode:(NSString *)verificationID {
    [TBAlert makeAlert:^(TBAlert * _Nonnull make) {
        make.title(@"SMS Verification").message(@"Enter the code we sent you.");
        make.configuredTextField(^(UITextField *textField) {
            textField.placeholder = @"6-digit code";
            textField.keyboardType = UIKeyboardTypePhonePad;
            textField.textContentType = UITextContentTypeTelephoneNumber;
            textField.returnKeyType = UIReturnKeyGo;    
        });
        make.button(@"Cancel").cancelStyle();
        make.button(@"Verify").handler(^(NSArray<NSString *> *strings) {
            // Display loading alert
            TBAlertController *loading = [TBAlertController alertViewWithTitle:@"One Moment…" message:nil];
            [loading showFromViewController:self];
            
            [YYClient.sharedClient verifyPhone:strings[0] identifier:verificationID completion:^(NSError *error) {
                [loading dismissAnimated:YES completion:^{
                    if (error) {
                        [self signInFailed:error];
                    } else {
                        [self didSignIn];
                    }
                }];
            }];
        });
    } showFrom:self];
}

- (void)didSignIn {
    TTTabBarController *tabBarController = self.tabBarController;
    
    if (self.presentingViewController) {
        [self.tabBarController notifyUserIsReady];
        [self.navigationController ?: self dismissAnimated];
    } else {
        [self presentViewController:tabBarController animated:YES completion:^{
            UIApplication.sharedApplication.keyWindow.rootViewController = tabBarController;
            [tabBarController notifyUserIsReady];
        }];
    }
}

- (void)notifyOfIncorrectPhoneFormat {
    [TBAlert makeAlert:^(TBAlert *make) {
        make.title(@"Oops!");
        make.message(@"Looks like that wasn't a valid US phone number. Try again. Include your area code.");
        make.button(@"Dismiss").cancelStyle().handler(^(NSArray<NSString *> *strings) {
            [self promptForPhoneNumber];
        });
    } showFrom:self];
}

- (void)signInFailed:(NSError *)error {
    [TBAlert makeAlert:^(TBAlert *make) {
        make.title(@"Sign In Failed").message(error.localizedDescription);
        make.button(@"Dismiss").cancelStyle();
    } showFrom:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    static NSCharacterSet *notAllowed = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notAllowed = [NSCharacterSet characterSetWithCharactersInString:@"-0123456789."].invertedSet;
    });
    
    NSString *newString        = [textField.text ?: @"" stringByReplacingCharactersInRange:range withString:string];
    NSUInteger countOfDecimals = [newString componentsSeparatedByString:@"."].count - 1;
    NSUInteger countOfSigns    = [newString componentsSeparatedByString:@"-"].count - 1;
    BOOL onlyHasAllowed        = [newString rangeOfCharacterFromSet:notAllowed].location == NSNotFound;
    
    // Negative sign must be at front
    if (countOfSigns == 1 && [newString characterAtIndex:0] != '-') {
        return NO;
    }
    
    return onlyHasAllowed && countOfDecimals < 2 && countOfSigns < 2;
}

@end
