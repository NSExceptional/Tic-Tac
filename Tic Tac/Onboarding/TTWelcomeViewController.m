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


@interface TTWelcomeViewController ()
@property (nonatomic, readonly) TTWelcomeView *welcomeView;
@end

@implementation TTWelcomeViewController

- (void)loadView { self.view = [[TTWelcomeView alloc] initWithFrame:[UIScreen mainScreen].bounds]; }
- (TTWelcomeView *)welcomeView { return (id)self.view; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTAppDelegate *appdelegate = (id)[UIApplication sharedApplication].delegate;
    
    // Generate a new user profile
    self.welcomeView.useNewUserButtonAction = ^{
        appdelegate.window.rootViewController = appdelegate.tabBarController;
        [appdelegate setupNewUser:^{
            [appdelegate.tabBarController notifyUserIsReady];
        }];
    };
    
    // Use an existing profile
    self.welcomeView.useTokenButtonAction = ^{
        // Temporary until I feel like designing an entire screen for this
        [self promptForUserIdentifier:appdelegate.tabBarController];
    };
}

- (void)promptForUserIdentifier:(TTTabBarController *)tabBarController {
    NSString *message = @"Your handle, yakarma, and notifications will be restored.";
    TBAlertController *getUserIdentifierPrompt = [TBAlertController alertViewWithTitle:@"Log-in with user token" message:message];
    [getUserIdentifierPrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {}];
    [getUserIdentifierPrompt setCancelButtonWithTitle:@"Cancel"];
    [getUserIdentifierPrompt addOtherButtonWithTitle:@"Go" buttonAction:^(NSArray *textFieldStrings) {
        
        // Display the tab bar, or tell them it wasn't a valid user token.
        if (YYIsValidUserIdentifier(textFieldStrings[0])) {
            [YYClient sharedClient].userIdentifier = textFieldStrings[0];
            [self presentViewController:tabBarController animated:YES completion:^{
                [tabBarController notifyUserIsReady];
            }];
        }
        else {
            [self notifyOfIncorrectUserIdentifierFormat:tabBarController];
        }
    }];
    
    [getUserIdentifierPrompt showFromViewController:self];
}

- (void)notifyOfIncorrectUserIdentifierFormat:(TTTabBarController *)tabBarController {
    TBAlertController *tryAgain = [TBAlertController alertViewWithTitle:@"Oops!" message:@"Looks like that wasn't a valid user token. Try again."];
    [tryAgain addOtherButtonWithTitle:@"OK" buttonAction:^(NSArray *textFieldStrings) {
        [self promptForUserIdentifier:tabBarController];
    }];
    
    [tryAgain showFromViewController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

@end
