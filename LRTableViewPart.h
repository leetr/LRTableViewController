//
//  LRTableViewPart.h
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRTableViewCellDelegate.h"

#define LRCellHeightDynamic -1

@class LRTableViewPart;

//old way
typedef void (^OnCellSelectedBlock)(UITableView *tableView, NSIndexPath *realIndexPath, NSInteger partRow); 
typedef void (^OnViewSelectedBlock)(UIView *view, NSInteger partRow);

//new way
typedef void (^OnPartCellSelected)(LRTableViewPart *part, UITableView *tableView, NSIndexPath *indexPath, NSInteger partRow);
typedef void (^OnPartCellViewSelected)(LRTableViewPart *part, UIView *view, NSInteger partRow);

@protocol LRTableViewPartDelegate <NSObject>

- (void)tableViewPart:(LRTableViewPart *)part insertRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation;
- (void)tableViewPart:(LRTableViewPart *)part deleteRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation;

@end

@interface LRTableViewPart : NSObject <LRTableViewCellDelegate>

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic) UITableViewCellStyle cellStyle;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *bindings;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, strong) OnPartCellSelected onPartCellSelected;
@property (nonatomic, strong) OnPartCellViewSelected onPartCellViewSelected;
@property (nonatomic, assign) id<LRTableViewPartDelegate> delegate;
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;

//deprecated attributes
@property (nonatomic, strong) OnCellSelectedBlock onCellSelectedBlock; //TODO: deprecate this in the future
@property (nonatomic, strong) OnViewSelectedBlock onViewSelectedBlock; //TODO: deprecate this in the future

+ (LRTableViewPart *)partWithCellStyle:(UITableViewCellStyle)style;
+ (LRTableViewPart *)partWithCellIdentifier:(NSString *)identifier;

- (NSInteger)numberOfRows;
- (UITableViewCell *)cellForRow:(NSInteger)row;
- (CGFloat)heightForRow:(NSInteger)row;
- (void)didSelectRow:(NSInteger)row realIndexPath:(NSIndexPath *)indexPath;
- (void)observeObject:(id)object forKeyPath:(NSString *)keyPath;
- (void)stopObserving;

- (void)setOnPartCellSelected:(void(^)(LRTableViewPart *part, UITableView *tableView, NSIndexPath *indexPath, NSInteger partRow))onPartCellSelected;
- (void)setOnPartCellViewSelected:(void(^)(LRTableViewPart *part, UIView *view, NSInteger partRow))onPartCellViewSelected;

@end
