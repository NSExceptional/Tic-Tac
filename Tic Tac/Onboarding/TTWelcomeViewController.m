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
    return [(id)[UIApplication sharedApplication] window];
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
    self.welcomeView.useTokenButtonAction = ^{
        // Temporary until I feel like designing an entire screen for this
        if ([YYClient sharedClient].location) {
            [self promptForUserIdentifier];
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
    }];
    [getLocationPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude";
        textField.delegate = self;
    }];
    
    [getLocationPrompt setCancelButtonWithTitle:@"Cancel"];
    [getLocationPrompt addOtherButtonWithTitle:@"Next" buttonAction:^(NSArray<NSString*> *textFieldStrings) {
        CLLocationDegrees lat = textFieldStrings[0].floatValue;
        CLLocationDegrees lng = textFieldStrings[1].floatValue;
        [YYClient sharedClient].location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        [self promptForUserIdentifier];
    }];
    
    [getLocationPrompt showFromViewController:self];
}

- (void)promptForUserIdentifier {
    NSString *message = @"Your handle, yakarma, and notifications will be restored.";
    TBAlertController *getUserIdentifierPrompt = [TBAlertController alertViewWithTitle:@"Log-in with user token" message:message];
    [getUserIdentifierPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {}];
    [getUserIdentifierPrompt setCancelButtonWithTitle:@"Cancel"];
    [getUserIdentifierPrompt addOtherButtonWithTitle:@"Go" buttonAction:^(NSArray *textFieldStrings) {
        
        // Display the tab bar, or tell them it wasn't a valid user token.
        if (YYIsValidUserIdentifier(textFieldStrings[0])) {
            // Must be grabbed before setting current user ID
            TTTabBarController *tabBarController = self.tabBarController;
            [NSUserDefaults setCurrentUserIdentifier:textFieldStrings[0]];
            [YYClient sharedClient].userIdentifier = textFieldStrings[0];
            
            if (self.presentingViewController) {
                [self.tabBarController notifyUserIsReady];
                [self.navigationController ?: self dismissAnimated];
            } else {
                [self presentViewController:tabBarController animated:YES completion:^{
                    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarController;
                    [tabBarController notifyUserIsReady];
                }];
            }
        }
        else {
            [self notifyOfIncorrectUserIdentifierFormat];
        }
    }];
    
    [getUserIdentifierPrompt showFromViewController:self];
}

- (void)notifyOfIncorrectUserIdentifierFormat {
    NSString *message = @"Looks like that wasn't a valid user token. Try again.";
    TBAlertController *tryAgain = [TBAlertController alertViewWithTitle:@"Oops!" message:message];
    [tryAgain addOtherButtonWithTitle:@"OK" buttonAction:^(NSArray *textFieldStrings) {
        [self promptForUserIdentifier];
    }];
    
    [tryAgain showFromViewController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
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
