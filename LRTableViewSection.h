//
//  LRTableSection.h
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRTableViewPart.h"

@class LRTableViewSection;

@protocol LRTableViewSectionDelegate <NSObject>

- (void)tableViewSection:(LRTableViewSection *)section insertRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation;
- (void)tableViewSection:(LRTableViewSection *)section deleteRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation;

@end

@interface LRTableViewSection : NSObject <LRTableViewPartDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic) BOOL hideHeaderWhenEmpty;
@property (nonatomic, weak) id<LRTableViewSectionDelegate> delegate;
@property (nonatomic) int tag;

+ (LRTableViewSection *)sectionWithParts:(LRTableViewPart *)part1, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)numberOfRows;
- (UITableViewCell *)cellForRow:(NSInteger)row;
- (CGFloat)heightForRow:(NSInteger)row;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addPart:(LRTableViewPart *)part;
- (void)removeAllParts;

@end
