//
//  TTProfileViewController.m
//  Tic Tac
//
//  Created by Tanner on 4/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTProfileViewController.h"
#import "TTWelcomeViewController.h"
#import "TTTabBarController.h"


static NSString * const kProfileReuse = @"kProfileReuse";

@interface TTProfileViewController ()
@property (nonatomic) NSInteger selectedProfileIdx;
@end

@implementation TTProfileViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:kYYDidUpdateUserNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add new user
    id item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUserButtonPressed)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kProfileReuse];
}

- (void)updateTitle {
    YYUser *user = [YYClient sharedClient].currentUser;
    self.title = user.handle ? [NSString stringWithFormat:@"%@ | %@", user.handle, @(user.karma).stringValue] : @(user.karma).stringValue;
    self.navigationController.title = user.handle ?: @"Profile";
}

- (void)addUserButtonPressed {
    UINavigationController *nav = [TTWelcomeViewController inNavigationController];
    TTWelcomeViewController *welcome = nav.viewControllers.firstObject;
    
    id cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nav action:@selector(dismissAnimated)];
    welcome.navigationItem.leftBarButtonItem = cancel;
    
    [self presentViewController:nav animated:YES completion:nil];
    // TODO chat does not update when adding a new user
}

- (void)showMyYaks {
    
}

- (void)showMyComments {
    
}

- (void)showOptionsForIdentifierAtIndex:(NSInteger)idx {
    NSString *identifier = [NSUserDefaults allUserIdentifiers][idx];
    
    TBAlertController *options = [TBAlertController alertViewWithTitle:@"Options" message:nil];
    [options addOtherButtonWithTitle:@"Copy user identifier" buttonAction:^(NSArray *textFieldStrings) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:1] animated:YES];
        [UIPasteboard generalPasteboard].string = identifier;
    }];
    if (idx != self.selectedProfileIdx) {
        [options addOtherButtonWithTitle:@"Switch profiles" buttonAction:^(NSArray * _Nonnull textFieldStrings) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:1] animated:YES];
            self.selectedProfileIdx = idx;
            [self switchToUser:identifier];
        }];
    }
    [options showFromViewController:self];
}

- (void)switchToUser:(NSString *)identifier {
    [TBNetworkActivity push];
    
    __block NSInteger count = 0;
    TBAlertController *wait = [TBAlertController alertViewWithTitle:@"Just a moment…" message:nil];
    [wait showFromViewController:self];
    
    VoidBlock maybeDismiss = ^{
        if (++count == 3) {
            [TBNetworkActivity pop];
            [wait dismiss];
            TTTabBarController *tabs = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
            [tabs notifyUserIsReady];
        }
    };
    
    [NSUserDefaults setCurrentUserIdentifier:identifier];
    [YYClient sharedClient].userIdentifier = identifier;
    [[YYClient sharedClient] updateUser:^(NSError *error) {
        [self displayOptionalError:error];
        wait.message = @"Updated user…";
        maybeDismiss();
    }];
    [[YYClient sharedClient] updateConfiguration:^(NSError *error) {
        [self displayOptionalError:error];
        wait.message = @"Updated configuration…";
        maybeDismiss();
    }];
}

- (void)setSelectedProfileIdx:(NSInteger)idx {
    if (idx == _selectedProfileIdx) return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedProfileIdx inSection:1]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:1]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedProfileIdx = idx;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    [self showMyYaks];
                    break;
                }
                case 1: {
                    [self showMyComments];
                    break;
                }
            }
            break;
        }
        case 1: {
            [self showOptionsForIdentifierAtIndex:indexPath.row];
            break;
        }
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileReuse];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"My Yaks";
                    break;
                }
                case 1: {
                    cell.textLabel.text = @"My Comments";
                    break;
                }
            }
            break;
        }
        case 1: {
            NSString *identifier = [NSUserDefaults allUserIdentifiers][indexPath.row];
            cell.textLabel.text  = [NSUserDefaults handleForUserIdentifier:identifier] ?: identifier;
            if ([identifier isEqualToString:[NSUserDefaults currentUserIdentifier]]) {
                cell.accessoryType  = UITableViewCellAccessoryCheckmark;
                _selectedProfileIdx = indexPath.row;
            }
            break;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return [NSUserDefaults allUserIdentifiers].count;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"My Stuff";
        case 1:
            return @"Accounts";
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 && ![[NSUserDefaults allUserIdentifiers][indexPath.row] isEqualToString:[NSUserDefaults currentUserIdentifier]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(style == UITableViewCellEditingStyleDelete);
    
    NSString *identifier = [NSUserDefaults allUserIdentifiers][indexPath.row];
    NSString *handle     = [NSUserDefaults handleForUserIdentifier:identifier];
    NSString *message    = [NSString stringWithFormat:@"%@ will be deleted from this device and you'll have to sign in again.", handle];
    
    TBAlertController *alert = [TBAlertController alertViewWithTitle:@"Are you sure?" message:message];
    [alert addOtherButtonWithTitle:@"I'm sure, delete it" buttonAction:^(NSArray *textFieldStrings) {
        [NSUserDefaults removeOtherUserIdentifier:identifier];
        [tableView deleteRow:indexPath.row inSection:indexPath.section];
    }];
    [alert setDestructiveButtonIndex:0];
    [alert setCancelButtonWithTitle:@"Nevermind"];
    [alert showFromViewController:self];
}

@end
