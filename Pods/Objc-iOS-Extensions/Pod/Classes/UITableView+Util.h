//
//  UITableView+Util.h
//  Luna
//
//  Created by Tanner on 3/8/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBTableUpdate;

@interface UITableView (Util)
- (void)performUpdate:(TBTableUpdate *)update;
- (void)performUpdate:(TBTableUpdate *)update deleteAnimation:(UITableViewRowAnimation)deleteAnimation insertAnimation:(UITableViewRowAnimation)insertAnimation;

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)insertSection:(NSUInteger)section;
- (void)reloadSection:(NSUInteger)section;

@end

@interface TBTableUpdate : NSObject

+ (instancetype)firstSectionInsert:(NSIndexSet *)insert delete:(NSIndexSet *)remove moveFrom:(NSIndexSet *)from moveTo:(NSIndexSet *)to reload:(NSIndexSet *)reload;
+ (instancetype)updateInsert:(NSArray *)insert delete:(NSArray *)remove moveFrom:(NSArray *)from moveTo:(NSArray *)to reload:(NSArray *)reload;
+ (instancetype)updateFromDataSource:(NSArray *)initial toDataSource:(NSArray *)final;

@property (nonatomic, readonly) NSArray *insert;
@property (nonatomic, readonly) NSArray *remove;
@property (nonatomic, readonly) NSArray *move;
@property (nonatomic, readonly) NSArray *reload;

@end