//
//  TTReplyViewController.m
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTReplyViewController.h"


@interface TTReplyViewController () <UITextViewDelegate>
@property (nonatomic) NSString *initialText;
@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, readonly) NSUInteger characterLimit;
@property (nonatomic, copy) void (^onSubmit)(NSString *, BOOL);

@property (nonatomic) MASConstraint *textViewHeight;

@property (nonatomic, readonly) BOOL useHandle;
@end

@implementation TTReplyViewController
@synthesize useHandle = _useHandle;

+ (UINavigationController *)initialText:(NSString *)text limit:(NSUInteger)limit  onSubmit:(void(^)(NSString *text, BOOL useHandle))submit {
    return [[UINavigationController alloc] initWithRootViewController:[[self alloc] initWithInitialText:text limit:limit andSubmitAction:submit]];
}

- (id)initWithInitialText:(NSString *)text limit:(NSUInteger)limit andSubmitAction:(void(^)(NSString *text, BOOL useHandle))submit {
    self = [super init];
    if (self) {
        _initialText = text;
        _onSubmit = submit;
        _characterLimit = limit;
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
        _textView.delegate = self;
        
        [view addSubview:_textView];
        [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view.mas_top);
            make.left.equalTo(view.mas_left);
            make.right.equalTo(view.mas_right);
            self.textViewHeight = make.height.equalTo(view.mas_height);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleUseHandle)];
        tap.numberOfTapsRequired = 2;
        tap.numberOfTouchesRequired = 2;
        [view addGestureRecognizer:tap];
        
        view;
    });
}

- (void)toggleUseHandle {
    _useHandle = !_useHandle;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(submit)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)submit {
    self.onSubmit(self.textView.text, self.useHandle);
    [self.navigationController dismissAnimated];
}

- (void)cancel {
    [self.navigationController dismissAnimated];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.navigationItem.rightBarButtonItem.enabled = newString.length > 0;
    return newString.length < _characterLimit;
}

- (BOOL)useHandle {
    return _useHandle;
}

@end
