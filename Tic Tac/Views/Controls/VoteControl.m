//
//  VoteControl.m
//  Tic Tac
//
//  Created by Tanner Bennett on 6/17/22.
//

#import "VoteControl.h"

@interface UIStepperHorizontalVisualElement : UIView
@property (nonatomic) double value;
@end

@interface UIStepper (Private)
@property (nonatomic, readonly) UIStepperHorizontalVisualElement *visualElement;
- (void)visualElementDidSetValue:(UIStepperHorizontalVisualElement *)sender;
@end

@interface _VoteControl : UIStepper
@property (nonatomic, readonly) UIButton *plusButton;
@property (nonatomic, readonly) UIButton *minusButton;
@property (nonatomic) YYVoteStatus status;
/// Initial score, independent of vote status
@property (nonatomic, readonly) NSInteger initialScore;
@property (nonatomic) YYVoteStatus lastVoteButtonPress;
@end

NSInteger YYScoreWithoutVote(YYVoteStatus vote, NSInteger score) {
    switch (vote) {
        case YYVoteStatusNone:
            break;
        case YYVoteStatusUpvoted: {
            score -= 1;
            break;
        }
        case YYVoteStatusDownvoted: {
            score += 1;
            break;
        }
    }
    
    return score;
}

@implementation _VoteControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _initialScore = 0;
        _status = YYVoteStatusNone;
        
        self.wraps = YES;
        self.continuous = NO;
        self.minimumValue = -1;
        self.maximumValue =  1;
        self.stepValue = 1;
        self.value = 0;
        
        self.tintColor = UIColor.whiteColor;
        [self setDecrementImage:[UIImage systemImageNamed:@"arrow.left"] forState:UIControlStateNormal];
        [self setIncrementImage:[UIImage systemImageNamed:@"arrow.right"] forState:UIControlStateNormal];
        [self refreshStatusIndicators];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.transform = CGAffineTransformRotate(self.transform, -M_PI_2);
        
        [self addAction:[UIAction actionWithHandler:^(UIAction *action) {
            _VoteControl *control = action.sender;
            [control refreshStatusIndicators];
        }] forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)setVote:(YYVoteStatus)status score:(NSInteger)score {
    _status = status;

    // Update score
    _initialScore = YYScoreWithoutVote(status, score);
    
    // Update value
    self.minimumValue = _initialScore - 1;
    self.maximumValue = _initialScore + 1;
    self.value = score;
    
    // Update status indicators
    [self refreshStatusIndicators];
}

- (UIButton *)plusButton {
    return [self.visualElement valueForKey:@"_plusButton"];
}

- (UIButton *)minusButton {
    return [self.visualElement valueForKey:@"_minusButton"];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    YYVoteStatus previous = self.status;
    
    if (self.plusButton.highlighted) {
        self.lastVoteButtonPress = YYVoteStatusUpvoted;
    } else if (self.minusButton.highlighted) {
        self.lastVoteButtonPress = YYVoteStatusDownvoted;
    } else {
        self.lastVoteButtonPress = YYVoteStatusNone;
    }
    
    if (self.status == self.lastVoteButtonPress) {
        self.status = YYVoteStatusNone;
    } else {
        self.status = self.lastVoteButtonPress;
    }
    
    // Initial score not affected
    NSInteger delta = -previous + self.status;
    self.value += delta;
    [self refreshStatusIndicators];
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)visualElementDidSetValue:(UIStepperHorizontalVisualElement *)sender {    
    sender.value = self.value;
    [super visualElementDidSetValue:sender];
}

- (void)refreshStatusIndicators {
    self.plusButton.tintColor = UIColor.whiteColor;
    self.minusButton.tintColor = UIColor.whiteColor;
    
    switch (self.status) {
        case YYVoteStatusNone:
            self.stepValue = 1;
            break;
        case YYVoteStatusUpvoted:
            self.stepValue = 2;
            self.plusButton.tintColor = UIColor.systemOrangeColor;
            break;
        case YYVoteStatusDownvoted:
            self.stepValue = 2;
            self.minusButton.tintColor = UIColor.systemIndigoColor;
            break;
    }
}

@end

@interface VoteControl ()
@property (nonatomic, readonly) UILabel *counter;
@property (nonatomic, readonly) _VoteControl *control;
@property (nonatomic, readonly) NSLayoutConstraint *heightConstraint;
@end

@implementation VoteControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _counter = [UILabel new];
        _control = [_VoteControl new];
        
        [self refreshCounter];
        
        [self addSubview:_counter];
        [self addSubview:_control];
        
        _counter.font = [UIFont monospacedDigitSystemFontOfSize:21 weight:UIFontWeightRegular];
        _counter.translatesAutoresizingMaskIntoConstraints = NO;
        
        const CGFloat kTransformOffset = 30;
        _heightConstraint = [self.heightAnchor constraintEqualToConstant:_control.frame.size.height];
        _heightConstraint.priority = UILayoutPriorityDefaultHigh; // stfu UIView-Encapsulated-Layout-Height
        
        [NSLayoutConstraint activateConstraints:@[
            [_counter.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_counter.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_counter.trailingAnchor constraintEqualToAnchor:_control.leadingAnchor constant:kTransformOffset - 15],
            
            [_control.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_control.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:kTransformOffset],
            self.heightConstraint,
//            [self.heightAnchor constraintEqualToAnchor:_control.widthAnchor],
//            [self.widthAnchor constraintEqualToConstant:72],
        ]];
        
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.counter setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.control addTarget:self action:@selector(refreshCounter) forControlEvents:UIControlEventValueChanged];
        
        [self sizeToFit];
    }
    
    return self;
}

- (void)setVote:(YYVoteStatus)status score:(NSInteger)score {
    [self.control setVote:status score:score];
    [self refreshCounter:NO];
}

- (NSInteger)score {
    return self.control.value;
}

- (YYVoteStatus)status {
    return self.control.status;
}

- (void)refreshCounter {
    [self refreshCounter:YES];
}

- (void)refreshCounter:(BOOL)sendEvents {
    self.counter.text = @(self.score).stringValue;

    if (sendEvents && self.onVoteStatusChange) {
        self.onVoteStatusChange(self.status, self.score);
    }
}

- (CGVector)stepperScale {
    return CGVectorMake(self.control.transform.d, self.control.transform.a);
}

- (void)setStepperScale:(CGVector)v {
    self.control.transform = CGAffineTransformScale(self.control.transform, v.dy, v.dx);
    self.heightConstraint.constant = self.control.frame.size.height;
    [self setNeedsUpdateConstraints];
}

- (BOOL)isEnabled {
    return self.control.isEnabled;
}

- (void)setEnabled:(BOOL)enabled {
    self.control.enabled = enabled;
}

@end

@implementation VoteControl (Private)

- (UIButton *)upvoteButton {
    return self.control.plusButton;
}

- (UIButton *)downvoteButton {
    return self.control.minusButton;
}

- (void)simulateVote:(YYVoteStatus)vote {
    switch (vote) {
        case YYVoteStatusUpvoted:
            self.upvoteButton.highlighted = YES;
            break;
        case YYVoteStatusDownvoted:
            self.downvoteButton.highlighted = YES;
            break;
        default: return;
    }
    
    [self.control endTrackingWithTouch:nil withEvent:nil];
}

@end
