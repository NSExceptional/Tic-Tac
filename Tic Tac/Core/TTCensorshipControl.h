//
//  TTCensorshipControl.h
//  Tic Tac
//
//  Created by CBORD Waco on 6/14/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TTCensorshipDelegate <NSObject>
@property (nonatomic) BOOL showsAll;
@end

@interface TTCensorshipControl : UISegmentedControl

+ (instancetype)withDelegate:(id<TTCensorshipDelegate>)delegate;

@end
