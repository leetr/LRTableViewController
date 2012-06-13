//
//  LRTableViewController.m
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "LRTableViewSection.h"
#import "LRTableViewPart.h"

@interface LRTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)addSection:(LRTableViewSection *)section;

@end