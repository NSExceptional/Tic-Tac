//
//  ATLBaseCollectionViewCell.h
//  Pods
//
//  Created by Kevin Coleman on 12/22/15.
//
//

#import <UIKit/UIKit.h>
#import "ATLMessageBubbleView.h"
#import "ATLAvatarImageView.h"
#import "ATLMessagePresenting.h"

@import LayerKit;

typedef NS_ENUM(NSInteger, ATLCellType) {
    ATLOutgoingCellType,
    ATLIncomingCellType,
};

extern CGFloat const ATLMessageCellHorizontalMargin;

/**
 @abstract The `ATLBaseCollectionViewCell` provides for building custom UI on top of a basic Atlas 'Bubble Cell'.
 @discussion Applications that wish to build custom UI inside of a bubble should create a subclass of `ATLBaseCollectionViewCell`
 and add subviews to the `bubbleView` property.
 */
@interface ATLBaseCollectionViewCell : UICollectionViewCell <ATLMessagePresenting>

/**
 @abstract The background color for the bubble view displayed in the cell. Default is light gray.
 */
@property (nonatomic) UIColor *bubbleViewColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The corner radius of the bubble view displayed in the cell. Default is 16.
 */
@property (nonatomic) CGFloat bubbleViewCornerRadius UI_APPEARANCE_SELECTOR;

/**
 @abstract The view that handles displaying the cell content.
 */
@property (nonatomic) ATLMessageBubbleView *bubbleView;

/**
 @abstract The optional avatar image view representing a user.
 */
@property (nonatomic) ATLAvatarImageView *avatarImageView;

/**
 @abstract The `LYRMessage` object passed in `ATLMessagePresenting` protocol `presentMessage:`.
 */
@property (nonatomic) LYRMessage *message;

/**
 @abstract Configures the message bubble's width.
 */
- (void)updateBubbleWidth:(CGFloat)bubbleWidth;

/**
 @abstract Updates the message cell's `ATLCellType`.
 @discussion The cell type determines the alignment of the cell in the conversation view. Cells with `ATLOutgoingCellType` will 
 right aligned and cells with `ATLIncomingCellType` will be left aligned.
 */
- (void)configureCellForType:(ATLCellType)cellType;

@end
