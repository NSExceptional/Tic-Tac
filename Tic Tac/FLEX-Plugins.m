//
//  FLEX-Plugins.m
//  Tic Tac
//
//  Created by Tanner Bennett on 9/6/22.
//

#import <Foundation/Foundation.h>
#import <FLEX.h>
#import <Firebase/Firebase.h>
#import <YakKit/YakKit.h>
#import "Tic_Tac-Swift.h"

@interface FLEXFirebaseSetDataInfo : NSObject
+ (instancetype)data:(NSDictionary *)data merge:(NSNumber *)merge mergeFields:(NSArray *)mergeFields;
/// The data that was set
@property (nonatomic, readonly) NSDictionary *documentData;
/// \c nil if \c mergeFields is populated
@property (nonatomic, readonly) NSNumber *merge;
/// \c nil if \c merge is populated
@property (nonatomic, readonly) NSArray *mergeFields;
@end

void TTRegisterFirebaseConsole();
void TTRegisterChangeEmoji();

@ctor {
    TTRegisterFirebaseConsole();
    TTRegisterChangeEmoji();
}

void TTFIRGetData(NSString *documentPath, void (^callback)(FIRDocumentSnapshot *document, NSError *error)) {
    FIRFirestore *store = FIRFirestore.firestore;
    FIRDocumentReference *doc = [store documentWithPath:documentPath];
    [doc getDocumentWithCompletion:callback];
}

void TTRegisterFirebaseConsole() {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Firebase Console" action:^(UITableViewController *host) {
        [FLEXAlert makeAlert:^(FLEXAlert *make) {
            make.title(@"Firebase Console")
                .configuredTextField(^(UITextField *field) {
                    field.text = @"Users/";
                    field.placeholder = @"Document Path";
                });
            
            make.button(@"Get Data").handler(^(NSArray<NSString *> *strings) {
                NSString *path = strings.firstObject;
                TTFIRGetData(path, ^(FIRDocumentSnapshot *document, NSError *error) {
                    if (document) {
                        FLEXNavigationController *nav = (id)host.navigationController;
                        [nav pushExplorerForObject:document];
                    }
                    else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                });
            });
            make.button(@"Cancel").cancelStyle();
        } showFrom:host];
    }];
}

@implementation FIRDocumentReference (FLEX)
- (void)flex_setData:(FLEXFirebaseSetDataInfo *)info host:(UIViewController *)host {
    void (^completion)(NSError *) = ^(NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error: %@", error.localizedDescription);
            });
        }
    };
    
    if (info.mergeFields.count) {
        [self setData:info.documentData merge:info.merge.boolValue completion:completion];
    } else {
        [self setData:info.documentData mergeFields:info.mergeFields completion:completion];
    }
}
@end

@implementation FIRCollectionReference (FLEX)
- (void)flex_setUserData:(FLEXFirebaseSetDataInfo *)info user:(NSString *)userID host:(UIViewController *)host {
    NSParameterAssert(info && userID);
    
    FIRDocumentReference *document = [self documentWithPath:userID];
    [document flex_setData:info host:host];
}
@end

void SetUserEmoji(NSString *userID, NSString *emoji, NSString *color1, NSString *color2, UIViewController *host) {
    FLEXFirebaseSetDataInfo *info = [FLEXFirebaseSetDataInfo
        data:@{ @"emoji": emoji, @"color": color1, @"secondaryColor": color2 }
        merge:@1 mergeFields:nil
    ];
    
    FIRFirestore *store = FIRFirestore.firestore;
    FIRCollectionReference *users = [store collectionWithPath:@"Users"];
    [users flex_setUserData:info user:userID host:host];
    
    [YYClient.current updateUser:nil];
}

void TTRegisterChangeEmoji() {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Change User Emoji" action:^(UITableViewController *host) {
        [FLEXAlert makeAlert:^(FLEXAlert *make) {
            make.title(@"Change User Emoji")
                .configuredTextField(^(UITextField *field) {
                    field.text = @"INkrqtCR58gwwvmb9nzhd3Hrbso1";
                    field.placeholder = @"User ID";
                })
                .configuredTextField(^(UITextField *field) {
                    field.text = @"🍿";
                    field.placeholder = @"Emoji";
                })
                .configuredTextField(^(UITextField *field) {
                    field.text = @"#FF0AD6";
                    field.placeholder = @"#FF0AD6";
                })
                .configuredTextField(^(UITextField *field) {
                    field.text = @"";
                    field.placeholder = @"#FF0AD6";
                });
            make.button(@"Purple").handler(^(NSArray<NSString *> *strings) {
                SetUserEmoji(strings[0], strings[1], @"#5857FF", @"#5857FF", host);
            });
            make.button(@"Gold").handler(^(NSArray<NSString *> *strings) {
                SetUserEmoji(strings[0], strings[1], @"#FFD38C", @"#C38737", host);
            });
            make.button(@"Black").handler(^(NSArray<NSString *> *strings) {
                SetUserEmoji(strings[0], strings[1], @"#000000", @"#000000", host);
            });
            make.button(@"White").handler(^(NSArray<NSString *> *strings) {
                SetUserEmoji(strings[0], strings[1], @"#FFFFFF", @"#FFFFFF", host);
            });
            
            make.button(@"Specififed").handler(^(NSArray<NSString *> *strings) {
                NSString *secondColor = strings[3].length ? strings[3] : strings[2];
                SetUserEmoji(strings[0], strings[1], strings[2], secondColor, host);
            });
            make.button(@"Cancel").cancelStyle();
        } showFrom:host];
    }];
}
