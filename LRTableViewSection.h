//
//  LRTableSection.h
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LRTableViewPart;

@interface LRTableViewSection : NSObject

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *headerTitle;

+ (LRTableViewSection *)sectionWithParts:(LRTableViewPart *)part1, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)numberOfRows;
- (UITableViewCell *)cellForRow:(NSInteger)row;
- (CGFloat)heightForRow:(NSInteger)row;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addPart:(LRTableViewPart *)part;
@end
