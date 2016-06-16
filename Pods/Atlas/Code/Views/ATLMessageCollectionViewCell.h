//
//  ATLUIMessageCollectionViewCell.h
//  Atlas
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
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

#import <UIKit/UIKit.h>
#import "ATLBaseCollectionViewCell.h"
#import "ATLMessagePresenting.h"
#import "ATLMessageBubbleView.h"
#import "ATLConstants.h"
#import "ATLAvatarImageView.h"

NS_ASSUME_NONNULL_BEGIN
extern CGFloat const ATLMessageCellHorizontalMargin;
extern NSString *const ATLGIFAccessibilityLabel;
extern NSString *const ATLImageAccessibilityLabel;
extern NSString *const ATLVideoAccessibilityLabel;

/**
 @abstract The `ATLMessageCollectionViewCell` class provides a lightweight, customizable collection
 view cell for presenting Layer message objects. The class is subclassed by `ATLIncomingMessageCollectionViewCell`
 and `ATLOutgoingMessageCollectionViewCell`.
 */
@interface ATLMessageCollectionViewCell : ATLBaseCollectionViewCell 

/**
 @abstract The font for text displayed in the cell. Default is 14pt system font.
 */
@property (nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for text displayed in the cell. Default is black.
 */
@property (nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for links displayed in the cell. Default is blue.
 */
@property (nonatomic) UIColor *messageLinkTextColor UI_APPEARANCE_SELECTOR;


/**
  @abstract The NSTextCheckingTypes that will be passed to the bubbleView
  @discussion Currently supports NSTextCheckingTypeLink and NSTextCheckingTypePhoneNumber
  @default NSTextCheckingTypeLink
*/
@property (nonatomic) NSTextCheckingType messageTextCheckingTypes;

/**
 @abstract Performs calculations to determine a cell's height.
 @param message The `LYRMessage` object that will be displayed in the cell.
 @param view The view where the cell will be displayed.
 @return The height for the cell.
 */
+ (CGFloat)cellHeightForMessage:(LYRMessage *)message inView:(UIView *)view;

@end
NS_ASSUME_NONNULL_END
