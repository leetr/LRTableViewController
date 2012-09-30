//
//  LRTableViewController.m
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "LRTableViewSection.h"
#import "LRTableViewPart.h"

@interface LRTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LRTableViewSectionDelegate>
{
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
}

@property (nonatomic, copy) NSString *refreshHeaderTextPull;
@property (nonatomic, copy) NSString *refreshHeaderTextRelease;
@property (nonatomic, copy) NSString *refreshHeaderTextLoading;
@property (nonatomic, copy) NSString *refreshHeaderImageName;
@property (nonatomic) BOOL isPullToRefresh;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)addSection:(LRTableViewSection *)section;
- (void)removeSection:(LRTableViewSection *)section;
- (void)removeSection:(LRTableViewSection *)section withAnimation:(UITableViewRowAnimation)animation;
- (void)removeAllSections;

- (void)startLoading;
- (void)stopLoading;
- (void)refresh;

//override these methods for custom pull view
- (UIView *)viewForRefreshHeaderView;
- (void)updateRefreshHeaderForPull;
- (void)updateRefreshHeaderForRelease;
- (void)updateRefreshHeaderForLoading;
- (void)resetRefreshHeader;

@end