//
//  ATLUIMessagingUtilities.h
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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

#import <Foundation/Foundation.h>
@import LayerKit;
#import <MapKit/MapKit.h>
#import <ImageIO/ImageIO.h>
#import "ATLMediaAttachment.h"
#import "UIResponder+ATLFirstResponder.h"
#import "ATLMessageComposeTextView.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString *const ATLMIMETypeTextPlain;          // text/plain
extern NSString *const ATLMIMETypeImagePNG;           // image/png
extern NSString *const ATLMIMETypeImageJPEG;          // image/jpeg
extern NSString *const ATLMIMETypeImageJPEGPreview;   // image/jpeg+preview
extern NSString *const ATLMIMETypeImageGIF;           // image/gif
extern NSString *const ATLMIMETypeImageGIFPreview;    // image/gif+preview
extern NSString *const ATLMIMETypeImageSize;          // application/json+imageSize
extern NSString *const ATLMIMETypeVideoQuickTime;     // video/quicktime
extern NSString *const ATLMIMETypeLocation;           // location/coordinate
extern NSString *const ATLMIMETypeDate;               // text/date
extern NSString *const ATLMIMETypeVideoMP4;           // video/mp4
extern NSUInteger const ATLDefaultThumbnailSize;      // 512px
extern NSUInteger const ATLDefaultGIFThumbnailSize;   // 64px

extern NSString *const ATLPasteboardImageKey;
extern NSString *const ATLImagePreviewWidthKey;
extern NSString *const ATLImagePreviewHeightKey;
extern NSString *const ATLLocationLatitudeKey;
extern NSString *const ATLLocationLongitudeKey;

extern NSString *const ATLUserNotificationInlineReplyActionIdentifier;
extern NSString *const ATLUserNotificationDefaultActionsCategoryIdentifier;

//-------------------
// @name Push Support
//-------------------

UIMutableUserNotificationCategory *ATLDefaultUserNotificationCategory();

//---------------------------------
// @name Internationalization Macro
//---------------------------------

#define ATLLocalizedString(key, value, comment) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], value, comment)

//--------------------------
// @name Max Cell Dimensions
//--------------------------

CGFloat ATLMaxCellWidth();

CGFloat ATLMaxCellHeight();

//----------------------
// @name Image Utilities
//----------------------

CGSize ATLImageSizeForData(NSData *data);

CGSize ATLImageSizeForJSONData(NSData *data);

CGSize ATLImageSize(UIImage *image);

/**
 @abstract Constraints the CGSize to the default cell size (defined in ATLMaxCellWidth() and ATLMaxCellHeight()) and preserving the original aspec ratio.
 @param imageSize The size of the source image that should be shrunk or enlarged.
 @return Returns a CGSize constrained to the cell size with the same aspect ratio as the source CGSize.
 */
CGSize ATLConstrainImageSizeToCellSize(CGSize imageSize);

CGSize ATLTextPlainSize(NSString *string, UIFont *font);

CGRect ATLImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

CGFloat ATLDegreeToRadians(CGFloat degrees);

//-----------------------------
// @name Conversation Utilities
//-----------------------------

LYRIdentity *__nullable ATLIdentityFromSet(NSString *userID, NSSet *participants);

//------------------------
// @name Message Utilities
//------------------------

LYRMessage *__nullable ATLMessageForParts(LYRClient *layerClient, NSArray <LYRMessagePart*> *messageParts, NSString *pushText, NSString *pushSound);

//-----------------------------
// @name Message Part Utilities
//-----------------------------

NSArray <LYRMessagePart*> *ATLMessagePartsWithMediaAttachment(ATLMediaAttachment *mediaAttachment);

LYRMessagePart *__nullable ATLMessagePartForMIMEType(LYRMessage *message, NSString *MIMEType);

//------------------------------
// @name Image Capture Utilities
//------------------------------

void ATLAssetURLOfLastPhotoTaken(void(^completionHandler)(NSURL *__nullable assetURL, NSError *__nullable error));

void ATLLastPhotoTaken(void(^completionHandler)(UIImage *__nullable image, NSError *__nullable error));

UIImage *__null_unspecified ATLPinPhotoForSnapshot(MKMapSnapshot *snapshot, CLLocationCoordinate2D location);

NSArray <NSTextCheckingResult *> *__nullable ATLTextCheckingResultsForText(NSString *text, NSTextCheckingType linkTypes);

//---------------------------------
// @name Resources Bundle Utilities
//---------------------------------

NSBundle *ATLResourcesBundle(void);
NS_ASSUME_NONNULL_END
