//
//  TTReplyViewController.m
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTReplyViewController.h"


@interface TTReplyViewController ()
@property (nonatomic) NSString *initialText;
@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, copy) void (^onSubmit)(NSString *, BOOL);

@property (nonatomic) MASConstraint *textViewHeight;
@end

@implementation TTReplyViewController

+ (UINavigationController *)replyWithInitialText:(NSString *)text onSubmit:(void(^)(NSString *text, BOOL useHandle))submit {
    return [[UINavigationController alloc] initWithRootViewController:[[self alloc] initWithInitialText:text andSubmitAction:submit]];
}

- (id)initWithInitialText:(NSString *)text andSubmitAction:(void(^)(NSString *text, BOOL useHandle))submit {
    self = [super init];
    if (self) {
        _initialText = text;
        _onSubmit = submit;
    }
    
    return self;
}

- (void)loadView {
    self.view = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor whiteColor];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.font = [UIFont systemFontOfSize:21];
        _textView.textContainerInset = UIEdgeInsetsMake(8, 5, 8, 5);
        _textView.text = self.initialText;
        
        [view addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view.mas_top);
            make.left.equalTo(view.mas_left);
            make.right.equalTo(view.mas_right);
            self.textViewHeight = make.height.equalTo(view.mas_height);
        }];
        
        view;
    });
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSValue *keyboardFrameBegin = [notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = keyboardFrameBegin.CGRectValue;
    
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        [self.textViewHeight uninstall];
        self.textViewHeight = make.height.equalTo(@(CGRectGetHeight(self.view.frame) - CGRectGetHeight(keyboardFrame)));
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submit)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)submit {
    self.onSubmit(self.textView.text, NO);
    [self.navigationController dismissAnimated];
}

- (void)cancel {
    [self.navigationController dismissAnimated];
}

@end
