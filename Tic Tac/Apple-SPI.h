//
//  Apple-SPI.h
//  Tic Tac
//
//  Created by Tanner Bennett on 10/14/22.
//

@import MapKit;

@interface MKMapView (Private)
@property (nonatomic, setter=_setShowsAppleLogo:) BOOL showsAppleLogo;
@end

NS_SWIFT_NAME(UIGrabber)
@interface _UIGrabber : UIView @end

static inline _UIGrabber * _Nonnull UIGrabberMake() {
    _UIGrabber *grabber = [NSClassFromString(@"_UIGrabber") new];
    [grabber sizeToFit];
    return grabber;
}

typedef CGFloat (^UISheetDetentResolver)(UIView * _Nonnull, CGRect, BOOL);

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UISheetDetentIdentifier) {
    UISheetDetentCustom = 0,
    UISheetDetentLarge,
    UISheetDetentMedium,
    UISheetDetentConstant,
};

NS_SWIFT_NAME(UISheetDetent)
@interface _UISheetDetent : NSObject

@property (nonatomic, readonly, class) _UISheetDetent *_mediumDetent NS_SWIFT_NAME(medium);
@property (nonatomic, readonly, class) _UISheetDetent *_largeDetent NS_SWIFT_NAME(large);

+ (instancetype)_constantDetent:(CGFloat)constant NS_SWIFT_NAME(constant(_:));
+ (instancetype)_detentWithContainerViewBlock:(UISheetDetentResolver)block NS_SWIFT_NAME(custom(_:));

@property (nonatomic, readonly) UISheetDetentIdentifier _identifier NS_SWIFT_NAME(identifier);
@property (nonatomic, readonly) UISheetDetentResolver _internalBlock NS_SWIFT_NAME(block);
@property (nonatomic, readonly) CGFloat _constant NS_SWIFT_NAME(constant);

- (CGFloat)_resolvedOffsetInContainerView:(UIView *)view
           fullHeightFrameOfPresentedView:(CGRect)presentedFrame
                           bottomAttached:(BOOL)bottomAttached
NS_SWIFT_NAME(resolvedOffsetIn(container:fullHeight:bottomAttached:));

@end


NS_ASSUME_NONNULL_END
