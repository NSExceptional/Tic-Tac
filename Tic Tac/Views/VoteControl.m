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
@property (nonatomic) VoteStatus status;
@property (nonatomic) NSInteger initialScore;
@property (nonatomic) VoteStatus lastVoteButtonPress;
@end

@implementation _VoteControl

+ (instancetype)withInitialScoreIgnoringVote:(NSInteger)score {
    return [[self alloc] initWithInitialScoreIgnoringVote:score];
}

- (instancetype)initWithInitialScoreIgnoringVote:(NSInteger)score {
    self = [self init];
    if (self) {
        _initialScore = score;
        
        self.wraps = YES;
        self.continuous = NO;
        self.minimumValue = score - 1;
        self.maximumValue = score + 1;
        self.stepValue = 1;
        self.value = score;
        
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

- (VoteStatus)status {
    VoteStatus stat = (NSInteger)self.value - self.initialScore;
    return MAX(VoteStatusDownvoted, MIN(VoteStatusUpvoted, stat));
}

- (void)setStatus:(VoteStatus)status {
    VoteStatus currentStatus = self.status;
    
    if (currentStatus == status) {
        return;
    }
    
    NSInteger delta = -currentStatus + status;
    self.value += delta;
    [self refreshStatusIndicators];
}

- (void)setInitialScore:(NSInteger)initialScore {
    // Status is dependent on initialScore; compute status first
    VoteStatus status = self.status;
    // Update score
    _initialScore = initialScore;
    // Update value to reflect new score and original vote status
    self.value = initialScore + (NSInteger)status;
}

- (UIButton *)plusButton {
    return [self.visualElement valueForKey:@"_plusButton"];
}

- (UIButton *)minusButton {
    return [self.visualElement valueForKey:@"_minusButton"];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.plusButton.highlighted) {
        self.lastVoteButtonPress = VoteStatusUpvoted;
    } else if (self.minusButton.highlighted) {
        self.lastVoteButtonPress = VoteStatusDownvoted;
    } else {
        self.lastVoteButtonPress = VoteStatusNone;
    }
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)visualElementDidSetValue:(UIStepperHorizontalVisualElement *)sender {    
    if (self.lastVoteButtonPress == self.status) {
        sender.value = self.initialScore;
    }
    
    [super visualElementDidSetValue:sender];
}

- (void)refreshStatusIndicators {
    self.plusButton.tintColor = UIColor.whiteColor;
    self.minusButton.tintColor = UIColor.whiteColor;
    
    switch (self.status) {
        case VoteStatusNone:
            self.stepValue = 1;
            break;
        case VoteStatusUpvoted:
            self.stepValue = 2;
            self.plusButton.tintColor = UIColor.systemOrangeColor;
            break;
        case VoteStatusDownvoted:
            self.stepValue = 2;
            self.minusButton.tintColor = UIColor.systemIndigoColor;
            break;
    }
}

@end

@interface VoteControl ()
@property (nonatomic, readonly) UILabel *counter;
@property (nonatomic, readonly) _VoteControl *control;
@end

@implementation VoteControl

+ (instancetype)withInitialScore:(NSInteger)score initialStatus:(VoteStatus)status {
    return [[self alloc] initWithInitialScore:score initialStatus:status];
}

- (instancetype)initWithInitialScore:(NSInteger)score initialStatus:(VoteStatus)status {
    self = [self init];
    if (self) {
        // Get true initail score by adjusting for our vote status
        switch (status) {
            case VoteStatusNone:
                break;
            case VoteStatusUpvoted: {
                score -= 1;
                break;
            }
            case VoteStatusDownvoted: {
                score += 1;
                break;
            }
        }
        
        _counter = [UILabel new];
        _control = [_VoteControl withInitialScoreIgnoringVote:score];
        _control.status = status;
        
        [self refreshCounter];
        self.status = status;
        
        [self addSubview:_counter];
        [self addSubview:_control];
        
        _counter.font = [UIFont monospacedDigitSystemFontOfSize:21 weight:UIFontWeightRegular];
        _counter.translatesAutoresizingMaskIntoConstraints = NO;
        
        const CGFloat kTransformOffset = 30;
        [NSLayoutConstraint activateConstraints:@[
            [_counter.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
//            [_counter.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_counter.trailingAnchor constraintEqualToAnchor:_control.leadingAnchor constant:kTransformOffset - 15],
            
            [_control.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_control.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:kTransformOffset],
            [self.heightAnchor constraintEqualToAnchor:_control.widthAnchor],
            [self.widthAnchor constraintEqualToConstant:72],
        ]];
        
        [self.control addTarget:self action:@selector(refreshCounter) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (NSInteger)score {
    return self.control.value;
}

- (VoteStatus)status {
    return self.control.status;
}

- (void)setStatus:(VoteStatus)status {
    self.control.status = status;
    [self refreshCounter:NO];
}

- (void)refreshCounter {
    [self refreshCounter:YES];
}

- (void)refreshCounter:(BOOL)sendEvents {
    self.counter.text = @(self.score).stringValue;

    if (sendEvents && self.onVoteStatusChange) {
        self.onVoteStatusChange(self.status);
    }
}

@end
