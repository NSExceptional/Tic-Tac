//
//  ATLBaseCollectionViewCell.m
//  Atlas
//
//  Created by Kevin Coleman on 12/22/15.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "ATLBaseCollectionViewCell.h"
#import "ATLConstants.h"
#import "ATLMessagingUtilities.h"
#import "ATLParticipant.h"

CGFloat const ATLMessageCellHorizontalMargin = 16.0f;
CGFloat const ATLAvatarImageLeadPadding = 12.0f;
CGFloat const ATLAvatarImageTailPadding = 4.0f;

@interface ATLBaseCollectionViewCell ()

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarLeadConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarLeadConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleViewWidthConstraint;

@property (nonatomic) BOOL messageSentState;
@property (nonatomic) BOOL shouldDisplayAvatar;

@end

@implementation ATLBaseCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_baseInit];
    }
    return self;
}

- (void)lyr_baseInit
{
    // Default UIAppearance
    _bubbleViewColor = ATLBlueColor();
    _bubbleViewCornerRadius = 17.0f;
    
    _bubbleView = [[ATLMessageBubbleView alloc] init];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    _bubbleView.layer.cornerRadius = _bubbleViewCornerRadius;
    _bubbleView.backgroundColor = _bubbleViewColor;
    [self.contentView addSubview:_bubbleView];
    
    _avatarImageView = [[ATLAvatarImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_avatarImageView];
    
    [self configureLayoutConstraints];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.avatarImageView resetView];
    [self.bubbleView prepareForReuse];
}

- (void)setBubbleViewColor:(UIColor *)bubbleViewColor
{
    _bubbleViewColor = bubbleViewColor;
    self.bubbleView.backgroundColor = bubbleViewColor;
}

- (void)setBubbleViewCornerRadius:(CGFloat)bubbleViewCornerRadius
{
    _bubbleViewCornerRadius = bubbleViewCornerRadius;
    self.bubbleView.layer.cornerRadius = bubbleViewCornerRadius;
}

- (void)updateBubbleWidth:(CGFloat)bubbleWidth
{
    if ([self.contentView.constraints containsObject:self.bubbleViewWidthConstraint]) {
        [self.contentView removeConstraints:@[self.bubbleViewWidthConstraint]];
    }

    self.bubbleViewWidthConstraint.constant = bubbleWidth;
    [self.contentView addConstraint:self.bubbleViewWidthConstraint];
}

- (void)presentMessage:(LYRMessage *)message
{
    self.message = message;
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem
{
    NSArray *constraints = [self.contentView constraints];
    if (shouldDisplayAvatarItem) {
        if ([constraints containsObject:self.bubbleWithAvatarLeadConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithoutAvatarLeadConstraint];
        [self.contentView addConstraint:self.bubbleWithAvatarLeadConstraint];
    } else {
        if ([constraints containsObject:self.bubbleWithoutAvatarLeadConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithAvatarLeadConstraint];
        [self.contentView addConstraint:self.bubbleWithoutAvatarLeadConstraint];
    }
    [self setNeedsUpdateConstraints];
    self.shouldDisplayAvatar = shouldDisplayAvatarItem;
}

- (void)updateWithSender:(id<ATLParticipant>)sender
{
    if (sender) {
        self.avatarImageView.hidden = NO;
        self.avatarImageView.avatarItem = sender;
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)configureLayoutConstraints
{
    _bubbleWithAvatarLeadConstraint = [NSLayoutConstraint new];
    _bubbleWithoutAvatarLeadConstraint = [NSLayoutConstraint new];
    
    CGFloat maxBubbleWidth = ATLMaxCellWidth() + ATLMessageBubbleLabelHorizontalPadding * 2;
    self.bubbleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxBubbleWidth];
    [self.contentView addConstraint:self.bubbleViewWidthConstraint];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)configureCellForType:(ATLCellType)cellType
{
    if ([self.contentView.constraints containsObject:self.bubbleWithAvatarLeadConstraint]) {
        [self.contentView removeConstraint:self.bubbleWithAvatarLeadConstraint];
    }
    
    if ([self.contentView.constraints containsObject:self.bubbleWithoutAvatarLeadConstraint]) {
        [self.contentView removeConstraint:self.bubbleWithoutAvatarLeadConstraint];
    }
    
    switch (cellType) {
        case ATLIncomingCellType:
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLAvatarImageLeadPadding]];
            self.bubbleWithAvatarLeadConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:ATLAvatarImageTailPadding];
            [self.contentView addConstraint:self.bubbleWithAvatarLeadConstraint];
            self.bubbleWithoutAvatarLeadConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLMessageCellHorizontalMargin];
            break;
        case ATLOutgoingCellType:
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-ATLAvatarImageLeadPadding]];
            self.bubbleWithAvatarLeadConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute: NSLayoutAttributeRight multiplier:1.0 constant:ATLAvatarImageTailPadding];
            [self.contentView addConstraint:self.bubbleWithAvatarLeadConstraint];
            self.bubbleWithoutAvatarLeadConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-ATLMessageCellHorizontalMargin];
            break;
        default:
            break;
    }
    [self shouldDisplayAvatarItem:self.shouldDisplayAvatar];
}


@end
