//
//  Hooks.m
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

#import <Foundation/Foundation.h>
@import FLEX;

//@interface Hooks : NSObject
//
//@end
//
//@implementation Hooks
//+ (void)load {
    // NSBundle.bundleIdentifier
//    FLEXMethod *bundleID = [NSBundle flex_methodNamed:@"bundleIdentifier"];
//    IMP orig = bundleID.implementation;
//    bundleID.implementation = imp_implementationWithBlock(^(NSBundle *bundle) {
//        NSString *identifier = ((NSString *(*)(id, SEL))orig)(bundle, @selector(bundleIdentifier));
//        if (bundle == NSBundle.mainBundle) {
//            return @"com.yikyak.2";
//        }
//
//        return identifier;
//    });
//
//    FLEXMethod *httpBody = [NSClassFromString(@"FIRVerifyClientRequest")
//        flex_methodNamed:@"unencodedHTTPRequestBodyWithError:"
//    ];
//
//    httpBody.implementation = imp_implementationWithBlock(^(id request) {
//        return @{ @"appToken": @"4F142D1D01594167D0B40DC2592E7990978A575A850B70DA63C81A2670F6B24B" };
//    });
//}
//@end

@interface _UISheetPresentationController : UIPresentationController
@property (setter=_setDetents:) NSArray *_detents;
@property (setter=_setWantsFullScreen:) BOOL _wantsFullScreen;
@property (setter=_setIndexOfCurrentDetent:) BOOL _indexOfCurrentDetent;
@property (setter=_setDimmingViewTapDismissing:) BOOL _isDimmingViewTapDismissing;
@property (setter=_setIndexOfLastUndimmedDetent:) BOOL _indexOfLastUndimmedDetent;
@property (setter=_setAllowsInteractiveDismissWhenFullScreen:) BOOL _allowsInteractiveDismissWhenFullScreen;
@property (setter=_setPresentsAtStandardHalfHeight:) BOOL _presentsAtStandardHalfHeight;
@property (setter=_setPrefersScrollingExpandsToLargerDetentWhenScrolledToEdge:)
           BOOL _prefersScrollingExpandsToLargerDetentWhenScrolledToEdge;
@end


#include <objc/message.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

__attribute__((unused)) static void _logos_register_hook(Class _class, SEL _cmd,
                                                         IMP _new, IMP *_old) {
  unsigned int _count, _i;
  Class _searchedClass = _class;
  Method *_methods;
  while (_searchedClass) {
    _methods = class_copyMethodList(_searchedClass, &_count);
    for (_i = 0; _i < _count; _i++) {
      if (method_getName(_methods[_i]) == _cmd) {
        if (_class == _searchedClass) {
          *_old = method_getImplementation(_methods[_i]);
          *_old = method_setImplementation(_methods[_i], _new);
        } else {
          class_addMethod(_class, _cmd, _new,
                          method_getTypeEncoding(_methods[_i]));
        }
        free(_methods);
        return;
      }
    }
    free(_methods);
    _searchedClass = class_getSuperclass(_searchedClass);
  }
}
@class _UISheetPresentationController;
@class UINavigationController;
static Class _logos_superclass$_ungrouped$_UISheetPresentationController;
static _UISheetPresentationController *_LOGOS_RETURN_RETAINED (
    *_logos_orig$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$)(
    _LOGOS_SELF_TYPE_INIT _UISheetPresentationController *, SEL, id, id);
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class
_logos_static_class_lookup$UINavigationController(void) {
  static Class _klass;
  if (!_klass) {
    _klass = objc_getClass("UINavigationController");
  }
  return _klass;
}
static _UISheetPresentationController *
_logos_method$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$(
    _LOGOS_SELF_TYPE_INIT _UISheetPresentationController *__unused self,
    SEL __unused _cmd, id present, id presenter) _LOGOS_RETURN_RETAINED {
  self =
      (_logos_orig$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$
           ? _logos_orig$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$
           : (__typeof__(_logos_orig$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$))
                 class_getMethodImplementation(
                     _logos_superclass$_ungrouped$_UISheetPresentationController,
                     @selector(initWithPresentedViewController:
                                      presentingViewController:)))(
          self, _cmd, present, presenter);
  if ([present isKindOfClass:_logos_static_class_lookup$UINavigationController()]) {
    self._presentsAtStandardHalfHeight = YES;
    self._indexOfCurrentDetent = 0;
    self._prefersScrollingExpandsToLargerDetentWhenScrolledToEdge = NO;
    self._indexOfLastUndimmedDetent = 1;
  }

  return self;
}

//static __attribute__((constructor)) void _logosLocalInit() {
//  {
//    Class _logos_class$_ungrouped$_UISheetPresentationController =
//        objc_getClass("_UISheetPresentationController");
//    _logos_superclass$_ungrouped$_UISheetPresentationController =
//        class_getSuperclass(
//            _logos_class$_ungrouped$_UISheetPresentationController);
//    {
//      _logos_register_hook(
//          _logos_class$_ungrouped$_UISheetPresentationController,
//          @selector(initWithPresentedViewController:presentingViewController:),
//          (IMP)&_logos_method$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$,
//          (IMP *)&_logos_orig$_ungrouped$_UISheetPresentationController$initWithPresentedViewController$presentingViewController$);
//    }
//  }
//}
